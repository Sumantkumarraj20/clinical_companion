import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ai/document_ai_service.dart';
import '../database/daos/clinical_dao.dart';
import '../ai/interactions_api_client.dart';
import '../providers/app_providers.dart';
import '../ui/raw_error.dart';
import 'ingestion_orchestrator.dart';

const String kIngestionSuccessMessage =
    'Clinical records updated successfully.';

/// Serialises the active inpatient census (id, name, DOB, gender, bed, ward)
/// for the extraction prompt. Best effort: returns null when unavailable.
Future<String?> buildActiveCensusJson(ClinicalDao dao) async {
  try {
    final rows = await dao.watchActiveWardRounds().first;
    if (rows.isEmpty) return null;
    return jsonEncode([
      for (final r in rows)
        <String, Object?>{
          'patient_id': r.patient.id,
          'name': r.patient.fullName,
          'date_of_birth': r.patient.dateOfBirth
              ?.toIso8601String()
              .split('T')
              .first,
          'gender': r.patient.gender,
          'bed': r.bedNumber,
          'ward': r.wardName,
        },
    ]);
  } catch (error, st) {
    debugPrint('[Ingestion] Active census unavailable: $error\n$st');
    return null;
  }
}

final ingestionOrchestratorProvider = Provider<IngestionOrchestrator>((ref) {
  final apiKey = ref.watch(documentAiServiceProvider).apiKey;
  return IngestionOrchestrator(
    client: InteractionsApiClient(apiKey: apiKey),
    db: ref.watch(appDatabaseProvider),
    model: DocumentAiService.defaultModel,
  );
});

/// Fire-and-forget submission facade for every capture entry point.
/// [state] is the number of submissions still processing.
class LiveIngestionController extends Notifier<int> {
  @override
  int build() => 0;

  Future<IngestionOutcome> submitText(
    String text, {
    ScaffoldMessengerState? messenger,
    String payloadType = 'text',
  }) => _run(() async {
    final census = await buildActiveCensusJson(ref.read(clinicalDaoProvider));
    return ref
        .read(ingestionOrchestratorProvider)
        .ingestText(text, payloadType: payloadType, activeCensusJson: census);
  }, messenger);

  Future<IngestionOutcome> submitFile(
    File file, {
    ScaffoldMessengerState? messenger,
  }) => _run(() async {
    final census = await buildActiveCensusJson(ref.read(clinicalDaoProvider));
    return ref
        .read(ingestionOrchestratorProvider)
        .ingestFile(
          file,
          recognizeText: ref.read(extractionPipelineProvider).recognizeRawText,
          activeCensusJson: census,
        );
  }, messenger);

  /// Re-submits a saved draft / failed inbox item through the orchestrator.
  /// The old row is removed only once the new attempt has been persisted
  /// (as records or as a fresh draft), so the input is never lost.
  Future<IngestionOutcome?> retryItem(
    String inboxId, {
    ScaffoldMessengerState? messenger,
  }) async {
    final dao = ref.read(ingestionInboxDaoProvider);
    final item = (await dao.getOpenItems())
        .where((entry) => entry.id == inboxId)
        .firstOrNull;
    if (item == null) return null;
    final raw = item.rawInput;
    final path = item.filePath;
    final IngestionOutcome outcome;
    if (raw.trim().isNotEmpty) {
      outcome = await submitText(
        raw,
        messenger: messenger,
        payloadType: item.payloadType == 'audio' ? 'audio' : 'text',
      );
    } else if (path != null) {
      outcome = await submitFile(File(path), messenger: messenger);
    } else {
      return null;
    }
    await dao.deleteItem(inboxId);
    return outcome;
  }

  Future<IngestionOutcome> _run(
    Future<IngestionOutcome> Function() job,
    ScaffoldMessengerState? messenger,
  ) async {
    state = state + 1;
    try {
      final outcome = await job();
      if (outcome.isError) {
        showRawErrorSnackBar(messenger, outcome.userMessage!);
      } else {
        messenger?.showSnackBar(
          SnackBar(
            content: Text(outcome.userMessage ?? kIngestionSuccessMessage),
          ),
        );
      }
      return outcome;
    } catch (error, st) {
      final raw = describeRawError(error, st);
      debugPrint('[Ingestion] could not persist input: $raw');
      showRawErrorSnackBar(messenger, raw);
      rethrow;
    } finally {
      state = state - 1;
    }
  }
}

final liveIngestionProvider = NotifierProvider<LiveIngestionController, int>(
  LiveIngestionController.new,
);
