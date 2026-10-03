import 'dart:io';

import 'package:clinical_companion/core/services/extraction_pipeline_service.dart';
import 'package:clinical_companion/core/utils/clinical_date_parser.dart';
import 'package:flutter_test/flutter_test.dart';

/// FIX 4 — scanned documents must be filed under the date *printed on the
/// document*, not the date the app happened to ingest it.
void main() {
  // Fixed clock so "today" never drifts into the assertions.
  final now = DateTime(2026, 3, 10);

  group('printed-format parsing (the formats Indian labs actually use)', () {
    test('dd/mm/yyyy', () {
      expect(
        ClinicalDateParser.parseClinicalDate(
          'Collection Date: 12/03/2024',
          now: now,
        ),
        DateTime(2024, 3, 12),
      );
    });

    test('dd-mm-yyyy with dashes', () {
      expect(
        ClinicalDateParser.parseClinicalDate('Report: 05-07-2025', now: now),
        DateTime(2025, 7, 5),
      );
    });

    test('dd.mm.yyyy with dots', () {
      expect(
        ClinicalDateParser.parseClinicalDate('Dated 3.8.2024', now: now),
        DateTime(2024, 8, 3),
      );
    });

    test('dd-Mon-yyyy with a month name', () {
      expect(
        ClinicalDateParser.parseClinicalDate('03-Sep-2023', now: now),
        DateTime(2023, 9, 3),
      );
    });

    test('full month name', () {
      expect(
        ClinicalDateParser.parseClinicalDate('12 August 2024', now: now),
        DateTime(2024, 8, 12),
      );
    });

    test('month-first form', () {
      expect(
        ClinicalDateParser.parseClinicalDate('August 12, 2024', now: now),
        DateTime(2024, 8, 12),
      );
    });

    test('ISO8601 still works (no regression on machine-generated files)', () {
      expect(
        ClinicalDateParser.parseClinicalDate('2024-03-12T09:30:00Z', now: now),
        isNotNull,
      );
      expect(
        ClinicalDateParser.parseClinicalDate('2024-03-12', now: now),
        DateTime(2024, 3, 12),
      );
    });

    test('picks the document date out of surrounding OCR noise', () {
      const text = '''
        GOVERNMENT HOSPITAL
        Department of Pathology
        Patient: Ramesh Kumar
        Sample Collected on: 14/02/2025
        Hb 12.4 g/dL
      ''';
      expect(
        ClinicalDateParser.parseClinicalDate(text, now: now),
        DateTime(2025, 2, 14),
      );
    });
  });

  group('rejects what it cannot trust', () {
    test('impossible calendar dates are rejected, not rolled over', () {
      // DateTime(2024, 2, 31) would silently become 2 March.
      expect(
        ClinicalDateParser.parseClinicalDate('31/02/2024', now: now),
        isNull,
      );
    });

    test('future dates are rejected', () {
      expect(
        ClinicalDateParser.parseClinicalDate('01/01/2099', now: now),
        isNull,
      );
    });

    test('no date at all yields null rather than guessing', () {
      expect(
        ClinicalDateParser.parseClinicalDate('Hb 12.4 g/dL', now: now),
        isNull,
      );
      expect(ClinicalDateParser.parseClinicalDate('', now: now), isNull);
    });
  });

  group('resolveDocumentedAt precedence', () {
    test('1. printed date in the OCR text wins over everything', () {
      final file = File('${Directory.systemTemp.path}/fake_report.jpg');
      final resolved = resolveDocumentedAt(
        'Collected on 05-07-2025',
        file.path,
        now: now,
      );
      expect(resolved, DateTime(2025, 7, 5));
    });

    test('2. falls back to file mtime when the text has no date', () async {
      final dir = await Directory.systemTemp.createTemp('docdate');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/scan.jpg')..writeAsBytesSync([1, 2, 3]);
      // Backdate the file so we can distinguish it from `now`.
      final backdated = DateTime(2024, 1, 15);
      file.setLastModifiedSync(backdated);

      final resolved = resolveDocumentedAt('no date here', file.path, now: now);
      expect(
        resolved.year,
        backdated.year,
        reason: 'must use file metadata, not the ingestion clock',
      );
      expect(resolved.month, 1);
      expect(resolved.day, 15);
    });

    test('3. uses now only as a last resort', () async {
      final dir = await Directory.systemTemp.createTemp('docdate2');
      addTearDown(() => dir.delete(recursive: true));
      // A path that does not exist -> no metadata available.
      final resolved = resolveDocumentedAt(
        'still no date',
        '${dir.path}/missing.jpg',
        now: now,
      );
      expect(resolved, now);
    });

    test('an unreadable content:// style path does not throw', () {
      final resolved = resolveDocumentedAt(
        'no date',
        'content://media/external/images/42',
        now: now,
      );
      expect(resolved, now);
    });

    test('null path is handled safely', () {
      expect(resolveDocumentedAt('no date', null, now: now), now);
    });
  });
}
