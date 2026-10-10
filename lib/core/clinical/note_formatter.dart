import '../database/local_database.dart';

/// Pure, dependency-free formatting of clinical notes into plain text that
/// pastes cleanly into a legacy hospital record system.
class ClinicalNoteFormatter {
  const ClinicalNoteFormatter._();

  static String _clean(String? v) => (v ?? '').trim();

  static String vitalsLine(ClinicalEncounter? e) {
    if (e == null) return '';
    final parts = <String>[
      if (e.sbp != null && e.dbp != null) 'BP ${e.sbp}/${e.dbp} mmHg',
      if (e.pulse != null) 'HR ${e.pulse}/min',
      if (e.respiratoryRate != null) 'RR ${e.respiratoryRate}/min',
      if (e.spo2 != null) 'SpO2 ${e.spo2}%',
      if (e.temperatureC != null)
        'Temp ${e.temperatureC!.toStringAsFixed(1)} °C',
    ];
    return parts.join(', ');
  }

  /// Formats free text as a SOAP progress note. Empty sections are omitted.
  static String progressNote({
    required String patientName,
    String? location,
    required DateTime when,
    String subjective = '',
    String objective = '',
    String assessment = '',
    String plan = '',
    String vitals = '',
  }) {
    final b = StringBuffer()
      ..writeln('PROGRESS NOTE')
      ..writeln(
        [
          patientName,
          if (_clean(location).isNotEmpty) location!.trim(),
        ].join(' | '),
      )
      ..writeln(_stamp(when));
    void section(String title, String body) {
      final text = body.trim();
      if (text.isEmpty) return;
      b
        ..writeln()
        ..writeln('$title:')
        ..writeln(text);
    }

    section('S', subjective);
    section(
      'O',
      [vitals, objective].where((s) => s.trim().isNotEmpty).join('\n'),
    );
    section('A', assessment);
    section('P', plan);
    return b.toString().trimRight();
  }

  static String _stamp(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.day)}/${two(t.month)}/${t.year} '
        '${two(t.hour)}:${two(t.minute)}';
  }

  /// One-line recap of a past encounter for the "at a glance" history.
  static String encounterDigest(ClinicalEncounter e) {
    final bits = <String>[
      if (_clean(e.chiefComplaints).isNotEmpty) _clean(e.chiefComplaints),
      if (_clean(e.clinicalDiagnosis).isNotEmpty)
        'Dx: ${_clean(e.clinicalDiagnosis)}',
      if (_clean(e.clinicalAssessment).isNotEmpty) _clean(e.clinicalAssessment),
      if (_clean(e.consultantAdvice).isNotEmpty)
        'Plan: ${_clean(e.consultantAdvice)}',
    ];
    return bits.join(' · ');
  }
}

/// One editable field on a note template.
class TemplateField {
  const TemplateField(this.key, this.label, {this.hint = '', this.lines = 2});
  final String key;
  final String label;
  final String hint;
  final int lines;
}

/// A predefined, fully editable note layout.
class NoteTemplate {
  const NoteTemplate({
    required this.id,
    required this.title,
    required this.fields,
  });

  final String id;
  final String title;
  final List<TemplateField> fields;

  /// Values the template can fill from known patient data.
  static Map<String, String> prefill({
    required Patient patient,
    DateTime? now,
    String? diagnosis,
    String? allergies,
  }) {
    final t = now ?? DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final dob = patient.dateOfBirth;
    final age = dob == null
        ? ''
        : '${t.year - dob.year - ((t.month < dob.month || (t.month == dob.month && t.day < dob.day)) ? 1 : 0)}';
    return {
      'patient': [
        patient.fullName,
        if (age.isNotEmpty) '$age y',
        if (patient.gender != null) patient.gender!,
      ].join(', '),
      'date': '${two(t.day)}/${two(t.month)}/${t.year}',
      if ((diagnosis ?? '').trim().isNotEmpty) 'diagnosis': diagnosis!.trim(),
      if ((allergies ?? '').trim().isNotEmpty) 'allergies': allergies!.trim(),
    };
  }

  String render(Map<String, String> values) {
    final b = StringBuffer()..writeln(title.toUpperCase());
    for (final f in fields) {
      final v = (values[f.key] ?? '').trim();
      if (v.isEmpty) continue;
      b
        ..writeln()
        ..writeln('${f.label}:')
        ..writeln(v);
    }
    return b.toString().trimRight();
  }

  static const procedure = NoteTemplate(
    id: 'procedure',
    title: 'Procedure Note',
    fields: [
      TemplateField('patient', 'Patient', lines: 1),
      TemplateField('date', 'Date', lines: 1),
      TemplateField('diagnosis', 'Indication / diagnosis'),
      TemplateField('allergies', 'Allergies', lines: 1),
      TemplateField('consent', 'Consent', hint: 'Informed consent obtained'),
      TemplateField('procedure', 'Procedure performed'),
      TemplateField('operator', 'Operator / assistants', lines: 1),
      TemplateField('anaesthesia', 'Anaesthesia / sedation', lines: 1),
      TemplateField('technique', 'Technique', lines: 4),
      TemplateField('findings', 'Findings', lines: 3),
      TemplateField('complications', 'Complications', hint: 'None'),
      TemplateField('plan', 'Post-procedure plan', lines: 3),
    ],
  );

  static const operation = NoteTemplate(
    id: 'ot',
    title: 'Operation Theatre Note',
    fields: [
      TemplateField('patient', 'Patient', lines: 1),
      TemplateField('date', 'Date', lines: 1),
      TemplateField('preop', 'Pre-operative diagnosis'),
      TemplateField('postop', 'Post-operative diagnosis'),
      TemplateField('allergies', 'Allergies', lines: 1),
      TemplateField('surgery', 'Operation performed'),
      TemplateField('surgeons', 'Surgeon / assistants / anaesthetist'),
      TemplateField('anaesthesia', 'Anaesthesia', lines: 1),
      TemplateField('position', 'Position & preparation'),
      TemplateField('steps', 'Operative steps', lines: 6),
      TemplateField('findings', 'Intra-operative findings', lines: 3),
      TemplateField('bloodloss', 'Blood loss / fluids', lines: 1),
      TemplateField('specimen', 'Specimen / implants', lines: 1),
      TemplateField(
        'counts',
        'Counts',
        hint: 'Sponge and instrument counts correct',
      ),
      TemplateField('complications', 'Complications', hint: 'None'),
      TemplateField('postplan', 'Post-operative orders', lines: 3),
    ],
  );

  static const all = [procedure, operation];
}
