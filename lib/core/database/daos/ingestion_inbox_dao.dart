import 'dart:convert';

import 'package:drift/drift.dart';

import '../../models/ai_extraction_result.dart';
import '../local_database.dart';

part 'ingestion_inbox_dao.g.dart';

@DriftAccessor(tables: [IngestionInboxes])
class IngestionInboxDao extends DatabaseAccessor<AppDatabase>
    with _$IngestionInboxDaoMixin {
  IngestionInboxDao(super.db);

  Stream<List<IngestionInboxItem>> watchOpenItems() =>
      (select(ingestionInboxes)
            ..where((item) => item.status.isNotValue('saved'))
            ..orderBy([(item) => OrderingTerm.desc(item.createdAt)]))
          .watch();

  Future<List<IngestionInboxItem>> getOpenItems() =>
      (select(ingestionInboxes)
            ..where((item) => item.status.isNotValue('saved'))
            ..orderBy([(item) => OrderingTerm.asc(item.createdAt)]))
          .get();

  Future<void> saveProcessing({
    required String id,
    required String payloadType,
    required String rawInput,
    String? filePath,
  }) async {
    await into(ingestionInboxes).insertOnConflictUpdate(
      IngestionInboxesCompanion.insert(
        id: id,
        payloadType: payloadType,
        rawInput: Value(rawInput),
        filePath: Value(filePath),
        status: const Value('processing'),
        extractedJson: const Value(null),
        errorMessage: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markReady({
    required String id,
    required AiExtractionResult result,
    required String rawText,
  }) async {
    final updated =
        await (update(
          ingestionInboxes,
        )..where((item) => item.id.equals(id))).write(
          IngestionInboxesCompanion(
            status: const Value('ready_for_review'),
            rawInput: Value(rawText),
            extractedJson: Value(jsonEncode(result.toJson())),
            errorMessage: const Value(null),
            updatedAt: Value(DateTime.now()),
          ),
        );
    if (updated != 1) {
      throw StateError('The clinical ingestion inbox item $id was not found.');
    }
  }

  Future<void> markError(String id, String message) async {
    final updated =
        await (update(
          ingestionInboxes,
        )..where((item) => item.id.equals(id))).write(
          IngestionInboxesCompanion(
            status: const Value('error'),
            errorMessage: Value(message),
            updatedAt: Value(DateTime.now()),
          ),
        );
    if (updated != 1) {
      throw StateError('The clinical ingestion inbox item $id was not found.');
    }
  }
}
