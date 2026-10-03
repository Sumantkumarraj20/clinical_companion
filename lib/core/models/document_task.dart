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
    this.errorMessage,
  });

  final String id;
  final File originalFile;
  final ExtractionStatus status;
  final AiExtractionResult? extractedData;
  final ExtractionSource source;
  final String? rawOcrText;

  /// Human readable reason for [ExtractionStatus.error]. Surfaced by the
  /// review UI so the clinician understands *why* a page needs a retry.
  final String? errorMessage;

  bool get isTerminal =>
      status == ExtractionStatus.readyForReview ||
      status == ExtractionStatus.error;

  bool get isInProgress =>
      status == ExtractionStatus.pending ||
      status == ExtractionStatus.processingOcr ||
      status == ExtractionStatus.processingAiFallback ||
      status == ExtractionStatus.processingAi;

  DocumentTask copyWith({
    ExtractionStatus? status,
    AiExtractionResult? extractedData,
    ExtractionSource? source,
    String? rawOcrText,
    String? errorMessage,
    bool clearError = false,
    bool clearExtractedData = false,
  }) {
    return DocumentTask(
      id: id,
      originalFile: originalFile,
      status: status ?? this.status,
      extractedData: clearExtractedData
          ? null
          : (extractedData ?? this.extractedData),
      source: source ?? this.source,
      rawOcrText: rawOcrText ?? this.rawOcrText,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
