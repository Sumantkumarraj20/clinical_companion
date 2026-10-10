import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/clinical_rule_engine.dart';
import 'clinical_guardrail_provider.dart';

final clinicalRuleGuardianProvider =
    NotifierProvider<ClinicalRuleGuardianNotifier, CachedClinicalRule?>(
      ClinicalRuleGuardianNotifier.new,
    );

class ClinicalRuleGuardianNotifier extends Notifier<CachedClinicalRule?> {
  late ClinicalRuleEngine _engine;
  final Set<String> _inFlight = {};
  int _latestRequest = 0;

  @override
  CachedClinicalRule? build() {
    _engine = ClinicalRuleEngine(
      ruleDao: ref.read(clinicalRuleDaoProvider),
      aiService: ref.read(documentAiServiceProvider),
    );
    return null;
  }

  Future<void> evaluate({
    required String triggerType,
    required String triggerValue,
  }) async {
    final normalizedType = triggerType.trim().toLowerCase();
    final value = triggerValue.trim();
    if (value.isEmpty) return;

    final key = '$normalizedType:${value.toLowerCase()}';
    if (!_inFlight.add(key)) return;

    final request = ++_latestRequest;
    state = null;
    try {
      final rule = await _engine.evaluate(
        triggerType: normalizedType,
        triggerValue: value,
      );
      if (request == _latestRequest) state = rule;
    } catch (error, stackTrace) {
      debugPrint(
        '[ClinicalRuleGuardian] Rule lookup/generation failed: $error\n'
        '$stackTrace',
      );
      // Sprint 27 — surface AI failures (400/500 INVALID_ARGUMENT etc.) as a
      // non-blocking toast instead of letting the Encounter UI swallow them.
      ref
          .read(aiErrorNoticeProvider.notifier)
          .show(
            'A clinical pathway could not be prepared right now. You can continue and try again later.',
          );
    } finally {
      _inFlight.remove(key);
    }
  }

  Future<void> verify(String id) async {
    try {
      final verified = await ref.read(clinicalRuleDaoProvider).verifyRule(id);
      if (state?.id == id) state = verified;
      await ref.read(clinicalGuardrailProvider.notifier).recheckCurrent();
    } catch (error, stackTrace) {
      debugPrint(
        '[ClinicalRuleGuardian] Could not verify rule: $error\n$stackTrace',
      );
    }
  }

  Future<void> dismiss(String id) async {
    try {
      await ref.read(clinicalRuleDaoProvider).dismissRule(id);
      if (state?.id == id) state = null;
    } catch (error, stackTrace) {
      debugPrint(
        '[ClinicalRuleGuardian] Could not dismiss rule: $error\n$stackTrace',
      );
    }
  }
}
