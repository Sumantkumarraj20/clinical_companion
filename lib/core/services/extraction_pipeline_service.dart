import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../ai/document_ai_service.dart';
import '../models/ai_extraction_result.dart';

class ExtractionPipelineService {
  ExtractionPipelineService(this._aiService);

  final DocumentAiService _aiService;
  final _textRecognizer = TextRecognizer();

  Future<AiExtractionResult> processDocument(File image) async {
    final recognizedText = await _textRecognizer.processImage(
      InputImage.fromFile(image),
    );
    final rawText = recognizedText.text;

    final requiresAiFallback = rawText.trim().length < 50;

    if (!requiresAiFallback) {
      final localData = _attemptLocalParsing(rawText);
      if (localData != null && _isDataAdequate(localData)) {
        return localData;
      }
    }

    final compressed = await _compressForAI(image);
    return await _aiService.extractDocument(
      image: compressed,
      prompt:
          'Extract patient demographics and lab values. OCR context: $rawText',
    );
  }

  AiExtractionResult? _attemptLocalParsing(String text) {
    // If we want to strictly rely on local regex first, parse here.
    // Returning null automatically triggers the cloud AI fallback securely.
    return null;
  }

  bool _isDataAdequate(AiExtractionResult data) {
    return data.labResults.isNotEmpty || data.medicationsOrdered.isNotEmpty;
  }

  Future<File> _compressForAI(File file) async {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final targetPath = '${file.absolute.parent.path}/ai_opt_$fileName';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
      minWidth: 1024,
      minHeight: 1024,
    );
    return File(result!.path);
  }
}
