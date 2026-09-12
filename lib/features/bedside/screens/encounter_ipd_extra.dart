import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/database/local_database.dart';

class AddProblemField extends ConsumerStatefulWidget {
  const AddProblemField({required this.patientId, super.key});
  final String patientId;
  @override
  ConsumerState<AddProblemField> createState() => _AddProblemFieldState();
}

class _AddProblemFieldState extends ConsumerState<AddProblemField> {
  final _controller = TextEditingController();
  bool _saving = false;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: '+ Add New Problem',
              isDense: true,
              prefixIcon: Icon(Icons.add_circle_outline, size: 20),
            ),
            onSubmitted: (_) => _add(),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
            onPressed: _saving ? null : _add, child: const Text('Add')),
      ],
    );
  }

  Future<void> _add() async {
    final term = _controller.text.trim();
    if (term.isEmpty) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(clinicalDaoProvider)
          .addPatientProblem(patientId: widget.patientId, problemName: term);
      await ref
          .read(clinicalDaoProvider)
          .recordCatalogUsage(category: 'diagnosis', term: term);
      _controller.clear();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

/// IPD continuous orders review.
class IpdContinuousOrders extends ConsumerWidget {
  const IpdContinuousOrders({required this.patientId, super.key});
  final String patientId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.watch(clinicalDaoProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Review Continuous Orders',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const Text('Stop/discontinue active meds.',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            StreamBuilder<List<PrescriptionOrder>>(
              stream: dao.watchActivePrescriptions(patientId),
              builder: (context, snapshot) {
                final orders = snapshot.data ?? const [];
                if (orders.isEmpty) {
                  return const Text('No active continuous medications.',
                      style: TextStyle(fontSize: 12, color: Colors.grey));
                }
                return Column(
                  children: [
                    for (final order in orders)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(order.drugName.trim().isEmpty
                            ? 'Not recorded'
                            : order.drugName),
                        subtitle: Text(
                            '${order.doseStrength ?? ''} ${order.frequency ?? ''}'
                                    .trim()
                                    .isEmpty
                                ? 'No dose recorded'
                                : '${order.doseStrength ?? ''} ${order.frequency ?? ''}'
                                    .trim(),
                            style: const TextStyle(fontSize: 12)),
                        trailing: TextButton(
                          onPressed: () => ref
                              .read(clinicalDaoProvider)
                              .stopPrescriptionOrder(order.id),
                          child: const Text('Stop'),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
