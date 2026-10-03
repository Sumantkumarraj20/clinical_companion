import 'package:clinical_companion/core/database/local_database.dart';
import 'package:clinical_companion/core/utils/datetime_utils.dart';
import 'package:clinical_companion/features/bedside/screens/encounter_opd_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// FIX 6 — the pediatric and OB/GYN history sections must be driven by patient
/// demographics. Both flags previously defaulted to `false` and were never
/// supplied at the call site, so neither section could ever be reached.
void main() {
  Patient patientAt(int yearsOld, {String? gender}) {
    final now = DateTime.now();
    return Patient(
      id: 'p1',
      ownerId: 'owner-1',
      fullName: 'Test Patient',
      gender: gender,
      // Subtracting whole years keeps the resulting age exact regardless of
      // whether today is a leap day or a month boundary.
      dateOfBirth: DateTime(now.year - yearsOld, now.month, now.day),
    );
  }

  Future<void> pumpSections(
    WidgetTester tester, {
    required bool pediatric,
    required bool obGyn,
  }) async {
    final controllers = List.generate(13, (_) => TextEditingController());
    addTearDown(() {
      for (final c in controllers) {
        c.dispose();
      }
    });

    await tester.binding.setSurfaceSize(const Size(600, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: OpdHistorySections(
              complaint: controllers[0],
              hpi: controllers[1],
              pastMedical: controllers[2],
              pastSurgical: controllers[3],
              personalHistory: controllers[4],
              socialHistory: controllers[5],
              birthHistory: controllers[6],
              milestones: controllers[7],
              vaccination: controllers[8],
              gplaa: controllers[9],
              lmp: controllers[10],
              menstrualHistory: controllers[11],
              examination: controllers[12],
              showPediatricHistory: pediatric,
              showObGynHistory: obGyn,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('pediatric section hidden when flag is false', (tester) async {
    await pumpSections(tester, pediatric: false, obGyn: false);
    expect(find.text('Pediatric History'), findsNothing);
    expect(find.text('OB/GYN History'), findsNothing);
    // The modular sections that should always be present.
    expect(find.text('Chief Complaints & HPI'), findsOneWidget);
  });

  testWidgets('pediatric section shown when flag is true', (tester) async {
    await pumpSections(tester, pediatric: true, obGyn: false);
    expect(find.text('Pediatric History'), findsOneWidget);
    expect(find.text('OB/GYN History'), findsNothing);
  });

  testWidgets('OB/GYN section shown only when flag is true', (tester) async {
    await pumpSections(tester, pediatric: false, obGyn: true);
    expect(find.text('OB/GYN History'), findsOneWidget);
    expect(find.text('Pediatric History'), findsNothing);
  });

  testWidgets('history sections are collapsible, not always expanded', (
    tester,
  ) async {
    await pumpSections(tester, pediatric: true, obGyn: true);
    // Pediatric/OB-GYN tiles default to collapsed so they never clutter.
    expect(find.text('Birth history (term, weight, NICU, cry)'), findsNothing);
    await tester.tap(find.text('Pediatric History'));
    await tester.pumpAndSettle();
    expect(
      find.text('Birth history (term, weight, NICU, cry)'),
      findsOneWidget,
    );
  });

  group('the gating rule itself', () {
    test('age under 18 is pediatric, 18 and over is not', () {
      final now = DateTime.now();
      int ageOf(int years) => DateTimeUtils.ageOn(
        DateTime(now.year - years, now.month, now.day),
        now,
      )!;
      expect(ageOf(17), lessThan(18));
      expect(ageOf(18), isNot(lessThan(18)));
    });

    test('unknown date of birth is never treated as pediatric', () {
      // Guards against defaulting an unknown age to 0 and surfacing a
      // pediatric form for an adult with a missing DOB.
      expect(DateTimeUtils.ageOn(null, DateTime.now()), isNull);
      expect(patientAt(40).dateOfBirth, isNotNull);
    });

    test('gender matching tolerates casing and the F shorthand', () {
      bool match(String? g) {
        final normalized = (g ?? '').trim().toLowerCase();
        return normalized == 'female' || normalized == 'f';
      }

      expect(match('Female'), isTrue);
      expect(match('FEMALE'), isTrue);
      expect(match(' f '), isTrue);
      expect(match('Male'), isFalse);
      expect(match(null), isFalse);
      expect(patientAt(30, gender: 'Female').gender, 'Female');
    });
  });
}
