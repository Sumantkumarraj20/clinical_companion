import 'dart:convert';

import 'package:drift/drift.dart';

import '../ai/document_ai_service.dart' show sanitizeStructuredJsonText;
import '../database/local_database.dart';

/// Gentle, non-technical message shown when extraction falls back to a draft.
const String kDraftSavedMessage =
    'Saved as draft. We will organize this data for you shortly.';

/// Flat JSON schema the model must follow. Keys map 1:1 onto local tables.
const Map<String, dynamic> kFlatIngestionJsonSchema = {
  'type': 'object',
  'properties': {
    'patient_id': {'type': 'string'},
    'patient_name': {'type': 'string'},
    'ward_name': {'type': 'string'},
    'bed_number': {'type': 'string'},
    'age': {'type': 'integer'},
    'gender': {'type': 'string'},
    'vitals': {
      'type': 'object',
      'properties': {
        'sbp': {'type': 'integer'},
        'dbp': {'type': 'integer'},
        'pulse': {'type': 'integer'},
        'temperature_c': {'type': 'number'},
        'respiratory_rate': {'type': 'integer'},
        'spo2': {'type': 'integer'},
      },
    },
    'chief_complaints': {
      'type': 'array',
      'items': {'type': 'string'},
    },
    'history': {'type': 'string'},
    'document_type': {
      'type': 'string',
      'description':
          'One of: clinical_note, lab_report, surgical_note, '
          'discharge_summary, prescription, imaging_report, other.',
      'nullable': true,
    },
    'document_date': {'type': 'string', 'nullable': true},
    'document_time': {'type': 'string', 'nullable': true},
    'lab_results': {
      'type': 'array',
      'items': {
        'type': 'object',
        'properties': {
          'test_name': {'type': 'string'},
          'value': {'type': 'string'},
          'unit': {'type': 'string'},
          'reference_range': {'type': 'string'},
          'is_abnormal': {'type': 'boolean'},
        },
        'required': ['test_name', 'value'],
      },
    },
    'diagnosis': {
      'type': 'array',
      'items': {'type': 'string'},
    },
    'medications': {
      'type': 'array',
      'items': {
        'type': 'object',
        'properties': {
          'name': {'type': 'string'},
          'dose': {'type': 'string'},
          'route': {'type': 'string'},
          'frequency': {'type': 'string'},
          'duration': {'type': 'string'},
        },
        'required': ['name'],
      },
    },
  },
  'required': [
    'patient_name',
    'age',
    'vitals',
    'chief_complaints',
    'history',
    'diagnosis',
    'medications',
    'lab_results',
  ],
};

/// System prompt pairing with [kFlatIngestionJsonSchema].
const String kFlatIngestionSystemPrompt = '''
You are a clinical data structuring engine. Convert the clinical text below into ONE JSON object and nothing else.
Use EXACTLY these keys: patient_name (string), age (integer years), gender ('Male'/'Female'/'Other' or null), vitals ({sbp, dbp, pulse, temperature_c, respiratory_rate, spo2} numbers), chief_complaints (array of strings), history (string), diagnosis (array of strings), medications (array of {name, dose, route, frequency, duration}).
Also include patient_id, ward_name and bed_number (strings or null).
DOCUMENT TYPE: classify document_type as exactly one of clinical_note, lab_report, surgical_note, discharge_summary, prescription, imaging_report, or other, based on the document's content and layout (e.g. a grid of numeric results with reference ranges is lab_report; operative findings are surgical_note). If it cannot be determined, return null.
TEMPORAL FIDELITY: document_date (YYYY-MM-DD) and document_time (HH:MM, 24-hour) — you MUST extract the exact date and time written or printed on the document. If and ONLY if no date is present, return null. Do not hallucinate the current time.
LAB REPORTS: put every laboratory or investigation result in lab_results as an array of {test_name, value, unit, reference_range, is_abnormal (boolean)}. Use [] when there are none.
Use null for unknown scalars and [] for unknown lists. Never invent data. Do not wrap the JSON in markdown fences or add prose.
''';

/// Appends the active ward census so bed references resolve to real patients.
String buildIngestionPrompt(String rawText, {String? activeCensusJson}) {
  final census = activeCensusJson?.trim();
  final censusBlock = census == null || census.isEmpty
      ? ''
      : '\nACTIVE WARD CENSUS (currently admitted patients):\n$census\n'
            'If the text refers to a bed or ward (e.g. "Bed 827") or a patient '
            'listed in the census, set patient_id to that census entry\'s '
            'patient_id and use its exact name. Only use a patient_id that '
            'appears in the census; otherwise set patient_id to null.\n';
  return '$kFlatIngestionSystemPrompt$censusBlock\nCLINICAL TEXT:\n$rawText';
}

/// Extracts the patient ids present in a census JSON array.
Set<String> censusPatientIds(String? activeCensusJson) {
  if (activeCensusJson == null || activeCensusJson.trim().isEmpty) {
    return const {};
  }
  try {
    final decoded = jsonDecode(activeCensusJson);
    if (decoded is! List) return const {};
    return {
      for (final entry in decoded)
        if (entry is Map && entry['patient_id'] is String)
          entry['patient_id'] as String,
    };
  } catch (_) {
    return const {};
  }
}

/// Counts of rows written by one mapping run.
class IngestionMappingResult {
  const IngestionMappingResult({
    required this.patientId,
    required this.encounterId,
    this.matchedExistingPatient = false,
    required this.problemCount,
    required this.medicationCount,
    this.labCount = 0,
  });

  final String patientId;
  final String encounterId;
  final bool matchedExistingPatient;
  final int problemCount;
  final int medicationCount;
  final int labCount;

  @override
  String toString() =>
      'patient=$patientId${matchedExistingPatient ? ' (existing)' : ''} '
      'encounter=$encounterId problems=$problemCount '
      'medications=$medicationCount labs=$labCount';
}

/// Sanitizes model output and persists it into Drift tables.
class ClinicalIngestionMapper {
  ClinicalIngestionMapper(this.db, {this.ownerId = 'local-practitioner'});

  final AppDatabase db;
  final String ownerId;

  /// Strips markdown fences/prose and decodes into a map. Throws
  /// [FormatException] when no JSON object can be recovered.
  static Map<String, dynamic> parse(String raw) {
    final decoded = jsonDecode(sanitizeStructuredJsonText(raw));
    if (decoded is! Map) throw const FormatException('Expected a JSON object.');
    return Map<String, dynamic>.from(decoded);
  }

  static String? _str(Object? v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty || s.toLowerCase() == 'null' ? null : s;
  }

  static num? _num(Object? v) {
    if (v is num) return v;
    final s = _str(v);
    if (s == null) return null;
    final m = RegExp(r'-?\d+(?:\.\d+)?').firstMatch(s);
    return m == null ? null : num.tryParse(m.group(0)!);
  }

  /// Combines `document_date` (YYYY-MM-DD or dd/mm/yyyy) and optional
  /// `document_time` (HH:MM) into a local DateTime; null when no date.
  static DateTime? parseDocumentMoment(Object? date, Object? time) {
    final d = _str(date);
    if (d == null) return null;
    DateTime? day;
    final iso = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})').firstMatch(d);
    if (iso != null) {
      day = DateTime(
        int.parse(iso.group(1)!),
        int.parse(iso.group(2)!),
        int.parse(iso.group(3)!),
      );
    } else {
      final dmy = RegExp(
        r'^(\d{1,2})[/.-](\d{1,2})[/.-](\d{2,4})',
      ).firstMatch(d);
      if (dmy != null) {
        var y = int.parse(dmy.group(3)!);
        if (y < 100) y += 2000;
        day = DateTime(y, int.parse(dmy.group(2)!), int.parse(dmy.group(1)!));
      }
    }
    if (day == null ||
        day.year < 1900 ||
        day.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      return null;
    }
    final t = _str(time);
    final m = t == null ? null : RegExp(r'(\d{1,2}):(\d{2})').firstMatch(t);
    if (m == null) return day;
    final h = int.parse(m.group(1)!);
    final min = int.parse(m.group(2)!);
    if (h > 23 || min > 59) return day;
    return DateTime(day.year, day.month, day.day, h, min);
  }

  static int? _int(Object? v) => _num(v)?.round();

  static List<String> _strings(Object? v) {
    if (v is List) return v.map(_str).whereType<String>().toList();
    final s = _str(v);
    return s == null ? const [] : [s];
  }

  static String _normName(String name) => name
      .toLowerCase()
      .replaceAll(
        RegExp(r'\b(mr|mrs|ms|miss|master|baby|dr|smt|shri)\b\.?'),
        ' ',
      )
      .replaceAll(RegExp(r'[^a-z\s]'), ' ')
      .split(RegExp(r'\s+'))
      .where((t) => t.isNotEmpty)
      .toList()
      .join(' ');

  static String? _normGender(String? g) {
    if (g == null) return null;
    final l = g.toLowerCase();
    if (l.startsWith('m')) return 'male';
    if (l.startsWith('f')) return 'female';
    return 'other';
  }

  /// Finds an existing patient with the same normalized name, compatible
  /// gender (when both known) and age within one year (when both known).
  /// Returns null for unnamed patients so they are never merged blindly.
  Future<Patient?> _findExisting(String? name, int? age, String? gender) async {
    if (name == null) return null;
    final wanted = _normName(name);
    if (wanted.isEmpty) return null;
    final now = DateTime.now();
    final rows = await (db.select(
      db.patients,
    )..where((p) => p.ownerId.equals(ownerId))).get();
    Patient? best;
    var bestScore = -1;
    for (final p in rows) {
      if (_normName(p.fullName) != wanted) continue;
      final pg = _normGender(p.gender);
      if (gender != null && pg != null && gender != pg) continue;
      var score = 0;
      if (age != null && p.dateOfBirth != null) {
        final dob = p.dateOfBirth!;
        var pAge = now.year - dob.year;
        if (now.month < dob.month ||
            (now.month == dob.month && now.day < dob.day)) {
          pAge--;
        }
        if ((pAge - age).abs() > 1) continue;
        score += 2;
      }
      if (gender != null && pg == gender) score += 1;
      if (score > bestScore) {
        best = p;
        bestScore = score;
      }
    }
    return best;
  }

  /// Parses [raw] and writes patient, encounter, problems and prescriptions
  /// atomically. Individual malformed fields fall back to null/empty.
  Future<IngestionMappingResult> persistRaw(
    String raw, {
    String? sourceText,
    Set<String> censusIds = const {},
  }) => persist(parse(raw), sourceText: sourceText, censusIds: censusIds);

  Future<IngestionMappingResult> persist(
    Map<String, dynamic> json, {
    String? sourceText,
    Set<String> censusIds = const {},
  }) {
    final age = _int(json['age']);
    final genderRaw = _str(json['gender']);
    final gender = _normGender(genderRaw);
    final vitals = json['vitals'] is Map
        ? Map<String, dynamic>.from(json['vitals'] as Map)
        : const <String, dynamic>{};
    final complaints = _strings(json['chief_complaints']);
    final diagnoses = _strings(json['diagnosis']);
    final meds = json['medications'] is List
        ? (json['medications'] as List).whereType<Map>().toList()
        : const <Map>[];
    final labs = json['lab_results'] is List
        ? (json['lab_results'] as List).whereType<Map>().toList()
        : const <Map>[];
    final now = DateTime.now();
    final docMoment = parseDocumentMoment(
      json['document_date'],
      json['document_time'],
    );

    return db.transaction(() async {
      final claimedId = _str(json['patient_id']);
      Patient? existing;
      if (claimedId != null && censusIds.contains(claimedId)) {
        existing = await (db.select(
          db.patients,
        )..where((p) => p.id.equals(claimedId))).getSingleOrNull();
      }
      existing ??= await _findExisting(_str(json['patient_name']), age, gender);
      final patient =
          existing ??
          await db
              .into(db.patients)
              .insertReturning(
                PatientsCompanion.insert(
                  ownerId: ownerId,
                  fullName: _str(json['patient_name']) ?? 'Unknown patient',
                  gender: Value(
                    gender == null
                        ? null
                        : '${gender[0].toUpperCase()}${gender.substring(1)}',
                  ),
                  dateOfBirth: Value(
                    age == null || age < 0 || age > 130
                        ? null
                        : DateTime(now.year - age, now.month, now.day),
                  ),
                ),
              );
      final encounter = await db
          .into(db.clinicalEncounters)
          .insertReturning(
            ClinicalEncountersCompanion.insert(
              ownerId: ownerId,
              patientId: patient.id,
              clinicalDiagnosis: Value(
                diagnoses.isEmpty ? null : diagnoses.join('; '),
              ),
              sbp: Value(_int(vitals['sbp'])),
              dbp: Value(_int(vitals['dbp'])),
              pulse: Value(_int(vitals['pulse'])),
              temperatureC: Value(_num(vitals['temperature_c'])?.toDouble()),
              respiratoryRate: Value(_int(vitals['respiratory_rate'])),
              spo2: Value(_int(vitals['spo2'])),
              chiefComplaints: Value(
                complaints.isEmpty ? null : complaints.join('; '),
              ),
              wardName: Value(_str(json['ward_name'])),
              bedNumber: Value(_str(json['bed_number'])),
              historyOfPresentIllness: Value(_str(json['history'])),
              aiSummary: Value(sourceText),
              occurredAt: docMoment == null
                  ? const Value.absent()
                  : Value(docMoment),
            ),
          );
      for (final name in diagnoses) {
        await db
            .into(db.patientProblems)
            .insert(
              PatientProblemsCompanion.insert(
                patientId: patient.id,
                problemName: name,
                initialEncounterId: Value(encounter.id),
              ),
            );
      }
      var medCount = 0;
      for (final med in meds) {
        final name = _str(med['name'] ?? med['drug_name']);
        if (name == null) continue;
        await db
            .into(db.prescriptionOrders)
            .insert(
              PrescriptionOrdersCompanion.insert(
                patientId: patient.id,
                encounterId: encounter.id,
                drugName: name,
                doseStrength: Value(_str(med['dose'])),
                route: Value(_str(med['route'])),
                frequency: Value(_str(med['frequency'])),
                duration: Value(_str(med['duration'])),
              ),
            );
        medCount++;
      }
      var labCount = 0;
      for (final lab in labs) {
        final name = _str(lab['test_name']);
        if (name == null) continue;
        final valueText = _str(lab['value']);
        final order = await db
            .into(db.investigationOrders)
            .insertReturning(
              InvestigationOrdersCompanion.insert(
                patientId: patient.id,
                encounterId: Value(encounter.id),
                testName: name,
                status: const Value('result_received'),
                orderedAt: Value(docMoment ?? now),
                resultReceivedAt: Value(docMoment ?? now),
              ),
            );
        await db
            .into(db.investigationResults)
            .insert(
              InvestigationResultsCompanion.insert(
                patientId: patient.id,
                testName: name,
                orderId: Value(order.id),
                numericValue: Value(_num(valueText)?.toDouble()),
                textValue: Value(valueText),
                unit: Value(_str(lab['unit'])),
                referenceRange: Value(_str(lab['reference_range'])),
                isAbnormal: Value(lab['is_abnormal'] == true),
                sourceAuthority: const Value('lab_report'),
                resultDate: Value(docMoment ?? now),
              ),
            );
        labCount++;
      }
      return IngestionMappingResult(
        patientId: patient.id,
        encounterId: encounter.id,
        matchedExistingPatient: existing != null,
        problemCount: diagnoses.length,
        medicationCount: medCount,
        labCount: labCount,
      );
    });
  }
}
