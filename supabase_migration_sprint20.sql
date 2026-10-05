-- Sprint 20: additive alignment for current local Drift clinical records.
-- Safe to re-run: columns, tables, constraints, and indexes are guarded.
-- Reflection text is private local learning data and is not part of sync.

BEGIN;

-- A patient may be associated with a default facility. Existing patient rows
-- remain valid and the relationship is cleared if that hospital is removed.
ALTER TABLE public.patients
  ADD COLUMN IF NOT EXISTS hospital_id uuid
    REFERENCES public.hospitals(id) ON DELETE SET NULL;

-- Keep these statements idempotent even when Sprint 16 has already been run.
ALTER TABLE public.clinical_encounters
  ADD COLUMN IF NOT EXISTS hospital_id uuid
    REFERENCES public.hospitals(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS is_draft boolean NOT NULL DEFAULT false;

-- Mirror the current Drift document registry. JSON extraction is stored as
-- text to match the local column and preserve its serialized payload exactly.
ALTER TABLE public.document_registries
  ADD COLUMN IF NOT EXISTS image_hash text,
  ADD COLUMN IF NOT EXISTS clincom_json text;

-- Problem links are nullable by design: unassigned management remains valid.
ALTER TABLE public.prescription_orders
  ADD COLUMN IF NOT EXISTS problem_id uuid;
ALTER TABLE public.investigation_orders
  ADD COLUMN IF NOT EXISTS problem_id uuid;
ALTER TABLE public.clinical_interventions
  ADD COLUMN IF NOT EXISTS problem_id uuid;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'public.prescription_orders'::regclass
      AND conname = 'prescription_orders_problem_id_fkey'
  ) THEN
    ALTER TABLE public.prescription_orders
      ADD CONSTRAINT prescription_orders_problem_id_fkey
      FOREIGN KEY (problem_id) REFERENCES public.patient_problems(id)
      ON DELETE SET NULL;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'public.investigation_orders'::regclass
      AND conname = 'investigation_orders_problem_id_fkey'
  ) THEN
    ALTER TABLE public.investigation_orders
      ADD CONSTRAINT investigation_orders_problem_id_fkey
      FOREIGN KEY (problem_id) REFERENCES public.patient_problems(id)
      ON DELETE SET NULL;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'public.clinical_interventions'::regclass
      AND conname = 'clinical_interventions_problem_id_fkey'
  ) THEN
    ALTER TABLE public.clinical_interventions
      ADD CONSTRAINT clinical_interventions_problem_id_fkey
      FOREIGN KEY (problem_id) REFERENCES public.patient_problems(id)
      ON DELETE SET NULL;
  END IF;
END
$$;

CREATE INDEX IF NOT EXISTS prescription_orders_problem_id_idx
  ON public.prescription_orders(problem_id);
CREATE INDEX IF NOT EXISTS investigation_orders_problem_id_idx
  ON public.investigation_orders(problem_id);
CREATE INDEX IF NOT EXISTS clinical_interventions_problem_id_idx
  ON public.clinical_interventions(problem_id);

-- This table mirrors ClinicalLearningLogs for backup/schema completeness only.
-- The app does not sync this table. RLS with no client policies explicitly
-- denies access to clinician reflections through Supabase's client APIs.
CREATE TABLE IF NOT EXISTS public.clinical_learning_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  encounter_id uuid REFERENCES public.clinical_encounters(id) ON DELETE SET NULL,
  patient_id uuid NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
  owner_id text NOT NULL DEFAULT 'local-practitioner',
  diagnosis_confidence_score integer NOT NULL DEFAULT 5
    CHECK (diagnosis_confidence_score BETWEEN 1 AND 10),
  differential_diagnoses text NOT NULL DEFAULT '',
  decision_rationale text NOT NULL DEFAULT '',
  clinical_takeaway text NOT NULL DEFAULT '',
  tags text NOT NULL DEFAULT '[]',
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.clinical_learning_logs ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS clinical_learning_logs_patient_created_idx
  ON public.clinical_learning_logs(patient_id, created_at DESC);

COMMIT;
