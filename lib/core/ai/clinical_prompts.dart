import 'package:google_generative_ai/google_generative_ai.dart';

enum ClinicalDocumentCategory {
  admissionNote,
  progressNote,
  dischargeSummary,
  opdSlip,
  treatmentChart,
  vitalsIoChart,
  labReport,
  microbiologyCulture,
  radiologyReport,
  surgicalOperativeNote,
}

extension ClinicalDocumentCategoryX on ClinicalDocumentCategory {
  String get wireName => switch (this) {
        ClinicalDocumentCategory.admissionNote => 'admission_note',
        ClinicalDocumentCategory.progressNote => 'progress_note',
        ClinicalDocumentCategory.dischargeSummary => 'discharge_summary',
        ClinicalDocumentCategory.opdSlip => 'opd_slip',
        ClinicalDocumentCategory.treatmentChart => 'treatment_chart',
        ClinicalDocumentCategory.vitalsIoChart => 'vitals_io_chart',
        ClinicalDocumentCategory.labReport => 'lab_report',
        ClinicalDocumentCategory.microbiologyCulture => 'microbiology_culture',
        ClinicalDocumentCategory.radiologyReport => 'radiology_report',
        ClinicalDocumentCategory.surgicalOperativeNote => 'surgical_operative_note',
      };

  String get label => switch (this) {
        ClinicalDocumentCategory.admissionNote => 'Admission Note',
        ClinicalDocumentCategory.progressNote => 'Progress Note',
        ClinicalDocumentCategory.dischargeSummary => 'Discharge Summary',
        ClinicalDocumentCategory.opdSlip => 'OPD Slip',
        ClinicalDocumentCategory.treatmentChart => 'Treatment Chart',
        ClinicalDocumentCategory.vitalsIoChart => 'Vitals / IO',
        ClinicalDocumentCategory.labReport => 'Lab Report',
        ClinicalDocumentCategory.microbiologyCulture => 'Culture',
        ClinicalDocumentCategory.radiologyReport => 'Radiology',
        ClinicalDocumentCategory.surgicalOperativeNote => 'Operative Note',
      };
}

class ClinicalPromptContracts {
  static String promptFor(ClinicalDocumentCategory category) => switch (category) {
        ClinicalDocumentCategory.vitalsIoChart => vitalsAndFluidDigestPrompt,
        ClinicalDocumentCategory.labReport => labPanelDigestPrompt,
        ClinicalDocumentCategory.microbiologyCulture => microbiologyDigestPrompt,
        _ => clinicalNarrativeDigestPrompt,
      };

  static Schema responseSchemaFor(ClinicalDocumentCategory category) =>
      switch (category) {
        ClinicalDocumentCategory.vitalsIoChart => vitalsAndFluidDigestSchema,
        ClinicalDocumentCategory.labReport => labPanelDigestSchema,
        ClinicalDocumentCategory.microbiologyCulture => microbiologyDigestSchema,
        _ => clinicalNarrativeDigestSchema,
      };

  static const vitalsAndFluidDigestPrompt = '''
Read this paper chart without inventing values. Extract every visible time-stamped
vital, continuous infusion, IV bolus, total intake, urine output, drain output,
and bowel habit. Preserve the source text in raw_ocr_transcript. Return null for
unreadable fields and use ISO-8601 timestamps when a date and time are visible.
''';

  static const labPanelDigestPrompt = '''
Read this laboratory report. Extract every analyte in CBC, KFT, LFT, ABG,
coagulation, or other panels, including value, unit, reference interval, and
whether the source flags it abnormal. Do not infer a reference interval.
Preserve the complete transcription in raw_ocr_transcript.
''';

  static const microbiologyDigestPrompt = '''
Read this microbiology report. Extract sample type, organism identity, colony
count, report time, and every antibiotic sensitivity. Keep interpretation as S,
I, or R when present and preserve MIC exactly. Preserve raw_ocr_transcript.
''';

  static const clinicalNarrativeDigestPrompt = '''
Read this clinical note and preserve all legible text. Parse it into SOAP-like
sections: chief complaints, HPI, past history, examination, bedside
investigations, and final plan. Do not invent absent clinical facts.
''';

  static final vitalsAndFluidDigestSchema = Schema.object(properties: {
    'raw_ocr_transcript': Schema.string(),
    'observations': Schema.array(items: Schema.object(properties: {
      'category': Schema.string(), 'code': Schema.string(),
      'display_name': Schema.string(), 'numeric_value': Schema.number(nullable: true),
      'text_value': Schema.string(nullable: true), 'unit': Schema.string(nullable: true),
      'recorded_at': Schema.string(nullable: true),
    })),
    'intake_output': Schema.array(items: Schema.object(properties: {
      'type': Schema.string(), 'value': Schema.number(nullable: true),
      'unit': Schema.string(nullable: true), 'recorded_at': Schema.string(nullable: true),
    })),
  });

  static final labPanelDigestSchema = Schema.object(properties: {
    'raw_ocr_transcript': Schema.string(),
    'observations': Schema.array(items: Schema.object(properties: {
      'code': Schema.string(), 'display_name': Schema.string(),
      'numeric_value': Schema.number(nullable: true), 'text_value': Schema.string(nullable: true),
      'unit': Schema.string(nullable: true), 'reference_low': Schema.number(nullable: true),
      'reference_high': Schema.number(nullable: true), 'is_abnormal': Schema.boolean(),
      'recorded_at': Schema.string(nullable: true),
    })),
  });

  static final microbiologyDigestSchema = Schema.object(properties: {
    'raw_ocr_transcript': Schema.string(), 'sample_type': Schema.string(),
    'organism_identified': Schema.string(nullable: true), 'colony_count': Schema.string(nullable: true),
    'reported_at': Schema.string(nullable: true),
    'sensitivities': Schema.array(items: Schema.object(properties: {
      'antibiotic': Schema.string(), 'interpretation': Schema.string(), 'mic': Schema.string(nullable: true),
    })),
  });

  static final clinicalNarrativeDigestSchema = Schema.object(properties: {
    'raw_ocr_transcript': Schema.string(),
    'chief_complaints': Schema.string(nullable: true), 'hpi': Schema.string(nullable: true),
    'past_history': Schema.string(nullable: true), 'examination': Schema.string(nullable: true),
    'bedside_investigations': Schema.string(nullable: true), 'final_plan': Schema.string(nullable: true),
  });
}