import 'dart:io';
import 'ai_extraction_result.dart'; 

enum ExtractionStatus {
  pending,
  processingOcr,
  processingAi,
  readyForReview,
  completed,
  error,
}

class DocumentTask {
  DocumentTask({
    required this.id,
    required this.originalFile,
    this.status = ExtractionStatus.pending,
    this.extractedData,
  });

  final String id;
  final File originalFile;
  final ExtractionStatus status;
  final AiExtractionResult? extractedData; 

  DocumentTask copyWith({
    ExtractionStatus? status,
    AiExtractionResult? extractedData,
  }) {
    return DocumentTask(
      id: id,
      originalFile: originalFile,
      status: status ?? this.status,
      extractedData: extractedData ?? this.extractedData,
    );
  }
}
