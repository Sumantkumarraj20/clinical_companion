import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../database/local_database.dart';
import '../providers/app_providers.dart';
import '../../features/bedside/screens/vitals_entry_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/drugs/screens/drug_reference_screen.dart';
import '../../features/labs/screens/lab_tracker_screen.dart';
import '../../features/knowledge_base/screens/wiki_screen.dart';
import '../../features/bedside/screens/dynamic_encounter_screen.dart';
import '../../features/patients/screens/patient_timeline_screen.dart';
import '../../features/patients/screens/patient_registry_screen.dart';
import '../../features/patients/screens/ward_dashboard_screen.dart';
import '../../features/bedside/screens/smart_capture_screen.dart';
import '../../features/research/screens/export_dashboard_screen.dart';
import '../../features/research/screens/comparative_analysis_screen.dart';
import '../../features/patients/screens/problem_dashboard_screen.dart';
import '../../features/cdss/screens/rule_builder_screen.dart';
import '../../features/admin/screens/data_management_screen.dart';
import '../../features/settings/screens/configuration_screen.dart';
import '../../features/bedside/screens/manual_entry_screen.dart';
import '../../features/ingestion/screens/adaptive_review_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final configuration = ref.watch(appConfigurationProvider);
  final isConfigured =
      configuration.hasGemini &&
      configuration.hasSupabase &&
      configuration.hasDatabasePassword;
  return GoRouter(
    initialLocation: isConfigured ? '/dashboard' : '/configuration',
    routes: [
      GoRoute(
        path: '/configuration',
        builder: (context, state) => const ConfigurationScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AdaptiveScaffold(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/vitals',
            builder: (context, state) => const VitalsEntryScreen(),
          ),
          GoRoute(
            path: '/labs',
            builder: (context, state) => const LabTrackerScreen(),
          ),
          GoRoute(
            path: '/drugs',
            builder: (context, state) => const DrugReferenceScreen(),
          ),
          GoRoute(
            path: '/research',
            builder: (context, state) => const ExportDashboardScreen(),
          ),
          GoRoute(
            path: '/comparative-analysis',
            builder: (context, state) => const ComparativeAnalysisScreen(),
          ),
          GoRoute(
            path: '/cdss-rules',
            builder: (context, state) => const RuleBuilderScreen(),
          ),
          GoRoute(
            path: '/data-management',
            builder: (context, state) => const DataManagementScreen(),
          ),
          GoRoute(
            path: '/wiki',
            builder: (context, state) => const WikiScreen(),
          ),
          GoRoute(
            path: '/patients',
            builder: (context, state) => const PatientRegistryScreen(),
          ),
          GoRoute(
            path: '/ward-dashboard',
            builder: (context, state) => const WardDashboardScreen(),
          ),
          GoRoute(
            path: '/smart-capture',
            builder: (context, state) {
              final patient = state.extra;
              return patient is Patient
                  ? SmartCaptureScreen(patient: patient)
                  : const _RouteMessage(
                      message: 'Select a patient before capturing a document.',
                    );
            },
          ),
          GoRoute(
            path: '/adaptive-review',
            builder: (context, state) {
              final patient = state.extra;
              return patient is Patient
                  ? AdaptiveReviewScreen(patient: patient)
                  : const _RouteMessage(message: 'Select a patient before reviewing a document.');
            },
          ),
          GoRoute(
            path: '/manual-entry',
            builder: (context, state) => const ManualEntryScreen(),
          ),
          GoRoute(
            path: '/encounter',
            builder: (context, state) {
              final patient = state.extra;
              return patient is Patient
                  ? DynamicEncounterScreen(patient: patient)
                  : const _RouteMessage(
                      message: 'Select a patient to start an encounter.',
                    );
            },
          ),
          GoRoute(
            path: '/patients/:id',
            builder: (context, state) {
              final patient = state.extra;
              final data = patient is Map ? patient : null;
              final selectedPatient = data?['patient'] ?? patient;
              final heroTag = data?['heroTag'] as String?;
              return selectedPatient is Patient
                  ? PatientTimelineScreen(patient: selectedPatient, heroTag: heroTag)
                  : const _RouteMessage(
                      message:
                          'Patient timeline is unavailable without a patient.',
                    );
            },
          ),
          GoRoute(
            path: '/patients/:id/problems',
            builder: (context, state) {
              final patient = state.extra;
              return patient is Patient
                  ? ProblemDashboardScreen(patient: patient)
                  : const _RouteMessage(
                      message:
                          'Problem record is unavailable without a patient.',
                    );
            },
          ),
        ],
      ),
    ],
  );
});

class AdaptiveScaffold extends ConsumerWidget {
  const AdaptiveScaffold({required this.child, super.key});

  final Widget child;
  static const _destinations = <({String path, IconData icon, String label})>[
    (path: '/dashboard', icon: Icons.dashboard_outlined, label: 'Dashboard'),
    (path: '/vitals', icon: Icons.monitor_heart_outlined, label: 'Vitals'),
    (path: '/labs', icon: Icons.science_outlined, label: 'Labs'),
    (path: '/drugs', icon: Icons.medication_outlined, label: 'Drugs'),
    (path: '/research', icon: Icons.table_view_outlined, label: 'Research'),
    (path: '/wiki', icon: Icons.menu_book_outlined, label: 'Wiki'),
    (path: '/ward-dashboard', icon: Icons.local_hotel_outlined, label: 'Ward'),
    (path: '/data-management', icon: Icons.manage_accounts_outlined, label: 'Data'),
  ];

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = _destinations.indexWhere(
      (destination) => location.startsWith(destination.path),
    );
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = _selectedIndex(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;
        final navigation = NavigationRail(
          selectedIndex: selected,
          onDestinationSelected: (index) =>
              context.go(_destinations[index].path),
          labelType: NavigationRailLabelType.all,
          destinations: [
            for (final destination in _destinations)
              NavigationRailDestination(
                icon: Icon(destination.icon),
                selectedIcon: Icon(destination.icon),
                label: Text(destination.label),
              ),
          ],
        );
        return Scaffold(
          floatingActionButton: _CaptureSpeedDial(ref: ref),
          body: Stack(
            children: [
              if (isWide)
                Row(
                  children: [
                    navigation,
                    const VerticalDivider(width: 1),
                    Expanded(child: child),
                  ],
                )
              else
                child,
              Positioned(
                top: MediaQuery.paddingOf(context).top + 4,
                right: 8,
                child: Material(
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: 'Settings',
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => context.push('/configuration'),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: isWide
              ? null
              : BottomNavigationBar(
                  currentIndex: selected,
                  onTap: (index) => context.go(_destinations[index].path),
                  items: [
                    for (final destination in _destinations)
                      BottomNavigationBarItem(
                        icon: Icon(destination.icon),
                        label: destination.label,
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class _CaptureSpeedDial extends ConsumerWidget {
  const _CaptureSpeedDial({required this.ref});
  final WidgetRef ref;

  Future<void> _selectPatient(BuildContext context) async {
    final patients = await ref.read(clinicalDaoProvider).watchAllPatients().first;
    if (!context.mounted) return;
    final selected = await showModalBottomSheet<Patient>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('Select a patient')),
            for (final patient in patients)
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(patient.fullName),
                subtitle: Text(patient.hospitalRegNo),
                onTap: () => Navigator.pop(sheetContext, patient),
              ),
          ],
        ),
      ),
    );
    if (selected != null && context.mounted) {
      context.push('/smart-capture', extra: selected);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => SpeedDial(
    icon: Icons.add,
    activeIcon: Icons.close,
    tooltip: 'Clinical capture options',
    children: [
      SpeedDialChild(
        child: const Icon(Icons.camera_alt_outlined),
        label: 'AI Smart Capture',
        onTap: () => _selectPatient(context),
      ),
      SpeedDialChild(
        child: const Icon(Icons.document_scanner_outlined),
        label: 'Adaptive document review',
        onTap: () async {
          final patients = await ref.read(clinicalDaoProvider).watchAllPatients().first;
          if (!context.mounted) return;
          final selected = await showModalBottomSheet<Patient>(
            context: context,
            builder: (sheetContext) => ListView(children: [
              const ListTile(title: Text('Select a patient')),
              for (final patient in patients) ListTile(title: Text(patient.fullName), subtitle: Text(patient.hospitalRegNo), onTap: () => Navigator.pop(sheetContext, patient)),
            ]),
          );
          if (selected != null && context.mounted) context.push('/adaptive-review', extra: selected);
        },
      ),
      SpeedDialChild(
        child: const Icon(Icons.edit_note_outlined),
        label: 'Manual Quick Entry',
        onTap: () => context.push('/manual-entry'),
      ),
    ],
  );
}

class _RouteMessage extends StatelessWidget {
  const _RouteMessage({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Clinical companion')),
    body: Center(
      child: Padding(padding: const EdgeInsets.all(24), child: Text(message)),
    ),
  );
}
