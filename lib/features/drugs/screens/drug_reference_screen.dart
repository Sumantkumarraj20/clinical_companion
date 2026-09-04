import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';

class DrugReferenceScreen extends ConsumerStatefulWidget {
  const DrugReferenceScreen({super.key});

  @override
  ConsumerState<DrugReferenceScreen> createState() =>
      _DrugReferenceScreenState();
}

class _DrugReferenceScreenState extends ConsumerState<DrugReferenceScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  String _term = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 150),
      () => setState(() => _term = value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stream = ref.watch(pharmacopeiaDaoProvider).searchDrugs(_term);
    return Scaffold(
      appBar: AppBar(title: const Text('Drug reference')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDrugEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('Add/Edit Drug'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _search,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Search generic or brand name',
                suffixIcon: Icon(Icons.medication),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Drug>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Unable to load drugs: ${snapshot.error}'),
                  );
                }
                final drugs = snapshot.data ?? const <Drug>[];
                if (drugs.isEmpty) {
                  return const Center(
                    child: Text('No matching drugs in the local reference'),
                  );
                }
                return ListView.builder(
                  itemCount: drugs.length,
                  itemBuilder: (context, index) {
                    final drug = drugs[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.medication_outlined),
                      ),
                      title: Text(drug.brandName ?? drug.genericName),
                      subtitle: Text(
                        [
                              drug.genericName,
                              drug.chemicalClass,
                              drug.uses,
                              drug.sideEffects,
                              drug.strength,
                              drug.dosageForm,
                              drug.route,
                            ]
                            .whereType<String>()
                            .where((value) => value.isNotEmpty)
                            .join(' · '),
                      ),
                      trailing: IconButton(
                        tooltip: drug.isTrusted
                            ? 'Remove trusted mark'
                            : 'Mark trusted',
                        icon: Icon(
                          drug.isTrusted ? Icons.star : Icons.star_border,
                          color: drug.isTrusted ? Colors.amber : null,
                        ),
                        onPressed: () => ref
                            .read(pharmacopeiaDaoProvider)
                            .markTrusted(drug.id, !drug.isTrusted),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDrugEditor(BuildContext context) async {
    final generic = TextEditingController();
    final brand = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add drug'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: generic,
              decoration: const InputDecoration(labelText: 'Generic name'),
            ),
            TextField(
              controller: brand,
              decoration: const InputDecoration(labelText: 'Brand name'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (generic.text.trim().isEmpty) return;
              await ref
                  .read(pharmacopeiaDaoProvider)
                  .insertDrug(
                    DrugsCompanion.insert(
                      ownerId: ref.read(currentOwnerIdProvider),
                      genericName: generic.text.trim(),
                      brandName: Value(
                        brand.text.trim().isEmpty ? null : brand.text.trim(),
                      ),
                    ),
                  );
              if (dialogContext.mounted) Navigator.pop(dialogContext, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    generic.dispose();
    brand.dispose();
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Drug saved locally.')));
    }
  }
}
