import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/daos/clinical_dao.dart';
import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/shimmer_loading.dart';

const _uuid = Uuid();

class LabTrackerScreen extends ConsumerStatefulWidget {
  const LabTrackerScreen({super.key});

  @override
  ConsumerState<LabTrackerScreen> createState() => _LabTrackerScreenState();
}

class _LabTrackerScreenState extends ConsumerState<LabTrackerScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dao = ref.watch(clinicalDaoProvider);
    final investigationsStream = dao.watchPendingInvestigationsWithPatients();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investigation Workorder Tracker'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) =>
                  setState(() => _searchQuery = val.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search by test, patient name, or CR no…',
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
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
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
      body: StreamBuilder<List<PendingInvestigation>>(
        stream: investigationsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: SelectableText(
                'Unable to load investigation orders:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerLoading(rows: 5),
            );
          }

          final allOrders = snapshot.data ?? [];

          // Filter by status and search query
          final filteredOrders = allOrders.where((item) {
            final order = item.investigation;
            if (_statusFilter != 'ALL' && order.status != _statusFilter) {
              return false;
            }

            if (_searchQuery.isNotEmpty) {
              final testName = order.testName.toLowerCase();
              final patientName = item.patient.fullName.toLowerCase();
              final cr = item.hospitalRegNo.toLowerCase();
              return testName.contains(_searchQuery) ||
                  patientName.contains(_searchQuery) ||
                  cr.contains(_searchQuery);
            }
            return true;
          }).toList();

          return Column(
            children: [
              // Status Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    _filterChip('ALL', 'All Pending (${allOrders.length})'),
                    const SizedBox(width: 8),
                    _filterChip(
                      'ordered',
                      'Pending Sample (${allOrders.where((o) => o.investigation.status == 'ordered').length})',
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      'sample_sent',
                      'Sample Sent (${allOrders.where((o) => o.investigation.status == 'sample_sent').length})',
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Orders List
              Expanded(
                child: filteredOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.biotech_outlined,
                              size: 56,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No pending laboratory workorders',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Orders placed during rounds or consultations appear here.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final item = filteredOrders[index];
                          return _InvestigationCard(item: item);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _filterChip(String statusKey, String label) {
    return FilterChip(
      label: Text(label),
      selected: _statusFilter == statusKey,
      onSelected: (selected) {
        if (selected) setState(() => _statusFilter = statusKey);
      },
    );
  }
}

class _InvestigationCard extends ConsumerWidget {
  const _InvestigationCard({required this.item});

  final PendingInvestigation item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = item.investigation;
    final patient = item.patient;
    final theme = Theme.of(context);
    final isSent = order.status == 'sample_sent';

    final isCulture =
        order.testName.toLowerCase().contains('culture') ||
        order.testName.toLowerCase().contains('sensitivity');

    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSent
              ? Colors.blue.withValues(alpha: 0.3)
              : theme.dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Status & Timing Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isSent
                        ? Colors.blue.withValues(alpha: 0.12)
                        : Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSent
                            ? Icons.local_shipping_outlined
                            : Icons.schedule_outlined,
                        size: 14,
                        color: isSent
                            ? Colors.blue.shade800
                            : Colors.amber.shade900,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isSent
                            ? 'Sample In Transit / Sent'
                            : 'Awaiting Collection',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSent
                              ? Colors.blue.shade800
                              : Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Ordered ${_timeAgo(order.orderedAt)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Patient Identity Row
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  child: Text(
                    patient.fullName.trim().isNotEmpty
                        ? patient.fullName.trim()[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.fullName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'CR No: ${item.hospitalRegNo} · ${patient.gender ?? '?'}, ${patient.approximateAge ?? '--'} yrs',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Test Details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isCulture ? Icons.biotech : Icons.science_outlined,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.testName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (order.clinicalIndication?.isNotEmpty == true)
                          Text(
                            'Indication: ${order.clinicalIndication}',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Action Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Cancel Action
                TextButton(
                  onPressed: () => _confirmCancel(context, ref, order),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Cancel Order'),
                ),
                const Spacer(),

                // Toggle Sample Sent
                if (!isSent)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.send_outlined, size: 16),
                    label: const Text('Sample Sent'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () async {
                      await ref
                          .read(clinicalDaoProvider)
                          .updateInvestigationStatus(order.id, 'sample_sent');
                    },
                  )
                else
                  TextButton.icon(
                    icon: const Icon(Icons.undo, size: 16),
                    label: const Text('Mark Pending'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () async {
                      await ref
                          .read(clinicalDaoProvider)
                          .updateInvestigationStatus(order.id, 'ordered');
                    },
                  ),
                const SizedBox(width: 8),

                // Record Results
                FilledButton.icon(
                  icon: const Icon(Icons.assignment_turned_in, size: 16),
                  label: const Text('Enter Result'),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () {
                    if (isCulture) {
                      _showCultureDialog(context, ref, order);
                    } else {
                      _showQuantitativeResultDialog(context, ref, order);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    WidgetRef ref,
    InvestigationOrder order,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Investigation?'),
        content: Text('Are you sure you want to cancel "${order.testName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Order'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(clinicalDaoProvider).deleteInvestigation(order);
    }
  }

  Future<void> _showQuantitativeResultDialog(
    BuildContext context,
    WidgetRef ref,
    InvestigationOrder order,
  ) async {
    final valCtrl = TextEditingController();
    final unitCtrl = TextEditingController();
    final refCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    bool isAbnormal = false;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Result: ${order.testName}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: valCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Result Value *',
                          hintText: 'e.g. 13.5',
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: unitCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          hintText: 'mg/dL',
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: refCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Reference Range (Optional)',
                    hintText: 'e.g. 0.6 - 1.2',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Flag as Clinically Abnormal'),
                  value: isAbnormal,
                  onChanged: (v) => setDialogState(() => isAbnormal = v),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Clinical Interpretation / Note',
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save Result'),
            ),
          ],
        ),
      ),
    );

    if (saved == true && valCtrl.text.trim().isNotEmpty) {
      final dao = ref.read(clinicalDaoProvider);
      final now = DateTime.now().toUtc();
      final numVal = double.tryParse(valCtrl.text.trim());

      // 1. Insert into InvestigationResults
      await dao
          .into(dao.investigationResults)
          .insert(
            InvestigationResultsCompanion.insert(
              orderId: Value(order.id),
              patientId: order.patientId,
              testName: order.testName,
              numericValue: Value(numVal),
              textValue: Value(valCtrl.text.trim()),
              unit: Value(
                unitCtrl.text.trim().isEmpty ? null : unitCtrl.text.trim(),
              ),
              referenceRange: Value(
                refCtrl.text.trim().isEmpty ? null : refCtrl.text.trim(),
              ),
              isAbnormal: Value(isAbnormal),
              resultDate: Value(now),
            ),
          );

      // 2. Insert into ClinicalObservations for Longitudinal EAV trends
      await dao
          .into(dao.clinicalObservations)
          .insert(
            ClinicalObservationsCompanion.insert(
              id: _uuid.v4(),
              patientId: order.patientId,
              documentId: order.id,
              observationCategory: 'lab_panel',
              code: order.testCode ?? 'LAB_${order.testName.toUpperCase()}',
              displayName: order.testName,
              numericValue: Value(numVal),
              textValue: Value(valCtrl.text.trim()),
              unit: Value(
                unitCtrl.text.trim().isEmpty ? null : unitCtrl.text.trim(),
              ),
              isAbnormal: Value(isAbnormal),
              recordedAt: now,
            ),
          );

      // 3. Mark workorder received
      await dao.updateInvestigationStatus(order.id, 'result_received');
    }
  }

  Future<void> _showCultureDialog(
    BuildContext context,
    WidgetRef ref,
    InvestigationOrder order,
  ) async {
    final result = await showDialog<_CultureResult>(
      context: context,
      builder: (_) => const _CultureDialog(),
    );

    if (result == null) return;

    final dao = ref.read(clinicalDaoProvider);
    final now = DateTime.now().toUtc();

    // Serialize antibiogram map (Antibiotic -> Sensitivity)
    final antibiogram = <String, String>{};
    for (final s in result.sensitive) {
      antibiogram[s] = 'Sensitive';
    }
    for (final r in result.resistant) {
      antibiogram[r] = 'Resistant';
    }

    // 1. Save structured result
    await dao
        .into(dao.investigationResults)
        .insert(
          InvestigationResultsCompanion.insert(
            orderId: Value(order.id),
            patientId: order.patientId,
            testName: order.testName,
            textValue: Value('Organism: ${result.organism}'),
            antibiogramJson: Value(jsonEncode(antibiogram)),
            isAbnormal: Value(result.organism != 'No growth / Sterile'),
            resultDate: Value(now),
          ),
        );

    // 2. Mark order completed
    await dao.updateInvestigationStatus(order.id, 'result_received');
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().toUtc().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _CultureResult {
  const _CultureResult({
    required this.organism,
    required this.sensitive,
    required this.resistant,
  });

  final String organism;
  final List<String> sensitive;
  final List<String> resistant;
}

class _CultureDialog extends StatefulWidget {
  const _CultureDialog();

  @override
  State<_CultureDialog> createState() => _CultureDialogState();
}

class _CultureDialogState extends State<_CultureDialog> {
  final _organisms = const [
    'No growth / Sterile',
    'Escherichia coli',
    'Klebsiella pneumoniae',
    'Pseudomonas aeruginosa',
    'Staphylococcus aureus (MRSA)',
    'Staphylococcus aureus (MSSA)',
    'Acinetobacter baumannii',
    'Enterococcus faecalis',
    'Proteus mirabilis',
    'Other',
  ];

  final _antibiotics = const [
    'Amikacin',
    'Ceftriaxone',
    'Cefoperazone-Sulbactam',
    'Ciprofloxacin',
    'Colistin',
    'Gentamicin',
    'Levofloxacin',
    'Linezolid',
    'Meropenem',
    'Piperacillin-Tazobactam',
    'Tigecycline',
    'Vancomycin',
  ];

  final _customOrganismCtrl = TextEditingController();
  final _customAntibioticCtrl = TextEditingController();

  String _organism = 'Escherichia coli';
  final _sensitive = <String>{};
  final _resistant = <String>{};

  @override
  void dispose() {
    _customOrganismCtrl.dispose();
    _customAntibioticCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Culture Antibiogram Entry'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _organism,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Organism Isolated',
                  prefixIcon: Icon(Icons.bug_report_outlined),
                  isDense: true,
                ),
                items: [
                  for (final org in _organisms)
                    DropdownMenuItem(value: org, child: Text(org)),
                ],
                onChanged: (val) =>
                    setState(() => _organism = val ?? _organism),
              ),
              if (_organism == 'Other') ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _customOrganismCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Specify Organism Name',
                    isDense: true,
                  ),
                ),
              ],
              const SizedBox(height: 16),

              const Text(
                'Antimicrobial Susceptibility Profile',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 4),
              const Text(
                'Select green for Sensitive (S), red for Resistant (R):',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 10),

              // Chip Matrix
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final abx in _antibiotics) _susceptibilityChip(abx),
                ],
              ),
              const SizedBox(height: 14),

              // Custom Antibiotic Addition
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customAntibioticCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Add Unlisted Antibiotic',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      final name = _customAntibioticCtrl.text.trim();
                      if (name.isNotEmpty) {
                        setState(() {
                          _sensitive.add(name);
                          _customAntibioticCtrl.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final finalOrg = _organism == 'Other'
                ? _customOrganismCtrl.text.trim()
                : _organism;
            if (finalOrg.isEmpty) return;

            Navigator.pop(
              context,
              _CultureResult(
                organism: finalOrg,
                sensitive: _sensitive.toList(),
                resistant: _resistant.toList(),
              ),
            );
          },
          child: const Text('Save Antibiogram'),
        ),
      ],
    );
  }

  Widget _susceptibilityChip(String abx) {
    final isS = _sensitive.contains(abx);
    final isR = _resistant.contains(abx);

    Color? bg;
    Color? fg;
    String badge = '';

    if (isS) {
      bg = Colors.green.shade100;
      fg = Colors.green.shade900;
      badge = ' (S)';
    } else if (isR) {
      bg = Colors.red.shade100;
      fg = Colors.red.shade900;
      badge = ' (R)';
    }

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        setState(() {
          if (!isS && !isR) {
            _sensitive.add(abx);
          } else if (isS) {
            _sensitive.remove(abx);
            _resistant.add(abx);
          } else {
            _resistant.remove(abx);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg ?? Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isS
                ? Colors.green
                : isR
                ? Colors.red
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          '$abx$badge',
          style: TextStyle(
            fontSize: 12,
            fontWeight: (isS || isR) ? FontWeight.bold : FontWeight.normal,
            color: fg ?? Colors.black87,
          ),
        ),
      ),
    );
  }
}
