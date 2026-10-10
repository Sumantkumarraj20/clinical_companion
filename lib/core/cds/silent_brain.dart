/// Local-first, deterministic safety net.
///
/// It never replaces clinical judgement: it only prompts the clinician to
/// consider next steps, widen a differential, or record a missing detail.
/// Every item carries a short rationale and is labelled as a prompt for review.
library;

class BrainInput {
  const BrainInput({
    this.complaints = '',
    this.history = '',
    this.examination = '',
    this.assessment = '',
    this.plan = '',
    this.age,
    this.sbp,
    this.dbp,
    this.pulse,
    this.spo2,
    this.temperatureC,
    this.respiratoryRate,
    this.hasAllergyRecord = false,
    this.hasMedicationRecord = false,
  });

  final String complaints;
  final String history;
  final String examination;
  final String assessment;
  final String plan;
  final int? age;
  final int? sbp;
  final int? dbp;
  final int? pulse;
  final int? spo2;
  final double? temperatureC;
  final int? respiratoryRate;
  final bool hasAllergyRecord;
  final bool hasMedicationRecord;

  String get _all =>
      '$complaints $history $examination $assessment $plan'.toLowerCase();
}

enum BrainKind { missingData, safety, nextStep, differential }

class BrainInsight {
  const BrainInsight(
    this.kind,
    this.title,
    this.rationale, {
    this.urgent = false,
  });
  final BrainKind kind;
  final String title;
  final String rationale;
  final bool urgent;
}

class _Syndrome {
  const _Syndrome(
    this.name,
    this.triggers,
    this.differentials,
    this.steps,
    this.requiredData,
  );
  final String name;
  final List<String> triggers;
  final List<String> differentials;
  final List<String> steps;
  final List<String> requiredData;
}

class SilentBrain {
  const SilentBrain._();

  static const _syndromes = [
    _Syndrome(
      'Chest pain',
      ['chest pain', 'chest discomfort', 'angina'],
      [
        'Acute coronary syndrome',
        'Pulmonary embolism',
        'Aortic dissection',
        'Pneumothorax',
        'Pericarditis',
        'GERD / musculoskeletal',
      ],
      ['12-lead ECG within 10 minutes', 'Troponin (serial)', 'Chest X-ray'],
      ['Pain character and radiation', 'Cardiovascular risk factors'],
    ),
    _Syndrome(
      'Breathlessness',
      ['breathless', 'dyspnea', 'dyspnoea', 'shortness of breath', 'sob'],
      [
        'Heart failure',
        'COPD / asthma exacerbation',
        'Pneumonia',
        'Pulmonary embolism',
        'Anaemia',
      ],
      [
        'SpO2 and respiratory rate',
        'Chest X-ray',
        'ECG',
        'NT-proBNP / D-dimer as indicated',
      ],
      ['Onset and duration', 'Orthopnoea / PND', 'Smoking history'],
    ),
    _Syndrome(
      'Fever',
      ['fever', 'pyrexia', 'chills', 'rigors'],
      [
        'Dengue',
        'Malaria',
        'Typhoid (enteric fever)',
        'Urinary tract infection',
        'Respiratory tract infection',
        'Tuberculosis (if prolonged)',
      ],
      [
        'CBC with platelets',
        'Malaria test',
        'Urine routine',
        'Blood culture before antibiotics',
      ],
      ['Duration of fever', 'Travel / contact history', 'Rash or bleeding'],
    ),
    _Syndrome(
      'Abdominal pain',
      ['abdominal pain', 'abdomen pain', 'belly pain', 'epigastric'],
      [
        'Acute appendicitis',
        'Cholecystitis / biliary colic',
        'Pancreatitis',
        'Peptic ulcer disease',
        'Intestinal obstruction',
        'Renal colic',
      ],
      [
        'Abdominal examination for guarding',
        'CBC, amylase / lipase',
        'Ultrasound abdomen',
      ],
      [
        'Site and radiation',
        'Last menstrual period (if applicable)',
        'Bowel and urine habit',
      ],
    ),
    _Syndrome(
      'Headache / neuro deficit',
      ['headache', 'weakness', 'slurred', 'facial droop', 'seizure', 'stroke'],
      [
        'Ischaemic stroke',
        'Intracranial haemorrhage',
        'Meningitis / encephalitis',
        'Hypoglycaemia',
        'Migraine',
      ],
      [
        'Capillary glucose now',
        'Time last known well',
        'Urgent CT head if deficit',
      ],
      ['Onset time', 'GCS', 'Focal deficit exam'],
    ),
    _Syndrome(
      'Diabetes',
      ['diabetes', 'dm2', 't2dm', 'type 2 dm'],
      [],
      [
        'HbA1c',
        'Urine albumin-creatinine ratio',
        'Foot and fundus screening',
        'Lipid profile',
      ],
      ['Current glucose-lowering drugs'],
    ),
    _Syndrome(
      'Hypertension',
      ['hypertension', 'htn'],
      [],
      ['Serum creatinine and potassium', 'ECG', 'Urine albumin'],
      ['Current antihypertensives'],
    ),
  ];

  static List<BrainInsight> evaluate(BrainInput i) {
    final out = <BrainInsight>[];
    final text = i._all;

    _vitalFlags(i, out);

    for (final s in _syndromes) {
      if (!s.triggers.any(text.contains)) continue;
      if (s.differentials.isNotEmpty) {
        out.add(
          BrainInsight(
            BrainKind.differential,
            '${s.name}: consider, in order of danger',
            s.differentials
                .asMap()
                .entries
                .map((e) => '${e.key + 1}. ${e.value}')
                .join('\n'),
          ),
        );
      }
      for (final step in s.steps) {
        out.add(
          BrainInsight(
            BrainKind.nextStep,
            step,
            'Commonly indicated with ${s.name.toLowerCase()}.',
          ),
        );
      }
      for (final d in s.requiredData) {
        if (!text.contains(d.split(' ').first.toLowerCase())) {
          out.add(
            BrainInsight(
              BrainKind.missingData,
              d,
              'Not yet recorded for ${s.name.toLowerCase()}.',
            ),
          );
        }
      }
    }

    if (!i.hasAllergyRecord && !text.contains('allerg')) {
      out.add(
        const BrainInsight(
          BrainKind.missingData,
          'Allergy status',
          'Confirm and record before prescribing.',
        ),
      );
    }
    if (!i.hasMedicationRecord &&
        !text.contains('medication') &&
        !text.contains('on tab')) {
      out.add(
        const BrainInsight(
          BrainKind.missingData,
          'Current medications',
          'Needed to avoid interactions and duplication.',
        ),
      );
    }
    if (i.assessment.trim().isEmpty && i.complaints.trim().isNotEmpty) {
      out.add(
        const BrainInsight(
          BrainKind.missingData,
          'Working diagnosis',
          'Record an impression, even a provisional one.',
        ),
      );
    }
    if (i.plan.trim().isEmpty && i.assessment.trim().isNotEmpty) {
      out.add(
        const BrainInsight(
          BrainKind.nextStep,
          'Document a plan',
          'An assessment is recorded but no plan yet.',
        ),
      );
    }
    if (i.age != null && i.age! >= 65 && text.contains('fall') == false) {
      out.add(
        const BrainInsight(
          BrainKind.nextStep,
          'Review medication burden and fall risk',
          'Age 65+: consider deprescribing and falls screen.',
        ),
      );
    }

    // A last cognitive-bias check on any non-trivial differential.
    if (out.any((e) => e.kind == BrainKind.differential)) {
      out.add(
        const BrainInsight(
          BrainKind.safety,
          'Pause: what else could this be?',
          'Consider the dangerous alternative before anchoring on the first diagnosis.',
        ),
      );
    }

    out.sort((a, b) => _rank(a).compareTo(_rank(b)));
    return out;
  }

  static int _rank(BrainInsight e) {
    if (e.urgent) return 0;
    return switch (e.kind) {
      BrainKind.safety => 1,
      BrainKind.differential => 2,
      BrainKind.nextStep => 3,
      BrainKind.missingData => 4,
    };
  }

  static void _vitalFlags(BrainInput i, List<BrainInsight> out) {
    void flag(String t, String r) =>
        out.add(BrainInsight(BrainKind.safety, t, r, urgent: true));
    if (i.sbp != null && i.sbp! < 90) {
      flag(
        'Low blood pressure (${i.sbp} systolic)',
        'Reassess perfusion; consider sepsis, bleeding, cardiac cause.',
      );
    }
    if (i.sbp != null && i.sbp! >= 180) {
      flag(
        'Severe hypertension (${i.sbp} systolic)',
        'Look for end-organ involvement.',
      );
    }
    if (i.spo2 != null && i.spo2! < 92) {
      flag(
        'Low oxygen saturation (${i.spo2}%)',
        'Consider oxygen and urgent cause assessment.',
      );
    }
    if (i.pulse != null && (i.pulse! > 120 || i.pulse! < 45)) {
      flag('Abnormal heart rate (${i.pulse}/min)', 'Check rhythm with an ECG.');
    }
    if (i.respiratoryRate != null && i.respiratoryRate! >= 24) {
      flag(
        'Raised respiratory rate (${i.respiratoryRate}/min)',
        'Early sign of deterioration.',
      );
    }
    if (i.temperatureC != null && i.temperatureC! >= 39.5) {
      flag(
        'High temperature (${i.temperatureC}°C)',
        'Look for a source; consider sepsis screen.',
      );
    }
  }
}
