import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class LocalOcrService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> extractTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      // Returns all the raw, unformatted text found in the image
      return recognizedText.text;
    } catch (e) {
      throw Exception('Local OCR failed: $e');
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
