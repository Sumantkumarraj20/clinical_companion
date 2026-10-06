import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../providers/staged_orders_provider.dart';
import '../providers/clinical_rule_guardian_provider.dart';

class SubtleGuardianBanner extends ConsumerWidget {
  const SubtleGuardianBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rule = ref.watch(clinicalRuleGuardianProvider);
    if (rule == null) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    final verified = rule.isVerified;
    final hasPathway =
        rule.differentialDiagnoses.isNotEmpty ||
        rule.recommendedInvestigations.isNotEmpty ||
        rule.recommendedManagement.isNotEmpty;
    final background = verified
        ? colors.primaryContainer.withValues(alpha: 0.45)
        : colors.tertiaryContainer.withValues(alpha: 0.55);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: verified
              ? colors.primary.withValues(alpha: 0.35)
              : colors.tertiary,
        ),
      ),
      child: Row(
        children: [
          Icon(
            verified ? Icons.shield_outlined : Icons.smart_toy_outlined,
            size: 20,
            color: verified ? colors.primary : colors.tertiary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  verified
                      ? 'Standard of Care: ${rule.suggestedAction}'
                      : 'ClinCom Suggestion: ${rule.suggestedAction}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  rule.evidenceRationale,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (verified)
            TextButton(
              onPressed: () => ref
                  .read(stagedOrdersProvider.notifier)
                  .addManual(
                    rule.suggestedAction,
                    source: 'clinical_rule',
                    details: rule.evidenceRationale,
                  ),
              child: const Text('Add to Orders'),
            )
          else if (hasPathway)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('Review in Knowledge Hub'),
            )
          else ...[
            IconButton(
              tooltip: 'Verify and save rule',
              visualDensity: VisualDensity.compact,
              onPressed: () => ref
                  .read(clinicalRuleGuardianProvider.notifier)
                  .verify(rule.id),
              icon: const Icon(Icons.check_circle_outline),
            ),
            IconButton(
              tooltip: 'Dismiss suggestion',
              visualDensity: VisualDensity.compact,
              onPressed: () => ref
                  .read(clinicalRuleGuardianProvider.notifier)
                  .dismiss(rule.id),
              icon: const Icon(Icons.close),
            ),
          ],
        ],
      ),
    );
  }
}
