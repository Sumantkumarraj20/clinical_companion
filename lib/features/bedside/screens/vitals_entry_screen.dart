import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/cds/decision_support_engine.dart';
import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';

class VitalsEntryScreen extends ConsumerStatefulWidget {
  const VitalsEntryScreen({this.preselectedPatientId, super.key});

  /// Allows passing patientId directly when launched from Ward Round or Patient Profile
  final String? preselectedPatientId;

  @override
  ConsumerState<VitalsEntryScreen> createState() => _VitalsEntryScreenState();
}

class _VitalsEntryScreenState extends ConsumerState<VitalsEntryScreen> {
  static const _uuid = Uuid();
  final _formKey = GlobalKey<FormState>();

  // Hemodynamic Controllers
  final _sbp = TextEditingController();
  final _dbp = TextEditingController();
  final _pulse = TextEditingController();
  final _spo2 = TextEditingController();
  final _rr = TextEditingController();
  final _temp = TextEditingController();
  final _note = TextEditingController();

  String? _selectedPatientId;
  double? _map;
  bool _saving = false;
  bool _tempInCelsius = true;

  @override
  void initState() {
    super.initState();
    _selectedPatientId = widget.preselectedPatientId;
    _sbp.addListener(_onVitalsChanged);
    _dbp.addListener(_onVitalsChanged);
    _pulse.addListener(_onVitalsChanged);
    _spo2.addListener(_onVitalsChanged);
  }

  void _onVitalsChanged() {
    _updateMap();
    // Rebuild so _VitalsLiveState snapshot + CDSS banners stay live.
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _sbp.dispose();
    _dbp.dispose();
    _pulse.dispose();
    _spo2.dispose();
    _rr.dispose();
    _temp.dispose();
    _note.dispose();
    super.dispose();
  }

  void _updateMap() {
    final systolic = int.tryParse(_sbp.text);
    final diastolic = int.tryParse(_dbp.text);
    _map = (systolic != null && diastolic != null)
        ? (systolic + (2 * diastolic)) / 3
        : null;
  }

  double? _calculateNormalizedTemp() {
    final raw = double.tryParse(_temp.text.trim());
    if (raw == null) return null;
    return _tempInCelsius ? raw : ((raw - 32) * 5 / 9);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatientId == null) {
      _message('Please select a patient first.');
      return;
    }

    setState(() => _saving = true);
    final dao = ref.read(clinicalDaoProvider);
    final ownerId = ref.read(currentOwnerIdProvider);
    final now = DateTime.now().toUtc();

    try {
      final sbpVal = int.tryParse(_sbp.text);
      final dbpVal = int.tryParse(_dbp.text);
      final pulseVal = int.tryParse(_pulse.text);
      final spo2Val = int.tryParse(_spo2.text);
      final rrVal = int.tryParse(_rr.text);
      final tempC = _calculateNormalizedTemp();

      // 1. Commit as Bedside Clinical Encounter
      final encounter = ClinicalEncountersCompanion.insert(
        ownerId: ownerId,
        patientId: _selectedPatientId!,
        encounterType: const Value('Vitals Check'),
        occurredAt: Value(now),
        sbp: Value(sbpVal),
        dbp: Value(dbpVal),
        pulse: Value(pulseVal),
        spo2: Value(spo2Val),
        respiratoryRate: Value(rrVal),
        temperatureC: Value(tempC),
        meanArterialPressure: Value(_map),
        clinicalAssessment: Value(
          _note.text.trim().isEmpty ? null : _note.text.trim(),
        ),
      );

      final savedEncounter = await dao.insertClinicalEncounter(encounter);

      // 2. Commit into ClinicalObservations for Longitudinal Trending
      final observations = <ClinicalObservationsCompanion>[
        if (sbpVal != null)
          ClinicalObservationsCompanion.insert(
            id: _uuid.v4(),
            patientId: _selectedPatientId!,
            documentId: savedEncounter.id,
            observationCategory: 'vital',
            code: 'LOINC_BP_SYS',
            displayName: 'Systolic BP',
            numericValue: Value(sbpVal.toDouble()),
            unit: const Value('mmHg'),
            isAbnormal: Value(sbpVal > 140 || sbpVal < 90),
            recordedAt: now,
          ),
        if (dbpVal != null)
          ClinicalObservationsCompanion.insert(
            id: _uuid.v4(),
            patientId: _selectedPatientId!,
            documentId: savedEncounter.id,
            observationCategory: 'vital',
            code: 'LOINC_BP_DIA',
            displayName: 'Diastolic BP',
            numericValue: Value(dbpVal.toDouble()),
            unit: const Value('mmHg'),
            isAbnormal: Value(dbpVal > 90 || dbpVal < 60),
            recordedAt: now,
          ),
        if (pulseVal != null)
          ClinicalObservationsCompanion.insert(
            id: _uuid.v4(),
            patientId: _selectedPatientId!,
            documentId: savedEncounter.id,
            observationCategory: 'vital',
            code: 'LOINC_PULSE',
            displayName: 'Heart Rate',
            numericValue: Value(pulseVal.toDouble()),
            unit: const Value('bpm'),
            isAbnormal: Value(pulseVal > 100 || pulseVal < 60),
            recordedAt: now,
          ),
        if (spo2Val != null)
          ClinicalObservationsCompanion.insert(
            id: _uuid.v4(),
            patientId: _selectedPatientId!,
            documentId: savedEncounter.id,
            observationCategory: 'vital',
            code: 'LOINC_SPO2',
            displayName: 'Oxygen Saturation',
            numericValue: Value(spo2Val.toDouble()),
            unit: const Value('%'),
            isAbnormal: Value(spo2Val < 94),
            recordedAt: now,
          ),
      ];

      for (final obs in observations) {
        await dao.into(dao.clinicalObservations).insert(obs);
      }

      if (mounted) {
        _message('Vitals recorded successfully.', isError: false);
        if (widget.preselectedPatientId != null) {
          Navigator.pop(context, true);
        } else {
          _clearForm();
        }
      }
    } catch (e) {
      if (mounted) _message('Error saving vitals: $e', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _clearForm() {
    _sbp.clear();
    _dbp.clear();
    _pulse.clear();
    _spo2.clear();
    _rr.clear();
    _temp.clear();
    _note.clear();
    setState(() => _map = null);
  }

  void _message(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dao = ref.watch(clinicalDaoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bedside Vitals Logging'),
        actions: [
          if (_selectedPatientId != null && widget.preselectedPatientId == null)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear Form',
              onPressed: _clearForm,
            ),
        ],
      ),
      body: _VitalsLiveState(
        sbp: int.tryParse(_sbp.text),
        pulse: int.tryParse(_pulse.text),
        spo2: int.tryParse(_spo2.text),
        child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // Patient Context Card or Dropdown
            if (widget.preselectedPatientId != null)
              _LockedPatientBanner(patientId: widget.preselectedPatientId!)
            else
              StreamBuilder<List<Patient>>(
                stream: dao.watchAllPatients(),
                builder: (context, snapshot) {
                  final patients = snapshot.data ?? const [];
                  final effectivePatientId =
                      patients.any((p) => p.id == _selectedPatientId)
                      ? _selectedPatientId
                      : null;

                  return DropdownButtonFormField<String>(
                    initialValue: effectivePatientId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Select Patient *',
                      prefixIcon: Icon(Icons.person_search_outlined),
                    ),
                    items: [
                      for (final p in patients)
                        DropdownMenuItem(
                          value: p.id,
                          child: FutureBuilder<String>(
                            future: dao.getPatientHospitalRegNo(p.id),
                            builder: (context, regSnap) {
                              final reg = regSnap.data ?? '…';
                              return Text(
                                '${p.fullName} (CR: $reg) · ${p.gender ?? '?'}, ${p.approximateAge ?? '--'}y',
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ),
                    ],
                    onChanged: (val) =>
                        setState(() => _selectedPatientId = val),
                    validator: (v) => v == null ? 'Patient is required' : null,
                  );
                },
              ),
            const SizedBox(height: 20),

            // CDSS live alerts — deterministic, one-tap order bundles.
            const _CdssAlertBanners(),

            // Blood Pressure Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _vitalInputField(
                    controller: _sbp,
                    label: 'Systolic BP',
                    suffix: 'mmHg',
                    validator: (v) {
                      final val = int.tryParse(v ?? '');
                      if (val == null || val <= 0) return 'Required';
                      final dbp = int.tryParse(_dbp.text);
                      if (dbp != null && val <= dbp) return 'Must exceed DBP';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _vitalInputField(
                    controller: _dbp,
                    label: 'Diastolic BP',
                    suffix: 'mmHg',
                    validator: (v) {
                      final val = int.tryParse(v ?? '');
                      if (val == null || val <= 0) return 'Required';
                      final sbp = int.tryParse(_sbp.text);
                      if (sbp != null && sbp <= val) return 'Below SBP';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // MAP Indicator Banner
            Card(
              elevation: 0,
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.5),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mean Arterial Pressure (MAP)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _map == null
                          ? '— mmHg'
                          : '${_map!.toStringAsFixed(1)} mmHg',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pulse & SpO2 Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _vitalInputField(
                    controller: _pulse,
                    label: 'Heart Rate',
                    suffix: 'bpm',
                    validator: (v) {
                      final val = int.tryParse(v ?? '');
                      if (val == null || val <= 0) return 'Required';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _vitalInputField(
                    controller: _spo2,
                    label: 'SpO2',
                    suffix: '%',
                    validator: (v) {
                      final val = int.tryParse(v ?? '');
                      if (val != null && (val < 0 || val > 100)) {
                        return '0-100%';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Respiratory Rate & Temperature Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _vitalInputField(
                    controller: _rr,
                    label: 'Resp. Rate',
                    suffix: '/min',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _temp,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Temperature',
                      suffixIcon: IconButton(
                        icon: Text(
                          _tempInCelsius ? '°C' : '°F',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () =>
                            setState(() => _tempInCelsius = !_tempInCelsius),
                        tooltip: 'Toggle Celsius / Fahrenheit',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Clinical Bedside Note
            TextFormField(
              controller: _note,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Bedside Observation / Context Note (Optional)',
                hintText: 'e.g., Post-nebulization, patient sitting up, pale',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            // Orders & Plan — staged CDSS bundles, shared provider.
            const _StagedOrdersSection(),

            const SizedBox(height: 16),

            // Save Action Button
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  _saving ? 'Recording…' : 'Save Vitals',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _vitalInputField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(labelText: label, suffixText: suffix),
      validator: validator,
    );
  }
}

/// Live deterministic CDSS banners at the top of the vitals form.
/// Watches the text controllers via a 300ms poll + onChanged rebuild;
/// tapping a banner stages its suggested orders into [stagedOrdersProvider].
class _CdssAlertBanners extends ConsumerStatefulWidget {
  const _CdssAlertBanners();

  @override
  ConsumerState<_CdssAlertBanners> createState() => _CdssAlertBannersState();
}

class _CdssAlertBannersState extends ConsumerState<_CdssAlertBanners> {
  @override
  Widget build(BuildContext context) {
    // Rebuild whenever staged orders change so "Added" state stays fresh.
    ref.watch(stagedOrdersProvider);
    final vitalsState = _VitalsLiveState.of(context);
    final alerts = DecisionSupportEngine.evaluateVitals(
      vitalsState?.sbp,
      vitalsState?.pulse,
      vitalsState?.spo2,
    );
    if (alerts.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        for (final alert in alerts)
          _CdssBanner(alert: alert, vitalsState: vitalsState),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _CdssBanner extends ConsumerWidget {
  const _CdssBanner({required this.alert, this.vitalsState});
  final CdssAlert alert;
  final _VitalsLiveState? vitalsState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staged = ref.watch(stagedOrdersProvider);
    final allStaged = alert.suggestedOrders.every(
      (o) => staged.any(
        (s) => s.label.trim().toLowerCase() == o.label.trim().toLowerCase(),
      ),
    );
    return Card(
      color: alert.severityColor.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: alert.severityColor, width: 1.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: allStaged
            ? null
            : () {
                ref
                    .read(stagedOrdersProvider.notifier)
                    .addAllProposals(alert.suggestedOrders);
                final names = alert.suggestedOrders.map((o) => o.label).join(', ');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Staged: $names. Review in Orders & Plan.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, color: alert.severityColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: alert.severityColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(alert.description, style: const TextStyle(fontSize: 12)),
                    if (alert.suggestedOrders.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final order in alert.suggestedOrders)
                            Chip(
                              label: Text(order.label),
                              avatar: Icon(
                                allStaged ? Icons.check : Icons.add,
                                size: 16,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                      Text(
                        allStaged
                            ? 'Added to Orders & Plan ✓ — tap individual chips in Orders section to remove.'
                            : 'Tap banner to stage all (${alert.suggestedOrders.length}) → Orders & Plan.',
                        style: const TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inherited live vitals snapshot so [_CdssAlertBanners] rebuilds on typing.
class _VitalsLiveState extends InheritedWidget {
  const _VitalsLiveState({
    required this.sbp,
    required this.pulse,
    required this.spo2,
    required super.child,
  });

  final int? sbp;
  final int? pulse;
  final int? spo2;

  static _VitalsLiveState? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_VitalsLiveState>();

  @override
  bool updateShouldNotify(_VitalsLiveState old) =>
      sbp != old.sbp || pulse != old.pulse || spo2 != old.spo2;
}

/// Shared Orders & Plan section bound to [stagedOrdersProvider].
class _StagedOrdersSection extends ConsumerWidget {
  const _StagedOrdersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(stagedOrdersProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.playlist_add_check_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Orders & Plan (${orders.length})',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (orders.isNotEmpty)
                  TextButton(
                    onPressed: () =>
                        ref.read(stagedOrdersProvider.notifier).clear(),
                    child: const Text('Clear'),
                  ),
              ],
            ),
            if (orders.isEmpty)
              const Text(
                'No staged orders. CDSS banners above can stage bundles in one tap.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < orders.length; i++)
                    InputChip(
                      label: Text(orders[i].label),
                      avatar: const Icon(Icons.medication_outlined, size: 16),
                      onDeleted: () => ref
                          .read(stagedOrdersProvider.notifier)
                          .removeAt(i),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _LockedPatientBanner extends ConsumerWidget {
  const _LockedPatientBanner({required this.patientId});
  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.watch(clinicalDaoProvider);

    return FutureBuilder<Patient?>(
      future: dao.findPatient(patientId),
      builder: (context, snapshot) {
        final p = snapshot.data;
        if (p == null) return const LinearProgressIndicator();

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.lock_clock, size: 20, color: Colors.teal),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    FutureBuilder<String>(
                      future: dao.getPatientHospitalRegNo(p.id),
                      builder: (context, regSnap) {
                        return Text(
                          'CR: ${regSnap.data ?? '…'} · ${p.gender ?? '?'}, ${p.approximateAge ?? '--'}y',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
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
}
