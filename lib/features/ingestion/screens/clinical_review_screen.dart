import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ingestion/live_ingestion_controller.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/pdf_render_adapter.dart';

/// Opens the verification screen for a captured image, PDF or text.
Future<bool?> openClinicalReview(
  NavigatorState navigator, {
  File? file,
  String? text,
  String payloadType = 'text',
  Map<String, dynamic>? initialData,
}) {
  return navigator.push<bool>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => ClinicalReviewScreen(
        sourceFile: file,
        sourceText: text,
        payloadType: payloadType,
        initialData: initialData,
      ),
    ),
  );
}

class _FieldDef {
  const _FieldDef(this.key, this.label, {this.multiline = false, this.list});
  final String key;
  final String label;
  final bool multiline;

  /// When true the value is stored as one entry per line.
  final bool? list;
}

const _scalarFields = <_FieldDef>[
  _FieldDef('patient_name', 'Patient name'),
  _FieldDef('age', 'Age'),
  _FieldDef('gender', 'Gender'),
  _FieldDef('ward_name', 'Ward'),
  _FieldDef('bed_number', 'Bed'),
  _FieldDef('document_type', 'Document type'),
  _FieldDef('document_date', 'Document date (YYYY-MM-DD)'),
  _FieldDef('document_time', 'Document time (HH:MM)'),
  _FieldDef(
    'chief_complaints',
    'Chief complaints',
    multiline: true,
    list: true,
  ),
  _FieldDef('history', 'History', multiline: true),
  _FieldDef('diagnosis', 'Diagnosis', multiline: true, list: true),
];

const _vitalFields = <_FieldDef>[
  _FieldDef('sbp', 'Systolic BP'),
  _FieldDef('dbp', 'Diastolic BP'),
  _FieldDef('pulse', 'Pulse'),
  _FieldDef('temperature_c', 'Temperature (°C)'),
  _FieldDef('respiratory_rate', 'Respiratory rate'),
  _FieldDef('spo2', 'SpO₂'),
];

const _medKeys = ['name', 'dose', 'route', 'frequency', 'duration'];
const _labKeys = ['test_name', 'value', 'unit', 'reference_range'];

class _Row {
  _Row(Map<String, String> values, {this.abnormal = false})
    : controllers = {
        for (final entry in values.entries)
          entry.key: TextEditingController(text: entry.value),
      };
  final Map<String, TextEditingController> controllers;
  bool abnormal;

  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
  }
}

/// Dual-pane verification: source on top, editable extracted data below.
class ClinicalReviewScreen extends ConsumerStatefulWidget {
  const ClinicalReviewScreen({
    super.key,
    this.sourceFile,
    this.sourceText,
    this.payloadType = 'text',
    this.initialData,
  });

  final File? sourceFile;
  final String? sourceText;
  final String payloadType;

  /// Pre-parsed data; when null the screen extracts it itself.
  final Map<String, dynamic>? initialData;

  @override
  ConsumerState<ClinicalReviewScreen> createState() =>
      _ClinicalReviewScreenState();
}

class _ClinicalReviewScreenState extends ConsumerState<ClinicalReviewScreen> {
  final _controllers = <String, TextEditingController>{};
  final _shown = <String>{};
  final _meds = <_Row>[];
  final _labs = <_Row>[];
  String? _ocrText;
  bool _loading = true;
  bool _deepScanning = false;
  bool _saving = false;
  bool _showSource = true;
  String? _notice;

  bool get _isPdf =>
      widget.sourceFile?.path.toLowerCase().endsWith('.pdf') ?? false;
  bool get _isImage => widget.sourceFile != null && !_isPdf;

  @override
  void initState() {
    super.initState();
    for (final f in [..._scalarFields, ..._vitalFields]) {
      _controllers[f.key] = TextEditingController();
    }
    _ocrText = widget.sourceText;
    if (widget.initialData != null) {
      _apply(widget.initialData!);
      _loading = false;
    } else {
      _extract();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final r in [..._meds, ..._labs]) {
      r.dispose();
    }
    super.dispose();
  }

  Future<String?> _census() =>
      buildActiveCensusJson(ref.read(clinicalDaoProvider));

  Future<void> _extract() async {
    try {
      final orchestrator = ref.read(ingestionOrchestratorProvider);
      var text = widget.sourceText;
      if (text == null && widget.sourceFile != null) {
        text = await ref
            .read(extractionPipelineProvider)
            .recognizeRawText(widget.sourceFile!);
        _ocrText = text;
      }
      if (text == null || text.trim().isEmpty) {
        throw const FormatException('No readable text.');
      }
      final data = await orchestrator.extractText(
        text,
        activeCensusJson: await _census(),
      );
      if (!mounted) return;
      setState(() {
        _apply(data);
        _loading = false;
      });
    } catch (error) {
      debugPrint('[Review] extraction failed: $error');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _notice = _isImage
            ? 'The text on this image was hard to read. Try "Run Deep Scan", '
                  'or enter the details manually.'
            : 'We could not organize this automatically. You can enter the '
                  'details manually.';
      });
    }
  }

  Future<void> _deepScan() async {
    final file = widget.sourceFile;
    if (file == null || _deepScanning) return;
    setState(() => _deepScanning = true);
    try {
      final data = await ref
          .read(ingestionOrchestratorProvider)
          .deepScanImage(file, activeCensusJson: await _census());
      if (!mounted) return;
      setState(() {
        _clear();
        _apply(data);
        _notice = null;
      });
    } catch (error) {
      debugPrint('[Review] deep scan failed: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deep Scan could not read this image. Please retry.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _deepScanning = false);
    }
  }

  void _clear() {
    for (final c in _controllers.values) {
      c.clear();
    }
    for (final r in [..._meds, ..._labs]) {
      r.dispose();
    }
    _meds.clear();
    _labs.clear();
    _shown.clear();
  }

  static String _text(Object? v) {
    if (v == null) return '';
    final s = v.toString().trim();
    return s.toLowerCase() == 'null' ? '' : s;
  }

  void _apply(Map<String, dynamic> data) {
    for (final f in _scalarFields) {
      final v = data[f.key];
      final text = v is List
          ? v.map(_text).where((e) => e.isNotEmpty).join('\n')
          : _text(v);
      _controllers[f.key]!.text = text;
      if (text.isNotEmpty) _shown.add(f.key);
    }
    final vitals = data['vitals'];
    if (vitals is Map) {
      for (final f in _vitalFields) {
        final text = _text(vitals[f.key]);
        _controllers[f.key]!.text = text;
        if (text.isNotEmpty) _shown.add(f.key);
      }
    }
    final meds = data['medications'];
    if (meds is List) {
      for (final m in meds.whereType<Map>()) {
        _meds.add(_Row({for (final k in _medKeys) k: _text(m[k])}));
      }
    }
    final labs = data['lab_results'];
    if (labs is List) {
      for (final l in labs.whereType<Map>()) {
        _labs.add(
          _Row({
            for (final k in _labKeys) k: _text(l[k]),
          }, abnormal: l['is_abnormal'] == true),
        );
      }
    }
  }

  Map<String, dynamic> _collect() {
    String? val(String k) {
      final t = _controllers[k]!.text.trim();
      return t.isEmpty ? null : t;
    }

    List<String> lines(String k) => (val(k) ?? '')
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    num? number(String k) => num.tryParse(val(k) ?? '');

    return {
      'patient_name': val('patient_name'),
      'age': number('age')?.round(),
      'gender': val('gender'),
      'ward_name': val('ward_name'),
      'bed_number': val('bed_number'),
      'document_type': val('document_type'),
      'document_date': val('document_date'),
      'document_time': val('document_time'),
      'chief_complaints': lines('chief_complaints'),
      'history': val('history'),
      'diagnosis': lines('diagnosis'),
      'vitals': {
        'sbp': number('sbp')?.round(),
        'dbp': number('dbp')?.round(),
        'pulse': number('pulse')?.round(),
        'temperature_c': number('temperature_c'),
        'respiratory_rate': number('respiratory_rate')?.round(),
        'spo2': number('spo2')?.round(),
      },
      'medications': [
        for (final r in _meds)
          if (r.controllers['name']!.text.trim().isNotEmpty)
            {
              for (final k in _medKeys)
                k: r.controllers[k]!.text.trim().isEmpty
                    ? null
                    : r.controllers[k]!.text.trim(),
            },
      ],
      'lab_results': [
        for (final r in _labs)
          if (r.controllers['test_name']!.text.trim().isNotEmpty)
            {
              for (final k in _labKeys) k: r.controllers[k]!.text.trim(),
              'is_abnormal': r.abnormal,
            },
      ],
    };
  }

  Future<void> _save() async {
    if (_saving) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _saving = true);
    try {
      final data = _collect();
      await ref
          .read(ingestionOrchestratorProvider)
          .commitReviewed(
            data,
            sourceText: _ocrText,
            activeCensusJson: await _census(),
          );
      messenger.showSnackBar(
        const SnackBar(content: Text(kIngestionSuccessMessage)),
      );
      navigator.pop(true);
    } catch (error) {
      debugPrint('[Review] save failed: $error');
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not save this right now. Please try again.'),
        ),
      );
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addField() async {
    final hidden = [
      for (final f in [..._scalarFields, ..._vitalFields])
        if (!_shown.contains(f.key)) f,
    ];
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.medication_outlined),
              title: const Text('Medication'),
              onTap: () => Navigator.pop(ctx, '__med'),
            ),
            ListTile(
              leading: const Icon(Icons.science_outlined),
              title: const Text('Lab result'),
              onTap: () => Navigator.pop(ctx, '__lab'),
            ),
            for (final f in hidden)
              ListTile(
                title: Text(f.label),
                onTap: () => Navigator.pop(ctx, f.key),
              ),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;
    setState(() {
      if (choice == '__med') {
        _meds.add(_Row({for (final k in _medKeys) k: ''}));
      } else if (choice == '__lab') {
        _labs.add(_Row({for (final k in _labKeys) k: ''}));
      } else {
        _shown.add(choice);
      }
    });
  }

  Widget _sourcePane() {
    final file = widget.sourceFile;
    if (file != null && _isImage) {
      return ColoredBox(
        color: Colors.black,
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 6,
          child: Center(child: Image.file(file, fit: BoxFit.contain)),
        ),
      );
    }
    if (file != null) return PdfRenderAdapter.buildViewer(file.path);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: SelectableText(widget.sourceText ?? ''),
    );
  }

  Widget _field(_FieldDef f) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: _controllers[f.key],
      minLines: 1,
      maxLines: f.multiline ? 6 : 1,
      decoration: InputDecoration(
        labelText: f.label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    ),
  );

  Widget _rowCard(
    _Row row,
    List<String> keys,
    Map<String, String> labels,
    VoidCallback onDelete, {
    bool showAbnormal = false,
  }) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          for (final k in keys)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                controller: row.controllers[k],
                decoration: InputDecoration(
                  labelText: labels[k],
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
          Row(
            children: [
              if (showAbnormal)
                Expanded(
                  child: CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Abnormal'),
                    value: row.abnormal,
                    onChanged: (v) => setState(() => row.abnormal = v ?? false),
                  ),
                )
              else
                const Spacer(),
              IconButton(
                tooltip: 'Remove',
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _form() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_notice != null)
          Card(
            color: theme.colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_notice!),
            ),
          ),
        for (final f in _scalarFields)
          if (_shown.contains(f.key)) _field(f),
        if (_vitalFields.any((f) => _shown.contains(f.key))) ...[
          Text('Vitals', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final f in _vitalFields)
            if (_shown.contains(f.key)) _field(f),
        ],
        if (_meds.isNotEmpty) ...[
          Text('Medications', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final r in List.of(_meds))
            _rowCard(
              r,
              _medKeys,
              const {
                'name': 'Drug',
                'dose': 'Dose',
                'route': 'Route',
                'frequency': 'Frequency',
                'duration': 'Duration',
              },
              () => setState(() {
                _meds.remove(r);
                r.dispose();
              }),
            ),
        ],
        if (_labs.isNotEmpty) ...[
          Text('Lab results', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final r in List.of(_labs))
            _rowCard(
              r,
              _labKeys,
              const {
                'test_name': 'Test',
                'value': 'Value',
                'unit': 'Unit',
                'reference_range': 'Reference range',
              },
              () => setState(() {
                _labs.remove(r);
                r.dispose();
              }),
              showAbnormal: true,
            ),
        ],
        OutlinedButton.icon(
          onPressed: _addField,
          icon: const Icon(Icons.add),
          label: const Text('Add Clinical Field'),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          label: const Text('Confirm & Save'),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Record'),
        actions: [
          if (_isImage)
            TextButton.icon(
              onPressed: _deepScanning || _loading ? null : _deepScan,
              icon: const Icon(Icons.search),
              label: const Text('🔍 Run Deep Scan'),
            ),
          IconButton(
            tooltip: _showSource ? 'Hide original' : 'Show original',
            icon: Icon(_showSource ? Icons.vertical_split : Icons.image),
            onPressed: () => setState(() => _showSource = !_showSource),
          ),
        ],
        bottom: _deepScanning
            ? const PreferredSize(
                preferredSize: Size.fromHeight(28),
                child: Column(
                  children: [
                    LinearProgressIndicator(),
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: Text('Running Deep Scan...'),
                    ),
                  ],
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          if (_showSource) Expanded(flex: 2, child: _sourcePane()),
          if (_showSource) const Divider(height: 1),
          Expanded(flex: 3, child: _form()),
        ],
      ),
    );
  }
}
