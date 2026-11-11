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
