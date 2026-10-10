import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/providers/app_providers.dart';

/// Sprint 28 — the single unified entry point for ALL clinical data.
Future<void> showOmniIngestionSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => const OmniIngestionSheet(),
  );
}

class OmniIngestionSheet extends ConsumerStatefulWidget {
  const OmniIngestionSheet({super.key});

  @override
  ConsumerState<OmniIngestionSheet> createState() => _OmniIngestionSheetState();
}

class _OmniIngestionSheetState extends ConsumerState<OmniIngestionSheet> {
  bool _busy = false;
  bool _listening = false;
  final _picker = ImagePicker();

  Future<void> _withBusy(Future<void> Function() work) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await work();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _census() async {
    try {
      return await BatchExtractionNotifier.buildActiveCensusJson(
        ref.read(clinicalDaoProvider),
      );
    } catch (_) {
      return null;
    }
  }

  void _goReview() {
    if (!mounted) return;
    Navigator.of(context).pop();
    unawaited(context.push<void>('/adaptive-review'));
  }

  void _fail(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Could not add data: $error')));
  }

  Future<void> _listen() => _withBusy(() async {
    try {
      final scribe = ref.read(ambientScribeServiceProvider);
      if (!_listening) {
        await scribe.startListening();
        if (mounted) setState(() => _listening = true);
        return;
      }
      final transcript = await scribe.stopAndGetTranscript();
      if (mounted) setState(() => _listening = false);
      if (!mounted) return;
      final census = await _census();
      ref
          .read(batchExtractionProvider.notifier)
          .addOmniText(
            transcript,
            activeCensusJson: census,
            isAmbientAudio: true,
          );
      _goReview();
    } catch (error) {
      _fail(error);
    }
  });

  void _paste() {
    if (!mounted) return;
    Navigator.of(context).pop();
    unawaited(context.push<void>('/text-ingestion'));
  }

  Future<void> _scanDocument() => _withBusy(() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );
      if (picked == null || !mounted) return;
      final census = await _census();
      if (!mounted) return;
      ref.read(batchExtractionProvider.notifier).addOmniFiles([
        File(picked.path),
      ], activeCensusJson: census);
      _goReview();
    } catch (error) {
      _fail(error);
    }
  });

  Future<void> _importPdf() => _withBusy(() async {
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
      final path = picked?.files.singleOrNull?.path;
      if (path == null || path.isEmpty || !mounted) return;
      final census = await _census();
      if (!mounted) return;
      ref.read(batchExtractionProvider.notifier).addOmniFiles([
        File(path),
      ], activeCensusJson: census);
      _goReview();
    } catch (error) {
      _fail(error);
    }
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Clinical Data', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Voice and text become structured notes; scans and PDFs '
              'join the review queue.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            if (_busy) const LinearProgressIndicator(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.mic_outlined),
              title: Text(
                _listening ? 'Stop Ambient Scribe' : 'Ambient Scribe',
              ),
              subtitle: Text(
                _listening
                    ? 'Recording in progress; tap to review the transcript'
                    : 'Capture the encounter by voice',
              ),
              enabled: !_busy,
              onTap: _listen,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.document_scanner_outlined),
              title: const Text('Capture Image'),
              subtitle: const Text('Photograph a paper report'),
              enabled: !_busy,
              onTap: () => _scanDocument(),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: const Text('Import PDF'),
              subtitle: const Text('Add a PDF from files'),
              enabled: !_busy,
              onTap: () => _importPdf(),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.content_paste_go_outlined),
              title: const Text('Paste Text/Guidelines'),
              subtitle: const Text('Add copied notes or clinical guidance'),
              enabled: !_busy,
              onTap: _paste,
            ),
          ],
        ),
      ),
    );
  }
}
