import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../models/ai_extraction_result.dart';
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
      final exact = await (_database.select(_database.patients)
            ..where(
              (patient) =>
                  patient.ownerId.equals(ownerId) &
                  patient.hospitalRegNo.equals(registrationNumber),
            ))
          .getSingleOrNull();
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
                patient.sex.equals(gender),
          ))
        .get();
    for (final candidate in candidates) {
      final candidateAge = _ageOn(candidate.dateOfBirth, DateTime.now());
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
                  patient.sex.equals(gender),
            ))
          .get();
      for (final candidate in candidates) {
        final age = _ageOn(candidate.dateOfBirth, DateTime.now());
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
    await _database.into(_database.patients).insert(
      PatientsCompanion.insert(
        id: Value(id),
        ownerId: ownerId,
        hospitalRegNo: registrationNumber?.isNotEmpty == true
            ? registrationNumber!
            : generatedRegistration,
        fullName: name?.isNotEmpty == true ? name! : 'Unknown patient',
        dateOfBirth: Value(_dateOfBirthFromAge(extractedData.age)),
        sex: Value(gender?.isNotEmpty == true ? gender : null),
      ),
    );
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
            'hospital_reg_no': registrationNumber?.isNotEmpty == true
                ? registrationNumber
                : generatedRegistration,
            'full_name': name?.isNotEmpty == true ? name : 'Unknown patient',
            'sex': gender?.isNotEmpty == true ? gender : null,
            'date_of_birth': _dateOfBirthFromAge(extractedData.age)
                ?.toIso8601String(),
          }),
        ),
        clientUpdatedAt: Value(now),
      ),
    );
    return id;
  }

  int? _ageOn(DateTime? dateOfBirth, DateTime date) {
    if (dateOfBirth == null) return null;
    var age = date.year - dateOfBirth.year;
    if (date.month < dateOfBirth.month ||
        (date.month == dateOfBirth.month && date.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  DateTime? _dateOfBirthFromAge(int? age) {
    if (age == null || age < 0) return null;
    final today = DateTime.now();
    return DateTime(today.year - age, today.month, today.day);
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
}