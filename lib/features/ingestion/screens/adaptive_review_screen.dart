import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:uuid/uuid.dart';

import '../../../core/ai/clinical_prompts.dart';
import '../../../core/ai/document_ai_service.dart';
import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/clinical_reconciliation_service.dart';
import '../../../core/services/extraction_pipeline_service.dart';

class AdaptiveReviewScreen extends ConsumerStatefulWidget {
  const AdaptiveReviewScreen({required this.patient, super.key});
  final Patient patient;

  @override
  ConsumerState<AdaptiveReviewScreen> createState() => _AdaptiveReviewScreenState();
}

class _AdaptiveReviewScreenState extends ConsumerState<AdaptiveReviewScreen> {
  final _picker = ImagePicker();
  final _rawText = TextEditingController();
  final _observations = TextEditingController();
  final _sampleType = TextEditingController();
  final _organism = TextEditingController();
  final _findings = TextEditingController();
  final _impression = TextEditingController();
  Map<String, dynamic> _extractedData = const {};
  ClinicalDocumentCategory _category = ClinicalDocumentCategory.progressNote;
  File? _image;
  bool _busy = false;
  bool _committing = false;
  PipelineSource? _pipelineSource;

  @override
  void dispose() {
    for (final controller in [_rawText, _observations, _sampleType, _organism, _findings, _impression]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _selectImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 92);
    if (picked == null) return;
    setState(() => _image = File(picked.path));
    await _extract();
  }

  Future<void> _extract() async {
    final image = _image;
    if (image == null) return;
    setState(() {
      _busy = true;
      _pipelineSource = null;
    });
    try {
      // Hybrid probe: free on-device OCR+regex first (no Gemini call here).
      // Tells the reviewer whether the local path would have handled this
      // document, then the category model below runs as usual for structured
      // observations.
      final pipeline = ref.read(extractionPipelineProvider);
      try {
        final localOnly = await pipeline.tryLocalOnly(image);
        _pipelineSource =
            localOnly != null ? PipelineSource.local : PipelineSource.ai;
      } catch (_) {
        _pipelineSource = PipelineSource.ai;
      }

      final data = await DocumentAiService(
        apiKey: ref.read(appConfigurationProvider).geminiApiKey,
      ).extractClinicalDocument(image: image, category: _category);
      _pipelineSource ??= PipelineSource.ai;
      _extractedData = data;
      _rawText.text = data['raw_ocr_transcript']?.toString() ?? '';
      _observations.text = const JsonEncoder.withIndent('  ').convert(data['observations'] ?? data);
      _sampleType.text = data['sample_type']?.toString() ?? '';
      _organism.text = data['organism_identified']?.toString() ?? '';
      _findings.text = data['findings']?.toString() ?? data['examination']?.toString() ?? '';
      _impression.text = data['impression']?.toString() ?? data['final_plan']?.toString() ?? '';
      if (mounted) setState(() {});
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _commit() async {
    final image = _image;
    if (image == null || _rawText.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add an image and confirm the transcription first.')));
      return;
    }
    setState(() => _committing = true);
    try {
      final documentId = const Uuid().v4();
      final database = ref.read(appDatabaseProvider);
      await database.into(database.documentRegistries).insert(
        DocumentRegistriesCompanion.insert(
          id: documentId,
          patientId: widget.patient.id,
          documentCategory: _category.wireName,
          imagePath: image.path,
          rawOcrTranscript: Value(_rawText.text.trim()),
          confidenceScore: const Value(1.0),
          documentedAt: DateTime.now().toUtc(),
        ),
      );
      final decoded = jsonDecode(_observations.text);
      final values = decoded is List ? decoded : const <dynamic>[];
      final inputs = <ClinicalObservationInput>[];
      for (final item in values.whereType<Map>()) {
        final numeric = item['numeric_value'];
        inputs.add(ClinicalObservationInput(
          category: item['category']?.toString() ?? _category.wireName,
          code: item['code']?.toString() ?? 'UNSPECIFIED',
          displayName: item['display_name']?.toString() ?? 'Clinical observation',
          numericValue: numeric is num ? numeric.toDouble() : double.tryParse('$numeric'),
          textValue: item['text_value']?.toString(),
          unit: item['unit']?.toString(),
          recordedAt: DateTime.tryParse(item['recorded_at']?.toString() ?? '') ?? DateTime.now().toUtc(),
          isAbnormal: item['is_abnormal'] == true,
        ));
      }
      await ClinicalReconciliationService(database).reconcile(
        patientId: widget.patient.id,
        documentId: documentId,
        observations: inputs,
      );
      if (_category == ClinicalDocumentCategory.microbiologyCulture) {
        await database.into(database.microbiologyCultures).insert(
          MicrobiologyCulturesCompanion.insert(
            id: const Uuid().v4(), patientId: widget.patient.id, documentId: documentId,
            sampleType: _sampleType.text.trim(), organismIdentified: Value(_organism.text.trim().isEmpty ? null : _organism.text.trim()),
            colonyCount: Value(_extractedData['colony_count']?.toString()),
            antibiogramJson: Value(ClinicalReconciliationService.antibiogramJson(
              ((_extractedData['sensitivities'] as List?) ?? const []).whereType<Map>().map(
                (item) => {'antibiotic': item['antibiotic']?.toString(), 'interpretation': item['interpretation']?.toString(), 'mic': item['mic']?.toString()},
              ),
            )),
            reportedAt: DateTime.now().toUtc(),
          ),
        );
      }
      if (_category == ClinicalDocumentCategory.radiologyReport) {
        await database.into(database.imagingStudies).insert(
          ImagingStudiesCompanion.insert(
            id: const Uuid().v4(), patientId: widget.patient.id, documentId: documentId,
            modality: _extractedData['modality']?.toString() ?? 'Unknown',
            anatomicalRegion: _extractedData['anatomical_region']?.toString() ?? 'Unspecified',
            findings: _findings.text.trim(), impression: _impression.text.trim(),
            performedAt: DateTime.now().toUtc(),
          ),
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Committed to the clinical ledger')));
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not commit document: $error')));
    } finally {
      if (mounted) setState(() => _committing = false);
    }
  }

  InputDecoration _field(String label, {bool required = false}) => InputDecoration(
    labelText: label,
    prefixIcon: required && _rawText.text.trim().isEmpty ? const Icon(Icons.warning_amber_rounded) : null,
    enabledBorder: required && _rawText.text.trim().isEmpty
        ? const OutlineInputBorder(borderSide: BorderSide(color: Colors.amber))
        : null,
  );

  Widget _provenanceBanner() {
    final source = _pipelineSource;
    if (_extractedData.isEmpty || source == null) {
      return const SizedBox.shrink();
    }
    final isLocal = source == PipelineSource.local;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isLocal
            ? Colors.green.shade50
            : Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLocal ? Colors.green.shade700 : Colors.purple.shade700,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isLocal ? Icons.offline_bolt_outlined : Icons.auto_awesome_outlined,
            color: isLocal ? Colors.green.shade800 : Colors.purple.shade800,
            semanticLabel: isLocal
                ? 'Locally extracted badge'
                : 'AI extracted badge',
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isLocal
                  ? 'Locally Extracted (Free) — on-device OCR matched labs/demographics, no AI call needed.'
                  : 'AI Extracted — escalated to Gemini after local OCR was insufficient.',
              style: TextStyle(
                color: isLocal ? Colors.green.shade900 : Colors.purple.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagePane = _image == null
        ? Center(child: Text('Capture or choose a paper document', style: Theme.of(context).textTheme.titleMedium))
        : PhotoView(imageProvider: FileImage(_image!), minScale: PhotoViewComputedScale.contained);
    final form = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Structured review', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        _provenanceBanner(),
        if (_category == ClinicalDocumentCategory.microbiologyCulture) ...[
          TextField(controller: _sampleType, decoration: _field('Sample type', required: true)),
          const SizedBox(height: 12),
          TextField(controller: _organism, decoration: _field('Organism identified')),
          const SizedBox(height: 12),
        ],
        if (_category == ClinicalDocumentCategory.radiologyReport) ...[
          TextField(controller: _findings, minLines: 3, maxLines: 7, decoration: _field('Findings', required: true)),
          const SizedBox(height: 12),
          TextField(controller: _impression, minLines: 2, maxLines: 5, decoration: _field('Impression', required: true)),
          const SizedBox(height: 12),
        ],
        TextField(controller: _observations, minLines: 4, maxLines: 12, decoration: const InputDecoration(labelText: 'Extracted observations (JSON)')),
        const SizedBox(height: 12),
        TextField(controller: _rawText, minLines: 6, maxLines: 14, onChanged: (_) => setState(() {}), decoration: _field('Full OCR transcription', required: true)),
        const SizedBox(height: 20),
        FilledButton.icon(onPressed: _committing ? null : _commit, icon: const Icon(Icons.fact_check_outlined), label: Text(_committing ? 'Committing...' : 'Confirm & Commit to Clinical Ledger')),
      ],
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Adaptive document review')),
      body: SafeArea(child: Column(children: [
        SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: SegmentedButton<ClinicalDocumentCategory>(segments: [for (final category in [ClinicalDocumentCategory.progressNote, ClinicalDocumentCategory.treatmentChart, ClinicalDocumentCategory.vitalsIoChart, ClinicalDocumentCategory.labReport, ClinicalDocumentCategory.microbiologyCulture, ClinicalDocumentCategory.radiologyReport]) ButtonSegment(value: category, label: Text(category.label))], selected: {_category}, onSelectionChanged: (value) { setState(() => _category = value.first); })),
        Expanded(child: LayoutBuilder(builder: (context, constraints) { final wide = constraints.maxWidth >= 800; return wide ? Row(children: [Expanded(child: imagePane), const VerticalDivider(width: 1), Expanded(child: form)]) : Column(children: [Expanded(flex: 4, child: imagePane), const Divider(height: 1), Expanded(flex: 6, child: form)]); })),
      ])),
      bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [Expanded(child: OutlinedButton.icon(onPressed: _busy ? null : () => _selectImage(ImageSource.camera), icon: const Icon(Icons.camera_alt_outlined), label: const Text('Camera'))), const SizedBox(width: 12), Expanded(child: OutlinedButton.icon(onPressed: _busy ? null : () => _selectImage(ImageSource.gallery), icon: const Icon(Icons.photo_library_outlined), label: Text(_busy ? 'Reading...' : 'Phone gallery')))]))),
    );
  }
}