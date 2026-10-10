import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../models/clinical_rule_suggestion.dart';
import '../local_database.dart';

part 'clinical_rule_dao.g.dart';

typedef ClinicalRuleImportResult = ({
  int insertedCount,
  List<CachedClinicalRule> rules,
});

@DriftAccessor(tables: [ClinicalRules])
class ClinicalRuleDao extends DatabaseAccessor<AppDatabase>
    with _$ClinicalRuleDaoMixin {
  ClinicalRuleDao(super.db);

  Future<CachedClinicalRule?> findRule({
    required String triggerType,
    required String triggerValue,
  }) =>
      (select(clinicalRules)
            ..where(
              (rule) =>
                  rule.triggerType.equals(triggerType.trim().toLowerCase()) &
                  rule.triggerValue.lower().equals(
                    triggerValue.trim().toLowerCase(),
                  ),
            )
            ..orderBy([
              (rule) => OrderingTerm.desc(rule.isVerified),
              (rule) => OrderingTerm.desc(rule.createdAt),
            ])
            ..limit(1))
          .getSingleOrNull();

  Future<List<CachedClinicalRule>> rulesForTrigger({
    required String triggerType,
    required String triggerValue,
  }) =>
      (select(clinicalRules)
            ..where(
              (rule) =>
                  rule.triggerType.equals(triggerType.trim().toLowerCase()) &
                  rule.triggerValue.lower().equals(
                    triggerValue.trim().toLowerCase(),
                  ) &
                  rule.isDismissed.equals(false),
            )
            ..orderBy([
              (rule) => OrderingTerm.desc(rule.isVerified),
              (rule) => OrderingTerm.desc(rule.createdAt),
            ]))
          .get();

  Stream<List<CachedClinicalRule>> watchRulesForTrigger({
    required String triggerType,
    required String triggerValue,
  }) =>
      (select(clinicalRules)
            ..where(
              (rule) =>
                  rule.triggerType.equals(triggerType.trim().toLowerCase()) &
                  rule.triggerValue.lower().equals(
                    triggerValue.trim().toLowerCase(),
                  ) &
                  rule.isDismissed.equals(false),
            )
            ..orderBy([
              (rule) => OrderingTerm.desc(rule.isVerified),
              (rule) => OrderingTerm.desc(rule.createdAt),
            ]))
          .watch();

  Future<CachedClinicalRule> saveGeneratedRule({
    required String triggerType,
    required String triggerValue,
    required String suggestedAction,
    required String evidenceRationale,
    List<String> contraindicatingConditions = const [],
    List<String> requiredMonitoring = const [],
    List<String> differentialDiagnoses = const [],
    List<String> recommendedInvestigations = const [],
    List<String> recommendedManagement = const [],
    String sourceReference = '',
  }) async {
    final triggerRules = await rulesForTrigger(
      triggerType: triggerType,
      triggerValue: triggerValue,
    );
    final existingPathway = triggerRules
        .where(
          (rule) =>
              rule.differentialDiagnoses.isNotEmpty ||
              rule.recommendedInvestigations.isNotEmpty ||
              rule.recommendedManagement.isNotEmpty,
        )
        .firstOrNull;
    if (existingPathway != null) return existingPathway;

    final existing = await findRule(
      triggerType: triggerType,
      triggerValue: triggerValue,
    );
    if (existing != null &&
        differentialDiagnoses.isEmpty &&
        recommendedInvestigations.isEmpty &&
        recommendedManagement.isEmpty) {
      return existing;
    }
    if (existing != null &&
        (existing.differentialDiagnoses.isNotEmpty ||
            existing.recommendedInvestigations.isNotEmpty ||
            existing.recommendedManagement.isNotEmpty)) {
      return existing;
    }

    final id = const Uuid().v4();
    await into(clinicalRules).insert(
      ClinicalRulesCompanion.insert(
        id: Value(id),
        triggerType: triggerType.trim().toLowerCase(),
        triggerValue: triggerValue.trim(),
        suggestedAction: suggestedAction.trim(),
        evidenceRationale: evidenceRationale.trim(),
        contraindicatingConditions: Value(contraindicatingConditions),
        requiredMonitoring: Value(requiredMonitoring),
        differentialDiagnoses: Value(differentialDiagnoses),
        recommendedInvestigations: Value(recommendedInvestigations),
        recommendedManagement: Value(recommendedManagement),
        sourceReference: Value(sourceReference.trim()),
      ),
    );
    return (select(
      clinicalRules,
    )..where((rule) => rule.id.equals(id))).getSingle();
  }

  Future<ClinicalRuleImportResult> saveGuidelineRules(
    List<ClinicalRuleSuggestion> suggestions,
  ) async {
    var inserted = 0;
    final savedRules = <CachedClinicalRule>[];
    await transaction(() async {
      for (final suggestion in suggestions) {
        final existing =
            await (select(clinicalRules)..where(
                  (rule) =>
                      rule.triggerType.equals(suggestion.triggerType) &
                      rule.triggerValue.lower().equals(
                        suggestion.triggerValue.toLowerCase(),
                      ) &
                      rule.suggestedAction.lower().equals(
                        suggestion.suggestedAction.toLowerCase(),
                      ),
                ))
                .getSingleOrNull();
        if (existing != null) {
          if (!savedRules.any((rule) => rule.id == existing.id)) {
            savedRules.add(existing);
          }
          continue;
        }
        final id = const Uuid().v4();
        await into(clinicalRules).insert(
          ClinicalRulesCompanion.insert(
            id: Value(id),
            triggerType: suggestion.triggerType,
            triggerValue: suggestion.triggerValue,
            suggestedAction: suggestion.suggestedAction,
            evidenceRationale: suggestion.evidenceRationale,
            contraindicatingConditions: Value(
              suggestion.contraindicatingConditions,
            ),
            requiredMonitoring: Value(suggestion.requiredMonitoring),
            differentialDiagnoses: Value(suggestion.differentialDiagnoses),
            recommendedInvestigations: Value(
              suggestion.recommendedInvestigations,
            ),
            recommendedManagement: Value(suggestion.recommendedManagement),
            sourceReference: Value(suggestion.sourceReference),
          ),
        );
        savedRules.add(
          await (select(
            clinicalRules,
          )..where((rule) => rule.id.equals(id))).getSingle(),
        );
        inserted++;
      }
    });
    return (insertedCount: inserted, rules: savedRules);
  }

  Stream<List<CachedClinicalRule>> watchPendingPathways() =>
      (select(clinicalRules)
            ..where(
              (rule) =>
                  rule.isVerified.equals(false) &
                  rule.isDismissed.equals(false) &
                  (rule.differentialDiagnoses.isNotValue('[]') |
                      rule.recommendedInvestigations.isNotValue('[]') |
                      rule.recommendedManagement.isNotValue('[]')),
            )
            ..orderBy([(rule) => OrderingTerm.desc(rule.createdAt)]))
          .watch();

  Future<CachedClinicalRule> updatePathwayAndVerify({
    required String id,
    required List<String> differentialDiagnoses,
    required List<String> recommendedInvestigations,
    required List<String> recommendedManagement,
    required String evidenceRationale,
  }) async {
    if (differentialDiagnoses.isEmpty &&
        recommendedInvestigations.isEmpty &&
        recommendedManagement.isEmpty) {
      throw ArgumentError(
        'A pathway must include at least one suggestion before verification.',
      );
    }
    if (evidenceRationale.trim().isEmpty) {
      throw ArgumentError('An evidence rationale is required for verification.');
    }
    await (update(clinicalRules)..where((rule) => rule.id.equals(id))).write(
      ClinicalRulesCompanion(
        differentialDiagnoses: Value(differentialDiagnoses),
        recommendedInvestigations: Value(recommendedInvestigations),
        recommendedManagement: Value(recommendedManagement),
        evidenceRationale: Value(evidenceRationale.trim()),
        isVerified: const Value(true),
        isDismissed: const Value(false),
      ),
    );
    return (select(
      clinicalRules,
    )..where((rule) => rule.id.equals(id))).getSingle();
  }

  Future<CachedClinicalRule> verifyRule(String id) async {
    await (update(clinicalRules)..where((rule) => rule.id.equals(id))).write(
      const ClinicalRulesCompanion(
        isVerified: Value(true),
        isDismissed: Value(false),
      ),
    );
    return (select(
      clinicalRules,
    )..where((rule) => rule.id.equals(id))).getSingle();
  }

  /// Sprint 28 — full CRUD for the Clinical Protocols editor. Manual edits
  /// overwrite the rule immediately so the local-first pre-compute check
  /// (verified first, newest first) picks them up on the next ingestion.
  Future<CachedClinicalRule> upsertManualRule({
    String? id,
    required String triggerType,
    required String triggerValue,
    required String suggestedAction,
    required String evidenceRationale,
    List<String> contraindicatingConditions = const [],
    List<String> requiredMonitoring = const [],
    List<String> differentialDiagnoses = const [],
    List<String> recommendedInvestigations = const [],
    List<String> recommendedManagement = const [],
    String sourceReference = '',
    bool isVerified = true,
  }) async {
    final normalizedType = triggerType.trim().toLowerCase();
    final normalizedValue = triggerValue.trim();
    if (normalizedType.isEmpty || normalizedValue.isEmpty) {
      throw ArgumentError('Trigger type and value are required.');
    }
    if (suggestedAction.trim().isEmpty) {
      throw ArgumentError('A suggested action is required.');
    }
    final ruleId = id ?? const Uuid().v4();
    await into(clinicalRules).insertOnConflictUpdate(
      ClinicalRulesCompanion.insert(
        id: Value(ruleId),
        triggerType: normalizedType,
        triggerValue: normalizedValue,
        suggestedAction: suggestedAction.trim(),
        evidenceRationale: evidenceRationale.trim(),
        contraindicatingConditions: Value(contraindicatingConditions),
        requiredMonitoring: Value(requiredMonitoring),
        differentialDiagnoses: Value(differentialDiagnoses),
        recommendedInvestigations: Value(recommendedInvestigations),
        recommendedManagement: Value(recommendedManagement),
        sourceReference: Value(sourceReference.trim()),
        isVerified: Value(isVerified),
        isDismissed: const Value(false),
      ),
    );
    return (select(
      clinicalRules,
    )..where((rule) => rule.id.equals(ruleId))).getSingle();
  }

  /// Permanently removes a protocol (distinct from [dismissRule], which only
  /// hides it from matching but keeps the row for audit).
  Future<void> deleteRule(String id) =>
      (delete(clinicalRules)..where((rule) => rule.id.equals(id))).go();

  /// All active protocols for the editor, verified first then newest.
  Stream<List<CachedClinicalRule>> watchActiveProtocols() =>
      (select(clinicalRules)
            ..where((rule) => rule.isDismissed.equals(false))
            ..orderBy([
              (rule) => OrderingTerm.desc(rule.isVerified),
              (rule) => OrderingTerm.desc(rule.createdAt),
            ]))
          .watch();

  /// All protocols, including deprecated rows retained for review and editing.
  Stream<List<CachedClinicalRule>> watchProtocols() =>
      (select(clinicalRules)
            ..orderBy([
              (rule) => OrderingTerm.desc(rule.isDismissed),
              (rule) => OrderingTerm.desc(rule.isVerified),
              (rule) => OrderingTerm.desc(rule.createdAt),
            ]))
          .watch();

  Future<List<CachedClinicalRule>> activeProtocols() =>
      (select(clinicalRules)
            ..where((rule) => rule.isDismissed.equals(false))
            ..orderBy([
              (rule) => OrderingTerm.desc(rule.isVerified),
              (rule) => OrderingTerm.desc(rule.createdAt),
            ]))
          .get();

  Future<void> dismissRule(String id) =>
      (update(clinicalRules)..where((rule) => rule.id.equals(id))).write(
        const ClinicalRulesCompanion(isDismissed: Value(true)),
      );

  Future<void> restoreRule(String id) =>
      (update(clinicalRules)..where((rule) => rule.id.equals(id))).write(
        const ClinicalRulesCompanion(isDismissed: Value(false)),
      );

  /// Fast candidate lookup for the live safety net. One indexed-free LIKE scan
  /// over a small table; callers debounce and run it off the typing path.
  /// Verified rules sort first. Dismissed rules are never returned.
  Future<List<CachedClinicalRule>> searchByKeywords(
    Iterable<String> keywords, {
    int limit = 24,
  }) {
    final terms = keywords
        .map((k) => k.trim().toLowerCase())
        .where((k) => k.length >= 3)
        .toSet()
        .take(16)
        .toList();
    if (terms.isEmpty) return Future.value(const []);
    String escape(String t) =>
        t.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
    Expression<bool> any = const Constant(false);
    for (final t in terms) {
      any =
          any |
          clinicalRules.triggerValue.lower().like(
            '%${escape(t)}%',
            escapeChar: r'\',
          );
    }
    return (select(clinicalRules)
          ..where((rule) => rule.isDismissed.equals(false) & any)
          ..orderBy([
            (rule) => OrderingTerm.desc(rule.isVerified),
            (rule) => OrderingTerm.desc(rule.createdAt),
          ])
          ..limit(limit))
        .get();
  }
}
