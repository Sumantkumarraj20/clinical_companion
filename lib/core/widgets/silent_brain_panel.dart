import 'package:flutter/material.dart';

import '../cds/silent_brain.dart';

/// Quiet, collapsible safety-net panel. Shows nothing when there is nothing
/// to prompt, and always frames items as prompts for the clinician to verify.
class SilentBrainPanel extends StatelessWidget {
  const SilentBrainPanel({super.key, required this.input});

  final BrainInput input;

  @override
  Widget build(BuildContext context) {
    final items = SilentBrain.evaluate(input);
    if (items.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final urgent = items.where((e) => e.urgent).length;

    return Card(
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerLow,
      child: ExpansionTile(
        initiallyExpanded: urgent > 0,
        shape: const Border(),
        leading: Icon(
          urgent > 0 ? Icons.priority_high : Icons.lightbulb_outline,
          color: urgent > 0 ? scheme.error : scheme.primary,
        ),
        title: Text(
          urgent > 0
              ? '$urgent item${urgent == 1 ? '' : 's'} need attention'
              : 'Worth a second look (${items.length})',
        ),
        subtitle: const Text(
          'Prompts for your review. Your judgement decides.',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final e in items.take(12))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _icon(e.kind),
                    size: 18,
                    color: e.urgent ? scheme.error : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          e.rationale,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static IconData _icon(BrainKind k) => switch (k) {
    BrainKind.safety => Icons.shield_outlined,
    BrainKind.differential => Icons.account_tree_outlined,
    BrainKind.nextStep => Icons.arrow_forward,
    BrainKind.missingData => Icons.edit_note,
  };
}
