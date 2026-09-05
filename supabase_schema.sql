-- Offline-first clinical assistant schema for Supabase PostgreSQL (POMR & CDSS Edition).
-- The application is single-user by design, while owner_id keeps every row
-- isolated and makes the schema safe if additional authenticated users are
-- introduced later.

create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function public.prevent_owner_change()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
begin
  if tg_op = 'UPDATE' and new.owner_id is distinct from old.owner_id then
    raise exception 'owner_id cannot be changed';
  end if;
  return new;
end;
$$;

-- 1. PATIENTS
create table if not exists public.patients (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  hospital_reg_no text not null,
  full_name text not null,
  date_of_birth date,
  sex text check (sex is null or sex in ('female', 'male', 'intersex', 'unknown')),
  phone text,
  diagnosis text,
  current_department text not null default 'Surgery',
  surgery_type text,
  complications text,
  admission_date timestamptz,
  discharge_date timestamptz,
  is_active boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_synced_at timestamptz,
  constraint patients_hospital_reg_no_not_blank check (length(btrim(hospital_reg_no)) > 0),
  constraint patients_full_name_not_blank check (length(btrim(full_name)) > 0),
  constraint patients_department_check check (current_department in ('Medicine', 'OBGYN', 'Pediatrics', 'Surgery', 'Plastic Surgery', 'Psychiatry', 'Emergency', 'Other')),
  constraint patients_admission_before_discharge check (
    discharge_date is null or admission_date is null or admission_date <= discharge_date
  )
);

create unique index if not exists patients_owner_hospital_reg_no_idx on public.patients (owner_id, lower(hospital_reg_no));
create index if not exists patients_owner_active_idx on public.patients (owner_id, is_active);
create index if not exists patients_owner_updated_idx on public.patients (owner_id, updated_at);

-- 2. CLINICAL ENCOUNTERS
create table if not exists public.clinical_encounters (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  patient_id uuid not null references public.patients (id) on delete cascade,
  encounter_type text not null default 'Ward Round' check (encounter_type in ('Ward Round', 'OPD', 'Pre-Op', 'Procedure', 'Emergency', 'Follow-Up', 'Other')),
  occurred_at timestamptz not null default now(),
  sbp smallint,
  dbp smallint,
  pulse smallint,
  temperature_c numeric(4, 1),
  respiratory_rate smallint,
  spo2 smallint,
  map numeric(6, 2),
  chief_complaint text,
  consultant_advice text,
  note text,
  dynamic_data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_synced_at timestamptz,
  constraint encounters_sbp_range check (sbp is null or sbp between 20 and 300),
  constraint encounters_dbp_range check (dbp is null or dbp between 10 and 250),
  constraint encounters_pulse_range check (pulse is null or pulse between 1 and 300),
  constraint encounters_sbp_above_dbp check (sbp is null or dbp is null or sbp > dbp)
);

create index if not exists encounters_owner_occurred_idx on public.clinical_encounters (owner_id, occurred_at desc);
create index if not exists encounters_patient_occurred_idx on public.clinical_encounters (patient_id, occurred_at desc);

-- 3. INVESTIGATION TRACKER
create table if not exists public.investigation_tracker (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  patient_id uuid not null references public.patients (id) on delete cascade,
  test_name text not null,
  test_code text,
  status text not null default 'pending' check (status in ('pending', 'sample_sent', 'result_received', 'cancelled')),
  ordered_at timestamptz not null default now(),
  sample_sent_at timestamptz,
  result_received_at timestamptz,
  result_value text,
  result_unit text,
  reference_range text,
  organism text,
  sensitive_antibiotics text[] not null default '{}',
  resistant_antibiotics text[] not null default '{}',
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_synced_at timestamptz,
  constraint investigation_test_name_not_blank check (length(btrim(test_name)) > 0)
);

-- 4. DRUG MASTER
create table if not exists public.drug_master (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  generic_name text not null,
  brand_name text,
  strength text,
  dosage_form text,
  route text,
  category text,
  searchable_text text generated always as (
    lower(
      coalesce(generic_name, '') || ' ' || coalesce(brand_name, '') || ' ' ||
      coalesce(strength, '') || ' ' || coalesce(dosage_form, '') || ' ' ||
      coalesce(route, '') || ' ' || coalesce(category, '')
    )
  ) stored,
  usage_frequency integer not null default 0,
  associated_problems jsonb not null default '[]'::jsonb,
  is_active boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_synced_at timestamptz,
  constraint drug_master_generic_name_not_blank check (length(btrim(generic_name)) > 0)
);

create index if not exists drug_master_searchable_idx on public.drug_master using gin (to_tsvector('simple', searchable_text));

-- 5. POMR: PATIENT PROBLEMS
create table if not exists public.patient_problems (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  patient_id uuid not null references public.patients(id) on delete cascade,
  problem_name text not null,
  status text not null default 'Active' check (status in ('Active', 'Resolved', 'Chronic')),
  onset_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_synced_at timestamptz
);
create index if not exists problems_patient_idx on public.patient_problems (patient_id, status);

-- 6. POMR: CLINICAL ACTIONS
create table if not exists public.clinical_actions (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  patient_id uuid not null references public.patients(id) on delete cascade,
  problem_id uuid not null references public.patient_problems(id) on delete cascade,
  action_type text not null check (action_type in ('Medication', 'Procedure', 'Investigation', 'Consultation')),
  description text not null,
  occurred_at timestamptz not null default now(),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_synced_at timestamptz
);
create index if not exists actions_problem_idx on public.clinical_actions (problem_id, occurred_at desc);

-- 7. POMR: CLINICAL OUTCOMES
create table if not exists public.clinical_outcomes (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  problem_id uuid not null references public.patient_problems(id) on delete cascade,
  metric_name text not null,
  metric_value numeric not null,
  metric_unit text,
  treatment_method text,
  measured_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_synced_at timestamptz
);

-- 8. CDSS: DECISION RULES
create table if not exists public.cdss_rules (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  target_problem text not null,
  trigger_condition text not null,
  suggested_action text not null,
  evidence_source text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_synced_at timestamptz
);

-- 9. PERSONAL WIKI
create table if not exists public.personal_wiki (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  topic text not null,
  markdown_content text not null default '',
  tags text[] not null default '{}',
  department_relevance text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_synced_at timestamptz,
  constraint personal_wiki_topic_not_blank check (length(btrim(topic)) > 0)
);

-- 10. SYNC QUEUE
create table if not exists public.sync_queue (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  entity_type text not null check (entity_type in (
    'patients', 'clinical_encounters', 'investigation_tracker', 'drug_master', 
    'personal_wiki', 'patient_problems', 'clinical_actions', 'clinical_outcomes', 'cdss_rules'
  )),
  entity_id uuid not null,
  operation text not null check (operation in ('insert', 'update', 'delete')),
  payload jsonb not null default '{}'::jsonb,
  client_updated_at timestamptz not null default now(),
  attempts integer not null default 0 check (attempts >= 0),
  next_attempt_at timestamptz not null default now(),
  last_error text,
  processed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_synced_at timestamptz
);
create index if not exists sync_queue_pending_idx on public.sync_queue (owner_id, next_attempt_at, created_at) where processed_at is null;

-- TRIGGERS & RLS FOR ALL TABLES
do $$ 
declare 
  t text; 
begin 
  for t in select unnest(array[
    'patients', 'clinical_encounters', 'investigation_tracker', 'drug_master', 
    'personal_wiki', 'patient_problems', 'clinical_actions', 'clinical_outcomes', 
    'cdss_rules', 'sync_queue'
  ]) 
  loop
    -- Apply set_updated_at trigger
    execute format('drop trigger if exists %I_set_updated_at on public.%I', t, t);
    execute format('create trigger %I_set_updated_at before update on public.%I for each row execute function public.set_updated_at()', t, t);
    
    -- Apply prevent_owner_change trigger
    execute format('drop trigger if exists %I_prevent_owner_change on public.%I', t, t);
    execute format('create trigger %I_prevent_owner_change before update on public.%I for each row execute function public.prevent_owner_change()', t, t);

    -- Enable RLS
    execute format('alter table public.%I enable row level security', t);

    -- Create unified RLS Policies
    execute format('drop policy if exists %I_owner_select on public.%I', t, t);
    execute format('create policy %I_owner_select on public.%I for select to authenticated using (owner_id = auth.uid())', t, t);
    
    execute format('drop policy if exists %I_owner_insert on public.%I', t, t);
    execute format('create policy %I_owner_insert on public.%I for insert to authenticated with check (owner_id = auth.uid())', t, t);
    
    execute format('drop policy if exists %I_owner_update on public.%I', t, t);
    execute format('create policy %I_owner_update on public.%I for update to authenticated using (owner_id = auth.uid()) with check (owner_id = auth.uid())', t, t);
    
    execute format('drop policy if exists %I_owner_delete on public.%I', t, t);
    execute format('create policy %I_owner_delete on public.%I for delete to authenticated using (owner_id = auth.uid())', t, t);
  end loop;
end $$;

-- Cross-Tenant Protection (Ensures records assigned to a patient belong to the same owner)
create or replace function public.ensure_patient_owner()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
declare
  patient_owner uuid;
begin
  select owner_id into patient_owner from public.patients where id = new.patient_id;
  if patient_owner is null or patient_owner is distinct from new.owner_id then
    raise exception 'patient does not belong to the authenticated owner';
  end if;
  return new;
end;
$$;

drop trigger if exists clinical_encounters_patient_owner on public.clinical_encounters;
create trigger clinical_encounters_patient_owner before insert or update on public.clinical_encounters for each row execute function public.ensure_patient_owner();

drop trigger if exists investigations_patient_owner on public.investigation_tracker;
create trigger investigations_patient_owner before insert or update on public.investigation_tracker for each row execute function public.ensure_patient_owner();

drop trigger if exists problems_patient_owner on public.patient_problems;
create trigger problems_patient_owner before insert or update on public.patient_problems for each row execute function public.ensure_patient_owner();

drop trigger if exists actions_patient_owner on public.clinical_actions;
create trigger actions_patient_owner before insert or update on public.clinical_actions for each row execute function public.ensure_patient_owner();