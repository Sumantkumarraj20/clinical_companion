import 'dart:io';
import 'ai_extraction_result.dart'; 

enum ExtractionStatus {
  pending,
  processingOcr,
  processingAiFallback,
  processingAi,
  readyForReview,
  completed,
  error,
}

/// Where the structured data actually came from. Kept outside the frozen
/// [AiExtractionResult] so we don't need to re-run codegen to track it.
enum ExtractionSource {
  /// Parsed fully on-device with regex — free, instant, offline.
  local,
  /// Escalated to Gemini cloud AI.
  ai,
  unknown,
}

class DocumentTask {
  DocumentTask({
    required this.id,
    required this.originalFile,
    this.status = ExtractionStatus.pending,
    this.extractedData,
    this.source = ExtractionSource.unknown,
    this.rawOcrText,
  });

  final String id;
  final File originalFile;
  final ExtractionStatus status;
  final AiExtractionResult? extractedData;
  final ExtractionSource source;
  final String? rawOcrText;

  DocumentTask copyWith({
    ExtractionStatus? status,
    AiExtractionResult? extractedData,
    ExtractionSource? source,
    String? rawOcrText,
  }) {
    return DocumentTask(
      id: id,
      originalFile: originalFile,
      status: status ?? this.status,
      extractedData: extractedData ?? this.extractedData,
      source: source ?? this.source,
      rawOcrText: rawOcrText ?? this.rawOcrText,
    );
  }
}
