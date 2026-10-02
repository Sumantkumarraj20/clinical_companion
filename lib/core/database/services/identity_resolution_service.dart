import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../models/ai_extraction_result.dart';
import '../../utils/datetime_utils.dart';
import '../local/local_database.dart';

class IdentityResolutionService {
  IdentityResolutionService({required AppDatabase database, required this.ownerId})
    : _database = database;

  final AppDatabase _database;
  final String ownerId;
  final _uuid = const Uuid();

  Future<Patient?> findExistingPatient(PatientIdentity extractedData) async {
    final registrationNumber = extractedData.hospitalRegNo?.trim();
    if (registrationNumber != null && registrationNumber.isNotEmpty) {
      final exactQuery = _database.select(_database.patients).join([
        innerJoin(
          _database.patientHospitalIdentifiers,
          _database.patientHospitalIdentifiers.patientId.equalsExp(
            _database.patients.id,
          ),
        ),
      ])..where(
          _database.patients.ownerId.equals(ownerId) &
              _database.patientHospitalIdentifiers.mrn.equals(
                registrationNumber,
              ),
        );
      final exact = (await exactQuery.getSingleOrNull())?.readTable(
        _database.patients,
      );
      if (exact != null) return exact;
    }
    final name = extractedData.name?.trim();
    final gender = extractedData.gender?.trim();
    final age = extractedData.age;
    if (name == null || name.isEmpty || gender == null || gender.isEmpty || age == null) {
      return null;
    }
    final candidates = await (_database.select(_database.patients)
          ..where(
            (patient) =>
                patient.ownerId.equals(ownerId) &
                patient.fullName.equals(name) &
                patient.gender.equals(gender),
          ))
        .get();
    for (final candidate in candidates) {
        final candidateAge =
          DateTimeUtils.ageOn(candidate.dateOfBirth, DateTime.now());
      if (candidateAge != null && (candidateAge - age).abs() <= 2) {
        return candidate;
      }
    }
    return null;
  }

  Future<String> resolvePatient(PatientIdentity extractedData) async {
    final existing = await findExistingPatient(extractedData);
    if (existing != null) return existing.id;

    final registrationNumber = extractedData.hospitalRegNo?.trim();
    final name = extractedData.name?.trim();
    final gender = extractedData.gender?.trim();
    if (name != null && name.isNotEmpty &&
        gender != null && gender.isNotEmpty && extractedData.age != null) {
      final candidates = await (_database.select(_database.patients)
            ..where(
              (patient) =>
                  patient.ownerId.equals(ownerId) &
                  patient.fullName.equals(name) &
                  patient.gender.equals(gender),
            ))
          .get();
      for (final candidate in candidates) {
        final age = DateTimeUtils.ageOn(candidate.dateOfBirth, DateTime.now());
        if (age != null && (age - extractedData.age!).abs() <= 2) {
          return candidate.id;
        }
      }
    }

    final id = _uuid.v4();
    final dateStamp = _formatDate(DateTime.now());
    final generatedRegistration =
        'AUTO-$dateStamp-${id.substring(0, 4).toUpperCase()}';
    final now = DateTime.now().toUtc();
    await _database.transaction(() async {
      await _database.into(_database.patients).insert(
        PatientsCompanion.insert(
        id: Value(id),
        ownerId: ownerId,
        fullName: name?.isNotEmpty == true ? name! : 'Unknown patient',
        gender: Value(gender?.isNotEmpty == true ? gender : null),
        dateOfBirth: Value(DateTimeUtils.dateOfBirthFromAge(extractedData.age)),
        ),
      );
      final hospital = await (_database.select(_database.hospitals)
            ..where((row) => row.isActive.equals(true))
            ..limit(1))
          .getSingleOrNull();
      final hospitalId = hospital?.id ?? _uuid.v4();
      if (hospital == null) {
        await _database.into(_database.hospitals).insert(
          HospitalsCompanion.insert(id: Value(hospitalId), name: 'Primary Hospital'),
        );
      }
      await _database.into(_database.patientHospitalIdentifiers).insert(
        PatientHospitalIdentifiersCompanion.insert(
          patientId: id,
          hospitalId: hospitalId,
          mrn: Value(
            registrationNumber?.isNotEmpty == true
                ? registrationNumber!
                : generatedRegistration,
          ),
          identifierType: const Value('MRN'),
          isPrimary: const Value(true),
        ),
      );
    });
    await _database.into(_database.offlineSyncQueue).insert(
      OfflineSyncQueueCompanion.insert(
        ownerId: ownerId,
        entityType: 'patients',
        entityId: id,
        operation: 'insert',
        payload: Value(
          jsonEncode({
            'id': id,
            'owner_id': ownerId,
            'mrn': registrationNumber?.isNotEmpty == true
                ? registrationNumber
                : generatedRegistration,
            // Legacy alias kept for older sync peers.
            'hospital_reg_no': registrationNumber?.isNotEmpty == true
                ? registrationNumber
                : generatedRegistration,
            'full_name': name?.isNotEmpty == true ? name : 'Unknown patient',
            'gender': gender?.isNotEmpty == true ? gender : null,
            'sex': gender?.isNotEmpty == true ? gender : null,
            'date_of_birth': DateTimeUtils.dateOfBirthFromAge(extractedData.age)
                ?.toIso8601String(),
          }),
        ),
        clientUpdatedAt: Value(now),
      ),
    );
    return id;
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
}