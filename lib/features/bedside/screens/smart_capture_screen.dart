import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/ai/document_ai_service.dart';
import '../../../core/models/document_task.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/extraction_pipeline_service.dart';
import 'extraction_review_screen.dart';

class SmartCaptureScreen extends ConsumerStatefulWidget {
  const SmartCaptureScreen({super.key});

  @override
  ConsumerState<SmartCaptureScreen> createState() => _SmartCaptureScreenState();
}

class _SmartCaptureScreenState extends ConsumerState<SmartCaptureScreen> {
  final _picker = ImagePicker();
  bool _processing = false;

  Future<void> _capture() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90, // Compresses image to save memory and API payload
    );
    if (picked == null) return;
    await _processImage(File(picked.path));
  }

  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null) return;
    await _processImage(File(picked.path));
  }

  Future<void> _processImage(File image) async {
    setState(() => _processing = true);

    try {
      final pipeline = ref.read(extractionPipelineProvider);
      PipelineExtraction extraction;

      // Free path first: tryLocalOnly inside the pipeline handles API-less
      // documents; processDocumentWithProvenance escalates to Gemini only
      // when local regex is inadequate.
      extraction = await pipeline.processDocumentWithProvenance(image);

      if (!mounted) return;

      final source = extraction.taskSource;
      final result = extraction.result;

      // Auto-navigate to Review Screen, preserving extraction provenance so
      // the banner can show "Locally Extracted (Free)" vs "AI Extracted".
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ExtractionReviewScreen(
            extraction: result,
            imagePath: image.path,
            source: source == ExtractionSource.local
                ? ExtractionSource.local
                : ExtractionSource.ai,
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        final message = error is DocumentAiException && error.cause != null
            ? '${error.message}\nDetails: ${error.cause}'
            : error.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Smart Capture')),
      body: Center(
        child: _processing
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 24),
                  Text('Gemini is analyzing the document...'),
                  Text(
                    'Extracting vitals, labs, and medications',
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
                    onPressed: _processing ? null : _pickFromGallery,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Choose image from phone'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Works with lab reports, ECGs, and handwritten notes.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
      ),
    );
  }
}
