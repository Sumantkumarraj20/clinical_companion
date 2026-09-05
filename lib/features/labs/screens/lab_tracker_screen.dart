import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/daos/clinical_dao.dart';
import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/shimmer_loading.dart';

class LabTrackerScreen extends ConsumerWidget {
  const LabTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingInvestigationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Investigation tracker')),
      body: pending.when(
        loading: () => const ShimmerLoading(),
        error: (error, stack) =>
            Center(child: Text('Unable to load investigations: $error')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No pending investigations'));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
            itemCount: items.length,
            itemBuilder: (context, index) =>
                _InvestigationTile(item: items[index]),
          );
        },
      ),
    );
  }
}

class _InvestigationTile extends ConsumerWidget {
  const _InvestigationTile({required this.item});

  final PendingInvestigation item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investigation = item.investigation;
    final isSent = investigation.status == 'sample_sent';
    return Dismissible(
      key: ValueKey(investigation.id),
      direction: DismissDirection.horizontal,
      background: _SwipeBackground(
        color: Colors.green,
        icon: Icons.check_circle,
        label: 'Result received',
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _SwipeBackground(
        color: Colors.blue,
        icon: Icons.local_shipping,
        label: 'Sample sent',
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        final status = direction == DismissDirection.startToEnd
            ? 'result_received'
            : 'sample_sent';
        try {
          await ref
              .read(clinicalDaoProvider)
              .updateInvestigationStatus(investigation.id, status);
          return true;
        } catch (error) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not update investigation: $error')),
            );
          }
          return false;
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 8,
          ),
          title: Text(
            item.patient.fullName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${investigation.testName} · ${item.patient.hospitalRegNo}\n${isSent ? 'Sample sent' : 'Pending sample'}',
          ),
          isThreeLine: true,
          trailing: IconButton(
            tooltip: 'Enter culture result',
            onPressed: () => _showCultureDialog(context, ref, investigation),
            icon: const Icon(Icons.biotech_outlined),
          ),
        ),
      ),
    );
  }

  Future<void> _showCultureDialog(
    BuildContext context,
    WidgetRef ref,
    Investigation investigation,
  ) async {
    final result = await showDialog<_CultureResult>(
      context: context,
      builder: (context) => const _CultureDialog(),
    );
    if (result == null) return;
    final now = DateTime.now().toUtc();
    try {
      await ref
          .read(clinicalDaoProvider)
          .updateInvestigation(
            investigation.copyWith(
              organism: Value(result.organism),
              sensitiveAntibiotics: jsonEncode(result.sensitive),
              resistantAntibiotics: jsonEncode(result.resistant),
              status: 'result_received',
              resultReceivedAt: Value(now),
              updatedAt: now,
            ),
          );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save culture result: $error')),
        );
      }
    }
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.color,
    required this.icon,
    required this.label,
    required this.alignment,
  });

  final Color color;
  final IconData icon;
  final String label;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
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
    'E. coli',
    'Klebsiella pneumoniae',
    'Pseudomonas aeruginosa',
    'Staphylococcus aureus',
    'Other',
  ];
  final _antibiotics = const [
    'Amikacin',
    'Ceftriaxone',
    'Ciprofloxacin',
    'Gentamicin',
    'Meropenem',
    'Piperacillin-tazobactam',
    'Vancomycin',
  ];
  final _other = TextEditingController();
  String? _organism;
  final _sensitive = <String>{};
  final _resistant = <String>{};

  @override
  void dispose() {
    _other.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Culture & sensitivity'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _organism,
              decoration: const InputDecoration(labelText: 'Organism'),
              items: [
                for (final value in _organisms)
                  DropdownMenuItem(value: value, child: Text(value)),
              ],
              onChanged: (value) => setState(() => _organism = value),
            ),
            if (_organism == 'Other') ...[
              const SizedBox(height: 10),
              TextField(
                controller: _other,
                decoration: const InputDecoration(labelText: 'Organism name'),
              ),
            ],
            const SizedBox(height: 14),
            const Text('Sensitive antibiotics'),
            _antibioticChips(_sensitive, _resistant),
            const SizedBox(height: 10),
            const Text('Resistant antibiotics'),
            _antibioticChips(_resistant, _sensitive),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save result')),
      ],
    );
  }

  Widget _antibioticChips(Set<String> selected, Set<String> other) {
    return Wrap(
      spacing: 4,
      children: [
        for (final antibiotic in _antibiotics)
          FilterChip(
            label: Text(antibiotic),
            selected: selected.contains(antibiotic),
            onSelected: (value) => setState(() {
              if (value) {
                other.remove(antibiotic);
                selected.add(antibiotic);
              } else {
                selected.remove(antibiotic);
              }
            }),
          ),
      ],
    );
  }

  void _submit() {
    final organism = _organism == 'Other' ? _other.text.trim() : _organism;
    if (organism == null || organism.isEmpty) return;
    Navigator.pop(
      context,
      _CultureResult(
        organism: organism,
        sensitive: _sensitive.toList(),
        resistant: _resistant.toList(),
      ),
    );
  }
}
