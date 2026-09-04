-- Offline-first clinical assistant schema for Supabase PostgreSQL.
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

create unique index if not exists patients_owner_hospital_reg_no_idx
  on public.patients (owner_id, lower(hospital_reg_no));
create index if not exists patients_owner_active_idx
  on public.patients (owner_id, is_active);
create index if not exists patients_owner_admission_idx
  on public.patients (owner_id, admission_date desc);
create index if not exists patients_owner_updated_idx
  on public.patients (owner_id, updated_at);

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
  constraint encounters_sbp_above_dbp check (sbp is null or dbp is null or sbp > dbp),
  constraint encounters_temperature_range check (temperature_c is null or temperature_c between 25 and 50),
  constraint encounters_respiratory_rate_range check (respiratory_rate is null or respiratory_rate between 1 and 100),
  constraint encounters_spo2_range check (spo2 is null or spo2 between 0 and 100)
);

create index if not exists encounters_owner_occurred_idx
  on public.clinical_encounters (owner_id, occurred_at desc);
create index if not exists encounters_patient_occurred_idx
  on public.clinical_encounters (patient_id, occurred_at desc);
create index if not exists encounters_owner_updated_idx
  on public.clinical_encounters (owner_id, updated_at);
create index if not exists encounters_dynamic_data_idx
  on public.clinical_encounters using gin (dynamic_data);

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
  constraint investigation_test_name_not_blank check (length(btrim(test_name)) > 0),
  constraint investigation_status_dates check (
    (status <> 'sample_sent' or sample_sent_at is not null)
    and (status <> 'result_received' or result_received_at is not null)
  )
);

create index if not exists investigation_owner_status_idx
  on public.investigation_tracker (owner_id, status);
create index if not exists investigation_patient_status_idx
  on public.investigation_tracker (patient_id, status);
create index if not exists investigation_test_name_idx
  on public.investigation_tracker (owner_id, lower(test_name));
create index if not exists investigation_owner_updated_idx
  on public.investigation_tracker (owner_id, updated_at);

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
    );

  ) stored,
  is_active boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_synced_at timestamptz,
  constraint drug_master_generic_name_not_blank check (length(btrim(generic_name)) > 0)
);

alter table public.drug_master add column if not exists usage_frequency integer not null default 0;
alter table public.drug_master add column if not exists associated_problems jsonb not null default '[]'::jsonb;

create index if not exists drug_master_owner_active_idx
  on public.drug_master (owner_id, is_active);
create index if not exists drug_master_searchable_idx
  on public.drug_master using gin (to_tsvector('simple', searchable_text));
create index if not exists drug_master_owner_updated_idx
  on public.drug_master (owner_id, updated_at);

create table if not exists public.patient_problems (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.patients(id) on delete cascade,
  problem_name text not null,
  status text not null default 'Active' check (status in ('Active', 'Resolved', 'Chronic')),
  onset_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.clinical_actions (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.patients(id) on delete cascade,
  problem_id uuid not null references public.patient_problems(id) on delete cascade,
  action_type text not null check (action_type in ('Medication', 'Procedure', 'Investigation', 'Consultation')),
  description text not null,
  occurred_at timestamptz not null default now(),
  metadata jsonb not null default '{}'::jsonb
);
create table if not exists public.clinical_outcomes (
  id uuid primary key default gen_random_uuid(),
  problem_id uuid not null references public.patient_problems(id) on delete cascade,
  metric_name text not null,
  metric_value numeric not null,
  metric_unit text,
  treatment_method text,
  measured_at timestamptz not null default now()
);
create table if not exists public.cdss_rules (
  id uuid primary key default gen_random_uuid(),
  target_problem text not null,
  trigger_condition text not null,
  suggested_action text not null,
  evidence_source text not null,
  last_updated timestamptz not null default now()
);

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
create index if not exists personal_wiki_owner_updated_idx
  on public.personal_wiki (owner_id, updated_at desc);
create index if not exists personal_wiki_tags_idx on public.personal_wiki using gin (tags);
create index if not exists personal_wiki_department_idx on public.personal_wiki using gin (department_relevance);

create table if not exists public.sync_queue (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  entity_type text not null check (entity_type in ('patients', 'clinical_encounters', 'investigation_tracker', 'drug_master', 'personal_wiki')),
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
  last_synced_at timestamptz,
  constraint sync_queue_processed_consistency check (
    processed_at is null or processed_at >= created_at
  )
);

create index if not exists sync_queue_pending_idx
  on public.sync_queue (owner_id, next_attempt_at, created_at)
  where processed_at is null;
create index if not exists sync_queue_entity_idx
  on public.sync_queue (owner_id, entity_type, entity_id);

-- Child rows must always belong to the same owner as their patient. This
-- prevents an otherwise valid UUID from being used to cross tenant boundaries.
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

drop trigger if exists patients_set_updated_at on public.patients;
create trigger patients_set_updated_at before update on public.patients
for each row execute function public.set_updated_at();
drop trigger if exists patients_prevent_owner_change on public.patients;
create trigger patients_prevent_owner_change before update on public.patients
for each row execute function public.prevent_owner_change();

drop trigger if exists clinical_encounters_set_updated_at on public.clinical_encounters;
create trigger clinical_encounters_set_updated_at before update on public.clinical_encounters
for each row execute function public.set_updated_at();
drop trigger if exists clinical_encounters_prevent_owner_change on public.clinical_encounters;
create trigger clinical_encounters_prevent_owner_change before update on public.clinical_encounters
for each row execute function public.prevent_owner_change();
drop trigger if exists clinical_encounters_patient_owner on public.clinical_encounters;
create trigger clinical_encounters_patient_owner before insert or update on public.clinical_encounters
for each row execute function public.ensure_patient_owner();

drop trigger if exists personal_wiki_set_updated_at on public.personal_wiki;
create trigger personal_wiki_set_updated_at before update on public.personal_wiki
for each row execute function public.set_updated_at();
drop trigger if exists personal_wiki_prevent_owner_change on public.personal_wiki;
create trigger personal_wiki_prevent_owner_change before update on public.personal_wiki
for each row execute function public.prevent_owner_change();

drop trigger if exists investigations_set_updated_at on public.investigation_tracker;
create trigger investigations_set_updated_at before update on public.investigation_tracker
for each row execute function public.set_updated_at();
drop trigger if exists investigations_prevent_owner_change on public.investigation_tracker;
create trigger investigations_prevent_owner_change before update on public.investigation_tracker
for each row execute function public.prevent_owner_change();
drop trigger if exists investigations_patient_owner on public.investigation_tracker;
create trigger investigations_patient_owner before insert or update on public.investigation_tracker
for each row execute function public.ensure_patient_owner();

drop trigger if exists drugs_set_updated_at on public.drug_master;
create trigger drugs_set_updated_at before update on public.drug_master
for each row execute function public.set_updated_at();
drop trigger if exists drugs_prevent_owner_change on public.drug_master;
create trigger drugs_prevent_owner_change before update on public.drug_master
for each row execute function public.prevent_owner_change();

drop trigger if exists sync_queue_set_updated_at on public.sync_queue;
create trigger sync_queue_set_updated_at before update on public.sync_queue
for each row execute function public.set_updated_at();
drop trigger if exists sync_queue_prevent_owner_change on public.sync_queue;
create trigger sync_queue_prevent_owner_change before update on public.sync_queue
for each row execute function public.prevent_owner_change();

-- RLS is enabled on every application table. `auth.uid()` is null for an
-- anonymous request, so anonymous clients receive no rows and cannot write.
alter table public.patients enable row level security;
alter table public.clinical_encounters enable row level security;
alter table public.investigation_tracker enable row level security;
alter table public.drug_master enable row level security;
alter table public.sync_queue enable row level security;
alter table public.personal_wiki enable row level security;

drop policy if exists patients_owner_select on public.patients;
create policy patients_owner_select on public.patients for select to authenticated
  using (owner_id = auth.uid());
drop policy if exists patients_owner_insert on public.patients;
create policy patients_owner_insert on public.patients for insert to authenticated
  with check (owner_id = auth.uid());
drop policy if exists patients_owner_update on public.patients;
create policy patients_owner_update on public.patients for update to authenticated
  using (owner_id = auth.uid()) with check (owner_id = auth.uid());
drop policy if exists patients_owner_delete on public.patients;
create policy patients_owner_delete on public.patients for delete to authenticated
  using (owner_id = auth.uid());

drop policy if exists clinical_encounters_owner_select on public.clinical_encounters;
create policy clinical_encounters_owner_select on public.clinical_encounters for select to authenticated
  using (owner_id = auth.uid());
drop policy if exists clinical_encounters_owner_insert on public.clinical_encounters;
create policy clinical_encounters_owner_insert on public.clinical_encounters for insert to authenticated
  with check (owner_id = auth.uid());
drop policy if exists clinical_encounters_owner_update on public.clinical_encounters;
create policy clinical_encounters_owner_update on public.clinical_encounters for update to authenticated
  using (owner_id = auth.uid()) with check (owner_id = auth.uid());
drop policy if exists clinical_encounters_owner_delete on public.clinical_encounters;
create policy clinical_encounters_owner_delete on public.clinical_encounters for delete to authenticated
  using (owner_id = auth.uid());

drop policy if exists personal_wiki_owner_select on public.personal_wiki;
create policy personal_wiki_owner_select on public.personal_wiki for select to authenticated using (owner_id = auth.uid());
drop policy if exists personal_wiki_owner_insert on public.personal_wiki;
create policy personal_wiki_owner_insert on public.personal_wiki for insert to authenticated with check (owner_id = auth.uid());
drop policy if exists personal_wiki_owner_update on public.personal_wiki;
create policy personal_wiki_owner_update on public.personal_wiki for update to authenticated using (owner_id = auth.uid()) with check (owner_id = auth.uid());
drop policy if exists personal_wiki_owner_delete on public.personal_wiki;
create policy personal_wiki_owner_delete on public.personal_wiki for delete to authenticated using (owner_id = auth.uid());

drop policy if exists investigations_owner_select on public.investigation_tracker;
create policy investigations_owner_select on public.investigation_tracker for select to authenticated
  using (owner_id = auth.uid());
drop policy if exists investigations_owner_insert on public.investigation_tracker;
create policy investigations_owner_insert on public.investigation_tracker for insert to authenticated
  with check (owner_id = auth.uid());
drop policy if exists investigations_owner_update on public.investigation_tracker;
create policy investigations_owner_update on public.investigation_tracker for update to authenticated
  using (owner_id = auth.uid()) with check (owner_id = auth.uid());
drop policy if exists investigations_owner_delete on public.investigation_tracker;
create policy investigations_owner_delete on public.investigation_tracker for delete to authenticated
  using (owner_id = auth.uid());

drop policy if exists drugs_owner_select on public.drug_master;
create policy drugs_owner_select on public.drug_master for select to authenticated
  using (owner_id = auth.uid());
drop policy if exists drugs_owner_insert on public.drug_master;
create policy drugs_owner_insert on public.drug_master for insert to authenticated
  with check (owner_id = auth.uid());
drop policy if exists drugs_owner_update on public.drug_master;
create policy drugs_owner_update on public.drug_master for update to authenticated
  using (owner_id = auth.uid()) with check (owner_id = auth.uid());
drop policy if exists drugs_owner_delete on public.drug_master;
create policy drugs_owner_delete on public.drug_master for delete to authenticated
  using (owner_id = auth.uid());

drop policy if exists sync_queue_owner_select on public.sync_queue;
create policy sync_queue_owner_select on public.sync_queue for select to authenticated
  using (owner_id = auth.uid());
drop policy if exists sync_queue_owner_insert on public.sync_queue;
create policy sync_queue_owner_insert on public.sync_queue for insert to authenticated
  with check (owner_id = auth.uid());
drop policy if exists sync_queue_owner_update on public.sync_queue;
create policy sync_queue_owner_update on public.sync_queue for update to authenticated
  using (owner_id = auth.uid()) with check (owner_id = auth.uid());
drop policy if exists sync_queue_owner_delete on public.sync_queue;
create policy sync_queue_owner_delete on public.sync_queue for delete to authenticated
  using (owner_id = auth.uid());

-- Idempotent migration for databases created by the surgery-only release.
do $$
begin
  if exists (select 1 from information_schema.columns where table_schema = 'public' and table_name = 'patients' and column_name = 'surgical_category')
     and not exists (select 1 from information_schema.columns where table_schema = 'public' and table_name = 'patients' and column_name = 'current_department') then
    alter table public.patients rename column surgical_category to current_department;
  end if;
  alter table public.patients add column if not exists current_department text;
  update public.patients
  set current_department = case when current_department in ('Medicine','OBGYN','Pediatrics','Surgery','Psychiatry','Emergency','Other') then current_department else 'Surgery' end;
  alter table public.patients alter column current_department set default 'Surgery';
  alter table public.patients alter column current_department set not null;
  if not exists (select 1 from pg_constraint where conname = 'patients_department_check') then
    alter table public.patients add constraint patients_department_check check (current_department in ('Medicine','OBGYN','Pediatrics','Surgery','Plastic Surgery','Psychiatry','Emergency','Other'));
  end if;

  if to_regclass('public.daily_vitals_notes') is not null and to_regclass('public.clinical_encounters') is null then
    alter table public.daily_vitals_notes rename to clinical_encounters;
  end if;
  if to_regclass('public.clinical_encounters') is not null then
    alter table public.clinical_encounters add column if not exists encounter_type text default 'Ward Round';
    alter table public.clinical_encounters add column if not exists occurred_at timestamptz default now();
    alter table public.clinical_encounters add column if not exists dynamic_data jsonb not null default '{}'::jsonb;
    if exists (select 1 from information_schema.columns where table_schema = 'public' and table_name = 'clinical_encounters' and column_name = 'recorded_at') then
      update public.clinical_encounters set occurred_at = recorded_at where occurred_at is null;
    end if;
    update public.clinical_encounters set encounter_type = 'Ward Round' where encounter_type is null;
    update public.clinical_encounters set occurred_at = now() where occurred_at is null;
    alter table public.clinical_encounters alter column encounter_type set not null;
    alter table public.clinical_encounters alter column occurred_at set not null;
  end if;
  if to_regclass('public.daily_vitals_notes') is not null and to_regclass('public.clinical_encounters') is not null then
    insert into public.clinical_encounters
      (id, owner_id, patient_id, encounter_type, occurred_at, sbp, dbp, pulse, temperature_c,
       respiratory_rate, spo2, map, chief_complaint, consultant_advice, note, dynamic_data,
       created_at, updated_at, last_synced_at)
    select id, owner_id, patient_id, 'Ward Round', recorded_at, sbp, dbp, pulse, temperature_c,
           respiratory_rate, spo2, map, chief_complaint, consultant_advice, note, '{}'::jsonb,
           created_at, updated_at, last_synced_at
    from public.daily_vitals_notes
    on conflict (id) do nothing;
  end if;
end $$;

alter table public.sync_queue drop constraint if exists sync_queue_entity_type_check;
update public.sync_queue set entity_type = 'clinical_encounters' where entity_type = 'daily_vitals_notes';
alter table public.sync_queue add constraint sync_queue_entity_type_check
  check (entity_type in ('patients','clinical_encounters','investigation_tracker','drug_master','personal_wiki'));
