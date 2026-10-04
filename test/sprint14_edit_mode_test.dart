import 'package:clinical_companion/core/database/daos/clinical_dao.dart';
import 'package:clinical_companion/core/database/local_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sprint 14.5 — Edit Mode corrections.
///
/// The critical property: correcting a saved document must UPDATE it. Routing
/// the save through `processAiExtraction` would hit its idempotency guard
/// (same patientId + imagePath) and silently discard the clinician's edits
/// while reporting success.
void main() {
  late AppDatabase db;
  late ClinicalDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = ClinicalDao(db);
  });

  tearDown(() async => db.close());

  Future<String> seedPatientAndDocument() async {
    await db
        .into(db.patients)
        .insert(
          PatientsCompanion.insert(
            id: const Value('p1'),
            ownerId: 'owner-1',
            fullName: 'Ramesh Kumar',
          ),
        );
    const documentId = 'doc-1';
    await db
        .into(db.documentRegistries)
        .insert(
          DocumentRegistriesCompanion.insert(
            id: documentId,
            patientId: 'p1',
            documentCategory: 'Histopathology Report',
            imagePath: '/tmp/scan.jpg',
            rawOcrTranscript: const Value('original transcript'),
            documentedAt: DateTime.utc(2024, 3, 12, 9, 30),
          ),
        );
    return documentId;
  }

  test('a corrected date is persisted, not replaced with "now"', () async {
    final id = await seedPatientAndDocument();
    final corrected = DateTime.utc(2024, 3, 13, 7, 45);

    expect(
      await dao.applyDocumentEdits(documentId: id, documentedAt: corrected),
      isTrue,
    );

    final row = await (db.select(
      db.documentRegistries,
    )..where((r) => r.id.equals(id))).getSingle();
    expect(row.documentedAt, corrected);
    // The whole point of the sprint: an old report must not become today.
    expect(row.documentedAt.year, 2024);
  });

  test('the transcript is updated when supplied', () async {
    final id = await seedPatientAndDocument();
    await dao.applyDocumentEdits(
      documentId: id,
      documentedAt: DateTime.utc(2024, 3, 12),
      rawOcrTranscript: 'Features suggestive of acute appendicitis.',
    );

    final row = await (db.select(
      db.documentRegistries,
    )..where((r) => r.id.equals(id))).getSingle();
    expect(row.rawOcrTranscript, 'Features suggestive of acute appendicitis.');
  });

  test('a null transcript leaves the stored one untouched', () async {
    final id = await seedPatientAndDocument();
    await dao.applyDocumentEdits(
      documentId: id,
      documentedAt: DateTime.utc(2024, 3, 12),
    );

    final row = await (db.select(
      db.documentRegistries,
    )..where((r) => r.id.equals(id))).getSingle();
    expect(row.rawOcrTranscript, 'original transcript');
  });

  test('editing never duplicates the document row', () async {
    final id = await seedPatientAndDocument();
    for (var i = 0; i < 3; i++) {
      await dao.applyDocumentEdits(
        documentId: id,
        documentedAt: DateTime.utc(2024, 3, 12 + i),
      );
    }
    final rows = await db.select(db.documentRegistries).get();
    expect(rows, hasLength(1));
  });

  test(
    'editing a missing document reports failure rather than throwing',
    () async {
      expect(
        await dao.applyDocumentEdits(
          documentId: 'does-not-exist',
          documentedAt: DateTime.utc(2024, 3, 12),
        ),
        isFalse,
      );
    },
  );
}
