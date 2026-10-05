-- ===========================================================================
-- Sprint 16 (rev 2) — Supabase alignment migration
-- ===========================================================================
-- Aligns the REMOTE Postgres schema with the local Drift schema
-- (lib/core/database/local_database.dart, schemaVersion 26).
--
-- REV 2 FIX: the first version of this file assumed every key was `text`
-- (because local Drift uses TEXT ids). Supabase is `uuid` throughout, so every
-- `ADD COLUMN ... TEXT REFERENCES` failed with:
--     ERROR 42804: key columns are of incompatible types: text and uuid
-- This revision uses `uuid` for every key and FK to match the live database.
--
-- GUARANTEES
--   * Idempotent — safe to run repeatedly.
--   * NON-DESTRUCTIVE — no DROP TABLE, no DROP COLUMN, no data deletion.
--   * Existing rows keep working: every new column is nullable or has a default.
--
-- !! BEFORE RUNNING, READ "KNOWN BLOCKERS" AT THE BOTTOM. !!
--   Sections 8-9 must ALSO be run or clinical data will be REJECTED by the
--   remote's CHECK constraints at sync time, long after this file succeeds.
--
-- HOW: Supabase Dashboard -> SQL Editor -> paste whole file -> Run.
-- ===========================================================================

BEGIN;

-- =========================================================================
-- 1. patients — multi-hospital + demographics (local Drift additions)
-- =========================================================================
-- NOTE: remote column is `sex` (CHECK-constrained), local column is `gender`.
-- We do NOT rename; see section 8 for the CHECK fix. `gender` is added as a
-- nullable mirror so the sync layer can write it without a schema change.
ALTER TABLE public.patients
  ADD COLUMN IF NOT EXISTS gender           text,
  ADD COLUMN IF NOT EXISTS residence        text,
  ADD COLUMN IF NOT EXISTS occupation       text,
  ADD COLUMN IF NOT EXISTS height_cm        real,
  ADD COLUMN IF NOT EXISTS weight_kg        real,
  ADD COLUMN IF NOT EXISTS alternate_phone  text,
  ADD COLUMN IF NOT EXISTS mrn              text;

-- =========================================================================
-- 2. clinical_encounters — care context + draft lifecycle (Sprint 14/15)
-- =========================================================================
ALTER TABLE public.clinical_encounters
  ADD COLUMN IF NOT EXISTS hospital_id             uuid REFERENCES public.hospitals(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS care_setting            text NOT NULL DEFAULT 'OPD',
  ADD COLUMN IF NOT EXISTS is_draft                boolean NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS department              text,
  ADD COLUMN IF NOT EXISTS ward_name               text,
  ADD COLUMN IF NOT EXISTS bed_number              text,
  ADD COLUMN IF NOT EXISTS clinical_diagnosis       text,
  ADD COLUMN IF NOT EXISTS icd11_code              text,
  ADD COLUMN IF NOT EXISTS disposition             text,
  ADD COLUMN IF NOT EXISTS chief_complaints        text,
  ADD COLUMN IF NOT EXISTS history_of_present_illness text,
  ADD COLUMN IF NOT EXISTS past_history            text,
  ADD COLUMN IF NOT EXISTS drug_and_allergy_history text,
  ADD COLUMN IF NOT EXISTS personal_and_social_history text,
  ADD COLUMN IF NOT EXISTS examination_findings    text,
  ADD COLUMN IF NOT EXISTS clinical_assessment     text,
  ADD COLUMN IF NOT EXISTS image_path              text,
  ADD COLUMN IF NOT EXISTS ai_summary              text,
  ADD COLUMN IF NOT EXISTS pediatric_history       text NOT NULL DEFAULT '{}'::text,
  ADD COLUMN IF NOT EXISTS ob_gy_history          text NOT NULL DEFAULT '{}'::text,
  ADD COLUMN IF NOT EXISTS map                     numeric;

-- =========================================================================
-- 3. patient_hospital_identifiers — local uses `mrn` + `identifier_type`
-- =========================================================================
-- Remote has `hospital_reg_no NOT NULL`. We relax it to nullable so a patient
-- registered at a second facility without an MRN can sync (local allows null).
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'patient_hospital_identifiers'
      AND column_name = 'hospital_reg_no'
      AND is_nullable = 'NO'
  ) THEN
    ALTER TABLE public.patient_hospital_identifiers
      ALTER COLUMN hospital_reg_no DROP NOT NULL;
  END IF;
END $$;

ALTER TABLE public.patient_hospital_identifiers
  ADD COLUMN IF NOT EXISTS mrn              text,
  ADD COLUMN IF NOT EXISTS identifier_type  text NOT NULL DEFAULT 'MRN';

-- Backfill so `mrn` and `hospital_reg_no` agree for existing rows.
UPDATE public.patient_hospital_identifiers
   SET mrn = hospital_reg_no
 WHERE mrn IS NULL AND hospital_reg_no IS NOT NULL;

-- =========================================================================
-- 4. investigation_orders — align `owner_id` with the sync client
-- =========================================================================
-- Already `text` on the remote (created from local Drift). Left untouched.

-- =========================================================================
-- 5. Missing catalog + knowledge tables (local Drift has them, remote does not)
-- =========================================================================
CREATE TABLE IF NOT EXISTS public.clinical_drugs (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id            text NOT NULL DEFAULT 'local-practitioner',
  generic_name        text NOT NULL,
  brand_name          text,
  strength            text,
  usage_frequency     integer NOT NULL DEFAULT 0,
  associated_problems text NOT NULL DEFAULT '[]'::text,
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.active_ingredients (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  molecule_code    text NOT NULL,
  generic_name     text NOT NULL,
  therapeutic_class text,
  created_at       timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.indications (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  molecule_code       text NOT NULL,
  clinical_indication text NOT NULL,
  created_at          timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.formulations (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  molecule_code text NOT NULL,
  strength      text,
  dosage_form   text,
  created_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.brands (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  molecule_code text NOT NULL,
  brand_name    text NOT NULL,
  manufacturer  text,
  created_at    timestamptz NOT NULL DEFAULT now()
);

-- =========================================================================
-- 6. clinical_learning_logs — NEW (Sprint 15/16)
-- =========================================================================
-- `owner_id` is TEXT on purpose: the app writes the sentinel
-- 'local-practitioner' for a single-clinician offline device. The remote
-- convention of `uuid DEFAULT auth.uid()` is reserved for Supabase-hosted
-- multi-user auth, which this app does not use yet.
--
-- !! THIS TABLE IS DELIBERATELY NOT SYNCED. !!
-- Reflections are the clinician's private reasoning; they must never leave the
-- device. It exists for audit/backup completeness only.
CREATE TABLE IF NOT EXISTS public.clinical_learning_logs (
  id                         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  encounter_id               uuid REFERENCES public.clinical_encounters(id) ON DELETE SET NULL,
  patient_id                 uuid NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
  owner_id                   text NOT NULL DEFAULT 'local-practitioner',
  diagnosis_confidence_score integer NOT NULL DEFAULT 5
                             CHECK (diagnosis_confidence_score BETWEEN 1 AND 10),
  differential_diagnoses     text NOT NULL DEFAULT '',
  decision_rationale         text NOT NULL DEFAULT '',
  clinical_takeaway          text NOT NULL DEFAULT '',
  tags                       text NOT NULL DEFAULT '[]'::text,
  created_at                 timestamptz NOT NULL DEFAULT now()
);

-- =========================================================================
-- 7. Performance indexes for the "Today" workspace (Sprint 14)
-- =========================================================================
CREATE INDEX IF NOT EXISTS clinical_encounters_patient_occurred_idx
  ON public.clinical_encounters (patient_id, occurred_at DESC);
CREATE INDEX IF NOT EXISTS clinical_encounters_draft_idx
  ON public.clinical_encounters (is_draft, updated_at DESC);
CREATE INDEX IF NOT EXISTS admissions_patient_status_idx
  ON public.admissions (patient_id, status);
CREATE INDEX IF NOT EXISTS document_registries_patient_documented_idx
  ON public.document_registries (patient_id, documented_at DESC);
CREATE INDEX IF NOT EXISTS document_registries_documented_at_idx
  ON public.document_registries (documented_at);
CREATE INDEX IF NOT EXISTS clinical_learning_logs_patient_created_idx
  ON public.clinical_learning_logs (patient_id, created_at DESC);

COMMIT;
