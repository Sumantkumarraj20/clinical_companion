/// Local-first, deterministic safety net.
///
/// It never replaces clinical judgement: it only prompts the clinician to
/// consider next steps, widen a differential, or record a missing detail.
/// Every item carries a short rationale and is labelled as a prompt for review.
library;

import '../database/local_database.dart';

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

  /// Everything the clinician has typed, for keyword search.
  String get allText => _all;
}

enum BrainKind { missingData, safety, nextStep, differential }

class BrainInsight {
  const BrainInsight(
    this.kind,
    this.title,
    this.rationale, {
    this.urgent = false,
    this.source,
    this.verified,
  });
  final BrainKind kind;
  final String title;
  final String rationale;
  final bool urgent;

  /// Where a learned insight came from, when known.
  final String? source;

  /// null for built-in prompts; otherwise whether the clinician has verified
  /// the learned protocol it came from.
  final bool? verified;
}

/// Turns typed text into search keywords and picks the learned protocols that
/// are genuinely relevant. Pure, so it is cheap to test and safe to call from
/// anywhere.
class LearnedRuleMatcher {
  const LearnedRuleMatcher._();

  static const _stop = {
    'with',
    'without',
    'from',
    'that',
    'this',
    'there',
    'have',
    'has',
    'been',
    'since',
    'days',
    'day',
    'week',
    'weeks',
    'months',
    'years',
    'for',
    'and',
    'the',
    'advice',
    'normal',
    'noted',
    'patient',
    'history',
    'past',
  };
  static const _generic = {
    'syndrome',
    'disease',
    'disorder',
    'acute',
    'chronic',
    'type',
    'primary',
    'secondary',
    'severe',
    'mild',
    'moderate',
  };

  static List<String> tokens(String text) => RegExp(r'[a-z][a-z0-9]{2,}')
      .allMatches(text.toLowerCase())
      .map((m) => m.group(0)!)
      .where((t) => !_stop.contains(t))
      .toList();

  /// Distinct, bounded keyword set (single words plus adjacent pairs).
  static List<String> keywords(String text) {
    final t = tokens(text);
    final out = <String>{};
    for (var i = 0; i < t.length; i++) {
      if (t[i].length >= 4 && !_generic.contains(t[i])) out.add(t[i]);
      if (i + 1 < t.length) out.add('${t[i]} ${t[i + 1]}');
    }
    return out.take(16).toList();
  }

  static bool _wordHit(String word, Set<String> textTokens) => textTokens.any(
    (t) =>
        t == word ||
        (t.length >= 4 && word.startsWith(t)) ||
        (word.length >= 4 && t.startsWith(word)),
  );

  /// Relevant when the whole trigger phrase appears, or at least half of its
  /// meaningful words do (so "nephrotic" finds "Nephrotic syndrome" but a bare
  /// "syndrome" finds nothing).
  static bool isRelevant(CachedClinicalRule rule, String text) {
    final trigger = rule.triggerValue.trim().toLowerCase();
    if (trigger.isEmpty) return false;
    if (text.contains(trigger)) return true;
    final words = tokens(
      trigger,
    ).where((w) => w.length >= 4 && !_generic.contains(w)).toList();
    if (words.isEmpty) return false;
    final textTokens = tokens(text).toSet();
    final hits = words.where((w) => _wordHit(w, textTokens)).length;
    return hits > 0 && hits / words.length >= 0.5;
  }

  static List<CachedClinicalRule> relevant(
    List<CachedClinicalRule> candidates,
    String text,
  ) {
    final seen = <String>{};
    final list = candidates
        .where((r) => !r.isDismissed && isRelevant(r, text) && seen.add(r.id))
        .toList();
    list.sort((a, b) {
      if (a.isVerified != b.isVerified) return a.isVerified ? -1 : 1;
      return b.createdAt.compareTo(a.createdAt);
    });
    return list.take(4).toList();
  }

  static List<BrainInsight> insightsFor(CachedClinicalRule r) {
    final tag = r.isVerified
        ? 'Verified protocol'
        : 'Awaiting your verification';
    final ref = r.sourceReference.trim();
    final source = ref.isEmpty ? tag : '$tag · $ref';
    final out = <BrainInsight>[
      BrainInsight(
        BrainKind.nextStep,
        '${r.triggerValue}: ${r.suggestedAction}',
        r.evidenceRationale,
        source: source,
        verified: r.isVerified,
      ),
    ];
    void list(BrainKind k, String title, List<String> items) {
      if (items.isEmpty) return;
      out.add(
        BrainInsight(
          k,
          title,
          items.take(6).map((e) => '• $e').join('\n'),
          source: source,
          verified: r.isVerified,
        ),
      );
    }

    list(
      BrainKind.differential,
      '${r.triggerValue}: differentials to weigh',
      r.differentialDiagnoses,
    );
    list(
      BrainKind.nextStep,
      '${r.triggerValue}: investigations',
      r.recommendedInvestigations,
    );
    list(
      BrainKind.nextStep,
      '${r.triggerValue}: management',
      r.recommendedManagement,
    );
    list(
      BrainKind.nextStep,
      '${r.triggerValue}: monitoring',
      r.requiredMonitoring,
    );
    list(
      BrainKind.safety,
      '${r.triggerValue}: avoid or use caution if',
      r.contraindicatingConditions,
    );
    return out;
  }
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

  static List<BrainInsight> evaluate(
    BrainInput i, {
    List<CachedClinicalRule> learned = const [],
  }) {
    final out = <BrainInsight>[];
    for (final r in LearnedRuleMatcher.relevant(learned, i.allText)) {
      out.addAll(LearnedRuleMatcher.insightsFor(r));
    }
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
