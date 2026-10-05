import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/utils/document_image_hasher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/database/daos/clinical_dao.dart';
import '../../../core/database/local_database.dart';
import '../../../core/models/ai_extraction_result.dart';
import '../../../core/models/clinical_drug_selection.dart';
import '../../../core/models/document_task.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/datetime_utils.dart';
import '../../../core/widgets/smart_drug_autocomplete.dart';
import '../../patients/screens/hospital_picker_field.dart';
import '../widgets/full_screen_image_viewer.dart';

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
  const AdaptiveReviewScreen({this.patient, this.editDocument, super.key});

  /// When launched from a patient timeline, every page is filed under this
  /// patient, skipping identity resolution entirely.
  final Patient? patient;

  /// Sprint 14.5 — Edit Mode. When set, the screen opens pre-seeded with this
  /// already-saved document instead of the pending scan queue, so a clinician
  /// can correct a mistyped timestamp, conclusion or field at any time.
  ///
  /// Returns the saved document id, or null if the clinician backed out.
  final DocumentRegistry? editDocument;

  /// Opens a saved document for correction.
  static Future<String?> editExisting(
    BuildContext context, {
    required DocumentRegistry document,
    required Patient patient,
  }) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        fullscreenDialog: true,
        builder: (_) => ProviderScope(
          // The screen reads its work list from `batchExtractionProvider`.
          // Overriding it with this single seeded task is what turns the
          // screen into Edit Mode without duplicating the review UI.
          overrides: [
            batchExtractionProvider.overrideWith(
              () => BatchExtractionNotifier(),
            ),
          ],
          child: AdaptiveReviewScreen(patient: patient, editDocument: document),
        ),
      ),
    );
  }

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
  List<PatientProblem> _knownActiveProblems = const [];

  int _index = 0;
  bool _saving = false;
  int _savedCount = 0;

  @override
  void initState() {
    super.initState();
    _patients = ref.read(clinicalDaoProvider).watchAllPatients();
    final patient = widget.patient;
    if (patient != null) {
      unawaited(
        ref.read(clinicalDaoProvider).getPatientProblems(patient.id).then((
          problems,
        ) {
          if (!mounted) return;
          setState(() {
            _knownActiveProblems = problems
                .where((problem) => problem.currentStatus == 'Active')
                .toList(growable: false);
          });
        }),
      );
    }
    if (widget.editDocument != null) {
      // Edit Mode: put the saved document into the work queue as a single
      // ready-for-review page so the existing review UI drives it unchanged.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => unawaited(_seedEditTask()),
      );
    }
  }

  /// Sprint 14.5 — rebuilds an editable task from an already-saved document.
  ///
  /// The stored OCR transcript is re-parsed locally where possible so the
  /// clinician sees the values that were originally extracted, rather than an
  /// empty form. `documentedAt` is preserved: correcting a document must not
  /// silently re-date it to today.
  Future<void> _seedEditTask() async {
    final document = widget.editDocument;
    if (document == null) return;

    final transcript = document.rawOcrTranscript.trim();

    // Sprint 17.5 — restore the FULL extraction when one was stored, so Edit
    // Mode rehydrates complaints, diagnoses, ordered investigations, vitals,
    // labs and meds instead of showing an almost-empty shell a year later.
    // Pre-17.5 rows have no JSON and degrade to the previous summary-only form.
    AiExtractionResult? stored;
    final json = document.clincomJson?.trim() ?? '';
    if (json.isNotEmpty) {
      try {
        stored = AiExtractionResult.fromJson(
          jsonDecode(json) as Map<String, dynamic>,
        );
      } catch (error) {
        debugPrint(
          '[ClinCom] Stored extraction unreadable, falling back: $error',
        );
      }
    }

    final extraction =
        stored ??
        AiExtractionResult(
          // The stored category is the closest thing to a document type we
          // keep, and re-seeding the date keeps Edit Mode from re-dating the
          // record.
          encounterContext: EncounterContext(
            documentType: document.documentCategory,
            date: document.documentedAt.toIso8601String(),
          ),
          clinicalSummary: transcript,
        );

    // The stored date always wins: correcting a document must never re-date
    // it, and the JSON must not be able to drift the encounter either.
    var rehydrated = extraction.copyWith(
      encounterContext: extraction.encounterContext.copyWith(
        documentType: extraction.encounterContext.documentType.trim().isEmpty
            ? document.documentCategory
            : extraction.encounterContext.documentType,
        date: document.documentedAt.toIso8601String(),
      ),
      clinicalSummary: extraction.clinicalSummary.trim().isEmpty
          ? transcript
          : extraction.clinicalSummary,
    );
    try {
      rehydrated = await ref
          .read(clinicalDaoProvider)
          .hydratePomrForDocument(document: document, extraction: rehydrated);
    } catch (error) {
      debugPrint('[ClinCom] Could not hydrate POMR links from SQLite: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not load problem links: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    if (!mounted) return;

    ref
        .read(batchExtractionProvider.notifier)
        .replaceWithSeed(
          DocumentTask(
            id: document.id,
            originalFile: File(document.imagePath),
            status: ExtractionStatus.readyForReview,
            source: ExtractionSource.local,
            rawOcrText: transcript.isEmpty ? null : transcript,
            extractedData: rehydrated,
          ),
          // The document's own date wins over "now" — the whole point of Edit
          // Mode is that saving does not re-date the record.
          documentedAt: document.documentedAt.toLocal(),
        );
    if (mounted) setState(() {});
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

    final linkedId =
        _linkedPatientId[task.id] ??
        widget.patient?.id ??
        extraction.inferredPatientId;
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
      final dao = ref.read(clinicalDaoProvider);
      final reviewed = editor.toResult(extraction);

      // Sprint 14.5 — Edit Mode updates the stored document in place.
      // `processAiExtraction` is deliberately idempotent and would return the
      // existing encounter without applying any of these corrections, which
      // would report success while discarding the clinician's work.
      final editingDocument = widget.editDocument;
      if (editingDocument != null) {
        final applied = await dao.applyDocumentEdits(
          documentId: editingDocument.id,
          documentedAt: editor.documentedAt.toUtc(),
          extraction: reviewed,
          rawOcrTranscript: editor.conclusion.text.trim().isEmpty
              ? editingDocument.rawOcrTranscript
              : editor.conclusion.text.trim(),
          // Sprint 17.5 — persist the corrections, or reopening the document
          // would resurrect the stale semantic fields.
          clincomJson: jsonEncode(reviewed.toJson()),
          verifiedProblemAssociations: editor.verifiedProblemAssociations,
        );
        if (!mounted) return;
        if (!applied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('That document is no longer available to edit.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        _savedCount++;
        // Edit Mode has exactly one page; close the screen so the timeline
        // refreshes behind it.
        Navigator.of(context).pop(editingDocument.id);
        return;
      }

      await dao.saveUniversalClinicalPayload(
        result: reviewed,
        imagePath: task.originalFile?.path ?? '',
        rawSourceText: task.rawOcrText,
        isTextInput: task.isTextInput,
        patientIdOverride: linkedId,
        // Sprint 17.5 — persist the reviewed form so Edit Mode can rebuild it.
        clincomJson: jsonEncode(reviewed.toJson()),
        verifiedProblemAssociations: editor.verifiedProblemAssociations,
      );

      // Sprint 17 — stamp the dedup key AFTER the save, and never await it.
      //
      // Saving the reviewed document is the clinical priority and must not be
      // gated on hashing bytes. Hashing runs on a background isolate; if the
      // clinician backgrounds the app first, the worst case is that this one
      // page is not content-deduplicated next time — never a lost record.
      final originalFile = task.originalFile;
      if (!task.isTextInput && originalFile != null) {
        unawaited(_stampImageHash(dao, originalFile));
      }

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
      // Sprint 14.5 — in Edit Mode this carries the saved document's real
      // timestamp, so the date/time pickers show when the report was actually
      // performed instead of when it was opened.
      documentedAt: ref
          .read(batchExtractionProvider.notifier)
          .takeSeedDocumentedAt(),
    );
    _editors[task.id] = created;
    return created;
  }

  /// Hashes a saved page's image and records it as its content dedup key.
  ///
  /// Fire-and-forget by design; failures are logged, never surfaced, because a
  /// missing dedup key is far less harmful than a failed save.
  Future<void> _stampImageHash(ClinicalDao dao, File file) async {
    final hash = await hashDocumentImageOrNull(file.path);
    if (hash == null) return;
    final document = await dao.findDocumentByImagePath(file.path);
    if (document == null) return;
    await dao.attachImageHash(document.id, hash);
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

      // ---- Sprint 17: absolute deduplication -----------------------------
      // Hash every picked file. A file whose exact bytes are already on file
      // never enters the queue: no OCR, no API call, no duplicate record. The
      // clinician is routed straight into Edit Mode for the existing record.
      final notifier = ref.read(batchExtractionProvider.notifier);
      final dao = ref.read(clinicalDaoProvider);
      final fresh = <File>[];
      for (final file in files) {
        final duplicate = await notifier.findDuplicate(file);
        if (!mounted) return;
        if (duplicate != null) {
          final patient = await dao.findPatient(duplicate.patientId);
          if (!mounted) return;
          if (patient != null) {
            await AdaptiveReviewScreen.editExisting(
              context,
              document: duplicate,
              patient: patient,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'This exact page was already saved. It was not captured again.',
                ),
              ),
            );
          }
          continue;
        }
        fresh.add(file);
      }

      if (fresh.isEmpty) {
        if (mounted) setState(() {});
        return;
      }
      // Sprint 17 — snapshot the live inpatient census onto the queued pages so
      // ClinCom can resolve a bed number to a patient at extraction time.
      final census = await BatchExtractionNotifier.buildActiveCensusJson(dao);
      if (!mounted) return;
      notifier.addFiles(fresh, activeCensusJson: census);
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
              ? (current.isTextInput ? 'Review pasted text' : 'Review document')
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
              : (_index == tasks.length - 1
                    ? (current.isTextInput ? 'Save note' : 'Save document')
                    : 'Save & Next'),
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
        'Running on-device OCR and matching labs, vitals and medications.',
      ),
      ExtractionStatus.processingAiFallback ||
      ExtractionStatus.processingAi => (
        'Normalizing with Cloud AI…',
        task.isTextInput
            ? 'Sending pasted text directly to ClinCom. OCR is not used.'
            : 'ClinCom is cleaning and structuring this page now.',
      ),
      _ => ('Working…', ''),
    };

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (task.originalFile case final image?)
              _thumb(image, height: 160)
            else
              _textSourcePreview(task, height: 160),
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
            if (task.originalFile case final image?)
              _thumb(image, height: 140)
            else
              _textSourcePreview(task, height: 140),
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

    // ---- Sprint 17.5 — the fluid form -----------------------------------
    // Every block below is OPTIONAL and renders only when ClinCom actually
    // found data for it, so a bare prescription never shows an empty Vitals
    // table or a blank Diagnoses card the clinician has to dismiss.
    final blocks = <Widget?>[
      _provenanceBanner(task),
      ..._identitySection(task, editor),

      // Time-based grouping: the clinician's anchor for everything below is
      // WHEN this document was written, not when it was scanned.
      _documentDateHeader(editor),

      ..._complaintsSection(editor),
      ..._problemOrientedSection(editor),
      ..._vitalsSection(editor),
      _summarySection(editor),
      _transcriptSection(task),
    ];

    final form = ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      children: [
        for (final block in blocks)
          if (block != null) block,
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 860;
        // Kept as a plain widget so it can be dropped into either a Row
        // (wrapped in Expanded) or a fixed-height Column without nesting an
        // Expanded inside another Expanded/SizedBox.
        final image = task.originalFile;
        final sourcePane = image == null
            ? _textSourcePreview(task)
            : InkWell(
                onTap: () => _openFullImage(image),
                child: Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(8),
                  child: _thumb(image, fit: BoxFit.contain),
                ),
              );

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: sourcePane),
              const VerticalDivider(width: 1),
              Expanded(child: form),
            ],
          );
        }
        return Column(
          children: [
            SizedBox(height: 190, child: sourcePane),
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

  Widget _textSourcePreview(DocumentTask task, {double? height}) {
    final text = task.rawOcrText ?? '';
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: ExpansionTile(
          leading: const Icon(Icons.text_snippet_outlined),
          title: const Text('Original Raw Text'),
          subtitle: Text(
            text.trim().isEmpty
                ? 'No text available'
                : '${text.length} characters',
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SelectableText(
                text,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
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

  /// Opens the scan full-screen for close reading.
  ///
  /// Sprint 14.5 — was a `Dialog` capped at 80% of screen height, which cropped
  /// wide pathology margins and forced repeated pinch-to-fit gestures. A real
  /// full-screen route gives the image the whole display plus double-tap zoom and
  /// a reset control, so fine print (grades, margins, measurements) is readable.
  void _openFullImage(File file, {String? title}) {
    if (!file.existsSync()) return;
    FullScreenImageViewer.open(
      context,
      imagePath: file.path,
      title: title ?? 'Scanned Document',
    );
  }

  /// "Locally Extracted (Free)" vs "ClinCom Extracted" provenance, kept from the
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
        'ClinCom extracted this — it read an otherwise unreadable local scan.',
        Icons.auto_awesome_outlined,
        Colors.purple.shade50,
        Colors.purple.shade900,
        Colors.purple.shade700,
      ),
      ExtractionSource.text => (
        'ClinCom processed pasted text directly. No image or OCR was used.',
        Icons.content_paste_go_outlined,
        Colors.blue.shade50,
        Colors.blue.shade900,
        Colors.blue.shade700,
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
            final current =
                _linkedPatientId[task.id] ??
                task.extractedData?.inferredPatientId;
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
      // Sprint 15 — the facility this document was captured at.
      //
      // A clinician covering several institutions can scan a report at hospital
      // B for a patient whose record lives at hospital A. Without this the
      // encounter would be filed against whichever facility was listed first.
      HospitalPickerField(
        selectedId: editor.hospitalId,
        onChanged: (value) => setState(() => editor.hospitalId = value),
      ),
      const SizedBox(height: 12),
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

  /// Sprint 17.5 — formats a clinical timestamp for display.
  ///
  /// Local rather than via `intl` so this stays inside the existing dependency
  /// set. UTC is converted to local first, so the clinician always sees their
  /// own wall-clock time.
  static String _formatStamp(DateTime value) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final local = value.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final suffix = local.hour < 12 ? 'AM' : 'PM';
    return '${local.day} ${months[local.month - 1]} ${local.year}, '
        '$hour:$minute $suffix';
  }

  /// Sprint 17.5 — the time anchor for every clinical block below it.
  ///
  /// A clinician reading a flowsheet needs to know WHICH moment these values
  /// belong to. It shows the document's own written date (never the scan time),
  /// so a back-dated report correctly stays in the past.
  Widget _documentDateHeader(_TaskEditor editor) {
    final stamp = _formatStamp(editor.documentedAt);
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 10),
      child: Row(
        children: [
          Icon(
            Icons.event_available,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Findings recorded on $stamp',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Renders [values] as editable chips with an add control.
  ///
  /// Shared by complaints, diagnoses and investigations so all three behave
  /// identically: tap to edit in place, X to delete, and the whole section
  /// collapses once the last chip is removed.
  List<Widget> _chipSection({
    required String title,
    required String hint,
    required List<String> Function() read,
    required void Function(List<String>) write,
    required IconData icon,
  }) {
    final values = read();
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '$title (${values.length})',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          TextButton.icon(
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add'),
            onPressed: () => setState(() => write([...values, ''])),
          ),
        ],
      ),
      if (values.isEmpty)
        Text(
          'ClinCom found no $hint on this page.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
        )
      else
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < values.length; i++)
              _EditableChip(
                key: ValueKey('$title-$i'),
                initialValue: values[i],
                onChanged: (text) => setState(() {
                  final next = [...read()];
                  next[i] = text;
                  write(next);
                }),
                onRemove: () => setState(() {
                  final next = [...read()]..removeAt(i);
                  write(next);
                }),
              ),
          ],
        ),
      const SizedBox(height: 14),
    ];
  }

  List<Widget> _complaintsSection(_TaskEditor editor) {
    // Only render when the page actually carried complaints.
    if (editor.complaints.isEmpty) return const [];
    return _chipSection(
      title: 'Chief complaints',
      hint: 'chief complaints',
      icon: Icons.healing_outlined,
      read: () => editor.complaints,
      write: (next) => editor.complaints = next,
    );
  }

  List<Widget> _problemOrientedSection(_TaskEditor editor) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Problems & linked management',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          TextButton.icon(
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add problem'),
            onPressed: () =>
                setState(() => editor.problems.add(_EditableProblem.empty())),
          ),
        ],
      ),
      for (var i = 0; i < editor.problems.length; i++) _problemCard(editor, i),
      _unlinkedManagementCard(editor),
      const SizedBox(height: 18),
    ];
  }

  Widget _problemCard(_TaskEditor editor, int index) {
    final problem = editor.problems[index];
    final diagnosis = problem.name.text.trim();
    final meds = [
      for (var i = 0; i < editor.meds.length; i++)
        if (editor.problemNameFor(editor.meds[i].problemName) == diagnosis) i,
    ];
    final labs = [
      for (var i = 0; i < editor.labs.length; i++)
        if (editor.problemNameFor(editor.labs[i].problemName) == diagnosis) i,
    ];
    final procedures = [
      for (var i = 0; i < editor.procedures.length; i++)
        if (editor.problemNameFor(editor.procedures[i].problemName) ==
            diagnosis)
          i,
    ];
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.local_hospital_outlined, color: colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: problem.name,
                    onChanged: (value) => setState(() {
                      problem.linkAliases.add(
                        problem.lastName.trim().toLowerCase(),
                      );
                      problem.lastName = value.trim();
                    }),
                    decoration: const InputDecoration(
                      labelText: 'Problem / diagnosis',
                      isDense: true,
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Remove problem and detach its management',
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() {
                    final removedName = problem.name.text.trim();
                    for (final item in editor.meds) {
                      if (editor.problemNameFor(item.problemName) ==
                          removedName) {
                        item.problemName = null;
                        item.linkVerified = true;
                      }
                    }
                    for (final item in editor.labs) {
                      if (editor.problemNameFor(item.problemName) ==
                          removedName) {
                        item.problemName = null;
                        item.linkVerified = true;
                      }
                    }
                    for (final item in editor.procedures) {
                      if (editor.problemNameFor(item.problemName) ==
                          removedName) {
                        item.problemName = null;
                        item.linkVerified = true;
                      }
                    }
                    problem.dispose();
                    editor.problems.removeAt(index);
                  }),
                ),
              ],
            ),
            TextField(
              controller: problem.reasoning,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Clinical rationale',
                isDense: true,
                border: InputBorder.none,
              ),
            ),
            const Divider(height: 20),
            _managementGroupTitle(
              'Medications',
              meds.length,
              onAdd: () => setState(
                () => editor.meds.add(
                  _EditableMedication.empty(problemName: diagnosis),
                ),
              ),
            ),
            if (meds.isEmpty)
              _emptyManagementLabel('No medications linked to this problem.')
            else
              for (final itemIndex in meds)
                _medicationEditor(editor, itemIndex),
            _managementGroupTitle(
              'Investigations / labs',
              labs.length,
              onAdd: () => setState(
                () =>
                    editor.labs.add(_EditableLab.empty(problemName: diagnosis)),
              ),
            ),
            if (labs.isEmpty)
              _emptyManagementLabel('No investigations linked to this problem.')
            else
              for (final itemIndex in labs) _labEditor(editor, itemIndex),
            _managementGroupTitle(
              'Procedures',
              procedures.length,
              onAdd: () => setState(
                () => editor.procedures.add(
                  _EditableProcedure.empty(problemName: diagnosis),
                ),
              ),
            ),
            if (procedures.isEmpty)
              _emptyManagementLabel('No procedures linked to this problem.')
            else
              for (final itemIndex in procedures)
                _procedureEditor(editor, itemIndex),
          ],
        ),
      ),
    );
  }

  Widget _unlinkedManagementCard(_TaskEditor editor) {
    final meds = [
      for (var i = 0; i < editor.meds.length; i++)
        if (editor.problemNameFor(editor.meds[i].problemName) == null) i,
    ];
    final labs = [
      for (var i = 0; i < editor.labs.length; i++)
        if (editor.problemNameFor(editor.labs[i].problemName) == null) i,
    ];
    final procedures = [
      for (var i = 0; i < editor.procedures.length; i++)
        if (editor.problemNameFor(editor.procedures[i].problemName) == null) i,
    ];
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: colors.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Unlinked management',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _managementGroupTitle(
              'Medications',
              meds.length,
              onAdd: () =>
                  setState(() => editor.meds.add(_EditableMedication.empty())),
            ),
            if (meds.isEmpty)
              _emptyManagementLabel('No unlinked medications.')
            else
              for (final itemIndex in meds)
                _medicationEditor(editor, itemIndex),
            _managementGroupTitle(
              'Investigations / labs',
              labs.length,
              onAdd: () =>
                  setState(() => editor.labs.add(_EditableLab.empty())),
            ),
            if (labs.isEmpty)
              _emptyManagementLabel('No unlinked investigations.')
            else
              for (final itemIndex in labs) _labEditor(editor, itemIndex),
            _managementGroupTitle(
              'Procedures',
              procedures.length,
              onAdd: () => setState(
                () => editor.procedures.add(_EditableProcedure.empty()),
              ),
            ),
            if (procedures.isEmpty)
              _emptyManagementLabel('No unlinked procedures.')
            else
              for (final itemIndex in procedures)
                _procedureEditor(editor, itemIndex),
          ],
        ),
      ),
    );
  }

  Widget _managementGroupTitle(
    String title,
    int count, {
    required VoidCallback onAdd,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$title ($count)',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Add $title',
            onPressed: onAdd,
            icon: const Icon(Icons.add_circle_outline, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _emptyManagementLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );

  Widget _linkageDropdown(
    _TaskEditor editor, {
    required String? linkedProblem,
    required ValueChanged<String?> onChanged,
  }) {
    final problemNames = editor.problemNames;
    final selected = editor.problemNameFor(linkedProblem);
    final value = selected != null && problemNames.contains(selected)
        ? selected
        : '';
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
      child: Row(
        children: [
          Text('Linked to:', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              isDense: true,
              underline: const SizedBox.shrink(),
              items: [
                const DropdownMenuItem(
                  value: '',
                  child: Text('Unlinked management'),
                ),
                for (final name in problemNames)
                  DropdownMenuItem(value: name, child: Text(name)),
              ],
              onChanged: (next) =>
                  onChanged(next == null || next.isEmpty ? null : next),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _vitalsSection(_TaskEditor editor) {
    // Sprint 17.5 — collapse entirely when the document carried no vitals.
    if (editor.hasNoVitals) return const [];
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
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: _numberField(
              'Respiratory rate',
              editor.respiratoryRate,
              suffix: '/min',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _numberField(
              'Mean arterial pressure',
              editor.meanArterialPressure,
              suffix: 'mmHg',
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
        child: Column(
          children: [
            Row(
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
                  tooltip: lab.isAbnormal
                      ? 'Flagged abnormal'
                      : 'Mark abnormal',
                  onPressed: () =>
                      setState(() => lab.isAbnormal = !lab.isAbnormal),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                  tooltip: 'Delete test',
                  onPressed: () => setState(() {
                    editor.labs.removeAt(index).dispose();
                  }),
                ),
              ],
            ),
            _linkageDropdown(
              editor,
              linkedProblem: lab.problemName,
              onChanged: (value) => setState(() {
                lab.problemName = value;
                lab.linkVerified = true;
              }),
            ),
          ],
        ),
      ),
    );
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
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: SmartDrugAutocomplete(
                    controller: med.drugName,
                    labelText: 'Drug name',
                    onSelected: (selection) =>
                        _onCatalogDrugSelected(editor, med, selection),
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
                  onPressed: () => setState(() {
                    editor.meds.removeAt(index).dispose();
                  }),
                ),
              ],
            ),
            _linkageDropdown(
              editor,
              linkedProblem: med.problemName,
              onChanged: (value) => setState(() {
                med.problemName = value;
                med.linkVerified = true;
              }),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: med.route,
                    decoration: const InputDecoration(
                      labelText: 'Route',
                      hintText: 'Oral',
                      isDense: true,
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: med.duration,
                    decoration: const InputDecoration(
                      labelText: 'Duration',
                      hintText: '5 days',
                      isDense: true,
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            for (final warning in _doseAdjustmentWarnings(med.selectedDrug))
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Chip(
                    avatar: const Icon(Icons.warning_amber, size: 18),
                    label: Text(warning, style: const TextStyle(fontSize: 12)),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.tertiaryContainer,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onCatalogDrugSelected(
    _TaskEditor editor,
    _EditableMedication medication,
    ClinicalDrugSelection selection,
  ) {
    setState(() {
      medication.selectedDrug = selection;
      medication.drugName.text = selection.molecule;
      if (medication.dosage.text.trim().isEmpty) {
        medication.dosage.text = selection.standardDosage ?? '';
      }
      if (medication.route.text.trim().isEmpty) {
        medication.route.text = selection.route ?? '';
      }
      if (medication.duration.text.trim().isEmpty) {
        medication.duration.text = selection.duration ?? '';
      }

      final activeNames = _knownActiveProblems.map(
        (problem) => problem.problemName,
      );
      final candidates = selection.commonIndications;
      for (final problemName in activeNames) {
        if (candidates.any(
          (indication) => _sameClinicalTerm(indication, problemName),
        )) {
          final existingProblem = editor.problems
              .where(
                (problem) => _sameClinicalTerm(problem.name.text, problemName),
              )
              .firstOrNull;
          final linkedProblem =
              existingProblem ??
              _EditableProblem(name: problemName, reasoning: '');
          if (existingProblem == null) {
            editor.problems.add(linkedProblem);
          }
          medication.problemName = linkedProblem.name.text;
          medication.linkVerified = false;
          break;
        }
      }
    });
  }

  List<String> _doseAdjustmentWarnings(ClinicalDrugSelection? selection) {
    if (selection == null) return const [];
    final problems = _knownActiveProblems
        .map((problem) => problem.problemName.toLowerCase())
        .toList(growable: false);
    final warnings = <String>[];
    for (final entry in selection.doseAdjustments.entries) {
      final condition = entry.key.toLowerCase();
      final isRenal =
          condition.contains('renal') || condition.contains('kidney');
      final isHepatic =
          condition.contains('hepatic') || condition.contains('liver');
      final matchingProblem = problems.any((problem) {
        if (isRenal) {
          return problem.contains('renal') ||
              problem.contains('kidney') ||
              problem.contains('ckd') ||
              problem.contains('nephro');
        }
        if (isHepatic) {
          return problem.contains('hepatic') ||
              problem.contains('liver') ||
              problem.contains('cirrhosis');
        }
        return problem.contains(condition);
      });
      if (matchingProblem) {
        final label = isRenal
            ? 'Renal Adjustment Required'
            : isHepatic
            ? 'Hepatic Adjustment Required'
            : '${entry.key} Adjustment Required';
        warnings.add('$label: ${entry.value}');
      }
    }
    return warnings;
  }

  static bool _sameClinicalTerm(String left, String right) {
    String normalize(String value) =>
        value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final a = normalize(left);
    final b = normalize(right);
    return a.isNotEmpty &&
        b.isNotEmpty &&
        (a == b || a.startsWith(b) || b.startsWith(a));
  }

  Widget _procedureEditor(_TaskEditor editor, int index) {
    final procedure = editor.procedures[index];
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: procedure.name,
                    decoration: const InputDecoration(
                      labelText: 'Procedure',
                      isDense: true,
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Delete procedure',
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(
                    () => editor.procedures.removeAt(index).dispose(),
                  ),
                ),
              ],
            ),
            _linkageDropdown(
              editor,
              linkedProblem: procedure.problemName,
              onChanged: (value) => setState(() {
                procedure.problemName = value;
                procedure.linkVerified = true;
              }),
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
        if (editor.clinicalWarnings.isNotEmpty) ...[
          _sectionTitle('Medication safety warnings'),
          for (final warning in editor.clinicalWarnings)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.warning_amber),
                title: Text(
                  warning.medication.isEmpty
                      ? warning.warning
                      : '${warning.medication}: ${warning.warning}',
                ),
                subtitle: Text(
                  [
                    if (warning.condition.isNotEmpty) warning.condition,
                    if (warning.doseAdjustment?.isNotEmpty == true)
                      warning.doseAdjustment!,
                  ].join(' · '),
                ),
              ),
            ),
          const SizedBox(height: 12),
        ],
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
        _sectionTitle('Conclusion / Impression'),
        TextField(
          controller: editor.conclusion,
          minLines: 2,
          maxLines: 6,
          decoration: _decoration(
            // Sprint 14.5 — surfaced explicitly because OCR truncation here is
            // the most clinically damaging failure: the numbers survive but the
            // radiologist's interpretation does not.
            'Verbatim conclusion from the report',
            missing: editor.conclusion.text.trim().isEmpty,
            hintText: 'e.g. "Features suggestive of acute appendicitis…"',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 18),
        _sectionTitle('Document date & time'),
        _dateTimeRow(editor),
        const SizedBox(height: 18),
      ],
    );
  }

  /// Sprint 14.5 — explicit date and time pickers so the clinician can verify
  /// and correct the *clinical* timestamp before saving, instead of the record
  /// silently inheriting the scan time.
  Widget _dateTimeRow(_TaskEditor editor) {
    final local = editor.documentedAt.toLocal();
    final dateLabel =
        '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
    final timeLabel =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.event_outlined),
            label: Text('Date: $dateLabel'),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: local,
                // A document cannot be dated in the future; allowing it would
                // let a typo file a report ahead of today.
                firstDate: DateTime(2000),
                lastDate: DateTime.now().add(const Duration(days: 1)),
              );
              if (picked == null) return;
              setState(() {
                editor.documentedAt = DateTime(
                  picked.year,
                  picked.month,
                  picked.day,
                  local.hour,
                  local.minute,
                );
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.schedule_outlined),
            label: Text('Time: $timeLabel'),
            onPressed: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(local),
              );
              if (picked == null) return;
              setState(() {
                editor.documentedAt = DateTime(
                  local.year,
                  local.month,
                  local.day,
                  picked.hour,
                  picked.minute,
                );
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _transcriptSection(DocumentTask task) {
    final transcript = (task.rawOcrText ?? '').trim();
    if (transcript.isEmpty || task.isTextInput) {
      return const SizedBox.shrink();
    }
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
  _TaskEditor(
    AiExtractionResult seed, {
    String? rawTranscript,
    DateTime? documentedAt,
  }) {
    clinicalWarnings = seed.clinicalWarnings;
    final identity = seed.patientIdentity;
    name = TextEditingController(text: identity.name ?? '');
    age = TextEditingController(text: identity.age?.toString() ?? '');
    gender = TextEditingController(text: identity.gender ?? '');
    registration = TextEditingController(text: identity.hospitalRegNo ?? '');

    // Sprint 15 — facility context, carried through to `toResult` so the DAO
    // can file the encounter against the hospital the document came from.
    hospitalId = identity.hospitalId;
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
    respiratoryRate = TextEditingController(
      text: vitals.respiratoryRate?.toString() ?? '',
    );
    meanArterialPressure = TextEditingController(
      text: vitals.meanArterialPressure?.toString() ?? '',
    );

    summary = TextEditingController(text: seed.clinicalSummary);
    // Sprint 14.5 — the pathologist's/radiologist's closing narrative is the
    // part most often truncated by OCR, so it gets its own editable field
    // rather than being flattened into the summary.
    conclusion = TextEditingController(text: seed.conclusion);

    // Seeded from the document's own date when one was parsed, otherwise the
    // capture time. The clinician can correct it before saving.
    //
    // Priority: the explicit Edit Mode seed > the date parsed off the document
    // > "now". Edit Mode must win because it carries the *stored* timestamp.
    final seedDate =
        documentedAt ?? DateTimeUtils.parseToUtc(seed.encounterContext.date);
    this.documentedAt = seedDate ?? DateTime.now().toUtc();
    transcript = rawTranscript ?? '';

    complaints = [...seed.chiefComplaints];
    problems = [];
    labs = [];
    meds = [];
    procedures = [];

    for (final item in seed.problems) {
      final diagnosis = item.diagnosis.trim();
      if (diagnosis.isEmpty) continue;
      _addProblem(diagnosis, item.reasoning);
      for (final medication in item.linkedMedications) {
        _addMedication(medication, diagnosis);
      }
      for (final investigation in item.linkedInvestigations) {
        _addInvestigation(investigation, diagnosis);
      }
      for (final procedure in item.linkedProcedures) {
        _addProcedure(procedure, diagnosis);
      }
    }
    for (final medication in seed.unlinkedManagement.medications) {
      _addMedication(medication, null);
    }
    for (final investigation in seed.unlinkedManagement.investigations) {
      _addInvestigation(investigation, null);
    }
    for (final procedure in seed.unlinkedManagement.procedures) {
      _addProcedure(procedure, null);
    }

    for (final diagnosis in seed.diagnoses) {
      _addProblem(diagnosis, '');
    }
    for (final lab in seed.labResults) {
      _addLabResult(lab, null);
    }
    for (final investigation in seed.plannedInvestigations) {
      if (!labs.any(
        (lab) =>
            lab.testName.text.trim().toLowerCase() ==
            investigation.trim().toLowerCase(),
      )) {
        _addInvestigation(AiInvestigation(testName: investigation), null);
      }
    }
    for (final medication in seed.medicationsOrdered) {
      if (!meds.any(
        (existing) =>
            existing.drugName.text.trim().toLowerCase() ==
                medication.drugName.trim().toLowerCase() &&
            existing.dosage.text.trim().toLowerCase() ==
                medication.dosage?.trim().toLowerCase() &&
            existing.frequency.text.trim().toLowerCase() ==
                medication.frequency?.trim().toLowerCase(),
      )) {
        _addMedication(medication, null);
      }
    }
  }

  late List<String> complaints;
  late final List<_EditableProblem> problems;
  late final List<_EditableLab> labs;
  late final List<_EditableMedication> meds;
  late final List<_EditableProcedure> procedures;

  List<String> get problemNames {
    final names = <String>[];
    for (final problem in problems) {
      final name = problem.name.text.trim();
      if (name.isNotEmpty &&
          !names.any(
            (existing) => existing.toLowerCase() == name.toLowerCase(),
          )) {
        names.add(name);
      }
    }
    return names;
  }

  String? problemNameFor(String? name) {
    final linkedName = name?.trim();
    if (linkedName == null || linkedName.isEmpty) return null;
    for (final problem in problems) {
      if (problem.linkAliases.contains(linkedName.toLowerCase())) {
        final current = problem.name.text.trim();
        return current.isEmpty ? null : current;
      }
    }
    return null;
  }

  List<String> get verifiedProblemAssociations => meds
      .where((medication) => medication.linkVerified)
      .map((medication) {
        final problemName = problemNameFor(medication.problemName);
        final drugName = medication.drugName.text.trim();
        if (problemName == null || drugName.isEmpty) return null;
        return '$drugName:$problemName';
      })
      .whereType<String>()
      .toSet()
      .toList(growable: false);

  void _addProblem(String name, String reasoning) {
    final cleaned = name.trim();
    if (cleaned.isEmpty ||
        problems.any(
          (problem) =>
              problem.name.text.trim().toLowerCase() == cleaned.toLowerCase(),
        )) {
      return;
    }
    problems.add(_EditableProblem(name: cleaned, reasoning: reasoning));
  }

  void _addMedication(OrderedMedication medication, String? problemName) {
    final normalized = medication.drugName.trim().toLowerCase();
    if (normalized.isEmpty ||
        meds.any(
          (existing) =>
              existing.drugName.text.trim().toLowerCase() == normalized &&
              existing.problemName?.toLowerCase() == problemName?.toLowerCase(),
        )) {
      return;
    }
    meds.add(_EditableMedication.from(medication, problemName: problemName));
  }

  void _addInvestigation(AiInvestigation investigation, String? problemName) {
    final normalized = investigation.testName.trim().toLowerCase();
    if (normalized.isEmpty) return;
    final existing = labs.where(
      (lab) =>
          lab.testName.text.trim().toLowerCase() == normalized &&
          lab.problemName?.toLowerCase() == problemName?.toLowerCase(),
    );
    if (existing.isNotEmpty) {
      final lab = existing.first;
      if (lab.value.text.trim().isEmpty && investigation.value.isNotEmpty) {
        lab.value.text = investigation.value;
        lab.unit.text = investigation.unit ?? '';
        lab.isAbnormal = investigation.isAbnormal;
      }
      return;
    }
    labs.add(
      _EditableLab.fromInvestigation(investigation, problemName: problemName),
    );
  }

  void _addLabResult(AiLabResult lab, String? problemName) {
    final matching = labs.where(
      (existing) =>
          existing.testName.text.trim().toLowerCase() ==
          lab.testName.trim().toLowerCase(),
    );
    if (matching.isNotEmpty) {
      final existing = matching.firstWhere(
        (item) => item.value.text.trim().isEmpty,
        orElse: () => matching.first,
      );
      if (existing.value.text.trim().isEmpty) {
        existing.value.text = lab.value;
        existing.unit.text = lab.unit ?? '';
        existing.isAbnormal = lab.isAbnormal;
      }
      return;
    }
    _addInvestigation(
      AiInvestigation(
        testName: lab.testName,
        value: lab.value,
        unit: lab.unit,
        isAbnormal: lab.isAbnormal,
      ),
      problemName,
    );
  }

  void _addProcedure(AiProcedure procedure, String? problemName) {
    final normalized = procedure.procedureName.trim().toLowerCase();
    if (normalized.isEmpty ||
        procedures.any(
          (existing) =>
              existing.name.text.trim().toLowerCase() == normalized &&
              existing.problemName?.toLowerCase() == problemName?.toLowerCase(),
        )) {
      return;
    }
    procedures.add(
      _EditableProcedure(
        name: procedure.procedureName,
        problemName: problemName,
      ),
    );
  }

  /// Sprint 17.5 — true when the document carried no vitals at all, so the
  /// Vitals block collapses instead of showing an empty table of dashes.
  ///
  /// Reads the *seeded* controllers, not the typed text: a clinician who
  /// blanks a field is still inside a section that already exists.
  bool get hasNoVitals =>
      sbp.text.trim().isEmpty &&
      dbp.text.trim().isEmpty &&
      pulse.text.trim().isEmpty &&
      spo2.text.trim().isEmpty &&
      temp.text.trim().isEmpty &&
      respiratoryRate.text.trim().isEmpty &&
      meanArterialPressure.text.trim().isEmpty;

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
  late final TextEditingController respiratoryRate;
  late final TextEditingController meanArterialPressure;
  late final TextEditingController summary;

  /// Sprint 14.5 — the report's closing narrative ("Conclusion" / "Impression"
  /// / "Final Remarks"), editable and persisted separately from the summary.
  late final TextEditingController conclusion;

  /// Sprint 14.5 — the clinical timestamp the clinician has verified. Seeded
  /// from the document's own printed date, never from the scan time when a
  /// date could be read.
  late DateTime documentedAt;

  /// Sprint 15 — facility chosen during review; null means "use the patient's
  /// primary facility".
  String? hospitalId;
  late final String transcript;
  late final List<AiClinicalWarning> clinicalWarnings;

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
    respiratoryRate.dispose();
    meanArterialPressure.dispose();
    summary.dispose();
    conclusion.dispose();
    for (final lab in labs) {
      lab.dispose();
    }
    for (final medication in meds) {
      medication.dispose();
    }
    for (final problem in problems) {
      problem.dispose();
    }
    for (final procedure in procedures) {
      procedure.dispose();
    }
  }

  /// Reads the validated controller values back into an [AiExtractionResult]
  /// ready for `ClinicalDao.processAiExtraction`.
  AiExtractionResult toResult(AiExtractionResult base) {
    final cleanProblems = <_EditableProblem>[
      for (final problem in problems)
        if (problem.name.text.trim().isNotEmpty) problem,
    ];
    final currentProblemName = <String, String>{};
    for (final problem in cleanProblems) {
      for (final alias in problem.linkAliases) {
        currentProblemName[alias] = problem.name.text.trim();
      }
    }
    String? resolved(String? oldName) {
      if (oldName == null) return null;
      return currentProblemName[oldName.trim().toLowerCase()] ??
          (problemNames.any(
                (name) => name.toLowerCase() == oldName.trim().toLowerCase(),
              )
              ? oldName.trim()
              : null);
    }

    final resultMeds = [
      for (final medication in meds)
        if (medication.drugName.text.trim().isNotEmpty)
          OrderedMedication(
            drugName: medication.drugName.text.trim(),
            dosage: emptyToNull(medication.dosage.text),
            frequency: emptyToNull(medication.frequency.text),
            route: emptyToNull(medication.route.text),
            duration: emptyToNull(medication.duration.text),
          ),
    ];
    final resultLabs = [
      for (final lab in labs)
        if (lab.testName.text.trim().isNotEmpty)
          AiLabResult(
            testName: lab.testName.text.trim(),
            value: lab.value.text.trim(),
            unit: emptyToNull(lab.unit.text),
            isAbnormal: lab.isAbnormal,
          ),
    ];
    final structuredProblems = [
      for (final problem in cleanProblems)
        AiProblem(
          diagnosis: problem.name.text.trim(),
          reasoning: problem.reasoning.text.trim(),
          linkedMedications: [
            for (final medication in meds)
              if (medication.drugName.text.trim().isNotEmpty &&
                  resolved(medication.problemName) == problem.name.text.trim())
                OrderedMedication(
                  drugName: medication.drugName.text.trim(),
                  dosage: emptyToNull(medication.dosage.text),
                  frequency: emptyToNull(medication.frequency.text),
                  route: emptyToNull(medication.route.text),
                  duration: emptyToNull(medication.duration.text),
                ),
          ],
          linkedInvestigations: [
            for (final lab in labs)
              if (lab.testName.text.trim().isNotEmpty &&
                  resolved(lab.problemName) == problem.name.text.trim())
                AiInvestigation(
                  testName: lab.testName.text.trim(),
                  value: lab.value.text.trim(),
                  unit: emptyToNull(lab.unit.text),
                  isAbnormal: lab.isAbnormal,
                ),
          ],
          linkedProcedures: [
            for (final procedure in procedures)
              if (resolved(procedure.problemName) == problem.name.text.trim())
                AiProcedure(procedureName: procedure.name.text.trim()),
          ],
        ),
    ];

    return base.copyWith(
      patientIdentity: base.patientIdentity.copyWith(
        name: emptyToNull(name.text),
        age: int.tryParse(age.text.trim()),
        gender: emptyToNull(gender.text),
        hospitalRegNo: emptyToNull(registration.text),
        // Sprint 15 — carry the chosen facility into the persisted result.
        hospitalId: hospitalId,
      ),
      encounterContext: base.encounterContext.copyWith(
        documentType: documentType.text.trim().isEmpty
            ? 'Clinical Document'
            : documentType.text.trim(),
        // Sprint 14.5 — the clinician-verified clinical timestamp, as ISO so
        // the DAO's `_date()` parses it into `occurredAt` / `documentedAt`.
        date: documentedAt.toIso8601String(),
      ),
      vitals: base.vitals.copyWith(
        sbp: int.tryParse(sbp.text.trim()),
        dbp: int.tryParse(dbp.text.trim()),
        pr: int.tryParse(pulse.text.trim()),
        spo2: int.tryParse(spo2.text.trim()),
        temperatureC: double.tryParse(temp.text.trim()),
        respiratoryRate: int.tryParse(respiratoryRate.text.trim()),
        meanArterialPressure: double.tryParse(meanArterialPressure.text.trim()),
      ),
      labResults: resultLabs,
      medicationsOrdered: resultMeds,
      problems: structuredProblems,
      unlinkedManagement: AiUnlinkedManagement(
        medications: [
          for (final medication in meds)
            if (medication.drugName.text.trim().isNotEmpty &&
                resolved(medication.problemName) == null)
              OrderedMedication(
                drugName: medication.drugName.text.trim(),
                dosage: emptyToNull(medication.dosage.text),
                frequency: emptyToNull(medication.frequency.text),
                route: emptyToNull(medication.route.text),
                duration: emptyToNull(medication.duration.text),
              ),
        ],
        investigations: [
          for (final lab in labs)
            if (lab.testName.text.trim().isNotEmpty &&
                resolved(lab.problemName) == null)
              AiInvestigation(
                testName: lab.testName.text.trim(),
                value: lab.value.text.trim(),
                unit: emptyToNull(lab.unit.text),
                isAbnormal: lab.isAbnormal,
              ),
        ],
        procedures: [
          for (final procedure in procedures)
            if (resolved(procedure.problemName) == null &&
                procedure.name.text.trim().isNotEmpty)
              AiProcedure(procedureName: procedure.name.text.trim()),
        ],
      ),
      clinicalSummary: summary.text.trim(),
      // Sprint 14.5 — carry the clinician-verified clinical timestamp and the
      // report's conclusion through to persistence.
      conclusion: conclusion.text.trim(),
      // Sprint 17.5 — the editable semantic layer round-trips back out, minus
      // any row the clinician blanked out.
      chiefComplaints: _cleaned(complaints),
      diagnoses: [
        for (final problem in cleanProblems) problem.name.text.trim(),
      ],
      plannedInvestigations: [
        for (final lab in labs)
          if (lab.testName.text.trim().isNotEmpty) lab.testName.text.trim(),
      ],
    );
  }

  /// Drops blank rows so removing a chip actually removes the data, instead of
  /// persisting an empty string that would re-render as an empty section.
  static List<String> _cleaned(List<String> values) => values
      .map((v) => v.trim())
      .where((v) => v.isNotEmpty)
      .toList(growable: false);
}

/// Sprint 17.5 — a single editable chip used for chief complaints, diagnoses
/// and ordered investigations.
///
/// Edits are committed through [onChanged] rather than held locally, so the
/// parent owns the authoritative list and a rebuild (e.g. removing the last
/// chip, which collapses the whole section) can never disagree with the field.
class _EditableChip extends StatefulWidget {
  const _EditableChip({
    super.key,
    required this.initialValue,
    required this.onChanged,
    required this.onRemove,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final VoidCallback onRemove;

  @override
  State<_EditableChip> createState() => _EditableChipState();
}

class _EditableChipState extends State<_EditableChip> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 260),
        child: TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: const InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
      onDeleted: widget.onRemove,
      deleteIcon: const Icon(Icons.close, size: 16),
    );
  }
}

class _EditableLab {
  _EditableLab({
    required this.testName,
    required this.value,
    required this.unit,
    required this.isAbnormal,
    this.problemName,
  });

  factory _EditableLab.fromInvestigation(
    AiInvestigation lab, {
    String? problemName,
  }) => _EditableLab(
    testName: TextEditingController(text: lab.testName),
    value: TextEditingController(text: lab.value),
    unit: TextEditingController(text: lab.unit ?? ''),
    isAbnormal: lab.isAbnormal,
    problemName: problemName,
  );

  factory _EditableLab.empty({String? problemName}) => _EditableLab(
    testName: TextEditingController(),
    value: TextEditingController(),
    unit: TextEditingController(),
    isAbnormal: false,
    problemName: problemName,
  );

  final TextEditingController testName;
  final TextEditingController value;
  final TextEditingController unit;
  bool isAbnormal;
  String? problemName;
  bool linkVerified = false;

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
    required this.route,
    required this.duration,
    this.problemName,
  });

  factory _EditableMedication.from(
    OrderedMedication medication, {
    String? problemName,
  }) => _EditableMedication(
    drugName: TextEditingController(text: medication.drugName),
    dosage: TextEditingController(text: medication.dosage ?? ''),
    frequency: TextEditingController(text: medication.frequency ?? ''),
    route: TextEditingController(text: medication.route ?? ''),
    duration: TextEditingController(text: medication.duration ?? ''),
    problemName: problemName,
  );

  factory _EditableMedication.empty({String? problemName}) {
    final medication = _EditableMedication(
      drugName: TextEditingController(),
      dosage: TextEditingController(),
      frequency: TextEditingController(),
      route: TextEditingController(),
      duration: TextEditingController(),
      problemName: problemName,
    );
    medication.linkVerified = problemName != null;
    return medication;
  }

  final TextEditingController drugName;
  final TextEditingController dosage;
  final TextEditingController frequency;
  final TextEditingController route;
  final TextEditingController duration;
  String? problemName;
  ClinicalDrugSelection? selectedDrug;
  bool linkVerified = false;

  void dispose() {
    drugName.dispose();
    dosage.dispose();
    frequency.dispose();
    route.dispose();
    duration.dispose();
  }
}

class _EditableProblem {
  _EditableProblem({required String name, required String reasoning})
    : lastName = name,
      name = TextEditingController(text: name),
      reasoning = TextEditingController(text: reasoning),
      linkAliases = {name.trim().toLowerCase()};

  factory _EditableProblem.empty() => _EditableProblem(name: '', reasoning: '');

  String lastName;
  final TextEditingController name;
  final TextEditingController reasoning;
  final Set<String> linkAliases;

  void dispose() {
    name.dispose();
    reasoning.dispose();
  }
}

class _EditableProcedure {
  _EditableProcedure({required String name, this.problemName})
    : name = TextEditingController(text: name);

  factory _EditableProcedure.empty({String? problemName}) =>
      _EditableProcedure(name: '', problemName: problemName);

  final TextEditingController name;
  String? problemName;
  bool linkVerified = false;

  void dispose() => name.dispose();
}
