import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';

class RuleBuilderScreen extends ConsumerStatefulWidget {
  const RuleBuilderScreen({super.key});
  @override
  ConsumerState<RuleBuilderScreen> createState() => _RuleBuilderScreenState();
}

class _RuleBuilderScreenState extends ConsumerState<RuleBuilderScreen> {
  final _problem = TextEditingController();
  final _condition = TextEditingController();
  final _action = TextEditingController();
  final _evidence = TextEditingController();
  final _medicolegal = TextEditingController();
  bool _requiresPreAuth = false;
  String? _editingId;

  @override
  void dispose() {
    for (final controller in [_problem, _condition, _action, _evidence, _medicolegal]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if ([
      _problem,
      _condition,
      _action,
      _evidence,
    ].any((controller) => controller.text.trim().isEmpty)) {
      return;
    }
    final values = CdssRulesCompanion.insert(
      targetProblem: _problem.text.trim(),
      triggerCondition: _condition.text.trim(),
      suggestedAction: _action.text.trim(),
      evidenceSource: _evidence.text.trim(),
      requiresPreAuth: Value(_requiresPreAuth),
      medicolegalAlert: Value(_medicolegal.text.trim()),
      lastUpdated: Value(DateTime.now().toUtc()),
    );
    await ref
        .read(cdssDaoProvider)
        .saveRule(
          _editingId == null ? values : values.copyWith(id: Value(_editingId!)),
        );
    for (final controller in [_problem, _condition, _action, _evidence]) {
      controller.clear();
    }
    setState(() => _editingId = null);
    setState(() => _requiresPreAuth = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('CDSS rule builder')),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _problem,
                decoration: const InputDecoration(labelText: 'Target problem'),
              ),
              TextField(
                controller: _condition,
                decoration: const InputDecoration(
                  labelText: 'Trigger condition',
                ),
              ),
              TextField(
                controller: _action,
                decoration: const InputDecoration(
                  labelText: 'Suggested action',
                ),
              ),
              TextField(
                controller: _evidence,
                decoration: const InputDecoration(
                  labelText: 'Evidence source / citation',
                ),
              ),
              TextField(
                controller: _medicolegal,
                decoration: const InputDecoration(labelText: 'Medicolegal alert text'),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Requires PM-JAY pre-authorization'),
                value: _requiresPreAuth,
                onChanged: (value) => setState(() => _requiresPreAuth = value),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.add),
                label: const Text('Save rule'),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<CdssRule>>(
            stream: ref.watch(cdssDaoProvider).watchRules(),
            builder: (context, snapshot) => ListView(
              children: [
                for (final rule in snapshot.data ?? const <CdssRule>[])
                  Dismissible(
                    key: ValueKey(rule.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) =>
                        ref.read(cdssDaoProvider).deleteRule(rule.id),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: ListTile(
                      title: Text(rule.targetProblem),
                      subtitle: Text(
                        '${rule.triggerCondition} → ${rule.suggestedAction}\n${rule.evidenceSource}',
                      ),
                      onTap: () {
                        _problem.text = rule.targetProblem;
                        _condition.text = rule.triggerCondition;
                        _action.text = rule.suggestedAction;
                        _evidence.text = rule.evidenceSource;
                        _medicolegal.text = rule.medicolegalAlert;
                        _requiresPreAuth = rule.requiresPreAuth;
                        setState(() => _editingId = rule.id);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
