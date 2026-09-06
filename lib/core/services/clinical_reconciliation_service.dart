import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/local_database.dart';

class ClinicalObservationInput {
  const ClinicalObservationInput({
    required this.category,
    required this.code,
    required this.displayName,
    required this.recordedAt,
    this.numericValue,
    this.textValue,
    this.unit,
    this.referenceLow,
    this.referenceHigh,
    this.isAbnormal = false,
  });

  final String category;
  final String code;
  final String displayName;
  final DateTime recordedAt;
  final double? numericValue;
  final String? textValue;
  final String? unit;
  final double? referenceLow;
  final double? referenceHigh;
  final bool isAbnormal;
}

class ReconciledObservation {
  const ReconciledObservation({required this.observation, required this.wasDuplicate});
  final ClinicalObservation observation;
  final bool wasDuplicate;
}

class ClinicalReconciliationService {
  ClinicalReconciliationService(this.database);
  final AppDatabase database;
  static const _ids = Uuid();

  Future<List<ReconciledObservation>> reconcile({
    required String patientId,
    required String documentId,
    required Iterable<ClinicalObservationInput> observations,
  }) => database.transaction(() async {
    final result = <ReconciledObservation>[];
    for (final input in observations) {
      final lower = input.recordedAt.subtract(const Duration(hours: 6));
      final upper = input.recordedAt.add(const Duration(hours: 6));
      final candidates = await (database.select(database.clinicalObservations)
            ..where((row) => row.patientId.equals(patientId))
            ..where((row) => row.code.equals(input.code))
            ..where((row) => row.recordedAt.isBetweenValues(lower, upper)))
          .get();
      ClinicalObservation? duplicate;
      for (final candidate in candidates) {
        final sameNumeric = input.numericValue != null &&
            candidate.numericValue == input.numericValue;
        final sameText = input.numericValue == null &&
            candidate.textValue?.trim() == input.textValue?.trim();
        if (sameNumeric || sameText) {
          duplicate = candidate;
          break;
        }
      }
      if (duplicate != null) {
        final updated = duplicate.copyWith(
          corroborationNote: const Value('corroborated_in_progress_note'),
        );
        await database.update(database.clinicalObservations).replace(updated);
        result.add(ReconciledObservation(observation: updated, wasDuplicate: true));
        continue;
      }
      final id = _ids.v4();
      await database.into(database.clinicalObservations).insert(
        ClinicalObservationsCompanion.insert(
          id: id, patientId: patientId, documentId: documentId,
          observationCategory: input.category, code: input.code,
          displayName: input.displayName, numericValue: Value(input.numericValue),
          textValue: Value(input.textValue), unit: Value(input.unit),
          referenceLow: Value(input.referenceLow), referenceHigh: Value(input.referenceHigh),
          isAbnormal: Value(input.isAbnormal), recordedAt: input.recordedAt,
        ),
      );
      final inserted = await (database.select(database.clinicalObservations)
            ..where((row) => row.id.equals(id))).getSingle();
      result.add(ReconciledObservation(observation: inserted, wasDuplicate: false));
    }
    return result;
  });

  static String antibiogramJson(Iterable<Map<String, String?>> sensitivities) =>
      jsonEncode(sensitivities.toList(growable: false));
}