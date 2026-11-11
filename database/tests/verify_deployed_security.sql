-- Read-only inspection for Adebanke to run in Supabase SQL Editor AFTER migration.
-- Expected: seven rows, each rls_enabled = true, no false values.
select c.relname as table_name, c.relrowsecurity as rls_enabled
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public'
  and c.relname in (
    'student_profiles','opportunity_sources','opportunities',
    'saved_opportunities','eligibility_assessments','applications',
    'application_checklist_items'
  )
order by c.relname;

-- Expected: every table has its documented policies; none use TO public.
select tablename, policyname, roles, cmd, qual, with_check
from pg_policies
where schemaname='public'
  and tablename in (
    'student_profiles','opportunity_sources','opportunities',
    'saved_opportunities','eligibility_assessments','applications',
    'application_checklist_items'
  )
order by tablename, policyname;

-- Expected: anon can SELECT only opportunity_sources and opportunities.
select table_name, grantee, privilege_type
from information_schema.role_table_grants
where table_schema='public'
  and table_name in (
    'student_profiles','opportunity_sources','opportunities',
    'saved_opportunities','eligibility_assessments','applications',
    'application_checklist_items'
  ) and grantee in ('anon','authenticated')
order by table_name, grantee, privilege_type;
