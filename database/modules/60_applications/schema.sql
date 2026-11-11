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
