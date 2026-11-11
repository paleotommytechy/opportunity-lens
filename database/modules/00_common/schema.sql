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
