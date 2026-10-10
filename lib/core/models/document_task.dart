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

  /// Escalated to ClinCom.
  ai,

  /// Clinician-pasted text sent directly to ClinCom without OCR.
  text,
  unknown,
}

class DocumentTask {
  DocumentTask({
    required this.id,
    this.originalFile,
    this.isTextInput = false,
    this.isAmbientAudio = false,
    this.useOmniIngestion = false,
    this.status = ExtractionStatus.pending,
    this.extractedData,
    this.source = ExtractionSource.unknown,
    this.rawOcrText,
    this.errorMessage,
    this.activeCensusJson,
  });

  final String id;
  final File? originalFile;
  final bool isTextInput;
  final bool isAmbientAudio;
  final bool useOmniIngestion;
  final ExtractionStatus status;
  final AiExtractionResult? extractedData;
  final ExtractionSource source;
  final String? rawOcrText;

  /// Human readable reason for [ExtractionStatus.error]. Surfaced by the
  /// review UI so the clinician understands *why* a page needs a retry.
  final String? errorMessage;

  /// Sprint 17 — serialised active inpatient census, captured by the screen at
  /// enqueue time and appended to the ClinCom prompt. Carried on the task (not
  /// read from the DB inside the queue) so extraction is a pure function of its
  /// inputs and stays trivially testable.
  ///
  /// Null when no census was available, in which case ClinCom simply skips
  /// patient inference rather than guessing.
  final String? activeCensusJson;

  bool get isTerminal =>
      status == ExtractionStatus.readyForReview ||
      status == ExtractionStatus.error;

  bool get isInProgress =>
      status == ExtractionStatus.pending ||
      status == ExtractionStatus.processingOcr ||
      status == ExtractionStatus.processingAiFallback ||
      status == ExtractionStatus.processingAi;

  DocumentTask copyWith({
    File? originalFile,
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
      originalFile: originalFile ?? this.originalFile,
      isTextInput: isTextInput,
      isAmbientAudio: isAmbientAudio,
      useOmniIngestion: useOmniIngestion,
      activeCensusJson: activeCensusJson,
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
