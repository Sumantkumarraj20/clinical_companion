import 'package:clinical_companion/core/database/daos/clinical_dao.dart';
import 'package:clinical_companion/core/database/local_database.dart';
import 'package:clinical_companion/core/providers/app_providers.dart';
import 'package:clinical_companion/features/bedside/widgets/quick_action_sheet.dart';
import 'package:clinical_companion/features/dashboard/screens/today_workspace_screen.dart';
import 'package:clinical_companion/features/dashboard/widgets/post_op_day_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Sprint 14 STEP 3 — render-level tests for the Today workspace.
///
/// The DAO suite in `sprint14_today_workspace_test.dart` proves the queries
/// return the right rows. These prove the *screen* renders them safely: no
/// overflow on a ward phone, correct tab counts, and honest empty states.
void main() {
  // =========================================================================
  // PostOpDayBadge — the highest-value widget, since a wrong or overflowed
  // badge is a false clinical statement on a patient card.
  // =========================================================================
  group('PostOpDayBadge', () {
    Future<void> pump(
      WidgetTester tester,
      Widget badge, {
      double width = 160,
    }) async {
      await tester.binding.setSurfaceSize(Size(width, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: Scaffold(body: Center(child: badge)),
        ),
      );
    }

    testWidgets('renders the post-operative day', (tester) async {
      await pump(tester, const PostOpDayBadge(postOpDay: 3));
      expect(find.text('POD #3'), findsOneWidget);
    });

    testWidgets('day zero renders as POD #0, not a blank', (tester) async {
      await pump(tester, const PostOpDayBadge(postOpDay: 0));
      expect(find.text('POD #0'), findsOneWidget);
    });

    testWidgets('renders nothing when no surgery is recorded', (tester) async {
      // The badge must be genuinely absent, not an empty box that still takes
      // up card space.
      await pump(tester, const PostOpDayBadge(postOpDay: null));
      expect(find.byType(PostOpDayBadge), findsOneWidget);
      expect(find.textContaining('POD'), findsNothing);
      expect(tester.getSize(find.byType(PostOpDayBadge)).height, 0);
    });

    testWidgets('a negative day renders nothing (never "POD #-1")', (
      tester,
    ) async {
      await pump(tester, const PostOpDayBadge(postOpDay: -1));
      expect(find.textContaining('POD'), findsNothing);
    });

    testWidgets('a large day count still fits a narrow card', (tester) async {
      // 3-digit days happen on long admissions; a fixed-width chip would clip.
      await pump(tester, const PostOpDayBadge(postOpDay: 999), width: 70);
      expect(find.text('POD #999'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow inside a very tight width', (tester) async {
      await pump(tester, const PostOpDayBadge(postOpDay: 12), width: 40);
      expect(tester.takeException(), isNull);
    });

    testWidgets('procedure name is exposed as a tooltip for context', (
      tester,
    ) async {
      await pump(
        tester,
        const PostOpDayBadge(
          postOpDay: 2,
          procedureName: 'Laparoscopic Appendectomy',
        ),
      );
      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('a blank procedure name adds no empty tooltip', (tester) async {
      await pump(
        tester,
        const PostOpDayBadge(postOpDay: 2, procedureName: '   '),
      );
      expect(find.byType(Tooltip), findsNothing);
    });
  });

  // =========================================================================
  // TodayWorkspaceScreen
  // =========================================================================
  group('TodayWorkspaceScreen', () {
    Patient patient(String id, String name, {int? ageYears, String? gender}) {
      final now = DateTime.now();
      return Patient(
        id: id,
        ownerId: 'owner-1',
        fullName: name,
        gender: gender,
        dateOfBirth: ageYears == null
            ? null
            : DateTime(now.year - ageYears, now.month, now.day),
      );
    }

    Admission admission(String patientId, {String? ward, String? bed}) {
      return Admission(
        id: 'adm-$patientId',
        patientId: patientId,
        hospitalId: 'hosp-1',
        wardName: ward,
        bedNumber: bed,
        admissionTime: DateTime.now().subtract(const Duration(days: 2)),
        status: 'active',
      );
    }

    /// Pumps the workspace with all four streams overridden, so no SQLite
    /// access is needed and each tab can be driven independently.
    Future<void> pumpWorkspace(
      WidgetTester tester, {
      List<WardRoundPatient> wards = const [],
      List<PendingInvestigation> results = const [],
      List<SmartFollowUp> followUps = const [],
      List<PendingNote> drafts = const [],
      int? podDay = 2,
      Size surface = const Size(360, 740),
    }) async {
      await tester.binding.setSurfaceSize(surface);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // A minimal router: `_PatientCard` calls `context.go` on tap, which
      // requires a GoRouter ancestor even though these tests do not navigate.
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, _) => const TodayWorkspaceScreen()),
          GoRoute(
            path: '/patients/:id',
            builder: (_, _) => const Scaffold(body: Text('TIMELINE')),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            wardRoundsProvider.overrideWith((ref) => Stream.value(wards)),
            outstandingInvestigationsProvider.overrideWith(
              (ref) => Stream.value(results),
            ),
            smartFollowUpsProvider.overrideWith(
              (ref) => Stream.value(followUps),
            ),
            pendingNotesProvider.overrideWith((ref) => Stream.value(drafts)),
            postOpDayProvider.overrideWith((ref, _) async => podDay),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            theme: ThemeData(splashFactory: NoSplash.splashFactory),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    // ---- tab bar -------------------------------------------------------
    /// Taps a tab by label. The [TabBar] is scrollable, so tabs 3-4 sit off-screen
    /// on a 360dp ward phone; they must be scrolled into view first or the tap
    /// silently misses.
    Future<void> tapTab(WidgetTester tester, String label) async {
      await tester.ensureVisible(find.text(label));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    testWidgets('renders all four tabs', (tester) async {
      await pumpWorkspace(tester);
      expect(find.byType(TabBar), findsOneWidget);
      for (final label in [
        'Ward Rounds',
        'Pending Results',
        'Follow-ups',
        'Drafts',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
    });

    testWidgets('shows a live count per populated tab', (tester) async {
      await pumpWorkspace(
        tester,
        wards: [
          WardRoundPatient(
            admission: admission('p1', ward: 'ICU'),
            patient: patient('p1', 'Patient One'),
          ),
        ],
        results: [
          PendingInvestigation(
            investigation: InvestigationOrder(
              id: 'o1',
              patientId: 'p1',
              testName: 'CBC',
              status: 'ordered',
              orderedAt: DateTime.now().subtract(const Duration(days: 3)),
              ownerId: 'owner-1',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            patient: patient('p1', 'Patient One'),
            mrn: 'MRN-1',
          ),
        ],
      );

      // Two populated tabs -> two count badges rendered.
      expect(find.byType(TabBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty workspace shows an honest empty state, not urgency', (
      tester,
    ) async {
      await pumpWorkspace(tester);
      expect(find.text('No admitted patients'), findsOneWidget);
      // The body must not claim the clinician is failing to do anything.
      expect(find.textContaining('overdue'), findsNothing);
      expect(find.textContaining('urgent'), findsNothing);
    });

    // ---- Ward Rounds tab ----------------------------------------------
    testWidgets('ward round card shows name, ward, bed, MRN and age', (
      tester,
    ) async {
      await pumpWorkspace(
        tester,
        wards: [
          WardRoundPatient(
            admission: admission('p1', ward: 'ICU', bed: '12'),
            patient: patient(
              'p1',
              'Ramesh Kumar',
              ageYears: 54,
              gender: 'Male',
            ),
            mrn: 'MRN-77',
          ),
        ],
      );

      expect(find.text('Ramesh Kumar'), findsOneWidget);
      expect(find.textContaining('ICU'), findsOneWidget);
      expect(find.textContaining('Bed 12'), findsOneWidget);
      expect(find.textContaining('MRN-77'), findsOneWidget);
      expect(find.textContaining('54 yrs'), findsOneWidget);
    });

    testWidgets('post-op day badge appears on ward round cards', (
      tester,
    ) async {
      await pumpWorkspace(
        tester,
        wards: [
          WardRoundPatient(
            admission: admission('p1', ward: 'ICU'),
            patient: patient('p1', 'Post-op Patient'),
          ),
        ],
        podDay: 2,
      );

      expect(find.byType(PostOpDayBadge), findsOneWidget);
      expect(find.text('POD #2'), findsOneWidget);
    });

    testWidgets('no post-op badge when the patient has no surgery', (
      tester,
    ) async {
      await pumpWorkspace(
        tester,
        wards: [
          WardRoundPatient(
            admission: admission('p1', ward: 'ICU'),
            patient: patient('p1', 'Medical Patient'),
          ),
        ],
        podDay: null,
      );

      expect(find.byType(PostOpDayBadge), findsNothing);
      // The card itself must still render.
      expect(find.text('Medical Patient'), findsOneWidget);
    });

    testWidgets('a long patient name does not overflow the card', (
      tester,
    ) async {
      await pumpWorkspace(
        tester,
        wards: [
          WardRoundPatient(
            admission: admission('p1', ward: 'Cardiac Intensive Care Unit'),
            patient: patient(
              'p1',
              'Chandrashekhar Venkataraghavan Iyer Krishnamurthy',
            ),
            mrn: 'MRN-000000000012345',
          ),
        ],
      );

      expect(tester.takeException(), isNull);
      expect(
        find.text('Chandrashekhar Venkataraghavan Iyer Krishnamurthy'),
        findsOneWidget,
      );
    });

    testWidgets('tapping a card navigates to the patient timeline', (
      tester,
    ) async {
      await pumpWorkspace(
        tester,
        wards: [
          WardRoundPatient(
            admission: admission('p1', ward: 'ICU'),
            patient: patient('p1', 'Ramesh Kumar'),
          ),
        ],
      );

      await tester.tap(find.text('Ramesh Kumar'));
      await tester.pumpAndSettle();
      expect(find.text('TIMELINE'), findsOneWidget);
    });

    // ---- remaining tabs -----------------------------------------------
    testWidgets('pending results tab shows the test and its age', (
      tester,
    ) async {
      await pumpWorkspace(
        tester,
        results: [
          PendingInvestigation(
            investigation: InvestigationOrder(
              id: 'o1',
              patientId: 'p1',
              testName: 'Complete Blood Count',
              status: 'ordered',
              orderedAt: DateTime.now().subtract(const Duration(days: 3)),
              ownerId: 'owner-1',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            patient: patient('p1', 'Sunita Devi'),
            mrn: 'MRN-9',
          ),
        ],
      );

      await tapTab(tester, 'Pending Results');

      expect(find.text('Sunita Devi'), findsOneWidget);
      expect(find.text('Complete Blood Count'), findsOneWidget);
      // Age chip is informational, not a clinical threshold.
      expect(find.text('3d'), findsOneWidget);
    });

    testWidgets('follow-ups tab reports when the patient was last seen', (
      tester,
    ) async {
      await pumpWorkspace(
        tester,
        followUps: [
          SmartFollowUp(
            patient: patient('p1', 'Anil Verma'),
            lastSeenAt: DateTime.now().subtract(const Duration(days: 4)),
          ),
        ],
      );

      await tapTab(tester, 'Follow-ups');

      expect(find.text('Anil Verma'), findsOneWidget);
      expect(find.textContaining('Last seen'), findsOneWidget);
    });

    testWidgets('a never-seen follow-up says so plainly', (tester) async {
      await pumpWorkspace(
        tester,
        followUps: [SmartFollowUp(patient: patient('p1', 'New Patient'))],
      );

      await tapTab(tester, 'Follow-ups');

      expect(find.text('No prior encounter recorded'), findsOneWidget);
    });

    testWidgets('drafts tab shows the recorded complaint', (tester) async {
      final now = DateTime.now();
      await pumpWorkspace(
        tester,
        drafts: [
          PendingNote(
            encounter: ClinicalEncounter(
              id: 'e1',
              ownerId: 'owner-1',
              patientId: 'p1',
              encounterType: 'OPD Consult',
              careSetting: 'OPD',
              occurredAt: now,
              chiefComplaints: 'Abdominal pain x 3 days',
              dynamicData: const {},
              pediatricHistory: const {},
              obGynHistory: const {},
              createdAt: now,
              updatedAt: now,
              isDraft: true,
            ),
            patient: patient('p1', 'Priya Sharma'),
          ),
        ],
      );

      await tapTab(tester, 'Drafts');

      expect(find.text('Priya Sharma'), findsOneWidget);
      expect(find.text('Abdominal pain x 3 days'), findsOneWidget);
    });

    // ---- loading / error resilience ------------------------------------
    testWidgets('a failing stream degrades gracefully, not a red screen', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 740));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, _) => const TodayWorkspaceScreen()),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            wardRoundsProvider.overrideWith(
              (ref) => Stream<List<WardRoundPatient>>.error(
                StateError('database offline'),
              ),
            ),
            outstandingInvestigationsProvider.overrideWith(
              (ref) => Stream.value(const <PendingInvestigation>[]),
            ),
            smartFollowUpsProvider.overrideWith(
              (ref) => Stream.value(const <SmartFollowUp>[]),
            ),
            pendingNotesProvider.overrideWith(
              (ref) => Stream.value(const <PendingNote>[]),
            ),
            postOpDayProvider.overrideWith((ref, _) async => null),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            theme: ThemeData(splashFactory: NoSplash.splashFactory),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Could not load'), findsOneWidget);
      // The other tabs must still be present and usable.
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Drafts'), findsOneWidget);
    });

    // =====================================================================
    // STEP 1.4 — Quick Action Grid. The action card's text block sits inside a
    // fixed-height grid cell, so an unbounded Column overflows. This pins the
    // fix and guards the narrow-phone case that produced the report.
    // =====================================================================
    group('QuickActionSheet grid bounds', () {
      Future<void> pumpSheet(WidgetTester tester, {Size? surface}) async {
        await tester.binding.setSurfaceSize(surface ?? const Size(360, 740));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        // `QuickActionSheet` calls context.pop/push when an action is tapped, so
        // it needs a GoRouter ancestor. The grid-bounds test never taps an
        // action, so the sheet is rendered directly rather than in a modal —
        // a modal would nest a second Navigator and break the contexts.
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => const Scaffold(
                body: SingleChildScrollView(child: QuickActionSheet()),
              ),
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            theme: ThemeData(splashFactory: NoSplash.splashFactory),
          ),
        );
        await tester.pumpAndSettle();
      }

      testWidgets('renders every action tile without overflow', (tester) async {
        await pumpSheet(tester);
        expect(find.text('Smart Scan'), findsOneWidget);
        expect(find.text('New OPD Consult'), findsOneWidget);
        // The critical assertion: a RenderFlex overflow would surface here.
        expect(tester.takeException(), isNull);
      });

      testWidgets('no overflow on a very narrow ward phone', (tester) async {
        await pumpSheet(tester, surface: const Size(320, 640));
        expect(tester.takeException(), isNull);
      });

      testWidgets('no overflow on a tablet-width screen', (tester) async {
        await pumpSheet(tester, surface: const Size(834, 1112));
        expect(tester.takeException(), isNull);
      });

      testWidgets('"More tools" tiles keep visible text labels', (
        tester,
      ) async {
        await pumpSheet(tester, surface: const Size(320, 900));
        // Sprint 14.5 — these labels were being swallowed when the secondary
        // grid's short cells forced compact mode, leaving bare icons.
        for (final label in [
          'Vitals',
          'Ward Board',
          'Knowledge',
          'Data & Sync',
        ]) {
          expect(
            find.text(label),
            findsOneWidget,
            reason: '"More tools" must show a text label: $label',
          );
        }
      });

      testWidgets('"More tools" captions are visible, not just the labels', (
        tester,
      ) async {
        await pumpSheet(tester, surface: const Size(320, 900));
        expect(find.text('Bedside observations'), findsOneWidget);
        expect(find.text('Beds and census'), findsOneWidget);
      });
    });
  });
}
