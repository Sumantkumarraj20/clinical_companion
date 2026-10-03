import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

import '../../../core/database/local_database.dart';
import '../../../core/models/ai_extraction_result.dart';
import '../../../core/models/document_task.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/datetime_utils.dart';

/// Sprint 9 — review half of the OCR/AI pipeline.
///
/// Watches `batchExtractionProvider` and renders one queue entry per
/// [PageView] leaf. Every stage is surfaced live:
///
/// * `processingOcr`        → "Extracting text locally…" progress
/// * `processingAiFallback` → "Normalizing with Cloud AI…" progress
/// * `error`                → explanation + one-tap retry of that task
/// * `readyForReview`       → fully editable [AiExtractionResult] form
///
/// "Save & Next" commits through `ClinicalDao.processAiExtraction`, drops the
/// task from the queue and lets the [PageView] land on the next document, so
/// the clinician reviews several pages without ever navigating "back".
class AdaptiveReviewScreen extends ConsumerStatefulWidget {
  const AdaptiveReviewScreen({this.patient, super.key});

  /// When launched from a patient timeline, every page is filed under this
  /// patient, skipping identity resolution entirely.
  final Patient? patient;

  @override
  ConsumerState<AdaptiveReviewScreen> createState() =>
      _AdaptiveReviewScreenState();
}

class _AdaptiveReviewScreenState extends ConsumerState<AdaptiveReviewScreen> {
  final _picker = ImagePicker();
  final _pageController = PageController();

  /// Editors are keyed by task id so half-finished edits survive swiping
  /// between pages and background status updates from the extraction queue.
  final Map<String, _TaskEditor> _editors = {};

  /// Per-task "attach to existing patient" choice (`null` = auto-resolve /
  /// create from the extracted demographics).
  final Map<String, String?> _linkedPatientId = {};

  late final Stream<List<Patient>> _patients;

  int _index = 0;
  bool _saving = false;
  int _savedCount = 0;

  @override
  void initState() {
    super.initState();
    _patients = ref.read(clinicalDaoProvider).watchAllPatients();
  }

  @override
  void dispose() {
    for (final editor in _editors.values) {
      editor.dispose();
    }
    _editors.clear();
    _pageController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // SAVE
  // ==========================================================================

  Future<void> _saveAndNext() async {
    if (_saving) return;

    final tasks = ref.read(batchExtractionProvider);
    if (_index < 0 || _index >= tasks.length) return;

    final task = tasks[_index];
    final extraction = task.extractedData;
    if (task.status != ExtractionStatus.readyForReview || extraction == null) {
      return;
    }
    final editor = _editors[task.id];
    if (editor == null) return;

    final linkedId = _linkedPatientId[task.id] ?? widget.patient?.id;
    if (linkedId == null && editor.name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Add the patient name — or link an existing patient — before saving.',
          ),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref
          .read(clinicalDaoProvider)
          .processAiExtraction(
            editor.toResult(extraction),
            task.originalFile.path,
            patientIdOverride: linkedId,
          );

      if (!mounted) return;
      _savedCount++;
      // Drop the reviewed page: the queue shrinks by one and the PageView
      // naturally lands on the next document.
      ref.read(batchExtractionProvider.notifier).removeTask(task.id);
      _editors.remove(task.id)?.dispose();
      _linkedPatientId.remove(task.id);
      _clampIndex();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _savedCount == 1
                ? 'Saved to the patient record.'
                : 'Saved — $_savedCount documents filed.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save this document: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Keeps [_index] pointing at a real page after the queue shrinks, and
  /// nudges the controller when the removal happened on the last page.
  void _clampIndex() {
    final length = ref.read(batchExtractionProvider).length;
    if (length == 0) return;
    if (_index >= length) _index = length - 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) return;
      try {
        final visible = _pageController.page?.round() ?? _index;
        if (visible != _index) _pageController.jumpToPage(_index);
      } catch (_) {
        // Position can transiently be out of range while the PageView
        // re-measures; the next frame settles it.
      }
    });
  }

  // ==========================================================================
  // QUEUE HELPERS
  // ==========================================================================

  _TaskEditor _editorFor(DocumentTask task) {
    final cached = _editors[task.id];
    if (cached != null) return cached;
    final created = _TaskEditor(
      task.extractedData ?? const AiExtractionResult(),
      rawTranscript: task.rawOcrText,
    );
    _editors[task.id] = created;
    return created;
  }

  Future<void> _addToQueue(ImageSource source) async {
    try {
      final List<File> files;
      if (source == ImageSource.gallery) {
        final picked = await _picker.pickMultiImage(imageQuality: 90);
        files = [for (final item in picked) File(item.path)];
      } else {
        final picked = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 90,
        );
        files = picked == null ? const [] : [File(picked.path)];
      }
      if (files.isEmpty || !mounted) return;

      ref.read(batchExtractionProvider.notifier).addFiles(files);
      _index = ref.read(batchExtractionProvider).length - 1;
      _clampIndex();
      setState(() {});
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not add a page: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Scan another page'),
              onTap: () {
                Navigator.pop(sheetContext);
                _addToQueue(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Add images from gallery'),
              onTap: () {
                Navigator.pop(sheetContext);
                _addToQueue(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(offlineNoticeProvider, (previous, message) {
      if (message == null || !mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      ref.read(offlineNoticeProvider.notifier).clear();
    });
    final tasks = ref.watch(batchExtractionProvider);

    if (tasks.isEmpty) return _finishedOrEmpty();

    if (_index >= tasks.length) _index = tasks.length - 1;
    if (_index < 0) _index = 0;

    final current = tasks[_index];
    final canSave =
        !_saving && current.status == ExtractionStatus.readyForReview;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tasks.length == 1
              ? 'Review document'
              : 'Review ${tasks.length} pages',
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                '${_index + 1} / ${tasks.length}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Add another page',
            icon: const Icon(Icons.add_a_photo_outlined),
            onPressed: _saving ? null : _showAddSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _statusStrip(tasks),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: _saving ? const NeverScrollableScrollPhysics() : null,
                itemCount: tasks.length,
                onPageChanged: (next) {
                  if (next == _index) return;
                  setState(() => _index = next);
                },
                itemBuilder: (context, position) => _buildPage(tasks[position]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: canSave ? _saveAndNext : null,
        icon: _saving
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_outlined),
        label: Text(
          _saving
              ? 'Saving…'
              : (_index == tasks.length - 1 ? 'Save document' : 'Save & Next'),
        ),
      ),
    );
  }

  /// Batch overview: how many pages are ready, still working, or need a retry.
  Widget _statusStrip(List<DocumentTask> tasks) {
    final ready = tasks
        .where((t) => t.status == ExtractionStatus.readyForReview)
        .length;
    final failed = tasks
        .where((t) => t.status == ExtractionStatus.error)
        .length;
    final working = tasks.length - ready - failed;

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            _pill(Icons.check_circle_outline, '$ready ready', Colors.green),
            const SizedBox(width: 12),
            if (working > 0)
              _pill(Icons.hourglass_top, '$working processing', Colors.blue),
            if (working > 0) const SizedBox(width: 12),
            if (failed > 0)
              _pill(Icons.error_outline, '$failed failed', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _pill(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 13)),
      ],
    );
  }

  /// Queue drained: either we filed something, or the user arrived with an
  /// empty queue.
  Widget _finishedOrEmpty() {
    final didSave = _savedCount > 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Review documents')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                didSave ? Icons.check_circle_outline : Icons.document_scanner,
                size: 88,
                color: didSave ? Colors.green : Colors.teal,
              ),
              const SizedBox(height: 20),
              Text(
                didSave
                    ? 'All $_savedCount document(s) filed'
                    : 'No documents queued',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                didSave
                    ? 'Encounters, vitals, labs and prescriptions are now on '
                          'the patient timeline.'
                    : 'Capture a lab report, chart or prescription to begin.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () => context.go('/smart-capture'),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Scan a document'),
              ),
              if (context.canPop()) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Done'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // PAGE BUILDERS (STEP 3 — status & error handling)
  // ==========================================================================

  Widget _buildPage(DocumentTask task) {
    switch (task.status) {
      case ExtractionStatus.readyForReview:
      case ExtractionStatus.completed:
        return _editorPane(task);
      case ExtractionStatus.error:
        return _errorPane(task);
      case ExtractionStatus.pending:
      case ExtractionStatus.processingOcr:
      case ExtractionStatus.processingAiFallback:
      case ExtractionStatus.processingAi:
        return _progressPane(task);
    }
  }

  /// Live feedback while the pipeline works. The wording matches the actual
  /// stage so the clinician knows whether the phone or the cloud is busy.
  Widget _progressPane(DocumentTask task) {
    final (headline, detail) = switch (task.status) {
      ExtractionStatus.pending => (
        'Queued for extraction',
        'This page will be read on-device next.',
      ),
      ExtractionStatus.processingOcr => (
        'Extracting text locally…',
        'Running on-device OCR and matching labs, vitals and medications. '
            'Free, offline — nothing leaves this phone.',
      ),
      ExtractionStatus.processingAiFallback ||
      ExtractionStatus.processingAi => (
        'Normalizing with Cloud AI…',
        'The local read was messy, so Gemini is cleaning and structuring '
            'this page now.',
      ),
      _ => ('Working…', ''),
    };

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _thumb(task.originalFile, height: 160),
            const SizedBox(height: 28),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              headline,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorPane(DocumentTask task) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _thumb(task.originalFile, height: 140),
            const SizedBox(height: 20),
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              'Could not extract this page',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              task.errorMessage ??
                  'Extraction failed for an unknown reason. Retrying usually '
                      'helps.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving
                  ? null
                  : () => ref
                        .read(batchExtractionProvider.notifier)
                        .retryTask(task.id),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry extraction'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _saving
                  ? null
                  : () => ref
                        .read(batchExtractionProvider.notifier)
                        .removeTask(task.id),
              child: const Text('Remove from queue'),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // EDITOR (STEP 2 — editable AiExtractionResult)
  // ==========================================================================

  Widget _editorPane(DocumentTask task) {
    final editor = _editorFor(task);

    final form = ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      children: [
        _provenanceBanner(task),
        ..._identitySection(task, editor),
        ..._vitalsSection(editor),
        ..._labsSection(editor),
        ..._medicationsSection(editor),
        _summarySection(editor),
        _transcriptSection(task),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 860;
        // Kept as a plain widget so it can be dropped into either a Row
        // (wrapped in Expanded) or a fixed-height Column without nesting an
        // Expanded inside another Expanded/SizedBox.
        final imagePane = InkWell(
          onTap: () => _openFullImage(task.originalFile),
          child: Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            child: _thumb(task.originalFile, fit: BoxFit.contain),
          ),
        );

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: imagePane),
              const VerticalDivider(width: 1),
              Expanded(child: form),
            ],
          );
        }
        return Column(
          children: [
            SizedBox(height: 190, child: imagePane),
            const Divider(height: 1),
            Expanded(child: form),
          ],
        );
      },
    );
  }

  Widget _thumb(File file, {double height = 140, BoxFit fit = BoxFit.cover}) {
    if (!file.existsSync()) return _thumbPlaceholder(height);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        file,
        height: height,
        width: double.infinity,
        fit: fit,
        errorBuilder: (_, __, ___) => _thumbPlaceholder(height),
      ),
    );
  }

  Widget _thumbPlaceholder(double height) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.description_outlined,
        size: 40,
        color: Colors.grey,
      ),
    );
  }

  void _openFullImage(File file) {
    if (!file.existsSync()) return;
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.8,
          child: PhotoView(
            imageProvider: FileImage(file),
            minScale: PhotoViewComputedScale.contained,
            backgroundDecoration: const BoxDecoration(
              color: Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  /// "Locally Extracted (Free)" vs "AI Extracted" provenance, kept from the
  /// earlier screens so reviewers can tell what produced the numbers.
  Widget _provenanceBanner(DocumentTask task) {
    final (label, icon, bg, fg, border) = switch (task.source) {
      ExtractionSource.local => (
        'Locally Extracted (Free) — on-device OCR matched this page.',
        Icons.offline_bolt_outlined,
        Colors.green.shade50,
        Colors.green.shade900,
        Colors.green.shade700,
      ),
      ExtractionSource.ai => (
        'AI Extracted — Gemini cleaned up an unreadable local scan.',
        Icons.auto_awesome_outlined,
        Colors.purple.shade50,
        Colors.purple.shade900,
        Colors.purple.shade700,
      ),
      ExtractionSource.unknown => (
        'Extraction source unknown — verify fields before saving.',
        Icons.help_outline,
        Colors.grey.shade200,
        Colors.grey.shade800,
        Colors.grey.shade500,
      ),
    };

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, semanticLabel: 'Extraction source badge'),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: fg, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // FORM SECTIONS
  // ==========================================================================

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(top: 6, bottom: 8),
    child: Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
    ),
  );

  InputDecoration _decoration(
    String label, {
    bool missing = false,
    String? hintText,
    String? suffixText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      suffixText: suffixText,
      helperText: missing ? 'Not detected on document' : null,
      prefixIcon: missing
          ? const Icon(
              Icons.warning_amber_rounded,
              size: 18,
              color: Colors.amber,
            )
          : null,
      filled: missing,
      fillColor: missing ? Colors.amber.withValues(alpha: 0.06) : null,
      enabledBorder: missing
          ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.amber),
            )
          : OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      isDense: true,
    );
  }

  List<Widget> _identitySection(DocumentTask task, _TaskEditor editor) {
    final needsIdentity =
        widget.patient == null &&
        _linkedPatientId[task.id] == null &&
        editor.name.text.trim().isEmpty;

    return [
      _sectionTitle('Patient'),
      if (widget.patient != null)
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.person_pin_circle_outlined, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Filed under ${widget.patient!.fullName}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        )
      else ...[
        StreamBuilder<List<Patient>>(
          stream: _patients,
          builder: (context, snapshot) {
            final patients = snapshot.data ?? const <Patient>[];
            final current = _linkedPatientId[task.id];
            final initial = patients.any((p) => p.id == current)
                ? current
                : null;
            return DropdownButtonFormField<String?>(
              initialValue: initial,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Link to an existing patient (optional)',
                prefixIcon: const Icon(Icons.link_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text(
                    'Auto — create / match from the details below',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...patients.map(
                  (p) => DropdownMenuItem<String?>(
                    value: p.id,
                    child: Text(
                      '${p.fullName} · ${p.gender ?? '?'} · '
                      '${DateTimeUtils.ageOn(p.dateOfBirth, DateTime.now()) ?? '--'}y',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: (value) => setState(() {
                _linkedPatientId[task.id] = value;
              }),
            );
          },
        ),
        const SizedBox(height: 12),
      ],
      TextField(
        controller: editor.name,
        decoration: _decoration('Patient full name', missing: needsIdentity),
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: editor.age,
              keyboardType: TextInputType.number,
              decoration: _decoration(
                'Age (years)',
                missing: editor.age.text.isEmpty,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: editor.gender,
              decoration: _decoration(
                'Gender (M/F/O)',
                missing: editor.gender.text.isEmpty,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      TextField(
        controller: editor.registration,
        decoration: _decoration(
          'Hospital Reg / OPD No.',
          missing: editor.registration.text.isEmpty,
        ),
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: editor.documentType,
        decoration: _decoration('Document type'),
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 18),
    ];
  }

  List<Widget> _vitalsSection(_TaskEditor editor) {
    return [
      _sectionTitle('Vitals'),
      Row(
        children: [
          Expanded(child: _numberField('Systolic', editor.sbp, suffix: 'mmHg')),
          const SizedBox(width: 8),
          Expanded(
            child: _numberField('Diastolic', editor.dbp, suffix: 'mmHg'),
          ),
          const SizedBox(width: 8),
          Expanded(child: _numberField('Pulse', editor.pulse, suffix: 'bpm')),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(child: _numberField('SpO2', editor.spo2, suffix: '%')),
          const SizedBox(width: 8),
          Expanded(
            child: _numberField(
              'Temp',
              editor.temp,
              suffix: '°C',
              decimal: true,
            ),
          ),
        ],
      ),
      const SizedBox(height: 18),
    ];
  }

  Widget _numberField(
    String label,
    TextEditingController controller, {
    String? suffix,
    bool decimal = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  List<Widget> _labsSection(_TaskEditor editor) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Lab results (${editor.labs.length})',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          TextButton.icon(
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add test'),
            onPressed: () =>
                setState(() => editor.labs.add(_EditableLab.empty())),
          ),
        ],
      ),
      if (editor.labs.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'No laboratory values on this page.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        )
      else
        for (var i = 0; i < editor.labs.length; i++) _labEditor(editor, i),
      const SizedBox(height: 18),
    ];
  }

  Widget _labEditor(_TaskEditor editor, int index) {
    final lab = editor.labs[index];
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: lab.testName,
                decoration: const InputDecoration(
                  labelText: 'Test',
                  isDense: true,
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: lab.value,
                decoration: const InputDecoration(
                  labelText: 'Value',
                  isDense: true,
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: lab.unit,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  isDense: true,
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                lab.isAbnormal ? Icons.flag : Icons.outlined_flag,
                color: lab.isAbnormal ? Colors.red : Colors.grey,
                size: 20,
              ),
              tooltip: lab.isAbnormal ? 'Flagged abnormal' : 'Mark abnormal',
              onPressed: () => setState(() => lab.isAbnormal = !lab.isAbnormal),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.grey),
              tooltip: 'Delete test',
              onPressed: () => setState(() => editor.labs.removeAt(index)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _medicationsSection(_TaskEditor editor) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Medications (${editor.meds.length})',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          TextButton.icon(
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add drug'),
            onPressed: () =>
                setState(() => editor.meds.add(_EditableMedication.empty())),
          ),
        ],
      ),
      if (editor.meds.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'No medications ordered on this page.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        )
      else
        for (var i = 0; i < editor.meds.length; i++)
          _medicationEditor(editor, i),
      const SizedBox(height: 18),
    ];
  }

  Widget _medicationEditor(_TaskEditor editor, int index) {
    final med = editor.meds[index];
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: TextField(
                controller: med.drugName,
                decoration: const InputDecoration(
                  labelText: 'Drug name',
                  isDense: true,
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: med.dosage,
                decoration: const InputDecoration(
                  labelText: 'Dose',
                  hintText: '500mg',
                  isDense: true,
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: med.frequency,
                decoration: const InputDecoration(
                  labelText: 'Freq',
                  hintText: 'TID',
                  isDense: true,
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.grey),
              tooltip: 'Delete drug',
              onPressed: () => setState(() => editor.meds.removeAt(index)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summarySection(_TaskEditor editor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle('Clinical summary'),
        TextField(
          controller: editor.summary,
          minLines: 2,
          maxLines: 5,
          decoration: _decoration(
            'What this document says',
            missing: editor.summary.text.trim().isEmpty,
            hintText: 'Short clinician-facing description…',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _transcriptSection(DocumentTask task) {
    final transcript = (task.rawOcrText ?? '').trim();
    if (transcript.isEmpty) return const SizedBox.shrink();
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        'Raw OCR transcript',
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            transcript,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

/// Per-page editing state. Kept outside the widget tree so a clinician can
/// swipe away, fix a vitals row on another page, and come back without losing
/// anything.
class _TaskEditor {
  _TaskEditor(AiExtractionResult seed, {String? rawTranscript}) {
    final identity = seed.patientIdentity;
    name = TextEditingController(text: identity.name ?? '');
    age = TextEditingController(text: identity.age?.toString() ?? '');
    gender = TextEditingController(text: identity.gender ?? '');
    registration = TextEditingController(text: identity.hospitalRegNo ?? '');
    documentType = TextEditingController(
      text: seed.encounterContext.documentType.trim().isEmpty
          ? 'Clinical Document'
          : seed.encounterContext.documentType.trim(),
    );

    final vitals = seed.vitals;
    sbp = TextEditingController(text: vitals.sbp?.toString() ?? '');
    dbp = TextEditingController(text: vitals.dbp?.toString() ?? '');
    pulse = TextEditingController(text: vitals.pr?.toString() ?? '');
    spo2 = TextEditingController(text: vitals.spo2?.toString() ?? '');
    temp = TextEditingController(text: vitals.temperatureC?.toString() ?? '');

    summary = TextEditingController(text: seed.clinicalSummary);
    labs = [for (final lab in seed.labResults) _EditableLab.from(lab)];
    meds = [
      for (final medication in seed.medicationsOrdered)
        _EditableMedication.from(medication),
    ];
    transcript = rawTranscript ?? '';
  }

  late final TextEditingController name;
  late final TextEditingController age;
  late final TextEditingController gender;
  late final TextEditingController registration;
  late final TextEditingController documentType;
  late final TextEditingController sbp;
  late final TextEditingController dbp;
  late final TextEditingController pulse;
  late final TextEditingController spo2;
  late final TextEditingController temp;
  late final TextEditingController summary;
  late final List<_EditableLab> labs;
  late final List<_EditableMedication> meds;
  late final String transcript;

  static String? emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void dispose() {
    name.dispose();
    age.dispose();
    gender.dispose();
    registration.dispose();
    documentType.dispose();
    sbp.dispose();
    dbp.dispose();
    pulse.dispose();
    spo2.dispose();
    temp.dispose();
    summary.dispose();
    for (final lab in labs) {
      lab.dispose();
    }
    for (final medication in meds) {
      medication.dispose();
    }
  }

  /// Reads the validated controller values back into an [AiExtractionResult]
  /// ready for `ClinicalDao.processAiExtraction`.
  AiExtractionResult toResult(AiExtractionResult base) {
    return base.copyWith(
      patientIdentity: base.patientIdentity.copyWith(
        name: emptyToNull(name.text),
        age: int.tryParse(age.text.trim()),
        gender: emptyToNull(gender.text),
        hospitalRegNo: emptyToNull(registration.text),
      ),
      encounterContext: base.encounterContext.copyWith(
        documentType: documentType.text.trim().isEmpty
            ? 'Clinical Document'
            : documentType.text.trim(),
      ),
      vitals: base.vitals.copyWith(
        sbp: int.tryParse(sbp.text.trim()),
        dbp: int.tryParse(dbp.text.trim()),
        pr: int.tryParse(pulse.text.trim()),
        spo2: int.tryParse(spo2.text.trim()),
        temperatureC: double.tryParse(temp.text.trim()),
      ),
      labResults: [
        for (final lab in labs)
          if (lab.testName.text.trim().isNotEmpty)
            AiLabResult(
              testName: lab.testName.text.trim(),
              value: lab.value.text.trim(),
              unit: emptyToNull(lab.unit.text),
              isAbnormal: lab.isAbnormal,
            ),
      ],
      medicationsOrdered: [
        for (final medication in meds)
          if (medication.drugName.text.trim().isNotEmpty)
            OrderedMedication(
              drugName: medication.drugName.text.trim(),
              dosage: emptyToNull(medication.dosage.text),
              frequency: emptyToNull(medication.frequency.text),
            ),
      ],
      clinicalSummary: summary.text.trim(),
    );
  }
}

class _EditableLab {
  _EditableLab({
    required this.testName,
    required this.value,
    required this.unit,
    required this.isAbnormal,
  });

  factory _EditableLab.from(AiLabResult lab) => _EditableLab(
    testName: TextEditingController(text: lab.testName),
    value: TextEditingController(text: lab.value),
    unit: TextEditingController(text: lab.unit ?? ''),
    isAbnormal: lab.isAbnormal,
  );

  factory _EditableLab.empty() => _EditableLab(
    testName: TextEditingController(),
    value: TextEditingController(),
    unit: TextEditingController(),
    isAbnormal: false,
  );

  final TextEditingController testName;
  final TextEditingController value;
  final TextEditingController unit;
  bool isAbnormal;

  void dispose() {
    testName.dispose();
    value.dispose();
    unit.dispose();
  }
}

class _EditableMedication {
  _EditableMedication({
    required this.drugName,
    required this.dosage,
    required this.frequency,
  });

  factory _EditableMedication.from(OrderedMedication medication) =>
      _EditableMedication(
        drugName: TextEditingController(text: medication.drugName),
        dosage: TextEditingController(text: medication.dosage ?? ''),
        frequency: TextEditingController(text: medication.frequency ?? ''),
      );

  factory _EditableMedication.empty() => _EditableMedication(
    drugName: TextEditingController(),
    dosage: TextEditingController(),
    frequency: TextEditingController(),
  );

  final TextEditingController drugName;
  final TextEditingController dosage;
  final TextEditingController frequency;

  void dispose() {
    drugName.dispose();
    dosage.dispose();
    frequency.dispose();
  }
}
