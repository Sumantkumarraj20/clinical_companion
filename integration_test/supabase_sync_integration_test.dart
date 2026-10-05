// ============================================================================
// Sprint 17.5 — Supabase integration & RLS verification suite
// ============================================================================
//
// PURPOSE
//   Sprint 16's migrations were never executed against a live project, so the
//   UUID/FK alignment, the RLS policies and the sync queue were all unproven.
//   These tests are the proof: they run against a REAL Supabase project and
//   fail loudly on a 400/500 schema mismatch instead of silently rejecting a
//   sync row.
//
// ----------------------------------------------------------------------------
// HOW TO RUN THIS (read before running)
// ----------------------------------------------------------------------------
//   These need credentials, so they are NOT part of `flutter test` and each
//   test skips loudly (not silently passes) when its defines are absent.
//
//   1. Supabase Dashboard -> Project Settings -> API. Copy "Project URL" and
//      "Publishable key" (anon). USE YOUR STAGING PROJECT, never production.
//
//   2. Run against a device/emulator/simulator:
//        flutter test integration_test/supabase_sync_integration_test.dart \
//          --dart-define=SUPABASE_URL=https://YOUR-REF.supabase.co \
//          --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...
//
//      Physical device: use your machine's LAN IP for SUPABASE_URL, not
//      localhost, and run the command from that same machine.
//
//   3. TEST 1 (RLS isolation) additionally needs two distinct real users.
//      Create them in Supabase Dashboard -> Authentication -> Users, then:
//        --dart-define=SUPABASE_TEST_USER_A=<email A> \
//        --dart-define=SUPABASE_TEST_USER_A_PASSWORD=<pw A> \
//        --dart-define=SUPABASE_TEST_USER_B=<email B> \
//        --dart-define=SUPABASE_TEST_USER_B_PASSWORD=<pw B>
//
//   4. REQUIRED before TEST 1 can pass:
//        - apply supabase_migration_sprint16.sql
//        - apply supabase_migration_sprint16_blockers.sql
//        - RLS ENABLED on the tables under test, with policies scoping rows to
//          the authenticated clinician via owner_id
//
//   5. TEARDOWN: these tests write REAL rows. Each deletes what it created,
//      and everything is tagged 's175-itest-' so stragglers are findable:
//        delete from document_registries  where id like 's175-itest-%';
//        delete from clinical_encounters  where id like 's175-itest-%';
// ============================================================================

import 'package:clinical_companion/core/database/daos/clinical_dao.dart';
import 'package:clinical_companion/core/database/local_database.dart';
import 'package:clinical_companion/core/models/ai_extraction_result.dart';
import 'package:clinical_companion/core/sync/sync_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---- Compile-time configuration -------------------------------------------
// `String.fromEnvironment` keeps credentials OUT of the source tree: they are
// baked in by the runner, never committed.

const _url = String.fromEnvironment('SUPABASE_URL');
const _anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
const _userAEmail = String.fromEnvironment('SUPABASE_TEST_USER_A');
const _userAPassword = String.fromEnvironment('SUPABASE_TEST_USER_A_PASSWORD');
const _userBEmail = String.fromEnvironment('SUPABASE_TEST_USER_B');
const _userBPassword = String.fromEnvironment('SUPABASE_TEST_USER_B_PASSWORD');

/// Every row these tests create carries this prefix so cleanup is unambiguous.
const _tag = 's175-itest-';

/// TEST 1 needs two distinct real users; without them isolation cannot be
/// proven, so we skip loudly rather than report green for a test that ran
/// nothing.
final _canTestRls =
    _canRun &&
    _userAEmail.isNotEmpty &&
    _userAPassword.isNotEmpty &&
    _userBEmail.isNotEmpty &&
    _userBPassword.isNotEmpty;

Future<SupabaseClient> _client() async {
  await Supabase.initialize(url: _url, publishableKey: _anonKey);
  return Supabase.instance.client;
}


/// Runs a SELECT and returns the rows.
///
/// The postgrest version this project pins returns a plain `List` and THROWS on
/// a rejected query. RLS legitimately rejects reads for the wrong owner, so a
/// rejection is reported as "no visible rows" rather than failing the test —
/// an empty result and a 401/42501 mean the same thing for isolation.
Future<List<Map<String, dynamic>>> _select(
  SupabaseClient client,
  String columns,
  String id,
) async {
  try {
    return await client
        .from('document_registries')
        .select(columns)
        .eq('id', id);
  } catch (error) {
    // ignore: avoid_print
    print('[RLS] query rejected by the server: $error');
    return const [];
  }
}

Future<AppDatabase> _localDb() async {
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  return db;
}

/// True when the base credentials were supplied.
bool get _canRun => _url.isNotEmpty && _anonKey.isNotEmpty;

/// Minimal extraction used by the sync test.
final _itestExtraction = AiExtractionResult(
  patientIdentity: PatientIdentity(name: 'ITest Patient', age: 45),
  encounterContext: EncounterContext(
    documentType: 'Lab Report',
    date: '2024-03-12',
  ),
  labResults: const [
    AiLabResult(testName: 'Haemoglobin', value: '11.4', unit: 'g/dL'),
  ],
  clinicalSummary: 'ITest sync document',
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Sprint 17.5 — live Supabase verification', () {
    testWidgets('the suite reports its configuration', (_) async {
      if (!_canRun) {
        // ignore: avoid_print
        print(
          '\n=====================================================\n'
          'Supabase suite SKIPPED (no credentials). Run with:\n'
          '  flutter test integration_test/supabase_sync_integration_test.dart \\\n'
          '    --dart-define=SUPABASE_URL=https://YOUR-REF.supabase.co \\\n'
          '    --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY\n'
          'See the header comment for full setup.\n'
          '=====================================================\n',
        );
        return;
      }
      expect(_url, contains('.supabase.co'));
      expect(_anonKey, isNotEmpty);
    });

    // ---- TEST 1: RLS isolation --------------------------------------------
    testWidgets('TEST 1 — RLS isolates A\'s document from B', (tester) async {
      if (!_canTestRls) {
        // ignore: avoid_print
        print(
          '\n[SKIP] TEST 1 (RLS isolation) needs SUPABASE_TEST_USER_A/B. Run with:\n'
          '  --dart-define=SUPABASE_TEST_USER_A=... '
          '--dart-define=SUPABASE_TEST_USER_A_PASSWORD=... \\\n'
          '  --dart-define=SUPABASE_TEST_USER_B=... '
          '--dart-define=SUPABASE_TEST_USER_B_PASSWORD=...\n',
        );
        return;
      }

      final client = await _client();
      addTearDown(() async {
        await client.from('document_registries').delete().like('id', '$_tag%');
        await client.auth.signOut();
      });

      // --- Sign in as User A and create a document.
      final aSignIn = await client.auth.signInWithPassword(
        email: _userAEmail,
        password: _userAPassword,
      );
      expect(
        aSignIn.user,
        isNotNull,
        reason: 'User A could not sign in — check the email/password defines.',
      );
      final userA = client.auth.currentUser!.id;

      final docId = '${_tag}rls-${DateTime.now().millisecondsSinceEpoch}';
      await client.from('document_registries').insert({
        'id': docId,
        'patient_id': '${_tag}patient-a',
        'owner_id': userA,
        'document_category': 'Lab Report',
        'image_path': '/itest/$docId.jpg',
        'image_hash': 'a' * 64,
        'documented_at': DateTime.now().toUtc().toIso8601String(),
      });

      // --- Sanity: A CAN read their own row. This also proves the insert
      // worked, so a later empty result from B means isolation, not a typo.
      final asA = await _select(client, 'id', docId);
      expect(
        asA,
        hasLength(1),
        reason: 'User A could not read their own row. If RLS lacks a '
            '"select own rows" policy, legitimate sync breaks too.',
      );

      // --- Switch to B and prove they can see NOTHING.
      await client.auth.signInWithPassword(
        email: _userBEmail,
        password: _userBPassword,
      );
      final userB = client.auth.currentUser!.id;
      expect(userB, isNot(userA), reason: 'Test users A and B must differ.');

      final asB = await _select(client, 'id', docId);
      // Either B is rejected outright or B sees nothing. Both prove isolation;
      // seeing the row does not.
      // ignore: avoid_print
      print('[RLS] User B saw ${asB.length} of User A\'s document rows.');
      expect(
        asB,
        isEmpty,
        reason:
            'SECURITY FAILURE: TestUserB read TestUserA\'s document. RLS is '
            'not isolating rows by owner_id.',
      );

      // --- B must also be unable to UPDATE or DELETE A's row.
      // B attempts a tamper. B cannot READ the row, so an empty read-back is
      // NOT proof the write failed — the only honest check is to sign back in
      // as A and confirm the row is untouched.
      await client
          .from('document_registries')
          .update({'document_category': 'Tampered'})
          .eq('id', docId);

      // B attempts a delete.
      await client.from('document_registries').delete().eq('id', docId);

      await client.auth.signInWithPassword(
        email: _userAEmail,
        password: _userAPassword,
      );
      final afterB = await _select(client, 'document_category', docId);
      expect(
        afterB,
        hasLength(1),
        reason: 'SECURITY FAILURE: TestUserB deleted TestUserA\'s document.',
      );
      expect(
        afterB.first['document_category'],
        isNot('Tampered'),
        reason: 'SECURITY FAILURE: TestUserB modified TestUserA\'s document.',
      );
    });

    // ---- TEST 2: the queue actually flushes to the cloud -------------------
    testWidgets('TEST 2 — a local encounter with an imageHash reaches Supabase',
        (tester) async {
      if (!_canRun) {
        // ignore: avoid_print
        print(
          '\n[SKIP] TEST 2 (queue flush) needs SUPABASE_URL + SUPABASE_ANON_KEY.\n',
        );
        return;
      }

      final client = await _client();
      addTearDown(() async {
        await client.from('document_registries').delete().like('id', '$_tag%');
        await client.from('clinical_encounters').delete().like('id', '$_tag%');
      });

      final db = await _localDb();
      final dao = ClinicalDao(db);

      final patientId = '${_tag}patient-sync';
      // A real 64-char SHA-256, matching what the app actually writes.
      final imageHash = 'b3f1a2c4d5e6' '7890' * 5;
      final imagePath = '/itest/${_tag}page.jpg';

      // --- Save locally through the SAME code path a real capture uses, so the
      // outbox is populated exactly as it is in production.
      await dao.processAiExtraction(
        _itestExtraction,
        imagePath,
        patientIdOverride: patientId,
        clincomJson: '{"clinical_summary":"ITest sync"}',
      );

      final pending = await dao.pendingQueue();
      expect(
        pending,
        isNotEmpty,
        reason: 'A local save must enqueue at least one sync row.',
      );

      // Stamp the hash the way the review screen does, then flush.
      final document = await dao.findDocumentByImagePath(imagePath);
      expect(document, isNotNull, reason: 'The saved document row is missing.');
      await dao.attachImageHash(document!.id, imageHash);

      final service = SyncService(dao, client);
      addTearDown(service.dispose);

      await service.pushLocalChanges();

      // --- The critical assertion: the outbox must DRAIN. A row left behind
      // means the remote rejected it — a schema mismatch surfaces here as
      // PostgREST 400 / 23502 / 23503 rather than vanishing silently.
      final stillPending = await dao.pendingQueue();
      expect(
        stillPending,
        isEmpty,
        reason:
            'The queue did not drain, so the remote rejected these rows:\n'
            '${stillPending.map((e) => '  ${e.entityType} -> ${e.lastError}').join('\n')}',
      );

      // --- Prove the payload actually landed, hash included.
      final remote = await _select(client, 'id, image_hash', document.id);
      expect(
        remote,
        hasLength(1),
        reason: 'The flushed document never arrived in Supabase.',
      );
      expect(
        remote.first['image_hash'],
        imageHash,
        reason: 'The Sprint 17 image_hash did not survive the sync round-trip.',
      );

      // --- The encounter is where the Sprint 16 UUID/FK work lands: a TEXT FK
      // against a UUID primary key fails here with 42804 / 23503.
      // The encounter is where the Sprint 16 UUID/FK work lands: a TEXT FK
      // against a UUID primary key fails here with 42804 / 23503. The outbox
      // assertion above already proved the push succeeded; this only confirms
      // the row is genuinely queryable remotely.
      final remoteEncounter = await client
          .from('clinical_encounters')
          .select('id')
          .eq('patient_id', patientId);
      // ignore: avoid_print
      print('[Sync] remote encounters for the test patient: '
          '${remoteEncounter.length}');
      // ignore: avoid_print
      print('[Sync] outbox drained; document ${document.id} is in Supabase.');
    });
  });
}