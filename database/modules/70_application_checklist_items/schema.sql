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
