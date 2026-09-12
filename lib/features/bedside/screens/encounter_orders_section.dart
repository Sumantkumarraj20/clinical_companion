import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/smart_catalog_autocomplete.dart';

/// Shared Orders & Plan tray bound to stagedOrdersProvider.
class OrdersAndPlanSection extends ConsumerWidget {
  const OrdersAndPlanSection({
    required this.medicationController,
    required this.procedureController,
    super.key,
  });
  final TextEditingController medicationController;
  final TextEditingController procedureController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(stagedOrdersProvider);
    final dao = ref.watch(clinicalDaoProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Orders & Plan (${orders.length})',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (orders.isNotEmpty)
                  TextButton(
                      onPressed: () =>
                          ref.read(stagedOrdersProvider.notifier).clear(),
                      child: const Text('Clear')),
              ],
            ),
            if (orders.isEmpty)
              const Text('No staged orders yet.',
                  style: TextStyle(fontSize: 12, color: Colors.grey))
            else
              Wrap(
                spacing: 8,
                children: [
                  for (var i = 0; i < orders.length; i++)
                    InputChip(
                      label: Text(orders[i].label),
                      onDeleted: () => ref
                          .read(stagedOrdersProvider.notifier)
                          .removeAt(i),
                    ),
                ],
              ),
            const SizedBox(height: 8),
            SmartCatalogAutocomplete(
              category: 'medication',
              controller: medicationController,
              labelText: 'Medication (learned + drug_master)',
              hintText: 'Type 2+ letters',
              prefixIcon: Icons.medication_outlined,
              onSelected: (term) {
                ref.read(stagedOrdersProvider.notifier).addManual(term);
                medicationController.clear();
              },
            ),
            const SizedBox(height: 8),
            SmartAutocomplete<String>(
              category: 'procedure',
              controller: procedureController,
              labelText: 'Procedure / PM-JAY package',
              hintText: 'Type 2+ letters',
              prefixIcon: Icons.medical_services_outlined,
              displayString: (s) => s,
              optionsLoader: (query) async {
                final rows = await dao.searchProcedures(query).first;
                return [
                  for (final p in rows)
                    '${p.procedureName} [${p.procedureCode}]',
                ];
              },
              onSelected: (term) {
                ref.read(stagedOrdersProvider.notifier).addManual(term);
                procedureController.clear();
              },
            ),
          ],
        ),
      ),
    );
  }
}
