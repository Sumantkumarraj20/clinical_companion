import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/smart_catalog_autocomplete.dart';
import '../../../core/widgets/smart_drug_autocomplete.dart';
import '../providers/staged_orders_provider.dart';
import '../../../core/cds/decision_support_engine.dart';

/// Shared Orders & Plan tray bound to [stagedOrdersProvider].
///
/// The drug catalog proposes a standard dose, route and administration
/// guidance; every field is rendered as an editable control so the clinician
/// approves — rather than retypes — the suggestion before finalizing. Nothing
/// here blocks the consult: suggestions can be overridden or deleted.
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
    final notifier = ref.read(stagedOrdersProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Orders & Plan (${orders.length})',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (orders.isNotEmpty)
                  TextButton(
                    onPressed: notifier.clear,
                    child: const Text('Clear'),
                  ),
              ],
            ),
            if (orders.isEmpty)
              const Text(
                'No staged orders yet.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              )
            else
              for (var i = 0; i < orders.length; i++)
                _OrderRow(
                  key: ValueKey('$i-${orders[i].label}'),
                  order: orders[i],
                  notifier: notifier,
                ),
            const SizedBox(height: 8),
            SmartDrugAutocomplete(
              controller: medicationController,
              labelText: 'Medication (drug catalog)',
              hintText: 'Type 3+ letters — e.g. amox',
              prefixIcon: Icons.medication_outlined,
              onSelected: (selection) {
                notifier.addMedication(selection);
                medicationController.clear();
              },
            ),
            const SizedBox(height: 8),
            SmartCatalogAutocomplete(
              category: 'medication',
              controller: procedureController,
              labelText: 'Previously used drug / test',
              hintText: 'Type 2+ letters',
              prefixIcon: Icons.history_outlined,
              onSelected: (term) {
                notifier.addManual(term, kind: OrderProposalKind.medication);
                procedureController.clear();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// One staged order. Medications get the full editable prescription row;
/// everything else stays a compact chip.
class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order, required this.notifier, super.key});

  final PendingOrder order;
  final StagedOrdersNotifier notifier;

  @override
  Widget build(BuildContext context) {
    if (!order.isMedication) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: InputChip(
          label: Text(order.label),
          onDeleted: () => notifier.removeByLabel(order.label),
        ),
      );
    }

    void edit(void Function(PendingOrder) change) =>
        notifier.updateAt(notifier.indexOf(order), change);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.medication_outlined,
                  size: 18,
                  color: Colors.teal,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order.prescriptionName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                if (order.source == 'catalog')
                  const Tooltip(
                    message:
                        'Suggested by the drug catalog — review before save',
                    child: Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: Colors.teal,
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                  tooltip: 'Remove',
                  onPressed: () => notifier.removeByLabel(order.label),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _field(
              context,
              'Dose / strength',
              initial: order.dose,
              hint: 'e.g. 500 mg twice daily',
              onChanged: (value) => edit((o) => o..dose = value),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _field(
                    context,
                    'Route',
                    initial: order.route,
                    hint: 'Oral / IV',
                    onChanged: (value) => edit((o) => o..route = value),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _field(
                    context,
                    'Frequency',
                    initial: order.frequency,
                    hint: 'TID / q12h',
                    onChanged: (value) => edit((o) => o..frequency = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _field(
              context,
              'Special instructions',
              initial: order.specialInstructions,
              hint: 'Post meals, check renal dose…',
              onChanged: (value) => edit((o) => o..specialInstructions = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    BuildContext context,
    String label, {
    required String? initial,
    required ValueChanged<String> onChanged,
    String? hint,
  }) {
    final suggested = initial != null && initial.trim().isNotEmpty;
    return TextFormField(
      initialValue: initial ?? '',
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        // A catalog-suggested value is tinted, so a pre-filled dose is visibly
        // distinct from one the clinician typed.
        filled: suggested,
        fillColor: suggested ? Colors.teal.withValues(alpha: 0.06) : null,
      ),
    );
  }
}
