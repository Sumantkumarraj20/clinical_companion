import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';

class PatientRegistryScreen extends ConsumerStatefulWidget {
  const PatientRegistryScreen({super.key});

  @override
  ConsumerState<PatientRegistryScreen> createState() =>
      _PatientRegistryScreenState();
}

class _PatientRegistryScreenState extends ConsumerState<PatientRegistryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dao = ref.watch(clinicalDaoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Registry'),
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
        label: const Text('New Patient'),
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
          final patients = allPatients.where((p) {
            if (_searchQuery.isEmpty) return true;
            final name = p.fullName.toLowerCase();
            final phone = p.phone?.toLowerCase() ?? '';
            final location = p.addressOrLocation?.toLowerCase() ?? '';
            return name.contains(_searchQuery) ||
                phone.contains(_searchQuery) ||
                location.contains(_searchQuery);
          }).toList();

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

          if (patients.isEmpty) {
            return Center(
              child: Text(
                'No patients matching "$_searchQuery"',
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 92),
            itemCount: patients.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final patient = patients[index];
              return _PatientCard(
                patient: patient,
                onEdit: () =>
                    _showPatientEditor(context, ref, patient: patient),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showPatientEditor(
    BuildContext context,
    WidgetRef ref, {
    Patient? patient,
  }) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PatientEditor(patient: patient),
    );
    if (saved == true && context.mounted) {
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
  const _PatientCard({required this.patient, required this.onEdit});

  final Patient patient;
  final VoidCallback onEdit;

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
        onTap: () => context.go('/patients/${patient.id}', extra: patient),
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
                          '${patient.gender ?? 'Unspecified'} · ${patient.approximateAge != null ? '${patient.approximateAge}y' : '--'}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (patient.addressOrLocation?.isNotEmpty == true ||
                        patient.phone?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (patient.addressOrLocation?.isNotEmpty == true)
                            patient.addressOrLocation,
                          if (patient.phone?.isNotEmpty == true) patient.phone,
                        ].join(' · '),
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
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (patient.phone?.isNotEmpty == true)
                    IconButton(
                      tooltip: 'Call Phone',
                      icon: const Icon(Icons.phone_outlined, size: 20),
                      onPressed: () =>
                          launchUrl(Uri(scheme: 'tel', path: patient.phone)),
                    ),
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
    text: widget.patient?.approximateAge?.toString() ?? '',
  );
  late final _regNo = TextEditingController();
  late final _phone = TextEditingController(text: widget.patient?.phone ?? '');
  late final _altPhone = TextEditingController(
    text: widget.patient?.alternatePhone ?? '',
  );
  late final _location = TextEditingController(
    text: widget.patient?.addressOrLocation ?? '',
  );
  late final _occupation = TextEditingController(
    text: widget.patient?.occupation ?? '',
  );
  late final _height = TextEditingController(
    text: widget.patient?.heightCm?.toString() ?? '',
  );
  late final _weight = TextEditingController(
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
    _phone.dispose();
    _altPhone.dispose();
    _location.dispose();
    _occupation.dispose();
    _height.dispose();
    _weight.dispose();
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
                      // Hospital & Identifier Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedHospitalId,
                              decoration: const InputDecoration(
                                labelText: 'Hospital / Clinic',
                                prefixIcon: Icon(Icons.local_hospital_outlined),
                                isDense: true,
                              ),
                              items: _hospitals.map((h) {
                                return DropdownMenuItem(
                                  value: h.id,
                                  child: Text(
                                    h.shortName?.isNotEmpty == true
                                        ? h.shortName!
                                        : h.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedHospitalId = val),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _regNo,
                              decoration: const InputDecoration(
                                labelText: 'CR / UHID No.',
                                prefixIcon: Icon(Icons.badge_outlined),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

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

                      // Phone & Alternate Phone
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: Icon(Icons.phone_outlined),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _altPhone,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Alternate Contact',
                                prefixIcon: Icon(Icons.contact_phone_outlined),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Address / Area & Occupation
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _location,
                              decoration: const InputDecoration(
                                labelText: 'District / Village / Town',
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
                      const SizedBox(height: 16),

                      // Height & Weight (for Clinical Dosing / BSA)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _height,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Height (cm)',
                                suffixText: 'cm',
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _weight,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Weight (kg)',
                                suffixText: 'kg',
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

      final patientCompanion = PatientsCompanion(
        ownerId: Value(ownerId),
        fullName: Value(_name.text.trim()),
        approximateAge: Value(int.tryParse(_age.text.trim())),
        gender: Value(_gender),
        phone: Value(_clean(_phone.text)),
        alternatePhone: Value(_clean(_altPhone.text)),
        addressOrLocation: Value(_clean(_location.text)),
        occupation: Value(_clean(_occupation.text)),
        heightCm: Value(double.tryParse(_height.text.trim())),
        weightKg: Value(double.tryParse(_weight.text.trim())),
        isActive: const Value(true),
        updatedAt: Value(DateTime.now().toUtc()),
      );

      final enteredRegNo = _regNo.text.trim().isEmpty
          ? 'TEMP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'
          : _regNo.text.trim();

      if (widget.patient == null) {
        await dao.insertPatientWithHospitalId(
          patient: patientCompanion,
          hospitalId:
              _selectedHospitalId ?? await dao.ensureDefaultHospitalId(),
          hospitalRegNo: enteredRegNo,
        );
      } else {
        await dao.updatePatient(
          widget.patient!.copyWith(
            fullName: _name.text.trim(),
            approximateAge: Value(int.tryParse(_age.text.trim())),
            gender: Value(_gender),
            phone: Value(_clean(_phone.text)),
            alternatePhone: Value(_clean(_altPhone.text)),
            addressOrLocation: Value(_clean(_location.text)),
            occupation: Value(_clean(_occupation.text)),
            heightCm: Value(double.tryParse(_height.text.trim())),
            weightKg: Value(double.tryParse(_weight.text.trim())),
            updatedAt: DateTime.now().toUtc(),
          ),
        );

        if (_selectedHospitalId != null) {
          await dao.upsertPatientHospitalIdentifier(
            patientId: widget.patient!.id,
            hospitalId: _selectedHospitalId!,
            hospitalRegNo: enteredRegNo,
            isPrimary: true,
          );
        }
      }

      if (mounted) Navigator.pop(context, true);
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
