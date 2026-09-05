import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../../core/ai/document_ai_service.dart';
import '../../../core/database/local_database.dart';
import '../../../core/models/ai_extraction_result.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/portable_directory.dart';
import 'extraction_review_screen.dart';

class SmartCaptureScreen extends ConsumerStatefulWidget {
  const SmartCaptureScreen({required this.patient, super.key});
  final Patient patient;

  @override
  ConsumerState<SmartCaptureScreen> createState() => _SmartCaptureScreenState();
}

class _SmartCaptureScreenState extends ConsumerState<SmartCaptureScreen> {
  final _picker = ImagePicker();
  final _ward = TextEditingController();
  final _bed = TextEditingController();
  final _summary = TextEditingController();
  final _prompt = TextEditingController(
    text:
        'Extract patient identifier, location, document type, vitals, '
        'clinical summary, and full raw text from this clinical document.',
  );
  AiExtractionResult? _result;
  File? _image;
  bool _processing = false;
  bool _saving = false;

  @override
  void dispose() {
    _ward.dispose();
    _bed.dispose();
    _summary.dispose();
    _prompt.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    if (picked == null) return;
    final image = File(picked.path);
    setState(() {
      _image = image;
      _result = null;
      _processing = true;
    });
    try {
      final result = await DocumentAiService(
        apiKey: ref.read(appConfigurationProvider).geminiApiKey,
      ).extractDocument(
        image: image,
        prompt: _prompt.text.trim(),
      );
      await DocumentAiService().routeMedicationKnowledge(
        result: result,
        pharmacopeiaDao: ref.read(pharmacopeiaDaoProvider),
        ownerId: ref.read(currentOwnerIdProvider),
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _ward.text = result.location.wardName ?? '';
        _bed.text = result.location.bedNumber ?? '';
        _summary.text = result.clinicalSummary;
      });
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ExtractionReviewScreen(
            extraction: result,
            imagePath: image.path,
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _save() async {
    final result = _result;
    final image = _image;
    if (result == null || image == null) return;
    setState(() => _saving = true);
    try {
      final directory = await getPortableStorageDirectory();
      final imageDirectory = Directory(
        p.join(directory.path, 'clinical_images'),
      );
      await imageDirectory.create(recursive: true);
      final storedImage = await image.copy(
        p.join(imageDirectory.path, '${const Uuid().v4()}.jpg'),
      );
      final vitals = result.vitalsExtracted;
      await ref
          .read(clinicalDaoProvider)
          .insertClinicalEncounter(
            ClinicalEncountersCompanion.insert(
              ownerId: ref.read(currentOwnerIdProvider),
              patientId: widget.patient.id,
              encounterType: const Value('AI Document Capture'),
              sbp: Value(vitals.sbp),
              dbp: Value(vitals.dbp),
              pulse: Value(vitals.pr),
              chiefComplaint: Value(result.documentType),
              consultantAdvice: Value(_summary.text.trim()),
              dynamicData: Value(result.toJson()),
              department: Value(
                result.location.department ?? widget.patient.currentDepartment,
              ),
              wardName: Value(_ward.text.trim()),
              bedNumber: Value(_bed.text.trim()),
              imagePath: Value(storedImage.path),
              aiSummary: Value(_summary.text.trim()),
            ),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI Extraction Saved')),
        );
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save capture: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Smart document capture')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FilledButton.icon(
          onPressed: _processing ? null : _capture,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Open Camera'),
        ),
        if (_processing) ...[
          const SizedBox(height: 24),
          const Center(child: CircularProgressIndicator()),
          const Center(child: Text('AI is reading the document...')),
        ],
        if (_result case final result?) ...[
          const SizedBox(height: 24),
          Text(
            'Review extracted data',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text('Patient: ${result.patientIdentifier ?? 'Not identified'}'),
          Text('Document: ${result.documentType}'),
          const SizedBox(height: 12),
          TextFormField(
            controller: _ward,
            decoration: const InputDecoration(labelText: 'Ward'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _bed,
            decoration: const InputDecoration(labelText: 'Bed number'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _summary,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Clinical summary'),
          ),
          const SizedBox(height: 12),
          ExpansionTile(
            title: const Text('Full transcribed text'),
            children: [SelectableText(result.rawText)],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.save),
            label: Text(_saving ? 'Saving...' : 'Save capture'),
          ),
        ],
      ],
    ),
  );
}
