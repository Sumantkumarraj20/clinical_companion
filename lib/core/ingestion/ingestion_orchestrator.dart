import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../ai/interactions_api_client.dart';
import '../database/daos/ingestion_inbox_dao.dart';
import '../database/local_database.dart';
import 'clinical_ingestion_mapper.dart';
import 'image_optimizer.dart';

/// Outcome of one ingestion attempt. Exactly one of [mapping] / draft is set.
class IngestionOutcome {
  const IngestionOutcome.structured(IngestionMappingResult this.mapping)
    : draftId = null,
      userMessage = null;

  const IngestionOutcome.draft(String this.draftId)
    : mapping = null,
      userMessage = kDraftSavedMessage;

  final IngestionMappingResult? mapping;
  final String? draftId;

  /// Non-technical toast text; null on success.
  final String? userMessage;

  bool get savedAsDraft => draftId != null;
}

/// Wraps the Gemini call with schema mapping and lossless fallback.
class IngestionOrchestrator {
  IngestionOrchestrator({
    required this.client,
    required this.db,
    required this.model,
    this.ownerId = 'local-practitioner',
  });

  final InteractionsApiClient client;
  final AppDatabase db;
  final String model;
  final String ownerId;

  Future<IngestionOutcome> ingestText(
    String rawText, {
    String payloadType = 'text',
    String? filePath,
    String? activeCensusJson,
  }) async {
    try {
      final result = await client.create(
        model: model,
        prompt: buildIngestionPrompt(
          rawText,
          activeCensusJson: activeCensusJson,
        ),
        jsonSchema: kFlatIngestionJsonSchema,
      );
      final mapping = await ClinicalIngestionMapper(db, ownerId: ownerId)
          .persistRaw(
            result.text,
            sourceText: rawText,
            censusIds: censusPatientIds(activeCensusJson),
          );
      debugPrint('[Ingestion] mapped: $mapping');
      return IngestionOutcome.structured(mapping);
    } catch (error) {
      debugPrint('[Ingestion] extraction failed, saving draft: $error');
      final id = const Uuid().v4();
      await IngestionInboxDao(db).saveDraft(
        id: id,
        payloadType: payloadType,
        rawInput: rawText,
        filePath: filePath,
        message: kDraftSavedMessage,
      );
      return IngestionOutcome.draft(id);
    }
  }

  /// Structures [rawText] without writing to the database so a clinician can
  /// verify it first. Throws when extraction fails.
  Future<Map<String, dynamic>> extractText(
    String rawText, {
    String? activeCensusJson,
  }) async {
    final result = await client.create(
      model: model,
      prompt: buildIngestionPrompt(rawText, activeCensusJson: activeCensusJson),
      jsonSchema: kFlatIngestionJsonSchema,
    );
    return ClinicalIngestionMapper.parse(result.text);
  }

  /// "Deep Scan": skips on-device OCR text and reads the photo itself. The
  /// image is resized to 1536 px and re-encoded as JPEG (80%) first.
  Future<Map<String, dynamic>> deepScanImage(
    File image, {
    String? activeCensusJson,
  }) async {
    final bytes = await optimizeImageFile(image);
    final result = await client.create(
      model: model,
      prompt: buildIngestionPrompt(
        '(The clinical document is the attached image. Read it directly.)',
        activeCensusJson: activeCensusJson,
      ),
      imageBytes: bytes,
      imageMimeType: 'image/jpeg',
      jsonSchema: kFlatIngestionJsonSchema,
    );
    return ClinicalIngestionMapper.parse(result.text);
  }

  /// Persists reviewed (possibly edited) data.
  Future<IngestionMappingResult> commitReviewed(
    Map<String, dynamic> json, {
    String? sourceText,
    String? activeCensusJson,
  }) => ClinicalIngestionMapper(db, ownerId: ownerId).persist(
    json,
    sourceText: sourceText,
    censusIds: censusPatientIds(activeCensusJson),
  );

  /// Images and PDFs: on-device OCR first, then the text pipeline. Any OCR
  /// failure still preserves the file path as a draft.
  Future<IngestionOutcome> ingestFile(
    File file, {
    required Future<String> Function(File file) recognizeText,
    String? payloadType,
    String? activeCensusJson,
  }) async {
    final type =
        payloadType ??
        (file.path.toLowerCase().endsWith('.pdf') ? 'pdf' : 'image');
    final String text;
    try {
      text = await recognizeText(file);
      if (text.trim().isEmpty) throw const FormatException('No text found.');
    } catch (error) {
      debugPrint('[Ingestion] OCR failed, saving draft: $error');
      final id = const Uuid().v4();
      await IngestionInboxDao(db).saveDraft(
        id: id,
        payloadType: type,
        rawInput: '',
        filePath: file.path,
        message: kDraftSavedMessage,
      );
      return IngestionOutcome.draft(id);
    }
    return ingestText(
      text,
      payloadType: type,
      filePath: file.path,
      activeCensusJson: activeCensusJson,
    );
  }
}
