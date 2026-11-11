-- GENERATED FROM database/modules/*/schema.sql
-- DO NOT EDIT: change source modules before first deployment, then generate a NEW migration for future changes.
-- Run database/scripts/build_migration.py --check to verify this snapshot.

-- BEGIN database/modules/00_common/schema.sql
-- Shared trigger function; private schema is NOT in the Supabase Data API.
create schema if not exists app_private;
revoke all on schema app_private from public, anon, authenticated;

create or replace function app_private.set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;
revoke all on function app_private.set_updated_at() from public, anon, authenticated;
-- END database/modules/00_common/schema.sql

-- BEGIN database/modules/10_student_profiles/schema.sql
create table public.student_profiles (
  user_id uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  full_name text not null default '',
  country text not null default '',
  institution text not null default '',
  course_of_study text not null default '',
  academic_level text not null default '',
  cgpa numeric(5,2),
  cgpa_scale numeric(5,2),
  qualifications text not null default '',
  age smallint,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint student_profiles_valid_scale check (cgpa_scale is null or (cgpa_scale > 0 and cgpa_scale <= 10)),
  constraint student_profiles_valid_cgpa check (cgpa is null or (cgpa_scale is not null and cgpa >= 0 and cgpa <= cgpa_scale)),
  constraint student_profiles_valid_age check (age is null or age between 10 and 120)
);
create trigger trg_student_profiles_updated_at
before update on public.student_profiles
for each row execute function app_private.set_updated_at();

alter table public.student_profiles enable row level security;
revoke all on table public.student_profiles from anon, authenticated;
grant select, insert, update, delete on table public.student_profiles to authenticated;
grant all on table public.student_profiles to service_role;

create policy "student_profiles_select_self" on public.student_profiles
for select to authenticated using ((select auth.uid()) = user_id);
create policy "student_profiles_insert_self" on public.student_profiles
for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "student_profiles_update_self" on public.student_profiles
for update to authenticated using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);
create policy "student_profiles_delete_self" on public.student_profiles
for delete to authenticated using ((select auth.uid()) = user_id);
-- END database/modules/10_student_profiles/schema.sql

-- BEGIN database/modules/20_opportunity_sources/schema.sql
-- A directory of official provider portals; NOT a live scholarship feed.
create table public.opportunity_sources (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  official_url text not null unique,
  provider_type text not null default 'other',
  description text not null default '',
  is_active boolean not null default false,
  last_verified_at timestamptz,
  created_at timestamptz not null default now(),
  constraint sources_https_url check (official_url ~* '^https://[^[:space:]]+$')
);
create index idx_opportunity_sources_active on public.opportunity_sources(name)
where is_active;

alter table public.opportunity_sources enable row level security;
revoke all on table public.opportunity_sources from anon, authenticated;
grant select on table public.opportunity_sources to anon, authenticated;
grant all on table public.opportunity_sources to service_role;

create policy "opportunity_sources_read_active" on public.opportunity_sources
for select to anon, authenticated using (is_active = true);
-- END database/modules/20_opportunity_sources/schema.sql

-- BEGIN database/modules/30_opportunities/schema.sql
-- Full extraction is stored as JSON matching schemas.ExtractedOpportunity.
-- A user can create only PRIVATE records. Publishing requires trusted SQL/admin privileges.
create table public.opportunities (
  id uuid primary key default gen_random_uuid(),
  created_by uuid references auth.users(id) on delete cascade,
  title text not null check (char_length(btrim(title)) > 0),
  organizing_institution text,
  category text,
  description text,
  official_url text,
  application_deadline text, -- preserve unverified AI-extracted wording, no guessed timestamp
  extracted_data jsonb not null default '{}'::jsonb,
  visibility text not null default 'private'
    check (visibility in ('private', 'public')),
  verified_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint opportunities_private_owner check (visibility <> 'private' or created_by is not null),
  constraint opportunities_public_verified check (visibility <> 'public' or verified_at is not null),
  constraint opportunities_json_object check (jsonb_typeof(extracted_data) = 'object'),
  constraint opportunities_https_url check (official_url is null or official_url ~* '^https://[^[:space:]]+$')
);
create index idx_opportunities_created_by on public.opportunities(created_by, created_at desc);
create index idx_opportunities_public on public.opportunities(created_at desc)
where visibility = 'public' and verified_at is not null;

create trigger trg_opportunities_updated_at
before update on public.opportunities
for each row execute function app_private.set_updated_at();

alter table public.opportunities enable row level security;
revoke all on table public.opportunities from anon, authenticated;
grant select on table public.opportunities to anon;
grant select, insert, update, delete on table public.opportunities to authenticated;
grant all on table public.opportunities to service_role;

create policy "opportunities_read_verified_public" on public.opportunities
for select to anon, authenticated
using (visibility = 'public' and verified_at is not null);
create policy "opportunities_read_own_private" on public.opportunities
for select to authenticated using (created_by = (select auth.uid()));
create policy "opportunities_create_own_private" on public.opportunities
for insert to authenticated
with check (created_by = (select auth.uid()) and visibility = 'private' and verified_at is null);
create policy "opportunities_update_own_private" on public.opportunities
for update to authenticated
using (created_by = (select auth.uid()) and visibility = 'private')
with check (created_by = (select auth.uid()) and visibility = 'private' and verified_at is null);
create policy "opportunities_delete_own_private" on public.opportunities
for delete to authenticated
using (created_by = (select auth.uid()) and visibility = 'private');
-- END database/modules/30_opportunities/schema.sql

-- BEGIN database/modules/40_saved_opportunities/schema.sql
create table public.saved_opportunities (
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  opportunity_id uuid not null references public.opportunities(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, opportunity_id)
);
create index idx_saved_opportunities_opportunity on public.saved_opportunities(opportunity_id);

alter table public.saved_opportunities enable row level security;
revoke all on table public.saved_opportunities from anon, authenticated;
grant select, insert, delete on table public.saved_opportunities to authenticated;
grant all on table public.saved_opportunities to service_role;

create policy "saved_opportunities_select_own" on public.saved_opportunities
for select to authenticated using (user_id = (select auth.uid()));
create policy "saved_opportunities_insert_own_visible" on public.saved_opportunities
for insert to authenticated
with check (
 user_id = (select auth.uid()) and exists (
  select 1 from public.opportunities o where o.id = opportunity_id
 )
);
create policy "saved_opportunities_delete_own" on public.saved_opportunities
for delete to authenticated using (user_id = (select auth.uid()));
-- END database/modules/40_saved_opportunities/schema.sql

-- BEGIN database/modules/50_eligibility_assessments/schema.sql
-- Immutable snapshots of eligibility evaluations (never a guarantee of acceptance).
create table public.eligibility_assessments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  opportunity_id uuid not null references public.opportunities(id) on delete cascade,
  overall_status text not null check (
    overall_status in ('LIKELY_ELIGIBLE','POTENTIALLY_ELIGIBLE',
      'LIKELY_INELIGIBLE','INSUFFICIENT_INFORMATION')
  ),
  profile_snapshot jsonb not null,
  result_data jsonb not null,
  created_at timestamptz not null default now(),
  constraint assessments_profile_object check (jsonb_typeof(profile_snapshot) = 'object'),
  constraint assessments_result_object check (jsonb_typeof(result_data) = 'object')
);
create index idx_eligibility_assessments_user on public.eligibility_assessments(user_id, created_at desc);
create index idx_eligibility_assessments_opportunity on public.eligibility_assessments(opportunity_id);

alter table public.eligibility_assessments enable row level security;
revoke all on table public.eligibility_assessments from anon, authenticated;
grant select, insert, delete on table public.eligibility_assessments to authenticated;
grant all on table public.eligibility_assessments to service_role;

create policy "assessments_read_own" on public.eligibility_assessments
for select to authenticated using (user_id = (select auth.uid()));
create policy "assessments_create_own_visible" on public.eligibility_assessments
for insert to authenticated
with check (
 user_id = (select auth.uid()) and exists (
  select 1 from public.opportunities o where o.id = opportunity_id
 )
);
create policy "assessments_delete_own" on public.eligibility_assessments
for delete to authenticated using (user_id = (select auth.uid()));
-- END database/modules/50_eligibility_assessments/schema.sql

-- BEGIN database/modules/60_applications/schema.sql
create table public.applications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  opportunity_id uuid not null references public.opportunities(id) on delete cascade,
  status text not null default 'planned'
    check (status in ('planned','preparing','submitted','interview',
      'accepted','rejected','withdrawn')),
  notes text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, opportunity_id),
  unique (id, user_id)
);
create index idx_applications_user on public.applications(user_id, updated_at desc);
create index idx_applications_opportunity on public.applications(opportunity_id);
create trigger trg_applications_updated_at
before update on public.applications
for each row execute function app_private.set_updated_at();

alter table public.applications enable row level security;
revoke all on table public.applications from anon, authenticated;
grant select, insert, update, delete on table public.applications to authenticated;
grant all on table public.applications to service_role;

create policy "applications_read_own" on public.applications
for select to authenticated using (user_id = (select auth.uid()));
create policy "applications_create_own_visible" on public.applications
for insert to authenticated with check (
 user_id = (select auth.uid()) and exists (
   select 1 from public.opportunities o where o.id = opportunity_id
 )
);
create policy "applications_update_own_visible" on public.applications
for update to authenticated
using (user_id = (select auth.uid()))
with check (
 user_id = (select auth.uid()) and exists (
   select 1 from public.opportunities o where o.id = opportunity_id
 )
);
create policy "applications_delete_own" on public.applications
for delete to authenticated using (user_id = (select auth.uid()));
-- END database/modules/60_applications/schema.sql

-- BEGIN database/modules/70_application_checklist_items/schema.sql
create table public.application_checklist_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  application_id uuid not null,
  category text not null default 'document'
    check (category in ('document','action','verification')),
  description text not null check (char_length(btrim(description)) > 0),
  detail text,
  sort_order integer not null default 0 check (sort_order >= 0),
  completed boolean not null default false,
  created_at timestamptz not null default now(),
  constraint checklist_parent_owned foreign key (application_id, user_id)
    references public.applications(id, user_id) on delete cascade
);
create index idx_checklist_by_application on public.application_checklist_items(application_id, sort_order);
create index idx_checklist_by_user on public.application_checklist_items(user_id);

alter table public.application_checklist_items enable row level security;
revoke all on table public.application_checklist_items from anon, authenticated;
grant select, insert, update, delete on table public.application_checklist_items to authenticated;
grant all on table public.application_checklist_items to service_role;

create policy "checklist_select_own" on public.application_checklist_items
for select to authenticated using (user_id = (select auth.uid()));
create policy "checklist_insert_own" on public.application_checklist_items
for insert to authenticated with check (user_id = (select auth.uid()));
create policy "checklist_update_own" on public.application_checklist_items
for update to authenticated using (user_id = (select auth.uid()))
with check (user_id = (select auth.uid()));
create policy "checklist_delete_own" on public.application_checklist_items
for delete to authenticated using (user_id = (select auth.uid()));
-- END database/modules/70_application_checklist_items/schema.sql

