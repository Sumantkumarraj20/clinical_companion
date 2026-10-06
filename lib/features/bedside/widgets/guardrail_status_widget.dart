import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/clinical_guardrail_provider.dart';

class GuardrailStatusWidget extends ConsumerWidget {
  const GuardrailStatusWidget({required this.patientId, super.key});

  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessment = ref.watch(clinicalGuardrailProvider);
    final notifier = ref.read(clinicalGuardrailProvider.notifier);
    if (assessment.patientId != patientId || assessment.medications.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = Theme.of(context).colorScheme;
    if (assessment.isChecking) {
      return const Card(
        child: ListTile(
          dense: true,
          leading: SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          title: Text('Checking local rules against patient context…'),
        ),
      );
    }
    if (!assessment.completed) {
      return Card(
        color: colors.errorContainer,
        child: ListTile(
          leading: Icon(Icons.error_outline, color: colors.error),
          title: const Text('Local safety check could not be completed.'),
          subtitle: Text(
            assessment.error ?? 'Check the local database and retry.',
          ),
          trailing: TextButton(
            onPressed: notifier.recheckCurrent,
            child: const Text('Retry'),
          ),
        ),
      );
    }
    if (assessment.conflicts.isEmpty) {
      return Card(
        color: colors.primaryContainer.withValues(alpha: 0.45),
        child: ListTile(
          dense: true,
          leading: Icon(Icons.check_circle_outline, color: colors.primary),
          title: Text(
            'No known contraindications (checked against '
            '${assessment.rulesChecked} local rules).',
          ),
          subtitle: assessment.requiredMonitoring.isEmpty
              ? null
              : Text('Monitoring: ${assessment.requiredMonitoring.join(', ')}'),
        ),
      );
    }

    return Card(
      color: colors.errorContainer.withValues(alpha: 0.75),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: colors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Potential contraindication found',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            for (final conflict in assessment.conflicts)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${conflict.rule.triggerValue}: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: 'contraindicated by ${conflict.condition}. ',
                      ),
                      TextSpan(text: 'Chart evidence: ${conflict.evidence}'),
                      if (conflict.rule.sourceReference.trim().isNotEmpty)
                        TextSpan(
                          text: ' (${conflict.rule.sourceReference})',
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Advisory only. Review with clinical judgment; your workflow remains available.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
