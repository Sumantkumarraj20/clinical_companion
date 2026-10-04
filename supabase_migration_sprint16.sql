-- ===========================================================================
-- Sprint 16 — Supabase alignment migration
-- ===========================================================================
-- Aligns the REMOTE Postgres schema with the current local Drift schema
-- (lib/core/database/local_database.dart, schemaVersion 25).
--
-- HOW TO USE
--   Supabase Dashboard -> SQL Editor -> paste -> Run.
--   Everything is idempotent (IF NOT EXISTS / DO $$ ... IF NOT EXISTS), so it
--   is safe to run more than once.
--
-- SAFE TO RUN WHEN THE REMOTE HAS PATIENT DATA
--   - No DROP TABLE and no DROP COLUMN anywhere.
--   - New columns are added nullable or with defaults, so existing rows keep
--     working and backfill cleanly.
--
-- !! CLINICAL_LEARNING_LOGS IS A NEW TABLE BUT IS **NOT** SYNCED BY THE APP !!
--   Sprint 15 deliberately kept reflections off the sync queue because they are
--   the clinician's private reasoning. This table exists for audit/backup
--   completeness only. Do NOT add it to any sync or cohort-export query.
-- ===========================================================================

BEGIN;

-- ---------------------------------------------------------------------------
-- 1. patients — multi-hospital tracking (Sprint 14)
-- ---------------------------------------------------------------------------
ALTER TABLE public.patients
  ADD COLUMN IF NOT EXISTS residence      TEXT,
  ADD COLUMN IF NOT EXISTS occupation     TEXT,
  ADD COLUMN IF NOT EXISTS height_cm      DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS weight_kg      DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS phone          TEXT,
  ADD COLUMN IF NOT EXISTS alternate_phone TEXT;

-- ---------------------------------------------------------------------------
-- 2. clinical_encounters — care context + draft lifecycle (Sprint 14/15)
-- ---------------------------------------------------------------------------
ALTER TABLE public.clinical_encounters
  ADD COLUMN IF NOT EXISTS hospital_id       TEXT REFERENCES public.hospitals(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS care_setting      TEXT NOT NULL DEFAULT 'OPD',
  ADD COLUMN IF NOT EXISTS is_draft          BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS department        TEXT,
  ADD COLUMN IF NOT EXISTS ward_name         TEXT,
  ADD COLUMN IF NOT EXISTS bed_number        TEXT,
  ADD COLUMN IF NOT EXISTS clinical_diagnosis TEXT,
  ADD COLUMN IF NOT EXISTS icd11_code        TEXT,
  ADD COLUMN IF NOT EXISTS disposition       TEXT,
  ADD COLUMN IF NOT EXISTS chief_complaints  TEXT,
  ADD COLUMN IF NOT EXISTS history_of_present_illness TEXT,
  ADD COLUMN IF NOT EXISTS past_history      TEXT,
  ADD COLUMN IF NOT EXISTS drug_and_allergy_history TEXT,
  ADD COLUMN IF NOT EXISTS personal_and_social_history TEXT,
  ADD COLUMN IF NOT EXISTS examination_findings TEXT,
  ADD COLUMN IF NOT EXISTS clinical_assessment TEXT,
  ADD COLUMN IF NOT EXISTS consultant_advice  TEXT,
  ADD COLUMN IF NOT EXISTS image_path        TEXT,
  ADD COLUMN IF NOT EXISTS ai_summary        TEXT,
  ADD COLUMN IF NOT EXISTS dynamic_data      TEXT NOT NULL DEFAULT '{}'::text,
  ADD COLUMN IF NOT EXISTS pediatric_history TEXT NOT NULL DEFAULT '{}'::text,
  ADD COLUMN IF NOT EXISTS ob_gyn_history    TEXT NOT NULL DEFAULT '{}'::text,
  ADD COLUMN IF NOT EXISTS last_synced_at    TIMESTAMPTZ;

-- ---------------------------------------------------------------------------
-- 3. admissions — ward / bed tracking (Sprint 14)
-- ---------------------------------------------------------------------------
ALTER TABLE public.admissions
  ADD COLUMN IF NOT EXISTS ward_name    TEXT,
  ADD COLUMN IF NOT EXISTS bed_number   TEXT,
  ADD COLUMN IF NOT EXISTS status       TEXT NOT NULL DEFAULT 'active',
  ADD COLUMN IF NOT EXISTS discharge_time TIMESTAMPTZ;

-- ---------------------------------------------------------------------------
-- 4. document_registries — the write path landed in Sprint 14.5, so the remote
--    must carry documented_at or synced scans lose their clinical date.
-- ---------------------------------------------------------------------------
ALTER TABLE public.document_registries
  ADD COLUMN IF NOT EXISTS document_category  TEXT,
  ADD COLUMN IF NOT EXISTS raw_ocr_transcript TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS confidence_score   DOUBLE PRECISION NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS documented_at      TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS created_at         TIMESTAMPTZ DEFAULT NOW();

-- ---------------------------------------------------------------------------
-- 5. clinical_learning_logs — NEW (Sprint 15)
--    Deliberately excluded from sync; see the header warning.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.clinical_learning_logs (
  id                        TEXT PRIMARY KEY,
  encounter_id              TEXT REFERENCES public.clinical_encounters(id) ON DELETE SET NULL,
  patient_id                TEXT NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
  owner_id                  TEXT NOT NULL DEFAULT 'local-practitioner',
  diagnosis_confidence_score INTEGER NOT NULL DEFAULT 5
                              CHECK (diagnosis_confidence_score BETWEEN 1 AND 10),
  differential_diagnoses    TEXT NOT NULL DEFAULT '',
  decision_rationale        TEXT NOT NULL DEFAULT '',
  clinical_takeaway         TEXT NOT NULL DEFAULT '',
  created_at                TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS clinical_learning_logs_patient_created_idx
  ON public.clinical_learning_logs (patient_id, created_at DESC);

CREATE INDEX IF NOT EXISTS clinical_learning_logs_owner_idx
  ON public.clinical_learning_logs (owner_id);

-- ---------------------------------------------------------------------------
-- 6. Supporting tables introduced across Sprints 11-13 that must exist
--    remotely for the sync queue to be able to land rows.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.patient_hospital_identifiers (
  id              TEXT PRIMARY KEY,
  patient_id      TEXT NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
  hospital_id     TEXT NOT NULL REFERENCES public.hospitals(id) ON DELETE CASCADE,
  mrn             TEXT,
  identifier_type TEXT NOT NULL DEFAULT 'MRN',
  is_primary      BOOLEAN NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS patient_hospital_identifiers_patient_idx
  ON public.patient_hospital_identifiers (patient_id);

CREATE TABLE IF NOT EXISTS public.problem_progress_snapshots (
  id              TEXT PRIMARY KEY,
  problem_id      TEXT NOT NULL REFERENCES public.patient_problems(id) ON DELETE CASCADE,
  recorded_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  snapshot_status TEXT NOT NULL DEFAULT '',
  notes           TEXT NOT NULL DEFAULT '',
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.clinical_drugs (
  id                   TEXT PRIMARY KEY,
  owner_id             TEXT,
  generic_name         TEXT NOT NULL,
  brand_name           TEXT,
  strength             TEXT,
  usage_frequency      INTEGER NOT NULL DEFAULT 0,
  associated_problems  TEXT NOT NULL DEFAULT '[]'::text,
  created_at           TIMESTAMPTZ DEFAULT NOW(),
  updated_at           TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.active_ingredients (
  id            TEXT PRIMARY KEY,
  molecule_code TEXT NOT NULL,
  generic_name  TEXT NOT NULL,
  therapeutic_class TEXT,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS active_ingredients_generic_idx
  ON public.active_ingredients (generic_name);

CREATE TABLE IF NOT EXISTS public.indications (
  id                 TEXT PRIMARY KEY,
  molecule_code      TEXT NOT NULL,
  clinical_indication TEXT NOT NULL,
  created_at         TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.formulations (
  id            TEXT PRIMARY KEY,
  molecule_code TEXT NOT NULL,
  strength      TEXT,
  dosage_form   TEXT,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.brands (
  id            TEXT PRIMARY KEY,
  molecule_code TEXT NOT NULL,
  brand_name    TEXT NOT NULL,
  manufacturer  TEXT,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ---------------------------------------------------------------------------
-- 7. Personal wiki — the "Clinical Guidelines" half of the knowledge hub.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.personal_wiki (
  id                   TEXT PRIMARY KEY,
  owner_id             TEXT NOT NULL,
  topic                TEXT NOT NULL,
  markdown_content     TEXT NOT NULL DEFAULT '',
  tags                 TEXT NOT NULL DEFAULT '[]'::text,
  department_relevance TEXT NOT NULL DEFAULT '[]'::text,
  created_at           TIMESTAMPTZ DEFAULT NOW(),
  updated_at           TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS personal_wiki_owner_topic_idx
  ON public.personal_wiki (owner_id, topic);

-- ---------------------------------------------------------------------------
-- 8. Query indexes the app's "Today" workspace depends on (Sprint 14).
-- ---------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS clinical_encounters_patient_occurred_idx
  ON public.clinical_encounters (patient_id, occurred_at DESC);

CREATE INDEX IF NOT EXISTS clinical_encounters_draft_idx
  ON public.clinical_encounters (is_draft, updated_at DESC);

CREATE INDEX IF NOT EXISTS admissions_patient_status_idx
  ON public.admissions (patient_id, status);

CREATE INDEX IF NOT EXISTS investigation_results_patient_idx
  ON public.investigation_results (patient_id, result_date DESC);

CREATE INDEX IF NOT EXISTS document_registries_patient_documented_idx
  ON public.document_registries (patient_id, documented_at DESC);

-- ---------------------------------------------------------------------------
-- 9. Support the app's local retention sweep on a restored backup.
--    StorageRetentionService keys off documented_at; without this index a
--    restore-then-prune pass would full-scan.
-- ---------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS document_registries_documented_at_idx
  ON public.document_registries (documented_at);

COMMIT;

-- ===========================================================================
-- POST-MIGRATION CHECKLIST
-- ===========================================================================
--  1. SELECT column_name FROM information_schema.columns
--     WHERE table_name = 'clinical_encounters' AND column_name = 'is_draft';
--     -> expect exactly one row.
--
--  2. SELECT to_regclass('public.clinical_learning_logs');
--     -> expect public.clinical_learning_logs (not NULL).
--
--  3. SELECT count(*) FROM public.clinical_encounters WHERE hospital_id IS NULL;
--     -> expected on a legacy database; backfill from the patient's primary
--        facility rather than leaving historical visits facility-less.
--
--  4. Verify Supabase Row Level Security. The app talks to Postgres with the
--     service/anon key; if RLS is enabled, every table above needs a policy or
--     sync will fail silently with 401/42501.
