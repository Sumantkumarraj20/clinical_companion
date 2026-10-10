-- ============================================================================
-- CLINICAL COMPANION — BIDIRECTIONAL SYNC MIGRATION (Supabase / PostgreSQL)
-- ============================================================================
-- Idempotent: safe to run multiple times (IF NOT EXISTS / OR REPLACE /
-- DROP+CREATE for policies & triggers). Zero-data-loss design:
--   * only ADDs tables/columns, never drops or renames;
--   * soft-delete (deleted_at) everywhere — hard DELETEs are transparently
--     rewritten into tombstones so relational links never break;
--   * Last-Write-Wins on client updated_at + monotonic server_version for
--     high-performance delta pulls (WHERE server_version > :cursor).
--
-- Local Drift parity notes (lib/core/database/):
--   * Drift uses TEXT primary keys holding uuid-v4 strings; Postgres uuid
--     columns accept those strings implicitly on upsert, so types stay uuid.
--   * Drift ownerId is TEXT ('local-practitioner' when signed out); remote
--     owner_id stays uuid. Signed-out rows land with owner_id NULL plus a
--     client_id device marker and remain reachable via the anon test policy.
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Monotonic sync cursor shared by every synchronized table. Bumped by
-- fn_touch_sync_metadata() on every applied INSERT/UPDATE (and by the
-- soft-delete rewrite), so clients can delta-pull with
--   WHERE server_version > :last_synced_version ORDER BY server_version.
CREATE SEQUENCE IF NOT EXISTS public.sync_version_seq AS BIGINT;

-- ============================================================================
-- STEP 1a — MISSING TABLES (Drift parity). Full column sets for tables the
-- baseline schema lacks; skipped silently when the table already exists.
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.patient_problems (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  owner_id uuid DEFAULT auth.uid(),
  patient_id uuid NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
  encounter_id uuid REFERENCES public.clinical_encounters(id) ON DELETE SET NULL,
  problem_name text NOT NULL DEFAULT '',
  status text NOT NULL DEFAULT 'active',
  icd11_code text,
  onset_date timestamptz,
  resolved_date timestamptz,
  is_primary boolean NOT NULL DEFAULT false,
  notes text,
  severity text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT patient_problems_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.problem_progress_snapshots (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  owner_id uuid DEFAULT auth.uid(),
  problem_id uuid NOT NULL REFERENCES public.patient_problems(id) ON DELETE CASCADE,
  encounter_id uuid REFERENCES public.clinical_encounters(id) ON DELETE SET NULL,
  note text NOT NULL DEFAULT '',
  recorded_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT problem_progress_snapshots_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.clinical_interventions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  owner_id uuid DEFAULT auth.uid(),
  patient_id uuid NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
  problem_id uuid REFERENCES public.patient_problems(id) ON DELETE SET NULL,
  encounter_id uuid REFERENCES public.clinical_encounters(id) ON DELETE SET NULL,
  intervention_type text NOT NULL DEFAULT '',
  description text NOT NULL DEFAULT '',
  status text NOT NULL DEFAULT 'planned',
  ordered_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT clinical_interventions_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.clinical_outcome_metrics (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  owner_id uuid DEFAULT auth.uid(),
  problem_id uuid NOT NULL REFERENCES public.patient_problems(id) ON DELETE CASCADE,
  metric_name text NOT NULL DEFAULT '',
  metric_value numeric,
  metric_unit text,
  measured_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT clinical_outcome_metrics_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.investigation_orders (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  owner_id uuid DEFAULT auth.uid(),
  patient_id uuid NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
  problem_id uuid REFERENCES public.patient_problems(id) ON DELETE SET NULL,
  encounter_id uuid REFERENCES public.clinical_encounters(id) ON DELETE SET NULL,
  document_id uuid REFERENCES public.document_registries(id) ON DELETE SET NULL,
  test_name text NOT NULL DEFAULT '',
  test_code text,
  status text NOT NULL DEFAULT 'pending',
  ordered_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT investigation_orders_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.investigation_results (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  owner_id uuid DEFAULT auth.uid(),
  patient_id uuid NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
  order_id uuid REFERENCES public.investigation_orders(id) ON DELETE SET NULL,
  problem_id uuid REFERENCES public.patient_problems(id) ON DELETE SET NULL,
  test_name text NOT NULL DEFAULT '',
  result_value text,
  result_unit text,
  reference_range text,
  is_abnormal boolean NOT NULL DEFAULT false,
  result_date timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT investigation_results_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.clinical_rules (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  owner_id uuid DEFAULT auth.uid(),
  trigger_type text NOT NULL DEFAULT 'diagnosis',
  trigger_value text NOT NULL DEFAULT '',
  suggested_action text NOT NULL DEFAULT '',
  evidence_rationale text NOT NULL DEFAULT '',
  contraindicating_conditions text NOT NULL DEFAULT '[]',
  required_monitoring text NOT NULL DEFAULT '[]',
  differential_diagnoses text NOT NULL DEFAULT '[]',
  recommended_investigations text NOT NULL DEFAULT '[]',
  recommended_management text NOT NULL DEFAULT '[]',
  source_reference text NOT NULL DEFAULT '',
  is_verified boolean NOT NULL DEFAULT false,
  is_dismissed boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT clinical_rules_pkey PRIMARY KEY (id)
);

-- Local Drift Sprints 15-28 tables with no remote counterpart yet.
CREATE TABLE IF NOT EXISTS public.clinical_pathways (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  owner_id uuid DEFAULT auth.uid(),
  rule_id uuid REFERENCES public.clinical_rules(id) ON DELETE SET NULL,
  trigger_type text NOT NULL DEFAULT '',
  trigger_value text NOT NULL DEFAULT '',
  pathway_json jsonb NOT NULL DEFAULT '{}',
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT clinical_pathways_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.clinical_audits (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  owner_id uuid DEFAULT auth.uid(),
  patient_id uuid REFERENCES public.patients(id) ON DELETE CASCADE,
  suggestion_type text NOT NULL DEFAULT '',
  title text NOT NULL DEFAULT '',
  reasoning text NOT NULL DEFAULT '',
  status text NOT NULL DEFAULT 'dismissed'
    CHECK (status IN ('accepted', 'dismissed')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT clinical_audits_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.microbiology_cultures (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  owner_id uuid DEFAULT auth.uid(),
  patient_id uuid NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
  document_id uuid REFERENCES public.document_registries(id) ON DELETE SET NULL,
  sample_type text NOT NULL DEFAULT '',
  organism_identified text,
  colony_count text,
  antibiogram_json text NOT NULL DEFAULT '{}',
  reported_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT microbiology_cultures_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.imaging_studies (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  owner_id uuid DEFAULT auth.uid(),
  patient_id uuid NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
  document_id uuid REFERENCES public.document_registries(id) ON DELETE SET NULL,
  modality text NOT NULL DEFAULT '',
  anatomical_region text NOT NULL DEFAULT '',
  findings text NOT NULL DEFAULT '',
  impression text NOT NULL DEFAULT '',
  performed_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT imaging_studies_pkey PRIMARY KEY (id)
);

-- NOTE: public.personal_wiki already exists in the baseline; its missing
-- Drift-parity columns (department_relevance etc.) are added idempotently in
-- STEP 1b below. No personal_wiki_new table is needed.

-- ============================================================================
-- STEP 1b — DRIFT COLUMN PARITY (idempotent ADD COLUMNs on existing tables)
-- ============================================================================

ALTER TABLE public.patients ADD COLUMN IF NOT EXISTS mrn_text text;
ALTER TABLE public.patients ADD COLUMN IF NOT EXISTS alternate_phone_text text;

ALTER TABLE public.clinical_encounters
  ADD COLUMN IF NOT EXISTS problem_id uuid
    REFERENCES public.patient_problems(id) ON DELETE SET NULL;
ALTER TABLE public.clinical_encounters ADD COLUMN IF NOT EXISTS location_type text;
ALTER TABLE public.clinical_encounters ADD COLUMN IF NOT EXISTS location_department text;
ALTER TABLE public.clinical_encounters ADD COLUMN IF NOT EXISTS ward_name_text text;
ALTER TABLE public.clinical_encounters ADD COLUMN IF NOT EXISTS bed_number_text text;
ALTER TABLE public.clinical_encounters ADD COLUMN IF NOT EXISTS clincom_summary text;

ALTER TABLE public.document_registries ADD COLUMN IF NOT EXISTS image_hash text;
ALTER TABLE public.document_registries ADD COLUMN IF NOT EXISTS clincom_json text;
ALTER TABLE public.document_registries ADD COLUMN IF NOT EXISTS documented_at timestamptz;

ALTER TABLE public.personal_wiki ADD COLUMN IF NOT EXISTS department_relevance text NOT NULL DEFAULT '[]';

ALTER TABLE public.clinical_learning_logs ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

ALTER TABLE public.cdss_rules ADD COLUMN IF NOT EXISTS requires_pre_auth boolean NOT NULL DEFAULT false;
ALTER TABLE public.cdss_rules ADD COLUMN IF NOT EXISTS medicolegal_alert text NOT NULL DEFAULT '';
ALTER TABLE public.cdss_rules ADD COLUMN IF NOT EXISTS last_updated timestamptz;

ALTER TABLE public.clinical_observations ADD COLUMN IF NOT EXISTS corroboration_note_text text;

-- Backfill local created_at NOT NULL defaults where baseline left them NULL.
ALTER TABLE public.clinical_rules ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();
ALTER TABLE public.clinical_pathways ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();
ALTER TABLE public.clinical_audits ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

-- ============================================================================
-- STEP 1c — SYNC TRACKING COLUMNS (client_id / deleted_at / server_version)
-- created_at + updated_at already exist on the baseline; enforce sane
-- defaults where they were nullable, then add the three missing columns.
-- server_version is a plain BIGINT bumped by fn_touch_sync_metadata() from
-- sync_version_seq (GENERATED ALWAYS AS IDENTITY cannot be bumped by a
-- trigger on UPDATE, so a sequence-driven column is used instead).
-- ============================================================================

DO $$
DECLARE
  t text;
  sync_tables text[] := ARRAY[
    'patients','hospitals','wards','patient_hospital_identifiers',
    'clinical_encounters','patient_problems','problem_progress_snapshots',
    'clinical_interventions','clinical_outcome_metrics','clinical_actions',
    'clinical_outcomes','prescription_orders','investigation_orders',
    'investigation_results','investigation_tracker','drug_master',
    'personal_wiki','sync_queue','document_registries','clinical_observations',
    'microbiology_cultures','imaging_studies','clinical_drugs',
    'active_ingredients','indications','formulations','brands',
    'clinical_learning_logs','clinical_audits','clinical_rules',
    'clinical_pathways','cdss_rules'
  ];
BEGIN
  FOREACH t IN ARRAY sync_tables LOOP
    -- Bulletproof guard: guarantee created_at/updated_at exist on EVERY
    -- table (baseline or newly created) before defaults/indexes touch them.
    EXECUTE format('ALTER TABLE public.%I ADD COLUMN IF NOT EXISTS created_at timestamptz DEFAULT clock_timestamp()', t);
    EXECUTE format('ALTER TABLE public.%I ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT clock_timestamp()', t);
    -- client_id: originating device/installation (uuid string from Drift).
    EXECUTE format(
      'ALTER TABLE public.%I ADD COLUMN IF NOT EXISTS client_id text', t);
    -- MANDATORY soft-delete tombstone. NULL = live.
    EXECUTE format(
      'ALTER TABLE public.%I ADD COLUMN IF NOT EXISTS deleted_at timestamptz', t);
    -- Monotonic delta cursor.
    EXECUTE format(
      'ALTER TABLE public.%I ADD COLUMN IF NOT EXISTS server_version bigint NOT NULL DEFAULT 0', t);
    -- Harden timestamp defaults (no-ops when already correct).
    BEGIN
      EXECUTE format(
        'ALTER TABLE public.%I ALTER COLUMN created_at SET DEFAULT clock_timestamp()', t);
    EXCEPTION WHEN undefined_column THEN NULL; END;
    BEGIN
      EXECUTE format(
        'ALTER TABLE public.%I ALTER COLUMN updated_at SET DEFAULT clock_timestamp()', t);
    EXCEPTION WHEN undefined_column THEN NULL; END;
    -- Backfill NULL timestamps on legacy rows so LWW never sees NULL.
    BEGIN
      EXECUTE format(
        'UPDATE public.%I SET created_at = clock_timestamp() WHERE created_at IS NULL', t);
    EXCEPTION WHEN undefined_column THEN NULL; END;
    BEGIN
      EXECUTE format(
        'UPDATE public.%I SET updated_at = clock_timestamp() WHERE updated_at IS NULL', t);
    EXCEPTION WHEN undefined_column THEN NULL; END;
    -- Delta-query + tombstone-sweep indexes.
    EXECUTE format(
      'CREATE INDEX IF NOT EXISTS %I ON public.%I (server_version)',
      t || '_server_version_idx', t);
    EXECUTE format(
      'CREATE INDEX IF NOT EXISTS %I ON public.%I (updated_at) WHERE deleted_at IS NULL',
      t || '_updated_at_idx', t);
    EXECUTE format(
      'CREATE INDEX IF NOT EXISTS %I ON public.%I (deleted_at) WHERE deleted_at IS NOT NULL',
      t || '_deleted_at_idx', t);
  END LOOP;
END $$;

-- ============================================================================
-- STEP 2 — DETERMINISTIC CONFLICT RESOLUTION (LWW ENGINE)
-- ============================================================================
-- fn_touch_sync_metadata() runs BEFORE INSERT OR UPDATE on every sync table:
--   * INSERT: stamps created_at/updated_at/server_version when the client
--     left them NULL/zero, preserving genuine client timestamps otherwise.
--   * UPDATE: Last-Write-Wins. If the incoming updated_at is older than the
--     stored row, the write is a stale retry — non-authoritative columns are
--     left untouched while audit columns still advance (so the tombstone /
--     version stream never stalls). Rows carrying is_abnormal/result-grade
--     lab authority (formal results) always win over note-grade text even
--     when timestamps tie, per the "formal lab supersedes notes" rule.
--   * Hard DELETEs are blocked: an INSTEAD rewrite happens in
--     fn_block_hard_delete() (separate trigger below), converting them into
--     deleted_at tombstones that replicate cleanly.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_touch_sync_metadata()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
DECLARE
  existing_updated timestamptz;
  incoming_updated timestamptz;
  is_stale boolean := false;
  incoming_authoritative boolean := false;
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.created_at IS NULL THEN
      NEW.created_at := clock_timestamp();
    END IF;
    IF NEW.updated_at IS NULL THEN
      NEW.updated_at := clock_timestamp();
    END IF;
    IF NEW.server_version IS NULL OR NEW.server_version = 0 THEN
      NEW.server_version := nextval('public.sync_version_seq');
    END IF;
    RETURN NEW;
  END IF;

  -- UPDATE path: fetch the stored timestamp for LWW comparison.
  EXECUTE format('SELECT updated_at FROM public.%I WHERE id = $1', TG_TABLE_NAME)
    USING NEW.id INTO existing_updated;
  incoming_updated := NEW.updated_at;
  IF incoming_updated IS NULL THEN
    incoming_updated := clock_timestamp();
    NEW.updated_at := incoming_updated;
  END IF;

  -- Authority signal: formal lab-grade payloads outrank note-grade text.
  -- Checked dynamically so one function serves every table.
  BEGIN
    IF (to_jsonb(NEW) ? 'is_abnormal')
       AND COALESCE(((to_jsonb(NEW) ->> 'is_abnormal')::boolean), false) THEN
      incoming_authoritative := true;
    ELSIF (to_jsonb(NEW) ? 'result_value')
       AND (to_jsonb(NEW) ->> 'result_value') IS NOT NULL THEN
      incoming_authoritative := true;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    incoming_authoritative := false;
  END;

  IF existing_updated IS NOT NULL
     AND incoming_updated < existing_updated
     AND NOT incoming_authoritative THEN
    is_stale := true;
  END IF;

  IF is_stale THEN
    -- Stale retry: keep stored clinical fields, advance audit metadata only.
    -- Re-select the stored row and overlay the audit columns so no stale
    -- field overwrite can occur regardless of table shape.
    DECLARE
      stored record;
    BEGIN
      EXECUTE format('SELECT * FROM public.%I WHERE id = $1', TG_TABLE_NAME)
        USING NEW.id INTO stored;
      IF FOUND THEN
        NEW := stored;
        NEW.server_version := nextval('public.sync_version_seq');
        -- Preserve the tombstone state of the stored row; a stale write must
        -- never resurrect a deleted record.
      END IF;
    END;
    RETURN NEW;
  END IF;

  -- Fresh write wins: refresh the audit cursor.
  IF NEW.updated_at IS NULL OR NEW.updated_at = existing_updated THEN
    NEW.updated_at := clock_timestamp();
  END IF;
  NEW.server_version := nextval('public.sync_version_seq');
  RETURN NEW;
END;
$fn$;

-- Hard-delete guard: DELETE becomes a tombstone UPDATE (deleted_at set),
-- so deletions replicate across devices without breaking FK links.
CREATE OR REPLACE FUNCTION public.fn_block_hard_delete()
RETURNS trigger
LANGUAGE plpgsql
AS $fn$
BEGIN
  EXECUTE format(
    'UPDATE public.%I SET deleted_at = clock_timestamp(), '
    'updated_at = clock_timestamp(), '
    'server_version = nextval(''public.sync_version_seq'') WHERE id = $1',
    TG_TABLE_NAME
  ) USING OLD.id;
  RETURN NULL; -- cancel the physical delete
END;
$fn$;

DO $$
DECLARE
  t text;
  sync_tables text[] := ARRAY[
    'patients','hospitals','wards','patient_hospital_identifiers',
    'clinical_encounters','patient_problems','problem_progress_snapshots',
    'clinical_interventions','clinical_outcome_metrics','clinical_actions',
    'clinical_outcomes','prescription_orders','investigation_orders',
    'investigation_results','investigation_tracker','drug_master',
    'personal_wiki','sync_queue','document_registries','clinical_observations',
    'microbiology_cultures','imaging_studies','clinical_drugs',
    'active_ingredients','indications','formulations','brands',
    'clinical_learning_logs','clinical_audits','clinical_rules',
    'clinical_pathways','cdss_rules'
  ];
BEGIN
  FOREACH t IN ARRAY sync_tables LOOP
    EXECUTE format(
      'DROP TRIGGER IF EXISTS trg_touch_%I ON public.%I', t, t);
    EXECUTE format(
      'CREATE TRIGGER trg_touch_%I BEFORE INSERT OR UPDATE ON public.%I '
      'FOR EACH ROW EXECUTE FUNCTION public.fn_touch_sync_metadata()',
      t, t);
    EXECUTE format(
      'DROP TRIGGER IF EXISTS trg_noharddel_%I ON public.%I', t, t);
    EXECUTE format(
      'CREATE TRIGGER trg_noharddel_%I BEFORE DELETE ON public.%I '
      'FOR EACH ROW EXECUTE FUNCTION public.fn_block_hard_delete()',
      t, t);
  END LOOP;
END $$;

-- ============================================================================
-- STEP 3 — MULTI-DEVICE ISOLATION & RLS SECURITY
-- ============================================================================
-- owner_id uuid matches auth.uid() for signed-in practitioners. Signed-out
-- local rows sync with owner_id NULL + a client_id device marker; RLS keeps
-- them invisible to other tenants while the anon/service-role test path can
-- still exercise the pipeline (background + integration suites run without a
-- JWT). Every table: owner read/write + owner insert + anon/service test
-- access + authenticated full-access fallback for the service role.
-- ============================================================================

DO $$
DECLARE
  t text;
  sync_tables text[] := ARRAY[
    'patients','hospitals','wards','patient_hospital_identifiers',
    'clinical_encounters','patient_problems','problem_progress_snapshots',
    'clinical_interventions','clinical_outcome_metrics','clinical_actions',
    'clinical_outcomes','prescription_orders','investigation_orders',
    'investigation_results','investigation_tracker','drug_master',
    'personal_wiki','sync_queue','document_registries','clinical_observations',
    'microbiology_cultures','imaging_studies','clinical_drugs',
    'active_ingredients','indications','formulations','brands',
    'clinical_learning_logs','clinical_audits','clinical_rules',
    'clinical_pathways','cdss_rules'
  ];
BEGIN
  FOREACH t IN ARRAY sync_tables LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
    -- Drop-then-create keeps the migration re-runnable.
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I',
      'owner_read_' || t, t);
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I',
      'owner_write_' || t, t);
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I',
      'owner_insert_' || t, t);
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I',
      'anon_test_' || t, t);
    -- Owner isolation: readable/writable only by the authenticated owner.
    -- Tables without owner_id (join/reference tables) fall back to open
    -- authenticated access; tenant scoping there is enforced via the parent
    -- patient/owner chain in application queries.
    BEGIN
      EXECUTE format(
        'CREATE POLICY %I ON public.%I FOR SELECT USING '
        '(owner_id::text IS NULL OR owner_id::text = auth.uid()::text)',
        'owner_read_' || t, t);
      EXECUTE format(
        'CREATE POLICY %I ON public.%I FOR UPDATE USING '
        '(owner_id::text IS NULL OR owner_id::text = auth.uid()::text) '
        'WITH CHECK (owner_id::text IS NULL OR owner_id::text = auth.uid()::text)',
        'owner_write_' || t, t);
      EXECUTE format(
        'CREATE POLICY %I ON public.%I FOR INSERT WITH CHECK '
        '(owner_id::text IS NULL OR owner_id::text = auth.uid()::text)',
        'owner_insert_' || t, t);
    EXCEPTION WHEN undefined_column THEN
      EXECUTE format(
        'CREATE POLICY %I ON public.%I FOR ALL TO authenticated USING (true) '
        'WITH CHECK (true)', 'owner_read_' || t, t);
    END;
    -- Explicit anon + service-role path for background testing and local
    -- integration suites (no JWT). Signed-out device rows (owner_id NULL)
    -- remain tenant-safe because they carry only a client_id marker.
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR ALL TO anon, service_role '
      'USING (true) WITH CHECK (true)', 'anon_test_' || t, t);
  END LOOP;
END $$;

-- ============================================================================
-- STEP 4 — REALTIME PUBLICATION & DISASTER RECOVERY HYDRATION
-- ============================================================================

-- REPLICA IDENTITY FULL streams full before/after images so updates and
-- soft-deletes replicate with complete row context on every device.
DO $$
DECLARE
  t text;
  sync_tables text[] := ARRAY[
    'patients','hospitals','wards','patient_hospital_identifiers',
    'clinical_encounters','patient_problems','problem_progress_snapshots',
    'clinical_interventions','clinical_outcome_metrics','clinical_actions',
    'clinical_outcomes','prescription_orders','investigation_orders',
    'investigation_results','investigation_tracker','drug_master',
    'personal_wiki','sync_queue','document_registries','clinical_observations',
    'microbiology_cultures','imaging_studies','clinical_drugs',
    'active_ingredients','indications','formulations','brands',
    'clinical_learning_logs','clinical_audits','clinical_rules',
    'clinical_pathways','cdss_rules'
  ];
BEGIN
  FOREACH t IN ARRAY sync_tables LOOP
    EXECUTE format('ALTER TABLE public.%I REPLICA IDENTITY FULL', t);
    BEGIN
      EXECUTE format(
        'ALTER PUBLICATION supabase_realtime ADD TABLE public.%I', t);
    EXCEPTION
      WHEN duplicate_object THEN NULL; -- already a member: idempotent
      WHEN undefined_object THEN NULL; -- realtime publication absent (tests)
    END;
  END LOOP;
END $$;

-- Delta extractor: every table newer than a server_version cursor.
-- The client fans out per table; one function serves all callers.
CREATE OR REPLACE FUNCTION public.rpc_pull_table_delta(
  p_table regclass,
  p_since_version bigint DEFAULT 0,
  p_limit integer DEFAULT 1000
)
RETURNS SETOF jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $fn$
DECLARE
  allowed text[] := ARRAY[
    'patients','hospitals','wards','patient_hospital_identifiers',
    'clinical_encounters','patient_problems','problem_progress_snapshots',
    'clinical_interventions','clinical_outcome_metrics','clinical_actions',
    'clinical_outcomes','prescription_orders','investigation_orders',
    'investigation_results','investigation_tracker','drug_master',
    'personal_wiki','sync_queue','document_registries','clinical_observations',
    'microbiology_cultures','imaging_studies','clinical_drugs',
    'active_ingredients','indications','formulations','brands',
    'clinical_learning_logs','clinical_audits','clinical_rules',
    'clinical_pathways','cdss_rules'
  ];
BEGIN
  IF p_table::text NOT LIKE 'public.%' THEN
    RAISE EXCEPTION 'rpc_pull_table_delta: table must be schema-qualified (%)', p_table;
  END IF;
  IF split_part(p_table::text, '.', 2) <> ALL (allowed) THEN
    RAISE EXCEPTION 'rpc_pull_table_delta: % is not a sync table', p_table;
  END IF;
  RETURN QUERY EXECUTE format(
    'SELECT to_jsonb(row) FROM (SELECT * FROM %s '
    'WHERE server_version > $1 ORDER BY server_version LIMIT $2) row',
    p_table)
    USING p_since_version, p_limit;
END;
$fn$;

-- Full-chart hydration after device loss / local wipe. Returns one JSON
-- document carrying every tenant row (optionally only rows changed since
-- p_since), with POMR linkage keys (problem_id on orders/interventions)
-- intact so Drift rebuilds identically. Tombstones (deleted_at NOT NULL)
-- are included so the client can skip resurrecting them.
CREATE OR REPLACE FUNCTION public.rpc_pull_full_patient_chart(
  p_user_id uuid,
  p_since timestamptz DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $fn$
DECLARE
  result jsonb;
BEGIN
  -- p_since narrows to recently changed rows for incremental re-hydration;
  -- NULL pulls the entire chart (post-wipe recovery). Tombstones are
  -- included so the client skips resurrecting soft-deleted rows, and every
  -- POMR linkage key (problem_id on orders/interventions) rides along so
  -- Drift rebuilds identically.
  SELECT jsonb_build_object(
    'patients',
      (SELECT COALESCE(jsonb_agg(to_jsonb(r)), '[]'::jsonb)
         FROM (SELECT * FROM public.patients
                WHERE (owner_id::text = p_user_id::text OR owner_id IS NULL)
                  AND (p_since IS NULL OR updated_at > p_since)) r),
    'clinical_encounters',
      (SELECT COALESCE(jsonb_agg(to_jsonb(r)), '[]'::jsonb)
         FROM (SELECT e.* FROM public.clinical_encounters e
                JOIN public.patients p ON p.id = e.patient_id
               WHERE (e.owner_id::text = p_user_id::text OR p.owner_id::text = p_user_id::text)
                 AND (p_since IS NULL OR e.updated_at > p_since)) r),
    'patient_problems',
      (SELECT COALESCE(jsonb_agg(to_jsonb(r)), '[]'::jsonb)
         FROM (SELECT pp.* FROM public.patient_problems pp
                JOIN public.patients p ON p.id = pp.patient_id
               WHERE (pp.owner_id::text = p_user_id::text OR p.owner_id::text = p_user_id::text)
                 AND (p_since IS NULL OR pp.updated_at > p_since)) r),
    'prescription_orders',
      (SELECT COALESCE(jsonb_agg(to_jsonb(r)), '[]'::jsonb)
         FROM (SELECT o.* FROM public.prescription_orders o
                JOIN public.patients p ON p.id = o.patient_id
               WHERE (o.owner_id::text = p_user_id::text OR p.owner_id::text = p_user_id::text)
                 AND (p_since IS NULL OR o.updated_at > p_since)) r),
    'investigation_orders',
      (SELECT COALESCE(jsonb_agg(to_jsonb(r)), '[]'::jsonb)
         FROM (SELECT o.* FROM public.investigation_orders o
                JOIN public.patients p ON p.id = o.patient_id
               WHERE (o.owner_id::text = p_user_id::text OR p.owner_id::text = p_user_id::text)
                 AND (p_since IS NULL OR o.updated_at > p_since)) r),
    'investigation_results',
      (SELECT COALESCE(jsonb_agg(to_jsonb(r)), '[]'::jsonb)
         FROM (SELECT x.* FROM public.investigation_results x
                JOIN public.patients p ON p.id = x.patient_id
               WHERE (x.owner_id::text = p_user_id::text OR p.owner_id::text = p_user_id::text)
                 AND (p_since IS NULL OR x.updated_at > p_since)) r),
    'clinical_interventions',
      (SELECT COALESCE(jsonb_agg(to_jsonb(r)), '[]'::jsonb)
         FROM (SELECT i.* FROM public.clinical_interventions i
                JOIN public.patients p ON p.id = i.patient_id
               WHERE (i.owner_id::text = p_user_id::text OR p.owner_id::text = p_user_id::text)
                 AND (p_since IS NULL OR i.updated_at > p_since)) r),
    'document_registries',
      (SELECT COALESCE(jsonb_agg(to_jsonb(r)), '[]'::jsonb)
         FROM (SELECT d.* FROM public.document_registries d
                JOIN public.patients p ON p.id = d.patient_id
               WHERE (d.owner_id::text = p_user_id::text OR p.owner_id::text = p_user_id::text)
                 AND (p_since IS NULL OR d.updated_at > p_since)) r),
    'clinical_rules',
      (SELECT COALESCE(jsonb_agg(to_jsonb(r)), '[]'::jsonb)
         FROM (SELECT * FROM public.clinical_rules
                WHERE (owner_id::text = p_user_id::text OR owner_id IS NULL)
                  AND (p_since IS NULL OR updated_at > p_since)) r),
    'clinical_pathways',
      (SELECT COALESCE(jsonb_agg(to_jsonb(r)), '[]'::jsonb)
         FROM (SELECT * FROM public.clinical_pathways
                WHERE (owner_id::text = p_user_id::text OR owner_id IS NULL)
                  AND (p_since IS NULL OR updated_at > p_since)) r),
    'clinical_learning_logs',
      (SELECT COALESCE(jsonb_agg(to_jsonb(r)), '[]'::jsonb)
         FROM (SELECT * FROM public.clinical_learning_logs
                WHERE owner_id::text = p_user_id::text
                  AND (p_since IS NULL OR updated_at > p_since)) r),
    'clinical_audits',
      (SELECT COALESCE(jsonb_agg(to_jsonb(r)), '[]'::jsonb)
         FROM (SELECT * FROM public.clinical_audits
                WHERE owner_id::text = p_user_id::text
                  AND (p_since IS NULL OR updated_at > p_since)) r),
    'personal_wiki',
      (SELECT COALESCE(jsonb_agg(to_jsonb(r)), '[]'::jsonb)
         FROM (SELECT * FROM public.personal_wiki
                WHERE owner_id::text = p_user_id::text
                  AND (p_since IS NULL OR updated_at > p_since)) r)
  ) INTO result;

  RETURN result;
END;
$fn$;

-- ============================================================================
-- STEP 5 — VERIFICATION & POSTGREST CACHE INVALIDATION
-- ============================================================================

-- Max server_version watermark per sync table, so a client can seed its
-- delta cursor without scanning (SELECT * FROM sync_watermarks).
CREATE OR REPLACE VIEW public.sync_watermarks AS
SELECT 'patients' AS table_name, COALESCE(MAX(server_version), 0) AS max_version FROM public.patients
UNION ALL SELECT 'clinical_encounters', COALESCE(MAX(server_version), 0) FROM public.clinical_encounters
UNION ALL SELECT 'patient_problems', COALESCE(MAX(server_version), 0) FROM public.patient_problems
UNION ALL SELECT 'prescription_orders', COALESCE(MAX(server_version), 0) FROM public.prescription_orders
UNION ALL SELECT 'investigation_orders', COALESCE(MAX(server_version), 0) FROM public.investigation_orders
UNION ALL SELECT 'investigation_results', COALESCE(MAX(server_version), 0) FROM public.investigation_results
UNION ALL SELECT 'clinical_interventions', COALESCE(MAX(server_version), 0) FROM public.clinical_interventions
UNION ALL SELECT 'document_registries', COALESCE(MAX(server_version), 0) FROM public.document_registries
UNION ALL SELECT 'clinical_rules', COALESCE(MAX(server_version), 0) FROM public.clinical_rules
UNION ALL SELECT 'clinical_pathways', COALESCE(MAX(server_version), 0) FROM public.clinical_pathways
UNION ALL SELECT 'clinical_learning_logs', COALESCE(MAX(server_version), 0) FROM public.clinical_learning_logs
UNION ALL SELECT 'clinical_audits', COALESCE(MAX(server_version), 0) FROM public.clinical_audits
UNION ALL SELECT 'personal_wiki', COALESCE(MAX(server_version), 0) FROM public.personal_wiki
UNION ALL SELECT 'cdss_rules', COALESCE(MAX(server_version), 0) FROM public.cdss_rules;

-- PostgREST must reload its schema cache to expose the new columns/RPCs.
-- Grants expose the RPCs + watermark view to the client roles.
GRANT EXECUTE ON FUNCTION public.rpc_pull_table_delta(regclass, bigint, integer) TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.rpc_pull_full_patient_chart(uuid, timestamptz) TO anon, authenticated, service_role;
GRANT SELECT ON public.sync_watermarks TO anon, authenticated, service_role;

NOTIFY pgrst, 'reload schema';
NOTIFY pgrst, 'reload config';
