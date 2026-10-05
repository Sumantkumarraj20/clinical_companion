import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../database/local_database.dart';
import '../providers/app_providers.dart';
import '../widgets/main_navigation_scaffold.dart';
import '../../features/bedside/screens/vitals_entry_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/dashboard/screens/today_workspace_screen.dart';
import '../../features/learning/screens/knowledge_hub_screen.dart';
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
import '../../features/ingestion/screens/text_ingestion_screen.dart';

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
        builder: (context, state, child) =>
            MainNavigationScaffold(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            // Sprint 14 — the "Today" workspace. Reachable from the dashboard
            // rather than replacing it: the existing dashboard still owns the
            // OTA banner and quick actions.
            path: '/today',
            builder: (context, state) => const TodayWorkspaceScreen(),
          ),
          GoRoute(
            // Sprint 16 — unified knowledge flywheel (reflections + wiki).
            path: '/knowledge-hub',
            builder: (context, state) => const KnowledgeHubScreen(),
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
            builder: (context, state) => PatientRegistryScreen(
              selectForOpd:
                  state.extra is Map && (state.extra as Map)['opdFlow'] == true,
            ),
          ),
          GoRoute(
            path: '/ward-dashboard',
            builder: (context, state) => const WardDashboardScreen(),
          ),
          GoRoute(
            path: '/smart-capture',
            builder: (context, state) => const SmartCaptureScreen(),
          ),
          GoRoute(
            path: '/text-ingestion',
            builder: (context, state) => const TextIngestionScreen(),
          ),
          GoRoute(
            path: '/adaptive-review',
            // Queue-driven review: works with no pre-selected patient because
            // identity is resolved from the document (or linked in the form).
            // Launching from a patient timeline passes `extra: Patient` so
            // every page is filed under that patient automatically.
            builder: (context, state) {
              final extra = state.extra;
              return AdaptiveReviewScreen(
                patient: extra is Patient ? extra : null,
              );
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
                  ? PatientTimelineScreen(
                      patient: selectedPatient,
                      heroTag: heroTag,
                    )
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

/// Backwards-compatible alias: the shell was renamed in Sprint 11 to
/// `MainNavigationScaffold` when the nav became a Material 3 NavigationBar.
/// Existing `ShellRoute` builders keep compiling.
typedef AdaptiveScaffold = MainNavigationScaffold;

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
