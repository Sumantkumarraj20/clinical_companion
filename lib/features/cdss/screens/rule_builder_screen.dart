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
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cdssDao = ref.watch(cdssDaoProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CDSS Guideline & Rule Studio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.biotech_outlined),
            tooltip: 'Simulate Clinical Decision Matrix',
            onPressed: () => _showRuleTesterDialog(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) =>
                  setState(() => _searchQuery = val.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search guidelines by condition, drug, or trial...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openRuleEditor(context),
        icon: const Icon(Icons.add_moderator_outlined),
        label: const Text('Author Protocol'),
      ),
      body: StreamBuilder<List<CdssRule>>(
        stream: cdssDao.watchRules(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: SelectableText(
                'Unable to load clinical guidelines:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final allRules = snapshot.data ?? [];
          final filteredRules = allRules.where((rule) {
            if (_selectedCategory != 'ALL' &&
                !rule.evidenceSource.toLowerCase().contains(
                  _selectedCategory.toLowerCase(),
                )) {
              return false;
            }

            if (_searchQuery.isEmpty) return true;
            final target = rule.targetProblem.toLowerCase();
            final condition = rule.triggerCondition.toLowerCase();
            final action = rule.suggestedAction.toLowerCase();
            final evidence = rule.evidenceSource.toLowerCase();
            return target.contains(_searchQuery) ||
                condition.contains(_searchQuery) ||
                action.contains(_searchQuery) ||
                evidence.contains(_searchQuery);
          }).toList();

          return Column(
            children: [
              // Category Quick-Filter Bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    _categoryChip('ALL', 'All Protocols (${allRules.length})'),
                    const SizedBox(width: 8),
                    _categoryChip('SURGERY', 'Surgical / Operative'),
                    const SizedBox(width: 8),
                    _categoryChip('SEPSIS', 'Sepsis / Critical Care'),
                    const SizedBox(width: 8),
                    _categoryChip('PMJAY', 'PM-JAY Pre-Auth'),
                    const SizedBox(width: 8),
                    _categoryChip('MLC', 'Medicolegal Safeguards'),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Rule Cards List
              Expanded(
                child: filteredRules.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.menu_book_outlined,
                              size: 56,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              allRules.isEmpty
                                  ? 'No Clinical Decision Guidelines Configured'
                                  : 'No protocols match your search query',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Define logic to trigger alerts during rounds and consultations.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 92),
                        itemCount: filteredRules.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final rule = filteredRules[index];
                          return _CdssRuleCard(
                            rule: rule,
                            onEdit: () =>
                                _openRuleEditor(context, existingRule: rule),
                            onDelete: () => _confirmDelete(context, rule.id),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _categoryChip(String key, String label) {
    return FilterChip(
      label: Text(label),
      selected: _selectedCategory == key,
      onSelected: (selected) {
        if (selected) setState(() => _selectedCategory = key);
      },
    );
  }

  Future<void> _openRuleEditor(
    BuildContext context, {
    CdssRule? existingRule,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _RuleEditorDialog(existingRule: existingRule),
    );

    if (saved == true) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            existingRule == null
                ? 'Clinical protocol registered and armed.'
                : 'Protocol criteria successfully revised.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, String ruleId) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Retire Clinical Protocol?'),
        content: const Text(
          'This protocol will be archived and will no longer trigger automatic alerts during bedside rounds.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Retire Protocol'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(cdssDaoProvider).deleteRule(ruleId);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Protocol retired from active decision engine.'),
        ),
      );
    }
  }

  void _showRuleTesterDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const _RuleTesterModal());
  }
}

class _CdssRuleCard extends StatelessWidget {
  const _CdssRuleCard({
    required this.rule,
    required this.onEdit,
    required this.onDelete,
  });

  final CdssRule rule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasMedicolegal = rule.medicolegalAlert.trim().isNotEmpty;

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: rule.requiresPreAuth
              ? Colors.amber.shade700.withValues(alpha: 0.4)
              : hasMedicolegal
              ? Colors.red.shade400.withValues(alpha: 0.4)
              : theme.dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    rule.targetProblem,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  tooltip: 'Revise Protocol',
                  onPressed: onEdit,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.archive_outlined,
                    size: 18,
                    color: Colors.red,
                  ),
                  tooltip: 'Retire Protocol',
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Clinical Trigger Logic
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tune, size: 14, color: Colors.blueGrey),
                      const SizedBox(width: 6),
                      const Text(
                        'TRIGGER PARAMETERS:',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    rule.triggerCondition,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Clinical Recommendation Action
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.subdirectory_arrow_right,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: 'ACTION ORDER SET: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        TextSpan(text: rule.suggestedAction),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Pre-Auth and Medicolegal Badges
            if (rule.requiresPreAuth || hasMedicolegal) ...[
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (rule.requiresPreAuth)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.amber.shade700),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 14,
                            color: Colors.amber.shade900,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'PM-JAY / CGHS Pre-Auth Mandate',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (hasMedicolegal)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.red.shade400),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.gavel_outlined,
                            size: 14,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'MLC Mandate: ${rule.medicolegalAlert}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Evidence Base & Revision Timestamp
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        size: 14,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          rule.evidenceSource,
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Rev: ${rule.lastUpdated.toIso8601String().split('T').first}',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleEditorDialog extends ConsumerStatefulWidget {
  const _RuleEditorDialog({this.existingRule});
  final CdssRule? existingRule;

  @override
  ConsumerState<_RuleEditorDialog> createState() => _RuleEditorDialogState();
}

class _RuleEditorDialogState extends ConsumerState<_RuleEditorDialog> {
  final _formKey = GlobalKey<FormState>();

  late final _problem = TextEditingController(
    text: widget.existingRule?.targetProblem ?? '',
  );
  late final _condition = TextEditingController(
    text: widget.existingRule?.triggerCondition ?? '',
  );
  late final _action = TextEditingController(
    text: widget.existingRule?.suggestedAction ?? '',
  );
  late final _evidence = TextEditingController(
    text: widget.existingRule?.evidenceSource ?? '',
  );
  late final _medicolegal = TextEditingController(
    text: widget.existingRule?.medicolegalAlert ?? '',
  );

  late bool _requiresPreAuth;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _requiresPreAuth = widget.existingRule?.requiresPreAuth ?? false;
  }

  @override
  void dispose() {
    _problem.dispose();
    _condition.dispose();
    _action.dispose();
    _evidence.dispose();
    _medicolegal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingRule != null;

    return AlertDialog(
      title: Text(
        isEditing ? 'Revise Clinical Protocol' : 'Author Clinical Protocol',
      ),
      content: SizedBox(
        width: 540,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _problem,
                  autofocus: !isEditing,
                  decoration: const InputDecoration(
                    labelText: 'Target Clinical Entity / Diagnosis *',
                    hintText:
                        'e.g. Acute Appendicitis, Septic Shock, Polytrauma',
                    isDense: true,
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Entity is required'
                      : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _condition,
                  decoration: const InputDecoration(
                    labelText: 'Computable Trigger Condition *',
                    hintText: 'e.g. Serum Lactate > 2.0 mmol/L & MAP < 65 mmHg',
                    helperText:
                        'Combine vitals, labs, and signs into computable Boolean thresholds',
                    isDense: true,
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Trigger condition required'
                      : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _action,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Evidence-Based Action Order Set *',
                    hintText:
                        'e.g. 30ml/kg IV Crystalloid Bolus + Blood Cultures before Abx',
                    alignLabelWithHint: true,
                    isDense: true,
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Suggested action required'
                      : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _evidence,
                  decoration: const InputDecoration(
                    labelText: 'Trial / Guideline Citation & Version *',
                    hintText:
                        'e.g. Surviving Sepsis Campaign 2021, Bailey & Love 28th Ed p.1240',
                    isDense: true,
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Citation is required'
                      : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _medicolegal,
                  decoration: const InputDecoration(
                    labelText: 'Medicolegal / Statutory Mandate (Optional)',
                    hintText:
                        'e.g. Mandatory MLC, Inform Police Outpost, High-Risk Form 13B',
                    prefixIcon: Icon(Icons.gavel_outlined, size: 20),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),

                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Requires PM-JAY / CGHS Pre-Authorization',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  subtitle: const Text(
                    'Flags mandatory TMS portal pre-auth to prevent billing rejection',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  value: _requiresPreAuth,
                  onChanged: (v) => setState(() => _requiresPreAuth = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Committing...' : 'Commit Protocol'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final cdssDao = ref.read(cdssDaoProvider);
      final now = DateTime.now().toUtc();

      final values = CdssRulesCompanion.insert(
        targetProblem: _problem.text.trim(),
        triggerCondition: _condition.text.trim(),
        suggestedAction: _action.text.trim(),
        evidenceSource: _evidence.text.trim(),
        requiresPreAuth: Value(_requiresPreAuth),
        medicolegalAlert: Value(_medicolegal.text.trim()),
        lastUpdated: Value(now),
      );

      await cdssDao.saveRule(
        widget.existingRule == null
            ? values
            : values.copyWith(id: Value(widget.existingRule!.id)),
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving protocol: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _RuleTesterModal extends ConsumerStatefulWidget {
  const _RuleTesterModal();

  @override
  ConsumerState<_RuleTesterModal> createState() => _RuleTesterModalState();
}

class _RuleTesterModalState extends ConsumerState<_RuleTesterModal> {
  final _testInputCtrl = TextEditingController();
  List<CdssRule> _matchingRules = [];
  bool _evaluated = false;

  @override
  void dispose() {
    _testInputCtrl.dispose();
    super.dispose();
  }

  Future<void> _evaluate() async {
    final query = _testInputCtrl.text.trim().toLowerCase();
    if (query.isEmpty) return;

    final cdssDao = ref.read(cdssDaoProvider);
    final rules = await cdssDao.watchRules().first;

    final matches = rules.where((r) {
      final target = r.targetProblem.toLowerCase();
      final trigger = r.triggerCondition.toLowerCase();
      return target.contains(query) || trigger.contains(query);
    }).toList();

    setState(() {
      _matchingRules = matches;
      _evaluated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Simulate Bedside Protocol Evaluation'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Input a simulated clinical entity or vital/lab finding to evaluate active protocol firing:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _testInputCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Clinical Parameter / Entity',
                      hintText: 'e.g. Sepsis, Appendicitis, Potassium, Shock',
                      isDense: true,
                    ),
                    onSubmitted: (_) => _evaluate(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: _evaluate,
                  child: const Text('Test'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_evaluated) ...[
              Text(
                'Fired Protocol Alerts (${_matchingRules.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              if (_matchingRules.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'No active protocols triggered for this scenario.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                )
              else
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    itemCount: _matchingRules.length,
                    itemBuilder: (context, index) {
                      final r = _matchingRules[index];
                      return Card(
                        elevation: 0,
                        color: Colors.teal.shade50,
                        margin: const EdgeInsets.only(bottom: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.targetProblem,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Trigger: ${r.triggerCondition}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Order Set: ${r.suggestedAction}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Dismiss'),
        ),
      ],
    );
  }
}
