import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/daos/clinical_dao.dart';
import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/datetime_utils.dart';
import '../widgets/cohort_tagger.dart';

class PatientRegistryScreen extends ConsumerStatefulWidget {
  const PatientRegistryScreen({this.selectForOpd = false, super.key});

  final bool selectForOpd;

  @override
  ConsumerState<PatientRegistryScreen> createState() =>
      _PatientRegistryScreenState();
}

class _PatientRegistryScreenState extends ConsumerState<PatientRegistryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  /// Cohort tags the clinician tapped to narrow the whole registry.
  final Set<String> _selectedCohorts = {};

  /// Cohort tags per patient id, loaded asynchronously because deriving them
  /// needs the patient's problems and procedures.
  Map<String, List<CohortTag>> _tagsByPatient = const {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Loads cohort tags for every patient and returns a cohort → count index
  /// alongside the per-patient map.
  Future<({Map<String, List<CohortTag>> byPatient, Map<CohortTag, int> counts})>
  _loadCohorts(ClinicalDao dao, List<Patient> patients) async {
    final byPatient = <String, List<CohortTag>>{};
    final counts = <CohortTag, int>{};
    final inputs = await dao.getCohortInputsForPatients();
    for (final patient in patients) {
      final patientInputs = inputs[patient.id];
      final tags = CohortTagger.tagsFor(
        problems: patientInputs?.problems ?? const [],
        interventions: patientInputs?.interventions ?? const [],
        patient: patient,
      );
      byPatient[patient.id] = tags;
      for (final tag in tags) {
        counts[tag] = (counts[tag] ?? 0) + 1;
      }
    }
    return (byPatient: byPatient, counts: counts);
  }

  bool _matchesFilters(
    Patient patient,
    Map<String, List<CohortTag>> byPatient,
  ) {
    if (_searchQuery.isNotEmpty) {
      final name = patient.fullName.toLowerCase();
      final residence = patient.residence?.toLowerCase() ?? '';
      final occupation = patient.occupation?.toLowerCase() ?? '';
      if (!(name.contains(_searchQuery) ||
          residence.contains(_searchQuery) ||
          occupation.contains(_searchQuery))) {
        return false;
      }
    }
    if (_selectedCohorts.isEmpty) return true;
    // Intersection, not union: tapping two chips narrows the cohort, which is
    // what someone assembling a research set expects.
    final tags = byPatient[patient.id] ?? const <CohortTag>[];
    return _selectedCohorts.every(tags.contains);
  }

  @override
  Widget build(BuildContext context) {
    final dao = ref.watch(clinicalDaoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.selectForOpd
              ? 'Select or Register for OPD'
              : 'Patient Registry',
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) =>
                  setState(() => _searchQuery = val.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search by name, phone, or location…',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPatientEditor(context, ref),
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(widget.selectForOpd ? 'Register Patient' : 'New Patient'),
      ),
      body: StreamBuilder<List<Patient>>(
        stream: dao.watchAllPatients(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: SelectableText(
                'Unable to load registry:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final allPatients = snapshot.data ?? const <Patient>[];

          if (allPatients.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.badge_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No patients registered yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Register your first patient or scan a clinical document.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Cohort tags need per-patient POMR reads, so the filter row waits on
          // a second pass. The list itself renders immediately — a clinician
          // searching by name never waits on cohort derivation.
          return FutureBuilder<
            ({
              Map<String, List<CohortTag>> byPatient,
              Map<CohortTag, int> counts,
            })
          >(
            future: _loadCohorts(dao, allPatients),
            builder: (context, cohortSnapshot) {
              final byPatient =
                  cohortSnapshot.data?.byPatient ?? _tagsByPatient;
              final counts = cohortSnapshot.data?.counts ?? const {};
              _tagsByPatient = byPatient;

              final patients = allPatients
                  .where((patient) => _matchesFilters(patient, byPatient))
                  .toList();

              return Column(
                children: [
                  if (counts.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 14),
                          child: Icon(
                            Icons.filter_alt_outlined,
                            size: 15,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: CohortFilterBar(
                            available: counts,
                            selected: _selectedCohorts,
                            onToggle: (tag) => setState(() {
                              if (!_selectedCohorts.remove(tag)) {
                                _selectedCohorts.add(tag);
                              }
                            }),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedCohorts.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                        child: Row(
                          children: [
                            Text(
                              'Showing ${patients.length} of '
                              '${allPatients.length}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => setState(_selectedCohorts.clear),
                              child: const Text('Clear filters'),
                            ),
                          ],
                        ),
                      ),
                  ],
                  Expanded(
                    child: patients.isEmpty
                        ? Center(
                            child: Text(
                              _emptyMessage(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 92),
                            itemCount: patients.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final patient = patients[index];
                              return _PatientCard(
                                patient: patient,
                                cohortTags:
                                    byPatient[patient.id] ??
                                    const <CohortTag>[],
                                onSelectForOpd: widget.selectForOpd
                                    ? () => context.go(
                                        '/encounter',
                                        extra: patient,
                                      )
                                    : null,
                                onEdit: () => _showPatientEditor(
                                  context,
                                  ref,
                                  patient: patient,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _emptyMessage() {
    final hasSearch = _searchQuery.isNotEmpty;
    final hasCohort = _selectedCohorts.isNotEmpty;
    if (hasSearch && hasCohort) {
      return 'No patients match this search and cohort.';
    }
    if (hasCohort) return 'No patients in this cohort.';
    if (hasSearch) return 'No patients matching "$_searchQuery"';
    return 'No patients to show.';
  }

  Future<void> _showPatientEditor(
    BuildContext context,
    WidgetRef ref, {
    Patient? patient,
  }) async {
    final saved = await showDialog<Patient>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PatientEditor(patient: patient),
    );
    if (saved != null && context.mounted) {
      if (widget.selectForOpd) {
        context.go('/encounter', extra: saved);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            patient == null ? 'Patient record created' : 'Patient updated',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

class _PatientCard extends ConsumerWidget {
  const _PatientCard({
    required this.patient,
    required this.onEdit,
    this.onSelectForOpd,
    this.cohortTags = const [],
  });

  final Patient patient;
  final VoidCallback onEdit;
  final VoidCallback? onSelectForOpd;

  /// Derived research cohorts shown on the card (Sprint 11).
  final List<CohortTag> cohortTags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.watch(clinicalDaoProvider);

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap:
            onSelectForOpd ??
            () => context.go('/patients/${patient.id}', extra: patient),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(
                  context,
                ).colorScheme.onPrimaryContainer,
                child: Text(
                  patient.fullName.trim().isNotEmpty
                      ? patient.fullName.trim()[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        FutureBuilder<String>(
                          future: dao.getPatientHospitalRegNo(patient.id),
                          builder: (context, snapshot) {
                            final crNo = snapshot.data ?? '…';
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'CR: $crNo',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            );
                          },
                        ),
                        Text(
                          '${patient.gender ?? 'Unspecified'} · ${DateTimeUtils.ageOn(patient.dateOfBirth, DateTime.now()) != null ? '${DateTimeUtils.ageOn(patient.dateOfBirth, DateTime.now())}y' : '--'}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (patient.residence?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        patient.residence!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (cohortTags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      // Research cohorts, derived from the POMR — the same
                      // tags the filter bar above is built from.
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          for (final tag in cohortTags.take(4))
                            Tooltip(
                              message: tag.source,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: tag.chipColor.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  tag.display,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: tag.chipColor,
                                  ),
                                ),
                              ),
                            ),
                          if (cohortTags.length > 4)
                            Text(
                              '+${cohortTags.length - 4}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Edit Profile',
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: onEdit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatientEditor extends ConsumerStatefulWidget {
  const _PatientEditor({this.patient});
  final Patient? patient;

  @override
  ConsumerState<_PatientEditor> createState() => _PatientEditorState();
}

class _PatientEditorState extends ConsumerState<_PatientEditor> {
  final _formKey = GlobalKey<FormState>();

  late final _name = TextEditingController(
    text: widget.patient?.fullName ?? '',
  );
  late final _age = TextEditingController(
    text:
        DateTimeUtils.ageOn(
          widget.patient?.dateOfBirth,
          DateTime.now(),
        )?.toString() ??
        '',
  );
  late final _regNo = TextEditingController();
  late final _residence = TextEditingController(
    text: widget.patient?.residence ?? '',
  );
  late final _occupation = TextEditingController(
    text: widget.patient?.occupation ?? '',
  );
  late final _phone = TextEditingController(text: widget.patient?.phone ?? '');
  late final _heightCm = TextEditingController(
    text: widget.patient?.heightCm?.toString() ?? '',
  );
  late final _weightKg = TextEditingController(
    text: widget.patient?.weightKg?.toString() ?? '',
  );

  String? _gender;
  String? _selectedHospitalId;
  List<Hospital> _hospitals = [];
  bool _saving = false;
  bool _loadingInitial = true;

  @override
  void initState() {
    super.initState();
    _gender = widget.patient?.gender ?? 'Male';
    _loadPrerequisites();
  }

  Future<void> _loadPrerequisites() async {
    final dao = ref.read(clinicalDaoProvider);
    final hospitalList = await (dao.select(
      dao.hospitals,
    )..where((t) => t.isActive.equals(true))).get();

    String defaultHospId;
    if (hospitalList.isEmpty) {
      defaultHospId = await dao.ensureDefaultHospitalId();
      final fresh = await (dao.select(dao.hospitals)).get();
      _hospitals = fresh;
    } else {
      _hospitals = hospitalList;
      defaultHospId = hospitalList.first.id;
    }

    _selectedHospitalId = defaultHospId;

    if (widget.patient != null) {
      final existingReg = await dao.getPatientHospitalRegNo(widget.patient!.id);
      if (existingReg != 'No Reg No') {
        _regNo.text = existingReg;
      }
    }

    if (mounted) {
      setState(() => _loadingInitial = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _regNo.dispose();
    _residence.dispose();
    _occupation.dispose();
    _phone.dispose();
    _heightCm.dispose();
    _weightKg.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.patient == null;

    return AlertDialog(
      title: Text(isNew ? 'New Patient Profile' : 'Edit Demographics'),
      content: _loadingInitial
          ? const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator()),
            )
          : SizedBox(
              width: 540,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ======== SECTION: Local Hospital MRN ========
                      // Facility-scoped identifier: belongs to the hospital,
                      // not to the global patient profile below.
                      Text(
                        'Local Hospital MRN',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // A vertical layout keeps labels and values legible on
                      // narrow ward phones and avoids clamped dialog fields.
                      DropdownButtonFormField<String>(
                        initialValue: _selectedHospitalId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Hospital / Clinic',
                          prefixIcon: Icon(Icons.local_hospital_outlined),
                        ),
                        items: _hospitals.map((h) {
                          return DropdownMenuItem(
                            value: h.id,
                            child: Text(
                              h.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedHospitalId = val),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _regNo,
                        decoration: const InputDecoration(
                          labelText: 'MRN / CR No.',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ======== SECTION: Global Patient Info ========
                      Text(
                        'Global Patient Info',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Full Name
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                          prefixIcon: Icon(Icons.person_outline),
                          isDense: true,
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),

                      // Age & Gender Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _age,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Approx. Age (Years)',
                                prefixIcon: Icon(Icons.cake_outlined),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Gender',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _genderChip('Male'),
                                    const SizedBox(width: 6),
                                    _genderChip('Female'),
                                    const SizedBox(width: 6),
                                    _genderChip('Other'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Phone & Anthropometrics — baseline contact + dose math
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Phone',
                                prefixIcon: Icon(Icons.phone_outlined),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _heightCm,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Height (cm)',
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _weightKg,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Weight (kg)',
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Residence / Area & Occupation
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _residence,
                              decoration: const InputDecoration(
                                labelText: 'Residence / District / Village',
                                prefixIcon: Icon(Icons.location_on_outlined),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _occupation,
                              decoration: const InputDecoration(
                                labelText: 'Occupation',
                                prefixIcon: Icon(Icons.work_outline),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
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
          child: Text(_saving ? 'Saving…' : 'Save Patient Profile'),
        ),
      ],
    );
  }

  Widget _genderChip(String label) {
    final selected = _gender == label;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected,
      showCheckmark: false,
      onSelected: (val) {
        if (val) setState(() => _gender = label);
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final dao = ref.read(clinicalDaoProvider);
      final ownerId = ref.read(currentOwnerIdProvider);

      final ageYears = int.tryParse(_age.text.trim());
      final patientCompanion = PatientsCompanion(
        ownerId: Value(ownerId),
        fullName: Value(_name.text.trim()),
        dateOfBirth: Value(DateTimeUtils.dateOfBirthFromAge(ageYears)),
        gender: Value(_gender),
        residence: Value(_clean(_residence.text)),
        occupation: Value(_clean(_occupation.text)),
        phone: Value(_clean(_phone.text)),
        heightCm: Value(double.tryParse(_heightCm.text.trim())),
        weightKg: Value(double.tryParse(_weightKg.text.trim())),
      );

      final enteredMrn = _regNo.text.trim().isEmpty
          ? 'TEMP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'
          : _regNo.text.trim();

      if (widget.patient == null) {
        final saved = await dao.insertPatientWithHospitalId(
          patient: patientCompanion,
          hospitalId:
              _selectedHospitalId ?? await dao.ensureDefaultHospitalId(),
          mrn: enteredMrn,
        );
        if (mounted) Navigator.pop(context, saved);
        return;
      } else {
        await dao.updatePatient(
          widget.patient!.copyWith(
            fullName: _name.text.trim(),
            dateOfBirth: Value(DateTimeUtils.dateOfBirthFromAge(ageYears)),
            gender: Value(_gender),
            residence: Value(_clean(_residence.text)),
            occupation: Value(_clean(_occupation.text)),
            phone: Value(_clean(_phone.text)),
            heightCm: Value(double.tryParse(_heightCm.text.trim())),
            weightKg: Value(double.tryParse(_weightKg.text.trim())),
          ),
        );

        if (_selectedHospitalId != null) {
          await dao.upsertPatientHospitalIdentifier(
            patientId: widget.patient!.id,
            hospitalId: _selectedHospitalId!,
            mrn: enteredMrn,
            isPrimary: true,
          );
        }
      }

      if (mounted) Navigator.pop(context, widget.patient);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _clean(String val) => val.trim().isEmpty ? null : val.trim();
}
