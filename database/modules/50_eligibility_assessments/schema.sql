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
