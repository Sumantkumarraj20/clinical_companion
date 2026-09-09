-- =========================================================================
-- SUPABASE COMPLETE MIGRATION: PROBLEM-ORIENTED CLINICAL TRAJECTORY (V16)
-- =========================================================================

-- 1. BASE HOSPITALS & WARDS
CREATE TABLE IF NOT EXISTS public.hospitals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    short_name TEXT,
    address TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS public.wards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hospital_id UUID REFERENCES public.hospitals(id) ON DELETE CASCADE,
    department TEXT,
    ward_name TEXT NOT NULL,
    bed_count INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 2. PATIENT DEMOGRAPHICS (STRICTLY INVARIANT)
CREATE TABLE IF NOT EXISTS public.patients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id TEXT NOT NULL,
    full_name TEXT NOT NULL,
    date_of_birth TIMESTAMPTZ,
    approximate_age INT,
    gender TEXT,
    height_cm REAL,
    weight_kg REAL,
    address_or_location TEXT,
    occupation TEXT,
    phone TEXT,
    alternate_phone TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS public.patient_hospital_identifiers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
    hospital_id UUID NOT NULL REFERENCES public.hospitals(id) ON DELETE CASCADE,
    hospital_reg_no TEXT NOT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 3. CLINICAL ENCOUNTERS
CREATE TABLE IF NOT EXISTS public.clinical_encounters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id TEXT NOT NULL,
    patient_id UUID NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
    hospital_id UUID REFERENCES public.hospitals(id) ON DELETE SET NULL,
    encounter_type TEXT NOT NULL DEFAULT 'OPD',
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    department TEXT,
    ward_name TEXT,
    bed_number TEXT,
    clinical_diagnosis TEXT,
    icd11_code TEXT,
    disposition TEXT,
    sbp INT,
    dbp INT,
    pulse INT,
    temperature_c REAL,
    respiratory_rate INT,
    spo2 INT,
    map REAL,
    chief_complaints TEXT,
    history_of_present_illness TEXT,
    past_history TEXT,
    drug_and_allergy_history TEXT,
    personal_and_social_history TEXT,
    examination_findings TEXT,
    clinical_assessment TEXT,
    consultant_advice TEXT,
    image_path TEXT,
    ai_summary TEXT,
    dynamic_data JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 4. PROBLEM TRAJECTORY (POMR CORE)
CREATE TABLE IF NOT EXISTS public.patient_problems (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
    initial_encounter_id UUID REFERENCES public.clinical_encounters(id) ON DELETE SET NULL,
    problem_name TEXT NOT NULL,
    icd11_code TEXT,
    current_status TEXT NOT NULL DEFAULT 'Active', -- Active, Improving, Deteriorating, Controlled, Resolved, Recurred
    onset_date TIMESTAMPTZ,
    resolved_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Serial tracking of how the problem evolutes over rounds/visits
CREATE TABLE IF NOT EXISTS public.problem_progress_snapshots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    problem_id UUID NOT NULL REFERENCES public.patient_problems(id) ON DELETE CASCADE,
    encounter_id UUID NOT NULL REFERENCES public.clinical_encounters(id) ON DELETE CASCADE,
    patient_id UUID NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
    status_snapshot TEXT NOT NULL,
    clinical_course_note TEXT NOT NULL,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 5. PROCEDURES & CLINICAL INTERVENTIONS
CREATE TABLE IF NOT EXISTS public.clinical_interventions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
    encounter_id UUID NOT NULL REFERENCES public.clinical_encounters(id) ON DELETE CASCADE,
    problem_id UUID REFERENCES public.patient_problems(id) ON DELETE SET NULL,
    procedure_name TEXT NOT NULL,
    procedure_code TEXT,
    coding_system TEXT, -- 'PMJAY', 'ICD11', 'LOCAL'
    anatomical_site TEXT,
    intervention_role TEXT NOT NULL DEFAULT 'Therapeutic', -- Diagnostic, Therapeutic, Palliative, Staging
    operative_findings TEXT,
    performed_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    performed_by TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 6. QUANTITATIVE OUTCOME METRICS
CREATE TABLE IF NOT EXISTS public.clinical_outcome_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
    problem_id UUID NOT NULL REFERENCES public.patient_problems(id) ON DELETE CASCADE,
    encounter_id UUID REFERENCES public.clinical_encounters(id) ON DELETE SET NULL,
    metric_name TEXT NOT NULL,
    metric_value REAL NOT NULL,
    metric_unit TEXT,
    qualifying_note TEXT,
    measured_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 7. PRESCRIPTION ORDERS
CREATE TABLE IF NOT EXISTS public.prescription_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
    encounter_id UUID NOT NULL REFERENCES public.clinical_encounters(id) ON DELETE CASCADE,
    problem_id UUID REFERENCES public.patient_problems(id) ON DELETE SET NULL,
    drug_name TEXT NOT NULL,
    dose_strength TEXT,
    dosage_form TEXT,
    route TEXT,
    frequency TEXT,
    duration TEXT,
    diluent_and_rate TEXT,
    special_instructions TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    ordered_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 8. INVESTIGATION ORDERS & RESULTS
CREATE TABLE IF NOT EXISTS public.investigation_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
    encounter_id UUID REFERENCES public.clinical_encounters(id) ON DELETE SET NULL,
    problem_id UUID REFERENCES public.patient_problems(id) ON DELETE SET NULL,
    test_name TEXT NOT NULL,
    test_code TEXT,
    clinical_indication TEXT,
    status TEXT NOT NULL DEFAULT 'ordered',
    ordered_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    sample_sent_at TIMESTAMPTZ,
    result_received_at TIMESTAMPTZ,
    owner_id TEXT NOT NULL DEFAULT 'local-practitioner',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS public.investigation_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES public.investigation_orders(id) ON DELETE SET NULL,
    patient_id UUID NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
    test_name TEXT NOT NULL,
    numeric_value REAL,
    text_value TEXT,
    unit TEXT,
    reference_range TEXT,
    is_abnormal BOOLEAN NOT NULL DEFAULT false,
    antibiogram_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    result_date TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 9. LEARNED CATALOG & CDSS
CREATE TABLE IF NOT EXISTS public.learned_catalog (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category TEXT NOT NULL,
    term TEXT NOT NULL,
    frequency INT NOT NULL DEFAULT 1,
    last_used_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS public.cdss_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    target_problem TEXT NOT NULL,
    trigger_condition TEXT NOT NULL,
    suggested_action TEXT NOT NULL,
    evidence_source TEXT NOT NULL,
    requires_pre_auth BOOLEAN NOT NULL DEFAULT false,
    medicolegal_alert TEXT NOT NULL DEFAULT '',
    last_updated TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- ROW LEVEL SECURITY (RLS) POLICIES
ALTER TABLE public.hospitals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.patient_hospital_identifiers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clinical_encounters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.patient_problems ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.problem_progress_snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clinical_interventions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clinical_outcome_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prescription_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.investigation_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.investigation_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.learned_catalog ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cdss_rules ENABLE ROW LEVEL SECURITY;

DO $$ 
BEGIN
    EXECUTE 'CREATE POLICY "Allow all authenticated" ON public.hospitals FOR ALL TO authenticated USING (true) WITH CHECK (true)';
    EXECUTE 'CREATE POLICY "Allow all authenticated" ON public.wards FOR ALL TO authenticated USING (true) WITH CHECK (true)';
    EXECUTE 'CREATE POLICY "Allow all authenticated" ON public.patients FOR ALL TO authenticated USING (true) WITH CHECK (true)';
    EXECUTE 'CREATE POLICY "Allow all authenticated" ON public.patient_hospital_identifiers FOR ALL TO authenticated USING (true) WITH CHECK (true)';
    EXECUTE 'CREATE POLICY "Allow all authenticated" ON public.clinical_encounters FOR ALL TO authenticated USING (true) WITH CHECK (true)';
    EXECUTE 'CREATE POLICY "Allow all authenticated" ON public.patient_problems FOR ALL TO authenticated USING (true) WITH CHECK (true)';
    EXECUTE 'CREATE POLICY "Allow all authenticated" ON public.problem_progress_snapshots FOR ALL TO authenticated USING (true) WITH CHECK (true)';
    EXECUTE 'CREATE POLICY "Allow all authenticated" ON public.clinical_interventions FOR ALL TO authenticated USING (true) WITH CHECK (true)';
    EXECUTE 'CREATE POLICY "Allow all authenticated" ON public.clinical_outcome_metrics FOR ALL TO authenticated USING (true) WITH CHECK (true)';
    EXECUTE 'CREATE POLICY "Allow all authenticated" ON public.prescription_orders FOR ALL TO authenticated USING (true) WITH CHECK (true)';
    EXECUTE 'CREATE POLICY "Allow all authenticated" ON public.investigation_orders FOR ALL TO authenticated USING (true) WITH CHECK (true)';
    EXECUTE 'CREATE POLICY "Allow all authenticated" ON public.investigation_results FOR ALL TO authenticated USING (true) WITH CHECK (true)';
    EXECUTE 'CREATE POLICY "Allow all authenticated" ON public.learned_catalog FOR ALL TO authenticated USING (true) WITH CHECK (true)';
    EXECUTE 'CREATE POLICY "Allow all authenticated" ON public.cdss_rules FOR ALL TO authenticated USING (true) WITH CHECK (true)';
EXCEPTION WHEN OTHERS THEN
    -- Policies already exist
END $$;