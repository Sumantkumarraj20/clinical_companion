-- ===========================================================================
-- Sprint 16 (rev 2) — KNOWN BLOCKERS: CHECK constraints that reject
--                    legitimate local data.
-- ===========================================================================
-- Run supabase_migration_sprint16.sql FIRST, then this file.
--
-- WHY A SEPARATE FILE
--   These are NOT schema-shape problems — the columns exist. They are enum
--   CHECKs whose allowed values are narrower than what the app actually
--   produces. Running only the main migration makes Supabase "succeed", and
--   the failure then shows up much later as rows that silently never sync.
--   That is the worst possible time to find out, so it is called out here.
--
-- SAFETY
--   * DROP CONSTRAINT IF EXISTS + ADD CONSTRAINT removes only the *rule*,
--     never the rows. No data is touched.
--   * Each new CHECK is a SUPERSET of the old values plus the ones the app
--     legitimately emits, so nothing that used to be accepted is rejected now.
--
-- HOW TO VERIFY A CLEAN RESULT
--   SELECT id, status FROM public.patient_problems WHERE status NOT IN
--     ('Active','Improving','Deteriorating','Controlled','Resolved','Recurred');
--   -- should return 0 rows.
-- ===========================================================================

BEGIN;

-- =========================================================================
-- 8. patient_problems.status
-- =========================================================================
-- Local Drift (ClinicalProblems.currentStatus) allows:
--   Active, Improving, Deteriorating, Controlled, Resolved, Recurred
-- Remote allows only:
--   Active, Resolved, Chronic
-- Verified against the app source: it writes Active, Improving, Deteriorating,
-- Controlled, Resolved and Recurred. Remote accepts only Active, Resolved and
-- Chronic, so TODAY FOUR of the six statuses are rejected on insert:
--   Improving, Deteriorating, Controlled, Recurred.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'patient_problems_status_check'
      AND conrelid = 'public.patient_problems'::regclass
  ) THEN
    ALTER TABLE public.patient_problems
      DROP CONSTRAINT patient_problems_status_check;
  END IF;
END $$;

ALTER TABLE public.patient_problems
  DROP CONSTRAINT IF EXISTS patient_problems_status_check;

ALTER TABLE public.patient_problems
  ADD CONSTRAINT patient_problems_status_check
  CHECK (status = ANY (ARRAY[
    'Active','Improving','Deteriorating','Controlled','Resolved','Chronic','Recurred'
  ]::text[]));

-- =========================================================================
-- 9. investigation_tracker.status
-- =========================================================================
-- Local emits 'ordered' as the initial status of a new investigation order.
-- Remote CHECK starts at 'pending', so the very first order of every patient
-- is rejected.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'investigation_tracker_status_check'
      AND conrelid = 'public.investigation_tracker'::regclass
  ) THEN
    ALTER TABLE public.investigation_tracker
      DROP CONSTRAINT investigation_tracker_status_check;
  END IF;
END $$;

ALTER TABLE public.investigation_tracker
  DROP CONSTRAINT IF EXISTS investigation_tracker_status_check;

ALTER TABLE public.investigation_tracker
  ADD CONSTRAINT investigation_tracker_status_check
  CHECK (status = ANY (ARRAY[
    'pending','ordered','sample_sent','result_received','cancelled'
  ]::text[]));

-- =========================================================================
-- 10. patients.sex  (local column is `gender`)
-- =========================================================================
-- Local writes 'Male' / 'Female' / 'Other'. Remote CHECK allows only
-- female/male/intersex/unknown, so:
--   * 'Male' / 'Female' (capitalised) are REJECTED, and
--   * 'Other' is not in the list at all.
-- This is why the mirror column `patients.gender` was added unconstrained in
-- the main migration. Widening the CHECK keeps the legacy column usable while
-- `gender` carries the app's real vocabulary.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'patients_sex_check'
      AND conrelid = 'public.patients'::regclass
  ) THEN
    ALTER TABLE public.patients DROP CONSTRAINT patients_sex_check;
  END IF;
END $$;

ALTER TABLE public.patients DROP CONSTRAINT IF EXISTS patients_sex_check;

ALTER TABLE public.patients
  ADD CONSTRAINT patients_sex_check
  CHECK (
    sex IS NULL OR lower(btrim(sex)) IN ('male','female','intersex','other','unknown')
  );

-- =========================================================================
-- 11. sync_queue  <-- HIGHEST RISK: NOTHING CAN SYNC TODAY
-- =========================================================================
-- Two independent defects here, both verified against the app source
-- (lib/core/database/daos/clinical_dao.dart lines ~2455 and ~79).
--
-- (a) owner_id is `uuid NOT NULL`, but the app writes the TEXT sentinel
--     'local-practitioner' (ClinicalDao.defaultOwnerId). Postgres cannot cast
--     that to uuid, so EVERY enqueued row is rejected. Cross-device sync is
--     silently 100% broken, not partially broken — and it fails quietly
--     because the client keeps retrying into a queue that never drains.
--
-- (b) entity_type is pinned to 5 values. The app enqueues 5 DIFFERENT ones:
--       app writes : patients, clinical_encounters, patient_problems,
--                    prescription_orders, ai_extraction
--       remote allows: patients, clinical_encounters, investigation_tracker,
--                    drug_master, personal_wiki
--     So patient_problems, prescription_orders and ai_extraction are rejected.
--
-- Fix (a): widen owner_id to text, matching the local column. Existing uuid
-- values cast cleanly, so this is lossless.
ALTER TABLE public.sync_queue
  ALTER COLUMN owner_id TYPE text USING owner_id::text;

-- auth.uid() is no longer valid for a text column; keep the existing value
-- rather than forcing a default that would be wrong for an offline device.
ALTER TABLE public.sync_queue
  ALTER COLUMN owner_id SET DEFAULT 'local-practitioner';

-- Fix (b): the enum is owned by the CLIENT. Pinning it server-side is exactly
-- what dropped rows in the first place, so replace it with a not-empty rule.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'sync_queue_entity_type_check'
      AND conrelid = 'public.sync_queue'::regclass
  ) THEN
    ALTER TABLE public.sync_queue DROP CONSTRAINT sync_queue_entity_type_check;
  END IF;
END $$;

ALTER TABLE public.sync_queue
  DROP CONSTRAINT IF EXISTS sync_queue_entity_type_check;

ALTER TABLE public.sync_queue
  ADD CONSTRAINT sync_queue_entity_type_check
  CHECK (length(btrim(entity_type)) > 0);

-- Same owner_id defect exists on the other tables the app writes with the
-- sentinel. Relax them all so nothing is rejected on a text-vs-uuid cast.
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'patients','clinical_encounters','patient_problems','clinical_actions',
    'clinical_outcomes','cdss_rules','admissions','prescription_orders',
    'clinical_interventions','clinical_outcome_metrics','document_registries',
    'clinical_observations','personal_wiki','problem_progress_snapshots'
  ] LOOP
    IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema='public' AND table_name = t
        AND column_name='owner_id' AND data_type='uuid'
    ) THEN
      EXECUTE format('ALTER TABLE public.%I ALTER COLUMN owner_id TYPE text USING owner_id::text', t);
      EXECUTE format('ALTER TABLE public.%I ALTER COLUMN owner_id SET DEFAULT %L', t, 'local-practitioner');
      EXECUTE format('ALTER TABLE public.%I DROP CONSTRAINT IF EXISTS %I', t, t || '_owner_id_fkey');
    END IF;
  END LOOP;
END $$;

COMMIT;

-- ===========================================================================
-- POST-RUN CHECKLIST
-- ===========================================================================
--  1. Column check:
--       SELECT column_name FROM information_schema.columns
--        WHERE table_name='clinical_encounters'
--          AND column_name IN ('hospital_id','is_draft','care_setting');
--     -> expect 3 rows.
--
--  2. NEW table exists:
--       SELECT to_regclass('public.clinical_learning_logs');
--     -> expect public.clinical_learning_logs.
--
--  3. Widened CHECKs took effect:
--       SELECT conname FROM pg_constraint
--        WHERE conname IN ('patient_problems_status_check',
--                           'investigation_tracker_status_check',
--                           'patients_sex_check',
--                           'sync_queue_entity_type_check');
--     -> expect all 4.
--
--  4. RLS: if Row Level Security is enabled on these tables, every one needs
--     a policy for the role the app uses, or sync fails with 401/42501 and
--     drops rows. Check: SELECT tablename, rowsecurity FROM pg_tables
--     WHERE schemaname='public';
--
--  5. Backfill hospital_id on historical encounters (optional but recommended
--     so old visits are not facility-less):
--       UPDATE public.clinical_encounters e
--          SET hospital_id = p.hospital_id
--         FROM (SELECT DISTINCT ON (patient_id) patient_id, hospital_id
--                 FROM public.patient_hospital_identifiers
--                WHERE is_primary) p
--        WHERE e.patient_id = p.patient_id AND e.hospital_id IS NULL;
