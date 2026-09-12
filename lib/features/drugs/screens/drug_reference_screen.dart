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
      const Duration(milliseconds: 200),
      () => setState(() => _term = value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stream = ref
        .watch(pharmacopeiaDaoProvider)
        .searchDrugsPaged(query: _term);

    return Scaffold(
      appBar: AppBar(title: const Text('Drug Reference & Editor')),
      // Kept away from the global bottom-right Smart Camera FAB.
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDrugEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('New Drug'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _search,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                labelText: 'Search generic, brand, uses, or class',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _search.clear();
                    _onSearchChanged('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Drug>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Database Schema Error: \n${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final drugs = snapshot.data!;
                if (drugs.isEmpty) {
                  return const Center(child: Text('No matching drugs found.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: drugs.length,
                  itemBuilder: (context, index) {
                    final drug = drugs[index];
                    return _buildDrugCard(drug);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrugCard(Drug drug) {
    final title = (drug.brandName?.isNotEmpty == true)
        ? drug.brandName!
        : drug.genericName;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDrugEditor(context, existingDrug: drug),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: drug.isTrusted
                        ? 'Trusted (Prioritize in search)'
                        : 'Mark Trusted',
                    icon: Icon(
                      drug.isTrusted ? Icons.star : Icons.star_border,
                      color: drug.isTrusted
                          ? Colors.amber
                          : Colors.grey.shade400,
                    ),
                    onPressed: () => ref
                        .read(pharmacopeiaDaoProvider)
                        .markTrusted(drug.id, !drug.isTrusted),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildFieldRow('Generic Name', drug.genericName, true),
              _buildFieldRow(
                'Category/Class',
                drug.category ?? drug.chemicalClass,
                false,
              ),
              _buildFieldRow(
                'Form & Strength',
                '${drug.dosageForm ?? ''} ${drug.strength ?? ''}'.trim(),
                false,
              ),
              _buildFieldRow('Route', drug.route, false),
              _buildFieldRow('Uses', drug.uses, false),
              _buildFieldRow('Side Effects', drug.sideEffects, false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldRow(String label, String? value, bool isRequired) {
    final isMissing = value == null || value.trim().isEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              isMissing ? '✏️ Tap to add ${label.toLowerCase()}' : value,
              style: TextStyle(
                fontSize: 13,
                color: isMissing ? Colors.blueGrey.shade300 : Colors.black87,
                fontStyle: isMissing ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDrugEditor(
    BuildContext context, {
    Drug? existingDrug,
  }) async {
    final generic = TextEditingController(text: existingDrug?.genericName);
    final brand = TextEditingController(text: existingDrug?.brandName);
    final strength = TextEditingController(text: existingDrug?.strength);
    final dosageForm = TextEditingController(text: existingDrug?.dosageForm);
    final route = TextEditingController(text: existingDrug?.route);
    final category = TextEditingController(
      text: existingDrug?.category ?? existingDrug?.chemicalClass,
    );
    final uses = TextEditingController(text: existingDrug?.uses);
    final sideEffects = TextEditingController(text: existingDrug?.sideEffects);
    final notes = TextEditingController(text: existingDrug?.customNotes);

    final isNew = existingDrug == null;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Column(
            children: [
              Text(
                isNew ? 'Create New Drug' : 'Edit Drug Profile',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: generic,
                        decoration: const InputDecoration(
                          labelText: 'Generic Name (Required)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: brand,
                        decoration: const InputDecoration(
                          labelText: 'Brand Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: strength,
                              decoration: const InputDecoration(
                                labelText: 'Strength (e.g. 500mg)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: dosageForm,
                              decoration: const InputDecoration(
                                labelText: 'Form (e.g. Tab, Inj)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: route,
                        decoration: const InputDecoration(
                          labelText: 'Route (e.g. PO, IV, SC)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: category,
                        decoration: const InputDecoration(
                          labelText: 'Clinical Category / Class',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: uses,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Primary Uses',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: sideEffects,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Key Side Effects',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: notes,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Custom Clinical Notes',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () async {
                      if (generic.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Generic name is required!'),
                          ),
                        );
                        return;
                      }

                      final dao = ref.read(pharmacopeiaDaoProvider);
                      String? safeNull(String text) =>
                          text.trim().isEmpty ? null : text.trim();


                      if (isNew) {
                        await dao.insertDrug(
                          DrugsCompanion.insert(
                            ownerId: ref.read(currentOwnerIdProvider),
                            genericName: generic.text.trim(),
                            brandName: Value(safeNull(brand.text)),
                            strength: Value(safeNull(strength.text)),
                            dosageForm: Value(safeNull(dosageForm.text)),
                            route: Value(safeNull(route.text)),
                            category: Value(safeNull(category.text)),
                            uses: Value(safeNull(uses.text)),
                            sideEffects: Value(safeNull(sideEffects.text)),
                            customNotes: Value(safeNull(notes.text)),
                            updatedAt: Value(DateTime.now().toUtc()),
                          ),
                        );
                      } else {
                        await dao.updateDrug(
                          existingDrug.copyWith(
                            genericName: generic.text.trim(),
                            brandName: Value(safeNull(brand.text)),
                            strength: Value(safeNull(strength.text)),
                            dosageForm: Value(safeNull(dosageForm.text)),
                            route: Value(safeNull(route.text)),
                            category: Value(safeNull(category.text)),
                            uses: Value(safeNull(uses.text)),
                            sideEffects: Value(safeNull(sideEffects.text)),
                            customNotes: Value(safeNull(notes.text)),
                            updatedAt: DateTime.now().toUtc(),
                          ),
                        );
                      }
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext, true);
                      }
                    },
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isNew
                ? 'New drug added to local catalog.'
                : 'Drug profile updated successfully.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
