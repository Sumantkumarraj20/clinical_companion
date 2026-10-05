import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/clinical_insight.dart';
import '../../../core/providers/app_providers.dart';

/// Collapsible, non-blocking chart-audit panel.
class ClinComInsightsPanel extends ConsumerStatefulWidget {
  const ClinComInsightsPanel({
    required this.patientId,
    this.auditRequest = 0,
    super.key,
  });

  final String patientId;
  final int auditRequest;

  @override
  ConsumerState<ClinComInsightsPanel> createState() =>
      _ClinComInsightsPanelState();
}

class _ClinComInsightsPanelState extends ConsumerState<ClinComInsightsPanel> {
  List<_InsightStatus> _insights = const [];
  bool _auditing = false;
  bool _expanded = false;
  String? _error;
  int _lastRequest = 0;

  @override
  void initState() {
    super.initState();
    _lastRequest = widget.auditRequest;
    if (_lastRequest > 0) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => unawaited(_runAudit()),
      );
    }
  }

  @override
  void didUpdateWidget(covariant ClinComInsightsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patientId != widget.patientId) {
      _insights = const [];
      _error = null;
    }
    if (_lastRequest != widget.auditRequest) {
      _lastRequest = widget.auditRequest;
      unawaited(_runAudit());
    }
  }

  Future<void> _runAudit() async {
    if (_auditing) return;
    setState(() {
      _auditing = true;
      _expanded = true;
      _error = null;
      _insights = const [];
    });
    try {
      final generated = await ref
          .read(clinComAuditServiceProvider)
          .auditPatient(widget.patientId);
      if (!mounted) return;
      setState(() {
        _insights = [
          for (final insight in generated) _InsightStatus(insight: insight),
        ];
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _auditing = false);
    }
  }

  Future<void> _recordDecision(_InsightStatus status, String decision) async {
    if (status.decision != null || status.saving) return;
    setState(() => status.saving = true);
    try {
      await ref
          .read(clinicalDaoProvider)
          .recordClinicalAudit(
            patientId: widget.patientId,
            suggestionType: status.insight.type,
            title: status.insight.title,
            reasoning: status.insight.reasoning,
            status: decision,
          );
      if (mounted) setState(() => status.decision = decision);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save audit feedback: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => status.saving = false);
    }
  }

  Future<void> _addToOrders(_InsightStatus status) async {
    final items = status.insight.actionableItems;
    if (items.isEmpty || status.decision != null || status.saving) return;
    setState(() => status.saving = true);
    try {
      await ref
          .read(clinicalDaoProvider)
          .recordClinicalAudit(
            patientId: widget.patientId,
            suggestionType: status.insight.type,
            title: status.insight.title,
            reasoning: status.insight.reasoning,
            status: 'accepted',
          );
      if (!mounted) return;
      final orders = ref.read(stagedOrdersProvider.notifier);
      for (final item in items) {
        orders.addManual(
          item,
          source: 'clincom_audit',
          details: status.insight.reasoning,
        );
      }
      setState(() => status.decision = 'accepted');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${items.length} investigation${items.length == 1 ? '' : 's'} added to Orders & Plan.',
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not add recommended orders: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => status.saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
            title: const Text(
              'ClinCom Insights',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text(
              'Evidence-based chart audit · clinician-reviewed',
            ),
            trailing: IconButton(
              tooltip: _auditing
                  ? 'Generating insights'
                  : 'Generate ClinCom Insights',
              onPressed: _auditing ? null : _runAudit,
              icon: _auditing
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
            ),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            if (_auditing)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Reviewing active problems, orders and results…',
                      ),
                    ),
                  ],
                ),
              )
            else if (_error != null)
              ListTile(
                leading: const Icon(Icons.error_outline, color: Colors.red),
                title: const Text('Could not generate insights'),
                subtitle: Text(_error!),
                trailing: TextButton(
                  onPressed: _runAudit,
                  child: const Text('Retry'),
                ),
              )
            else if (_insights.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No actionable gaps identified in the current chart.',
                ),
              )
            else
              for (final item in _insights) _insightCard(item),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                'Decision support only. Verify relevance and contraindications before ordering.',
                style: TextStyle(fontSize: 11),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _insightCard(_InsightStatus status) {
    final insight = status.insight;
    final scheme = Theme.of(context).colorScheme;
    final (icon, color) = switch (insight.type) {
      'missing_investigation' => (Icons.science_outlined, scheme.primary),
      'warning' => (Icons.warning_amber_rounded, scheme.tertiary),
      'differential_diagnosis' => (Icons.manage_search, scheme.secondary),
      _ => (Icons.lightbulb_outline, scheme.secondary),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Card(
        elevation: 0,
        color: color.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(insight.reasoning),
              if (insight.actionableItems.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  insight.actionableItems.join(' · '),
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              if (status.decision == null)
                Wrap(
                  spacing: 8,
                  children: [
                    if (insight.type == 'missing_investigation' &&
                        insight.actionableItems.isNotEmpty)
                      FilledButton.tonalIcon(
                        onPressed: status.saving
                            ? null
                            : () => _addToOrders(status),
                        icon: status.saving
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.add, size: 18),
                        label: const Text('Add to Orders'),
                      )
                    else
                      TextButton.icon(
                        onPressed: status.saving
                            ? null
                            : () => _recordDecision(status, 'accepted'),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Helpful'),
                      ),
                    TextButton(
                      onPressed: status.saving
                          ? null
                          : () => _recordDecision(status, 'dismissed'),
                      child: const Text('Dismiss'),
                    ),
                  ],
                )
              else
                Chip(
                  label: Text(
                    status.decision == 'accepted' ? 'Accepted' : 'Dismissed',
                  ),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightStatus {
  _InsightStatus({required this.insight});

  final ClinicalInsight insight;
  String? decision;
  bool saving = false;
}
