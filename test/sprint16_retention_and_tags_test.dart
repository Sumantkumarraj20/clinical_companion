import 'dart:io';

import 'package:clinical_companion/core/database/daos/clinical_dao.dart';
import 'package:clinical_companion/core/database/local_database.dart';
import 'package:clinical_companion/core/services/storage_retention_service.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sprint 16 — image pruning and reflection #tagging.
///
/// The property that matters most in both: **clinical text is never lost**.
/// Pruning may delete a JPEG; it must never delete the OCR transcript. And a
/// tag typo must not silently make a reflection unfindable forever.
void main() {
  late AppDatabase db;
  late ClinicalDao dao;
  late StorageRetentionService retention;
  late Directory tmp;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    dao = ClinicalDao(db);
    retention = StorageRetentionService(db);
    tmp = await Directory.systemTemp.createTemp('retention');
    await db
        .into(db.patients)
        .insert(
          PatientsCompanion.insert(
            id: const Value('p1'),
            ownerId: 'owner-1',
            fullName: 'Ramesh Kumar',
          ),
        );
  });

  tearDown(() async {
    await db.close();
    if (tmp.existsSync()) await tmp.delete(recursive: true);
  });

  /// Creates a real file on disk and a matching document row.
  Future<DocumentRegistry> seedDocument({
    required DateTime documentedAt,
    String name = 'scan.jpg',
    String transcript = 'CONCLUSION: features suggestive of appendicitis',
  }) async {
    final file = File('${tmp.path}/$name')..writeAsBytesSync([1, 2, 3, 4]);
    final id = 'doc-${documentedAt.millisecondsSinceEpoch}';
    await db
        .into(db.documentRegistries)
        .insert(
          DocumentRegistriesCompanion.insert(
            id: id,
            patientId: 'p1',
            documentCategory: 'Histopathology Report',
            imagePath: file.path,
            rawOcrTranscript: Value(transcript),
            documentedAt: documentedAt,
          ),
        );
    final rows = await (db.select(
      db.documentRegistries,
    )..where((r) => r.id.equals(id))).get();
    return rows.single;
  }

  // =========================================================================
  // PRUNING
  // =========================================================================
  group('pruneOldImages', () {
    test('deletes the file but keeps the row and transcript', () async {
      final doc = await seedDocument(
        documentedAt: DateTime.now().subtract(const Duration(days: 800)),
      );
      final file = File(doc.imagePath);
      expect(file.existsSync(), isTrue);

      expect(await retention.pruneOldImages(), 1);

      expect(file.existsSync(), isFalse, reason: 'the JPEG must be freed');
      final row = await (db.select(
        db.documentRegistries,
      )..where((r) => r.id.equals(doc.id))).getSingle();
      expect(
        row.rawOcrTranscript,
        'CONCLUSION: features suggestive of appendicitis',
        reason: 'the clinically valuable text must survive verbatim',
      );
      expect(row.documentedAt, doc.documentedAt);
      expect(row.documentCategory, 'Histopathology Report');
    });

    test('marks the row with the pruned sentinel, not a dead path', () async {
      final doc = await seedDocument(
        documentedAt: DateTime.now().subtract(const Duration(days: 500)),
      );
      await retention.pruneOldImages();

      final row = await (db.select(
        db.documentRegistries,
      )..where((r) => r.id.equals(doc.id))).getSingle();
      // A dangling path would render a broken thumbnail and invite a retry
      // against a file that no longer exists.
      expect(row.imagePath, StorageRetentionService.prunedSentinel);
    });

    test('recent documents are never touched', () async {
      final doc = await seedDocument(
        documentedAt: DateTime.now().subtract(const Duration(days: 300)),
      );
      expect(await retention.pruneOldImages(), 0);
      expect(File(doc.imagePath).existsSync(), isTrue);
    });

    test('only prunes documents past the cutoff', () async {
      await seedDocument(
        documentedAt: DateTime.now().subtract(const Duration(days: 400)),
        name: 'old.jpg',
      );
      await seedDocument(
        documentedAt: DateTime.now().subtract(const Duration(days: 10)),
        name: 'new.jpg',
      );

      expect(await retention.pruneOldImages(), 1);
      final remaining = await db.select(db.documentRegistries).get();
      expect(remaining, hasLength(2), reason: 'no row is ever deleted');
      expect(remaining.where((r) => !r.imagePath.contains('pruned')).length, 1);
    });

    test('is idempotent — a second sweep finds nothing left to do', () async {
      await seedDocument(
        documentedAt: DateTime.now().subtract(const Duration(days: 900)),
      );
      expect(await retention.pruneOldImages(), 1);
      expect(
        await retention.pruneOldImages(),
        0,
        reason: 'the sentinel must not be re-selected',
      );
    });

    test(
      'a row whose file already vanished is still marked, not stuck',
      () async {
        final doc = await seedDocument(
          documentedAt: DateTime.now().subtract(const Duration(days: 900)),
        );
        File(doc.imagePath).deleteSync();

        expect(await retention.pruneOldImages(), 1);
        final row = await (db.select(
          db.documentRegistries,
        )..where((r) => r.id.equals(doc.id))).getSingle();
        expect(row.imagePath, StorageRetentionService.prunedSentinel);
      },
    );

    test('respects a custom retention window', () async {
      await seedDocument(
        documentedAt: DateTime.now().subtract(const Duration(days: 40)),
      );
      expect(await retention.pruneOldImages(maxAgeDays: 30), 1);
    });

    test(
      'countPrunedDocuments reports how many images were reclaimed',
      () async {
        await seedDocument(
          documentedAt: DateTime.now().subtract(const Duration(days: 900)),
        );
        expect(await retention.countPrunedDocuments(), 0);
        await retention.pruneOldImages();
        expect(await retention.countPrunedDocuments(), 1);
      },
    );
  });

  // =========================================================================
  // HASHTAGS
  // =========================================================================
  group('extractHashtags', () {
    test('pulls a tag out of prose and lower-cases it', () {
      expect(ClinicalDao.extractHashtags('Watch the sodium. #Hyponatremia'), [
        'hyponatremia',
      ]);
    });

    test('collects several tags in first-appearance order', () {
      expect(ClinicalDao.extractHashtags('#renal #hyponatremia then #fluid'), [
        'renal',
        'hyponatremia',
        'fluid',
      ]);
    });

    test('de-duplicates case-insensitively', () {
      expect(ClinicalDao.extractHashtags('#Renal and #renal again'), ['renal']);
    });

    test('ignores text with no tags', () {
      expect(ClinicalDao.extractHashtags('Plain prose, no tags.'), isEmpty);
      expect(ClinicalDao.extractHashtags(''), isEmpty);
    });

    test('ignores a lone hash or a one-character tag', () {
      // '#b' is a single character and is rejected as noise, not a tag.
      expect(ClinicalDao.extractHashtags('# a #b #renal'), ['renal']);
    });

    test('is bounded so a pasted paragraph cannot flood the row', () {
      final spam = List.generate(50, (i) => '#tag$i').join(' ');
      expect(ClinicalDao.extractHashtags(spam).length, lessThanOrEqualTo(12));
    });

    test('tags are persisted and searchable on the reflection', () async {
      final log = await dao.saveReflection(
        patientId: 'p1',
        confidenceScore: 6,
        differentialDiagnoses: 'Hypotonic hyponatremia #hyponatremia #renal',
        decisionRationale: 'Sodium 118, volume depleted',
        clinicalTakeaway: 'Check volume first #renal',
      );

      expect(log.tags, containsAll(['hyponatremia', 'renal']));

      final found = await dao.getReflectionsByTag('hyponatremia');
      expect(found, hasLength(1));
      expect(found.single.id, log.id);

      // Tag lookup tolerates the leading '#' the clinician actually typed.
      expect(await dao.getReflectionsByTag('#renal'), hasLength(1));
      expect(await dao.getReflectionsByTag('unrelated'), isEmpty);
    });

    test('getAllReflections returns the hub feed newest first', () async {
      await dao.saveReflection(
        patientId: 'p1',
        confidenceScore: 3,
        differentialDiagnoses: 'older',
        decisionRationale: 'older',
        clinicalTakeaway: 'older',
        createdAt: DateTime.utc(2026, 1, 1),
      );
      await dao.saveReflection(
        patientId: 'p1',
        confidenceScore: 9,
        differentialDiagnoses: 'newer',
        decisionRationale: 'newer',
        clinicalTakeaway: 'newer',
        createdAt: DateTime.utc(2026, 2, 1),
      );

      final all = await dao.getAllReflections();
      expect(all, hasLength(2));
      expect(all.first.decisionRationale, 'newer');
    });
  });
}
