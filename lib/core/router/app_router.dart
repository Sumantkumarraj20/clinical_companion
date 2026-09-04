import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../database/local_database.dart';
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

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
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
              return patient is Patient
                  ? PatientTimelineScreen(patient: patient)
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

class AdaptiveScaffold extends StatelessWidget {
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
  ];

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = _destinations.indexWhere(
      (destination) => location.startsWith(destination.path),
    );
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
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
          body: isWide
              ? Row(
                  children: [
                    navigation,
                    const VerticalDivider(width: 1),
                    Expanded(child: child),
                  ],
                )
              : child,
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
