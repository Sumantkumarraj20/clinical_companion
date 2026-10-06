import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cds/decision_support_engine.dart';
import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';

final _navigatorRulesProvider = StreamProvider.family<
  List<CachedClinicalRule>,
  ({String triggerType, String triggerValue})
>((ref, trigger) {
  return ref
      .watch(clinicalRuleDaoProvider)
      .watchRulesForTrigger(
        triggerType: trigger.triggerType,
        triggerValue: trigger.triggerValue,
      );
});

class ClinicalRuleNavigator extends ConsumerWidget {
  const ClinicalRuleNavigator({
    required this.triggerType,
    required this.triggerValue,
    super.key,
  });

  final String triggerType;
  final String triggerValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = triggerValue.trim();
    if (value.isEmpty) return const SizedBox.shrink();
    final rules = ref.watch(
      _navigatorRulesProvider((
        triggerType: triggerType,
        triggerValue: value,
      )),
    );

    return rules.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          'Local suggestions could not be loaded: $error',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
      data: (matches) {
        final pathway = matches
            .where(
              (rule) =>
                  rule.isVerified &&
                  (rule.differentialDiagnoses.isNotEmpty ||
                      rule.recommendedInvestigations.isNotEmpty ||
                      rule.recommendedManagement.isNotEmpty),
            )
            .firstOrNull;
        final hasPending = matches.any(
          (rule) =>
              !rule.isVerified &&
              (rule.differentialDiagnoses.isNotEmpty ||
                  rule.recommendedInvestigations.isNotEmpty ||
                  rule.recommendedManagement.isNotEmpty),
        );
        if (pathway == null && !hasPending) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.only(top: 8, bottom: 4),
          child: ExpansionTile(
            leading: const Icon(Icons.explore_outlined),
            title: const Text('ClinCom Navigator'),
            subtitle: Text(
              pathway == null
                  ? 'A generated pathway is awaiting verification in Knowledge Hub.'
                  : 'Evidence-informed suggestions for $value',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            children: [
              if (pathway != null) ...[
                if (pathway.differentialDiagnoses.isNotEmpty)
                  _SuggestionList(
                    title: 'Differential diagnoses',
                    icon: Icons.search,
                    suggestions: pathway.differentialDiagnoses,
                  ),
                if (pathway.recommendedInvestigations.isNotEmpty)
                  _SuggestionList(
                    title: 'Next best investigations',
                    icon: Icons.science_outlined,
                    suggestions: pathway.recommendedInvestigations,
                    actionLabel: 'Add',
                    onAction: (suggestion) => ref
                        .read(stagedOrdersProvider.notifier)
                        .addManual(
                          suggestion,
                          source: 'clinical_navigator',
                          details: pathway.evidenceRationale,
                        ),
                  ),
                if (pathway.recommendedManagement.isNotEmpty)
                  _SuggestionList(
                    title: 'Management options',
                    icon: Icons.medical_services_outlined,
                    suggestions: pathway.recommendedManagement,
                    actionLabel: 'Draft Prescription',
                    onAction: (suggestion) => ref
                        .read(stagedOrdersProvider.notifier)
                        .addManual(
                          suggestion,
                          source: 'clinical_navigator',
                          details: pathway.evidenceRationale,
                          kind: OrderProposalKind.medication,
                        ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Tooltip(
                      triggerMode: TooltipTriggerMode.tap,
                      message: pathway.evidenceRationale,
                      child: const Icon(
                        Icons.help_outline,
                        size: 20,
                        semanticLabel: 'View evidence rationale',
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({
    required this.title,
    required this.icon,
    required this.suggestions,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final IconData icon;
  final List<String> suggestions;
  final String? actionLabel;
  final ValueChanged<String>? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          for (final suggestion in suggestions)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(icon, size: 18),
              title: Text(suggestion),
              trailing: actionLabel == null
                  ? null
                  : TextButton(
                      onPressed: () => onAction?.call(suggestion),
                      child: Text(actionLabel!),
                    ),
            ),
        ],
      ),
    );
  }
}
