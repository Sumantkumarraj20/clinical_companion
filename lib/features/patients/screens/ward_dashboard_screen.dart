import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/daos/clinical_dao.dart';
import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../bedside/screens/dynamic_encounter_screen.dart';
import '../../bedside/screens/vitals_entry_screen.dart';

class WardDashboardScreen extends ConsumerStatefulWidget {
  const WardDashboardScreen({super.key});

  @override
  ConsumerState<WardDashboardScreen> createState() =>
      _WardDashboardScreenState();
}

class _WardDashboardScreenState extends ConsumerState<WardDashboardScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedWardFilter = 'ALL';
  String _selectedDeptFilter = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dao = ref.watch(clinicalDaoProvider);

    // Watch all active clinical encounters to identify currently admitted patients
    final encountersStream = dao.select(dao.clinicalEncounters).watch();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inpatient Ward Census'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Census',
            onPressed: () => setState(() {}),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) =>
                  setState(() => _searchQuery = val.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search admitted patient by name or bed…',
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
      body: StreamBuilder<List<ClinicalEncounter>>(
        stream: encountersStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: SelectableText(
                'Unable to load ward census:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerLoading(rows: 5),
            );
          }

          final allEncounters = snapshot.data ?? [];

          // Group by patient and get the latest encounter for each
          final Map<String, ClinicalEncounter> latestEncounterByPatient = {};
          for (final enc in allEncounters) {
            final existing = latestEncounterByPatient[enc.patientId];
            if (existing == null ||
                enc.occurredAt.isAfter(existing.occurredAt)) {
              latestEncounterByPatient[enc.patientId] = enc;
            }
          }

          // Filter for active inpatient admissions (disposition == 'Admitted' or active ward assignment)
          final admittedEncounters = latestEncounterByPatient.values.where((e) {
            final isDischarged =
                e.disposition == 'Discharged' || e.disposition == 'LAMA';
            final hasBed =
                (e.wardName?.isNotEmpty ?? false) ||
                (e.bedNumber?.isNotEmpty ?? false);
            final isMarkedAdmitted =
                e.disposition == 'Admitted' || e.encounterType == 'Ward Round';
            return !isDischarged && (hasBed || isMarkedAdmitted);
          }).toList();

          // Collect unique wards and departments for filter chips
          final availableWards = {
            'ALL',
            ...admittedEncounters.map((e) => e.wardName ?? 'General Ward'),
          };
          final availableDepts = {
            'ALL',
            ...admittedEncounters.map((e) => e.department ?? 'General'),
          };

          return Column(
            children: [
              // Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Text(
                      'Ward: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    for (final ward in availableWards) ...[
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          label: Text(ward),
                          selected: _selectedWardFilter == ward,
                          onSelected: (sel) {
                            if (sel) setState(() => _selectedWardFilter = ward);
                          },
                        ),
                      ),
                    ],
                    const SizedBox(width: 12),
                    const Text(
                      'Dept: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    for (final dept in availableDepts) ...[
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          label: Text(dept),
                          selected: _selectedDeptFilter == dept,
                          onSelected: (sel) {
                            if (sel) setState(() => _selectedDeptFilter = dept);
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1),

              // Census List View
              Expanded(
                child: _CensusListView(
                  dao: dao,
                  encounters: admittedEncounters,
                  searchQuery: _searchQuery,
                  wardFilter: _selectedWardFilter,
                  deptFilter: _selectedDeptFilter,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CensusListView extends StatelessWidget {
  const _CensusListView({
    required this.dao,
    required this.encounters,
    required this.searchQuery,
    required this.wardFilter,
    required this.deptFilter,
  });

  final ClinicalDao dao;
  final List<ClinicalEncounter> encounters;
  final String searchQuery;
  final String wardFilter;
  final String deptFilter;

  @override
  Widget build(BuildContext context) {
    if (encounters.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.hotel_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              'No active inpatients in census',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            const Text(
              'Admit patients from the consultation screen or bedside round.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      itemCount: encounters.length,
      itemBuilder: (context, index) {
        final encounter = encounters[index];

        // Apply ward and department filters
        final encWard = encounter.wardName ?? 'General Ward';
        final encDept = encounter.department ?? 'General';
        if (wardFilter != 'ALL' && encWard != wardFilter) {
          return const SizedBox.shrink();
        }
        if (deptFilter != 'ALL' && encDept != deptFilter) {
          return const SizedBox.shrink();
        }

        return FutureBuilder<Patient?>(
          future: dao.findPatient(encounter.patientId),
          builder: (context, patientSnapshot) {
            final patient = patientSnapshot.data;
            if (patient == null) return const SizedBox.shrink();

            // Apply search query filter
            if (searchQuery.isNotEmpty) {
              final name = patient.fullName.toLowerCase();
              final bed = (encounter.bedNumber ?? '').toLowerCase();
              final ward = encWard.toLowerCase();
              if (!name.contains(searchQuery) &&
                  !bed.contains(searchQuery) &&
                  !ward.contains(searchQuery)) {
                return const SizedBox.shrink();
              }
            }

            return _InpatientCensusCard(
              patient: patient,
              latestEncounter: encounter,
            );
          },
        );
      },
    );
  }
}

class _InpatientCensusCard extends ConsumerWidget {
  const _InpatientCensusCard({
    required this.patient,
    required this.latestEncounter,
  });

  final Patient patient;
  final ClinicalEncounter latestEncounter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.watch(clinicalDaoProvider);
    final theme = Theme.of(context);

    final wardText = latestEncounter.wardName?.isNotEmpty == true
        ? latestEncounter.wardName!
        : 'Ward';
    final bedText = latestEncounter.bedNumber?.isNotEmpty == true
        ? 'Bed ${latestEncounter.bedNumber}'
        : 'Bed Unassigned';

    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/patients/${patient.id}', extra: patient),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Bed & Location Badge + Time of Last Round
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$wardText · $bedText',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  Text(
                    'Last check: ${_timeAgo(latestEncounter.occurredAt)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Patient Demographics & CR Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    foregroundColor: theme.colorScheme.onSecondaryContainer,
                    child: Text(
                      patient.fullName.trim().isNotEmpty
                          ? patient.fullName.trim()[0].toUpperCase()
                          : '?',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FutureBuilder<String>(
                          future: dao.getPatientHospitalRegNo(patient.id),
                          builder: (context, regSnap) {
                            return Text(
                              'CR: ${regSnap.data ?? '…'} · ${patient.gender ?? '?'}, ${patient.approximateAge ?? '--'} yrs',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Diagnosis / Clinical Problem Summary
              if (latestEncounter.clinicalDiagnosis?.isNotEmpty == true ||
                  latestEncounter.chiefComplaints?.isNotEmpty == true) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    latestEncounter.clinicalDiagnosis?.isNotEmpty == true
                        ? latestEncounter.clinicalDiagnosis!
                        : latestEncounter.chiefComplaints!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Vitals Snapshot Chips
              Row(
                children: [
                  _vitalChip(
                    label: 'BP',
                    value:
                        (latestEncounter.sbp != null &&
                            latestEncounter.dbp != null)
                        ? '${latestEncounter.sbp}/${latestEncounter.dbp}'
                        : '—',
                    unit: 'mmHg',
                    theme: theme,
                  ),
                  const SizedBox(width: 8),
                  _vitalChip(
                    label: 'HR',
                    value: latestEncounter.pulse?.toString() ?? '—',
                    unit: 'bpm',
                    theme: theme,
                  ),
                  const SizedBox(width: 8),
                  _vitalChip(
                    label: 'SpO2',
                    value: latestEncounter.spo2 != null
                        ? '${latestEncounter.spo2}%'
                        : '—',
                    unit: '',
                    theme: theme,
                  ),
                  const Spacer(),

                  // Quick Action Buttons
                  IconButton.filledTonal(
                    icon: const Icon(Icons.speed, size: 18),
                    tooltip: 'Log Vitals',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VitalsEntryScreen(
                            preselectedPatientId: patient.id,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  FilledButton.icon(
                    icon: const Icon(Icons.edit_note, size: 18),
                    label: const Text('Round', style: TextStyle(fontSize: 13)),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DynamicEncounterScreen(patient: patient),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vitalChip({
    required String label,
    required String value,
    required String unit,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value $unit'.trim(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().toUtc().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
