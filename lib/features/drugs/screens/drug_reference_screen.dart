import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/daos/pharmacopeia_dao.dart';
import '../../../core/database/local_database.dart';
import '../../../core/models/clinical_drug_selection.dart';
import '../../../core/providers/app_providers.dart';

class DrugReferenceScreen extends ConsumerStatefulWidget {
  const DrugReferenceScreen({super.key});

  @override
  ConsumerState<DrugReferenceScreen> createState() =>
      _DrugReferenceScreenState();
}

class _DrugReferenceScreenState extends ConsumerState<DrugReferenceScreen>
    with SingleTickerProviderStateMixin {
  final _search = TextEditingController();
  final _cloudSearch = TextEditingController();
  Timer? _debounce;
  Timer? _cloudDebounce;
  String _term = '';
  String _cloudTerm = '';
  late final TabController _tab = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _debounce?.cancel();
    _cloudDebounce?.cancel();
    _search.dispose();
    _cloudSearch.dispose();
    _tab.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 200),
      () => setState(() => _term = value),
    );
  }

  void _onCloudSearchChanged(String value) {
    _cloudDebounce?.cancel();
    _cloudDebounce = Timer(
      const Duration(milliseconds: 200),
      () => setState(() => _cloudTerm = value),
    );
  }

  bool _isCatalogSyncing = false;

  /// Manual OTA catalog pull (mirrors the silent nightly sync that runs at
  /// app startup). Network + Drift work is fully async — the UI stays live.
  Future<void> _triggerCatalogSync() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isCatalogSyncing = true);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Syncing latest clinical catalog...'),
        duration: Duration(seconds: 2),
      ),
    );
    try {
      await ref
          .read(catalogSyncProvider)
          .syncCatalogFromCloud(catalogScriptUrl);
      messenger.showSnackBar(
        const SnackBar(content: Text('Catalog up to date.')),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Catalog sync failed: $error')),
      );
    } finally {
      if (mounted) setState(() => _isCatalogSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dao = ref.watch(pharmacopeiaDaoProvider);
    final clinicalFuture = dao.searchClinicalDrugs(_term);
    final stream = dao.searchDrugsPaged(query: _term);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Drug Reference & Editor'),
          actions: [
            IconButton(
              icon: _isCatalogSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              tooltip: 'Sync latest clinical catalog',
              onPressed: _isCatalogSyncing ? null : _triggerCatalogSync,
            ),
          ],
          bottom: TabBar(
            controller: _tab,
            tabs: const [
              Tab(
                icon: Icon(Icons.medical_services_outlined),
                text: 'Clinical Reference',
              ),
              Tab(icon: Icon(Icons.edit_note), text: 'My Catalog'),
              Tab(icon: Icon(Icons.cloud_outlined), text: 'Cloud Catalog'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tab,
          children: [
            _buildClinicalTab(clinicalFuture),
            _buildCatalogTab(stream),
            _buildCloudTab(dao),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // TAB 1 — CLINICAL REFERENCE (POMR-integrated master table)
  // =========================================================================
  Widget _buildClinicalTab(Future<List<ClinicalDrugSelection>> future) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _search,
            onChanged: _onSearchChanged,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Search molecule, brand, form, or clinical problem',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<ClinicalDrugSelection>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'ClinicalDrugs error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final drugs = snapshot.data!;
              if (drugs.isEmpty) {
                return const Center(
                  child: Text(
                    'No clinical drugs found.\n'
                    'Sync the drug catalog from the toolbar, or search the '
                    'offline master list.',
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: drugs.length,
                itemBuilder: (context, index) =>
                    _ClinicalDrugCard(drug: drugs[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // TAB 2 — MY CATALOG (user's own editable drug list)
  // =========================================================================
  Widget _buildCatalogTab(Stream<List<Drug>> stream) {
    return Column(
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

  // =========================================================================
  // TAB 3 — CLOUD CATALOG (nightly OTA merge, Sprint 7)
  // =========================================================================

  /// Streams the rows merged by [PharmacopeiaDao.upsertOtaCatalog]; the
  /// catalog is read-only for the clinician and never touches patient tables.
  Widget _buildCloudTab(PharmacopeiaDao dao) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _cloudSearch,
            onChanged: _onCloudSearchChanged,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Search synced drug, ID, or pharmacological class',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<ActiveIngredient>>(
            stream: dao.watchOtaIngredients(query: _cloudTerm),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Cloud catalog error: ${snapshot.error}'),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = snapshot.data!;
              if (items.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Cloud catalog is empty.\n'
                      'Tap the sync icon above to fetch the nightly sheet.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final subtitle = [
                    if (item.pharmacologicalClass != null)
                      item.pharmacologicalClass!,
                    if (item.primaryRoutes != null)
                      'Routes: ${item.primaryRoutes}',
                  ].join('\n');
                  return ListTile(
                    leading: const Icon(Icons.medication_outlined),
                    title: Text(item.genericName),
                    subtitle: subtitle.isEmpty ? null : Text(subtitle),
                    trailing: Text(
                      item.moleculeCode ?? item.ingredientId,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    onTap: () => _showCloudDrugDetail(item),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// One synced molecule in full: pharmacology + safety fields from
  /// `clinical_core`, then the dose matrix / formulation / brand rows joined
  /// through the derived molecule code.
  void _showCloudDrugDetail(ActiveIngredient ingredient) {
    final dao = ref.read(pharmacopeiaDaoProvider);
    final code = ingredient.moleculeCode;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(ingredient.genericName),
        content: SizedBox(
          width: 460,
          child: ListView(
            shrinkWrap: true,
            children: [
              _sectionHeader(
                dialogContext,
                Icons.biotech_outlined,
                'Pharmacology',
                Colors.teal,
              ),
              _cloudField('Class', ingredient.pharmacologicalClass),
              _cloudField('Mechanism', ingredient.mechanismOfAction),
              _cloudField('Primary routes', ingredient.primaryRoutes),
              _sectionHeader(
                dialogContext,
                Icons.warning_amber_outlined,
                'Safety',
                Colors.orange,
              ),
              _cloudField('Renal', ingredient.renalAdjustment),
              _cloudField('Hepatic', ingredient.hepaticRisk),
              _cloudField('Pregnancy', ingredient.pregnancyCategory),
              _cloudField('Critical alerts', ingredient.criticalAlerts),
              if (code != null) ...[
                _cloudFutureSection<Indication>(
                  future: dao.indicationsForMolecule(code),
                  icon: Icons.playlist_add_check_circle_outlined,
                  color: Colors.indigo,
                  label: 'Indications & dosing',
                  titleOf: (row) => row.clinicalIndication ?? row.indicationId,
                  subtitleOf: (row) => [
                    if (row.patientCohort != null) row.patientCohort!,
                    if (row.standardRegimen != null) row.standardRegimen!,
                    if (row.routeFrequency != null) row.routeFrequency!,
                    if (row.typicalDuration != null)
                      'Duration: ${row.typicalDuration}',
                    if (row.evidenceLevel != null)
                      'Evidence: ${row.evidenceLevel}',
                  ].join(' · '),
                ),
                _cloudFutureSection<Formulation>(
                  future: dao.formulationsForMolecule(code),
                  icon: Icons.science_outlined,
                  color: Colors.deepPurple,
                  label: 'Formulations',
                  titleOf: (row) => row.dosageFormStrength ?? row.formulationId,
                  subtitleOf: (row) => [
                    if (row.administrationRoute != null)
                      row.administrationRoute!,
                    if (row.storageStability != null) row.storageStability!,
                  ].join(' · '),
                ),
                _cloudFutureSection<Brand>(
                  future: dao.brandsForMolecule(code),
                  icon: Icons.sell_outlined,
                  color: Colors.blueGrey,
                  label: 'Brands',
                  titleOf: (row) => row.brandName,
                  subtitleOf: (row) => [
                    if (row.manufacturer != null) row.manufacturer!,
                    if (row.trustTier != null) 'Tier: ${row.trustTier}',
                    if (row.mrp != null) 'MRP ₹${row.mrp!.toStringAsFixed(2)}',
                  ].join(' · '),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Label + value row that disappears when the sheet cell was empty/NA.
  Widget _cloudField(String label, String? value) {
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(value, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  /// Read-only section backed by one of the OTA child-table futures.
  Widget _cloudFutureSection<T>({
    required Future<List<T>> future,
    required IconData icon,
    required Color color,
    required String label,
    required String Function(T row) titleOf,
    String Function(T row)? subtitleOf,
  }) {
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snapshot) {
        final rows = snapshot.data ?? <T>[];
        if (rows.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(context, icon, '$label (${rows.length})', color),
              const SizedBox(height: 4),
              for (final row in rows)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titleOf(row),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (subtitleOf != null && subtitleOf(row).isNotEmpty)
                        Text(
                          subtitleOf(row),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Section heading used by the cloud-catalog detail dialogs (copy of
  /// the card's helper — the two widgets are separate classes).
  Widget _sectionHeader(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// CLINICAL DRUG CARD — renders the POMR-integrated master row.
// JSON-encoded arrays are safely decoded via PharmacopeiaDao.decodeStringList
// and displayed as distinct ActionChips.
// ===========================================================================
class _ClinicalDrugCard extends StatelessWidget {
  const _ClinicalDrugCard({required this.drug});

  final ClinicalDrugSelection drug;

  static const _problemColor = Color(0xFF1565C0);
  static const _sideEffectColor = Color(0xFFC62828);

  @override
  Widget build(BuildContext context) {
    final master = drug.master;
    final problems = PharmacopeiaDao.decodeStringList(
      master?.problemIndications,
    );
    final sideEffects = PharmacopeiaDao.decodeStringList(
      master?.prioritizedSideEffects,
    );
    // available_forms / top_brands are JSON arrays in the bundled catalog, so
    // they go through the model's tolerant decoder instead of a naive split.
    final forms = drug.availableForms;
    final brands = drug.brandNames;
    final theme = Theme.of(context);
    final dose = drug.standardDosage;
    final route = drug.route;
    final guidelines = drug.administrationGuidelines;
    final pearls = master?.prescribingPearls;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    drug.displayLabel,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (drug.hasClinicalDetail)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(
                      Icons.verified_outlined,
                      size: 18,
                      color: Colors.teal,
                    ),
                  ),
                if ((master?.usageFrequency ?? 0) > 0)
                  Chip(
                    avatar: const Icon(Icons.trending_up, size: 16),
                    label: Text('${master!.usageFrequency}'),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            if (problems.isNotEmpty) ...[
              const SizedBox(height: 12),
              _sectionHeader(
                context,
                Icons.coronavirus_outlined,
                'Indicated For',
                _problemColor,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: problems
                    .map(
                      (p) => ActionChip(
                        label: Text(p, style: const TextStyle(fontSize: 12)),
                        backgroundColor: _problemColor.withValues(alpha: 0.08),
                        side: const BorderSide(color: _problemColor),
                        onPressed: () => _showProblemDrugs(context, p),
                      ),
                    )
                    .toList(),
              ),
            ],

            if (sideEffects.isNotEmpty) ...[
              const SizedBox(height: 12),
              _sectionHeader(
                context,
                Icons.warning_amber_outlined,
                'Watch For (prioritized)',
                _sideEffectColor,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: sideEffects
                    .map(
                      (s) => ActionChip(
                        label: Text(s, style: const TextStyle(fontSize: 12)),
                        backgroundColor: _sideEffectColor.withValues(
                          alpha: 0.08,
                        ),
                        side: const BorderSide(color: _sideEffectColor),
                        onPressed: () => _showProblemDrugs(context, s),
                      ),
                    )
                    .toList(),
              ),
            ],
            if (dose != null || route != null) ...[
              const SizedBox(height: 12),
              _sectionHeader(
                context,
                Icons.receipt_long_outlined,
                'Standard Dosing',
                Colors.teal,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (dose != null)
                    Chip(
                      label: Text(dose, style: const TextStyle(fontSize: 12)),
                      avatar: const Icon(Icons.science_outlined, size: 16),
                      visualDensity: VisualDensity.compact,
                    ),
                  if (route != null)
                    Chip(
                      label: Text(route, style: const TextStyle(fontSize: 12)),
                      avatar: const Icon(Icons.route_outlined, size: 16),
                      visualDensity: VisualDensity.compact,
                    ),
                  if (drug.duration != null)
                    Chip(
                      label: Text(
                        drug.duration!,
                        style: const TextStyle(fontSize: 12),
                      ),
                      avatar: const Icon(Icons.schedule, size: 16),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
            if (guidelines != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.rule_outlined,
                      size: 18,
                      color: Colors.teal,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(guidelines, style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
            ],
            if (pearls?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.tips_and_updates_outlined,
                      size: 18,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(pearls!, style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
            ],
            if (forms.isNotEmpty || brands.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...forms.map(
                    (f) => Chip(
                      label: Text(f, style: const TextStyle(fontSize: 12)),
                      avatar: const Icon(Icons.medication, size: 16),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  ...brands.map(
                    (b) => Chip(
                      label: Text(b, style: const TextStyle(fontSize: 12)),
                      avatar: const Icon(Icons.sell_outlined, size: 16),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Tapping a problem chip performs a reverse POMR lookup: which other
  /// molecules also treat this problem.
  void _showProblemDrugs(BuildContext context, String problem) {
    final dao = ProviderScope.containerOf(
      context,
    ).read(pharmacopeiaDaoProvider);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(problem),
        content: SizedBox(
          width: 360,
          child: FutureBuilder<List<ClinicalDrug>>(
            future: dao.getDrugsForProblem(problem),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final drugs = snapshot.data!;
              if (drugs.isEmpty) {
                return const Text('No linked molecules found.');
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: drugs.length,
                itemBuilder: (context, index) => ListTile(
                  dense: true,
                  leading: Text('${index + 1}'),
                  title: Text(drugs[index].genericMolecule),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
