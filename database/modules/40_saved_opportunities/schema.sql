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
