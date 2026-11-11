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
