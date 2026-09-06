import 'dart:io';

import 'package:clinical_companion/core/database/local_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/ai/document_ai_service.dart';
import '../../../core/providers/app_providers.dart';
import 'extraction_review_screen.dart';

class SmartCaptureScreen extends ConsumerStatefulWidget {
  // Removed the required patient parameter!
  const SmartCaptureScreen({super.key, required Patient patient});

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

    final image = File(picked.path);
    setState(() => _processing = true);

    try {
      final apiKey = ref.read(appConfigurationProvider).geminiApiKey;
      if (apiKey.isEmpty) {
        throw Exception("Gemini API Key is missing in Configuration.");
      }

      final result = await DocumentAiService(apiKey: apiKey).extractDocument(
        image: image,
        prompt:
            'Extract patient identifier, location, document type, vitals, clinical summary, and full raw text from this clinical document.',
      );

      // Learn from medications silently in the background
      await DocumentAiService().routeMedicationKnowledge(
        result: result,
        pharmacopeiaDao: ref.read(pharmacopeiaDaoProvider),
        ownerId: ref.read(currentOwnerIdProvider),
      );

      if (!mounted) return;

      // Auto-navigate to Review Screen upon successful AI extraction
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) =>
              ExtractionReviewScreen(extraction: result, imagePath: image.path),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI Extraction Failed: $error'),
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
