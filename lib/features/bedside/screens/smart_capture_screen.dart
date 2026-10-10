import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/providers/app_providers.dart';

/// Entry point of the OCR/ClinCom pipeline.
///
/// This screen only *queues* work: the picked file(s) are handed to
/// [batchExtractionProvider], which runs on-device OCR and — when the local
/// read is messy — ClinCom cleans and structures it in the background. We navigate to the
/// review queue immediately so the clinician never waits on a spinner; the
/// review screen renders live progress per page.
class SmartCaptureScreen extends ConsumerStatefulWidget {
  const SmartCaptureScreen({super.key});

  @override
  ConsumerState<SmartCaptureScreen> createState() => _SmartCaptureScreenState();
}

class _SmartCaptureScreenState extends ConsumerState<SmartCaptureScreen> {
  final _picker = ImagePicker();
  bool _busy = false;

  Future<void> _capture() => _pick(source: ImageSource.camera, multiple: false);

  Future<void> _pickFromGallery() =>
      _pick(source: ImageSource.gallery, multiple: true);

  Future<void> _pick({
    required ImageSource source,
    required bool multiple,
  }) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final List<File> files;
      if (multiple) {
        final picked = await _picker.pickMultiImage(imageQuality: 90);
        files = [for (final item in picked) File(item.path)];
      } else {
        final picked = await _picker.pickImage(
          source: source,
          imageQuality: 90, // Compresses image to save memory and API payload
        );
        files = picked == null ? const [] : [File(picked.path)];
      }
      if (files.isEmpty || !mounted) return;

      // Sprint 17 — attach the live census so bed numbers resolve to patients.
      final census = await BatchExtractionNotifier.buildActiveCensusJson(
        ref.read(clinicalDaoProvider),
      );
      if (!mounted) return;
      ref
          .read(batchExtractionProvider.notifier)
          .addOmniFiles(files, activeCensusJson: census);
      if (!mounted) return;

      context.go('/dashboard');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open the image picker: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ClinCom Smart Capture')),
      body: Center(
        child: _busy
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 24),
                  Text('Opening camera…'),
                  Text(
                    'Adding pages to the extraction queue',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.document_scanner,
                    size: 80,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    onPressed: _capture,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text(
                      'Open Camera',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Choose images from phone'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Works with lab reports, ECGs, and handwritten notes.\n'
                    'Pages are read on-device first, then polished with ClinCom '
                    'only when needed.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
      ),
    );
  }
}
