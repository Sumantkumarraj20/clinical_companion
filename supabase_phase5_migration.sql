-- Run against an existing Supabase project that was created before Phase 5.
-- The main supabase_schema.sql is idempotent; this focused migration is useful
-- for deployments that prefer versioned migrations.
begin;

do $$ begin
  if exists (select 1 from information_schema.columns where table_schema='public' and table_name='patients' and column_name='surgical_category')
     and not exists (select 1 from information_schema.columns where table_schema='public' and table_name='patients' and column_name='current_department') then
    alter table public.patients rename column surgical_category to current_department;
  end if;
end $$;
alter table if exists public.patients add column if not exists current_department text;
update public.patients set current_department = case when current_department in ('Medicine','OBGYN','Pediatrics','Surgery','Plastic Surgery','Psychiatry','Emergency','Other') then current_department else 'Surgery' end;
alter table public.patients alter column current_department set default 'Surgery';
alter table public.patients alter column current_department set not null;
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'patients_department_check') then
    alter table public.patients add constraint patients_department_check check (current_department in ('Medicine','OBGYN','Pediatrics','Surgery','Plastic Surgery','Psychiatry','Emergency','Other'));
  end if;
end $$;

create table if not exists public.clinical_encounters (
  id uuid primary key default gen_random_uuid(), owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  patient_id uuid not null references public.patients(id) on delete cascade,
  encounter_type text not null default 'Ward Round', occurred_at timestamptz not null default now(),
  sbp smallint, dbp smallint, pulse smallint, temperature_c numeric(4,1), respiratory_rate smallint, spo2 smallint, map numeric(6,2),
  chief_complaint text, consultant_advice text, note text, dynamic_data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(), last_synced_at timestamptz
);
do $$ begin
  if to_regclass('public.daily_vitals_notes') is not null then
    insert into public.clinical_encounters (id, owner_id, patient_id, encounter_type, occurred_at, sbp, dbp, pulse, temperature_c, respiratory_rate, spo2, map, chief_complaint, consultant_advice, note, dynamic_data, created_at, updated_at, last_synced_at)
    select id, owner_id, patient_id, 'Ward Round', recorded_at, sbp, dbp, pulse, temperature_c, respiratory_rate, spo2, map, chief_complaint, consultant_advice, note, '{}'::jsonb, created_at, updated_at, last_synced_at
    from public.daily_vitals_notes on conflict (id) do nothing;
  end if;
end $$;
create index if not exists clinical_encounters_patient_occurred_idx on public.clinical_encounters(patient_id, occurred_at desc);
create index if not exists clinical_encounters_dynamic_data_idx on public.clinical_encounters using gin(dynamic_data);
alter table public.clinical_encounters enable row level security;
drop policy if exists clinical_encounters_owner_select on public.clinical_encounters;
create policy clinical_encounters_owner_select on public.clinical_encounters for select to authenticated using (owner_id = auth.uid());
drop policy if exists clinical_encounters_owner_insert on public.clinical_encounters;
create policy clinical_encounters_owner_insert on public.clinical_encounters for insert to authenticated with check (owner_id = auth.uid());
drop policy if exists clinical_encounters_owner_update on public.clinical_encounters;
create policy clinical_encounters_owner_update on public.clinical_encounters for update to authenticated using (owner_id = auth.uid()) with check (owner_id = auth.uid());
drop policy if exists clinical_encounters_owner_delete on public.clinical_encounters;
create policy clinical_encounters_owner_delete on public.clinical_encounters for delete to authenticated using (owner_id = auth.uid());
drop trigger if exists clinical_encounters_set_updated_at on public.clinical_encounters;
create trigger clinical_encounters_set_updated_at before update on public.clinical_encounters for each row execute function public.set_updated_at();
drop trigger if exists clinical_encounters_prevent_owner_change on public.clinical_encounters;
create trigger clinical_encounters_prevent_owner_change before update on public.clinical_encounters for each row execute function public.prevent_owner_change();
drop trigger if exists clinical_encounters_patient_owner on public.clinical_encounters;
create trigger clinical_encounters_patient_owner before insert or update on public.clinical_encounters for each row execute function public.ensure_patient_owner();

create table if not exists public.personal_wiki (
  id uuid primary key default gen_random_uuid(), owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  topic text not null, markdown_content text not null default '', tags text[] not null default '{}', department_relevance text[] not null default '{}',
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(), last_synced_at timestamptz
);
create index if not exists personal_wiki_owner_updated_idx on public.personal_wiki(owner_id, updated_at desc);
create index if not exists personal_wiki_tags_idx on public.personal_wiki using gin(tags);
create index if not exists personal_wiki_department_idx on public.personal_wiki using gin(department_relevance);
alter table public.personal_wiki enable row level security;
drop policy if exists personal_wiki_owner_select on public.personal_wiki;
create policy personal_wiki_owner_select on public.personal_wiki for select to authenticated using (owner_id = auth.uid());
drop policy if exists personal_wiki_owner_insert on public.personal_wiki;
create policy personal_wiki_owner_insert on public.personal_wiki for insert to authenticated with check (owner_id = auth.uid());
drop policy if exists personal_wiki_owner_update on public.personal_wiki;
create policy personal_wiki_owner_update on public.personal_wiki for update to authenticated using (owner_id = auth.uid()) with check (owner_id = auth.uid());
drop policy if exists personal_wiki_owner_delete on public.personal_wiki;
create policy personal_wiki_owner_delete on public.personal_wiki for delete to authenticated using (owner_id = auth.uid());
drop trigger if exists personal_wiki_set_updated_at on public.personal_wiki;
create trigger personal_wiki_set_updated_at before update on public.personal_wiki for each row execute function public.set_updated_at();
drop trigger if exists personal_wiki_prevent_owner_change on public.personal_wiki;
create trigger personal_wiki_prevent_owner_change before update on public.personal_wiki for each row execute function public.prevent_owner_change();
alter table public.sync_queue drop constraint if exists sync_queue_entity_type_check;
update public.sync_queue set entity_type = 'clinical_encounters' where entity_type = 'daily_vitals_notes';
alter table public.sync_queue add constraint sync_queue_entity_type_check check (entity_type in ('patients','clinical_encounters','investigation_tracker','drug_master','personal_wiki'));

commit;
