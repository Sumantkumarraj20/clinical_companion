import 'dart:convert';

/// Pretty-printed template of the exact JSON the database mapper accepts.
/// Every field is nullable/optional; empty lists are valid.
String buildIngestionSchemaTemplate() =>
    const JsonEncoder.withIndent('  ').convert(ingestionSchemaTemplate);

const Map<String, dynamic> ingestionSchemaTemplate = {
  'patient_id': null,
  'patient_name': 'string',
  'ward_name': null,
  'bed_number': null,
  'age': 0,
  'gender': 'Male | Female | Other | null',
  'document_type':
      'clinical_note | lab_report | surgical_note | discharge_summary | '
      'prescription | imaging_report | other | null',
  'document_date': 'YYYY-MM-DD | null',
  'document_time': 'HH:MM | null',
  'vitals': {
    'sbp': null,
    'dbp': null,
    'pulse': null,
    'temperature_c': null,
    'respiratory_rate': null,
    'spo2': null,
  },
  'chief_complaints': ['string'],
  'history': null,
  'diagnosis': ['string'],
  'medications': [
    {
      'name': 'string',
      'dose': null,
      'route': null,
      'frequency': null,
      'duration': null,
    },
  ],
  'lab_results': [
    {
      'test_name': 'string',
      'value': 'string',
      'unit': null,
      'reference_range': null,
      'is_abnormal': false,
    },
  ],
};
