import '../ai/document_ai_service.dart';
import '../database/daos/clinical_rule_dao.dart';
import '../database/local_database.dart';
import '../models/patient_clinical_context.dart';

class ClinicalRuleConflict {
  const ClinicalRuleConflict({
    required this.rule,
    required this.condition,
    required this.evidence,
  });

  final CachedClinicalRule rule;
  final String condition;
  final String evidence;
}

class ClinicalRuleEngine {
  const ClinicalRuleEngine({
    required ClinicalRuleDao ruleDao,
    required DocumentAiService aiService,
  }) : _ruleDao = ruleDao,
       _aiService = aiService;

  final ClinicalRuleDao _ruleDao;
  final DocumentAiService _aiService;

  Future<CachedClinicalRule?> evaluate({
    required String triggerType,
    required String triggerValue,
  }) async {
    final rules = await evaluateRules(
      triggerType: triggerType,
      triggerValue: triggerValue,
    );
    return rules.firstOrNull;
  }

  Future<List<CachedClinicalRule>> evaluateRules({
    required String triggerType,
    required String triggerValue,
  }) async {
    final normalizedType = triggerType.trim().toLowerCase();
    final value = triggerValue.trim();
    if ((normalizedType != 'diagnosis' &&
            normalizedType != 'symptom' &&
            normalizedType != 'medication') ||
        value.isEmpty) {
      return const [];
    }

    final cached = await _ruleDao.rulesForTrigger(
      triggerType: normalizedType,
      triggerValue: value,
    );
    final cachedPathways = cached
        .where(
          (rule) =>
              rule.differentialDiagnoses.isNotEmpty ||
              rule.recommendedInvestigations.isNotEmpty ||
              rule.recommendedManagement.isNotEmpty,
        )
        .toList(growable: false);
    if (cachedPathways.isNotEmpty) return cached;

    final dismissed = await _ruleDao.findRule(
      triggerType: normalizedType,
      triggerValue: value,
    );
    if (dismissed?.isDismissed == true) return cached;

    final generated = await _aiService.generateClinicalRule(
      triggerType: normalizedType,
      triggerValue: value,
    );
    final saved = await _ruleDao.saveGeneratedRule(
      triggerType: generated.triggerType,
      triggerValue: generated.triggerValue,
      suggestedAction: generated.suggestedAction,
      evidenceRationale: generated.evidenceRationale,
      contraindicatingConditions: generated.contraindicatingConditions,
      requiredMonitoring: generated.requiredMonitoring,
      differentialDiagnoses: generated.differentialDiagnoses,
      recommendedInvestigations: generated.recommendedInvestigations,
      recommendedManagement: generated.recommendedManagement,
      sourceReference: generated.sourceReference,
    );
    return saved.isDismissed ? const [] : [saved];
  }

  static List<ClinicalRuleConflict> findConflicts({
    required Iterable<CachedClinicalRule> rules,
    required PatientClinicalContext context,
  }) {
    final conflicts = <ClinicalRuleConflict>[];
    for (final rule in rules.where((candidate) => candidate.isVerified)) {
      for (final condition in rule.contraindicatingConditions) {
        final evidence = _matchingEvidence(condition, context);
        if (evidence != null) {
          conflicts.add(
            ClinicalRuleConflict(
              rule: rule,
              condition: condition,
              evidence: evidence,
            ),
          );
        }
      }
    }
    return conflicts;
  }

  static String? _matchingEvidence(
    String condition,
    PatientClinicalContext context,
  ) {
    final normalized = condition.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    if (normalized.startsWith('allergy:')) {
      final allergyHistory = context.allergyHistory.toLowerCase();
      if (allergyHistory.isEmpty) return null;
      final allergens = normalized
          .substring('allergy:'.length)
          .split(RegExp(r'[,;/]'))
          .map(_normalizePhrase)
          .where((allergen) => allergen.isNotEmpty);
      for (final allergen in allergens) {
        if (_containsPhrase(allergyHistory, allergen)) {
          return context.allergyHistory;
        }
      }
      return null;
    }

    final pressureMatch = RegExp(
      r'\b(?:sbp|systolic blood pressure|systolic bp)\s*'
      r'(<=|<|>=|>|≤|≥|below|under|at most|at least)\s*(\d+(?:\.\d+)?)',
      caseSensitive: false,
    ).firstMatch(condition);
    if (pressureMatch != null) {
      final operator = pressureMatch.group(1)!.toLowerCase();
      final limit = double.parse(pressureMatch.group(2)!);
      for (final vital in context.recentVitals) {
        final valueMatch = RegExp(
          r'\bSBP\s+(\d+(?:\.\d+)?)',
          caseSensitive: false,
        ).firstMatch(vital);
        if (valueMatch == null) continue;
        final systolic = double.parse(valueMatch.group(1)!);
        final contraindicated = switch (operator) {
          '<' || 'below' || 'under' => systolic < limit,
          '<=' || '≤' || 'at most' => systolic <= limit,
          '>' => systolic > limit,
          '>=' || '≥' || 'at least' => systolic >= limit,
          _ => false,
        };
        if (contraindicated) return vital;
      }
      return null;
    }

    final phrase = _normalizePhrase(normalized);
    if (phrase.isEmpty) return null;

    final negation = RegExp(
      '\\b(?:no|denies|denied|without|absent|negative for)\\s+'
      '(?:\\w+\\s+){0,2}${RegExp.escape(phrase)}\\b',
      caseSensitive: false,
    );

    final candidates = [
      if (context.allergyHistory.isNotEmpty) context.allergyHistory,
      ...context.activeProblems,
      ...context.recentSymptoms,
      ...context.recentVitals,
    ];
    for (final candidate in candidates) {
      final normalizedCandidate = candidate.toLowerCase();
      if (_containsPhrase(normalizedCandidate, phrase) &&
          !negation.hasMatch(normalizedCandidate)) {
        return candidate;
      }
    }
    return null;
  }

  static String _normalizePhrase(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();

  static bool _containsPhrase(String source, String phrase) {
    if (phrase.isEmpty) return false;
    final escaped = RegExp.escape(phrase).replaceAll(r'\ ', r'\s+');
    return RegExp('(?:^|\\b)$escaped(?:\\b|\\\$)').hasMatch(source);
  }
}
