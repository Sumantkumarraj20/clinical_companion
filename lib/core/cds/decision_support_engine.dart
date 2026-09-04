import '../database/daos/clinical_dao.dart';
import '../database/daos/cdss_dao.dart';

class DecisionRule {
  const DecisionRule({
    required this.ifProblemIs,
    required this.labName,
    required this.operator,
    required this.threshold,
    required this.thenSuggestAction,
    required this.evidenceLevel,
  });

  final String ifProblemIs;
  final String labName;
  final String operator;
  final double threshold;
  final String thenSuggestAction;
  final String evidenceLevel;
}

class DecisionSuggestion {
  const DecisionSuggestion(this.action, this.evidenceLevel);
  final String action;
  final String evidenceLevel;
}

class DecisionSupportEngine {
  DecisionSupportEngine(this.dao, this.rulesDao);
  final ClinicalDao dao;
  final CdssDao rulesDao;

  static const baselineRules = [
    DecisionRule(
      ifProblemIs: 'Sepsis',
      labName: 'Lactate',
      operator: '>',
      threshold: 2,
      thenSuggestAction:
          'Consider IV fluid bolus and broad-spectrum antibiotics.',
      evidenceLevel: 'Baseline guidance; clinician verification required',
    ),
  ];

  Future<List<DecisionSuggestion>> generateSuggestions(String problemId) async {
    final problem = await dao.getPatientProblem(problemId);
    if (problem == null) return const [];
    final encounters = await dao.getEncountersForPatient(problem.patientId);
    final lactate = encounters
        .expand((row) => [row.dynamicData['lactate']])
        .whereType<num>()
        .firstOrNull
        ?.toDouble();
    final rules = await rulesDao.rulesForProblem(problem.problemName);
    return [
      for (final rule in rules)
        if (lactate != null && rule.triggerCondition.contains('Lactate') &&
            lactate > (double.tryParse(rule.triggerCondition.split('>').last.trim()) ?? double.infinity))
          DecisionSuggestion(rule.suggestedAction, rule.evidenceSource),
    ];
  }
}
