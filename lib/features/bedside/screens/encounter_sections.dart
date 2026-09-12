import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cds/decision_support_engine.dart';
import '../../../core/providers/app_providers.dart';

/// Live deterministic CDSS banners for the encounter screen.
class EncounterCdssBanners extends ConsumerWidget {
  const EncounterCdssBanners({this.sbp, this.pulse, this.spo2, super.key});

  final int? sbp;
  final int? pulse;
  final int? spo2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staged = ref.watch(stagedOrdersProvider);
    final alerts = DecisionSupportEngine.evaluateVitals(sbp, pulse, spo2);
    if (alerts.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        for (final alert in alerts)
          Card(
            color: alert.severityColor.withValues(alpha: 0.12),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: alert.severityColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                ref
                    .read(stagedOrdersProvider.notifier)
                    .addAllProposals(alert.suggestedOrders);
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: alert.severityColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(alert.title,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: alert.severityColor)),
                          Text(alert.description,
                              style: const TextStyle(fontSize: 12)),
                          Text(
                            'Tap to stage (${staged.length} staged)',
                            style: const TextStyle(
                                fontSize: 11, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}
