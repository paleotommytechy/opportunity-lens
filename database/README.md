# OpportunityLens — Supabase database system

This folder is the reviewable database contract for OpportunityLens. **Adebanke owns the Supabase deployment; contributors change SQL in GitHub, not the live database.**

## Structure

```text
database/
  modules/
    00_common/                     trigger utilities (non-exposed)
    10_student_profiles/           academic profiles
    20_opportunity_sources/        official provider portal directory
    30_opportunities/              private drafts / human-verified public entries
    40_saved_opportunities/        bookmarks
    50_eligibility_assessments/    immutable eligibility snapshots
    60_applications/               application tracking
    70_application_checklist_items/ checklist progress
  scripts/build_migration.py       snapshot verification
  tests/check_sql_security.py      static security assertions
  tests/verify_deployed_security.sql read-only Supabase SQL Editor checks
supabase/
  migrations/
    20261111220000_opportunitylens_database_foundation.sql
```

Each module owns **its table, constraints, indexes, RLS policies and grants** in the same `schema.sql`. The generated migration is the *only* file Adebanke should execute for a fresh deployment. Do not separately execute the component files. They are organized source references and must be kept in sync before initial deployment.

**Important:** Once this migration is applied anywhere, treat it as immutable. All subsequent schema changes go into new timestamped migration files, created with `supabase migration new <descriptive_name>`, with a focused PR and a tested rollback/recovery plan. Do not regenerate an already-applied migration.

## First-time owner deployment

1. Back up the target project. Confirm there are no existing `public.student_profiles`, `opportunities`, etc. This initial migration is designed for a new schema and intentionally fails on name collisions rather than silently overwriting tables.
2. Review every `database/modules/*/schema.sql` file, especially policies and role grants. Review the bundled migration.
3. Use a **staging Supabase project first**. Either run the bundled SQL **once** in Supabase SQL Editor, **or** apply the versioned migration with Supabase CLI. **Do not do both.** If SQL Editor was used, coordinate migration history before trying `db push`; otherwise the CLI may attempt to apply it again.
4. For CLI v3, authenticate and link the project, inspect `supabase db push --help`, then use `supabase db push --remote --yes` only after inspecting its planned target and migrations. The `--remote` flag is essential in v3; `--yes` consents to remote writes. Never run automatic production migration from a pull-request workflow.
5. Run `database/tests/verify_deployed_security.sql` in SQL Editor and manually test with two distinct Supabase Auth users (each sees only their own rows). Test that unauthenticated visitors cannot read personal data or create records.
6. Repeat the reviewed migration on production after staging passes.

## API and Vercel boundary

Adebanke needs to provide only:
- `VITE_SUPABASE_URL=https://<project-ref>.supabase.co`
- `VITE_SUPABASE_PUBLISHABLE_KEY=sb_publishable_...`

Set these in **Vercel Project > Settings > Environment Variables** for the `web/` Vite project and redeploy. Vite's `VITE_*` values become public in browser JavaScript; this is expected **only** for the URL and publishable key. Do NOT send a `sb_secret_...`, `service_role`, database password, or Supabase access token. Do not put credentials in Git.

These migrations do **not** yet add Supabase sign-in or database CRUD to the current React guest preview. Installing frontend auth and persistence requires a separate PR, after Adebanke has applied and tested the schema. Currently Vercel still connects to the existing FastAPI service for AI extraction and eligibility analysis; Supabase will handle future authenticated storage. This separation avoids breaking the deployed frontend before credentials and RLS are ready.

## Data model and safety

- `student_profiles`: one profile per `auth.users` user; stores the same academic fields as Python `schemas.StudentProfile`.
- `opportunity_sources`: active official *portal links* only, not live scholarship records; administered directly by the database owner.
- `opportunities`: each user can create private structured data; only a trusted admin can publish a verified listing. Extracted announcement dates remain text to avoid inventing deadlines.
- `saved_opportunities`: private per-user bookmarks to visible opportunities.
- `eligibility_assessments`: immutable snapshots of existing backend rule results.
- `applications`: self-reported application stage; not an official application submission.
- `application_checklist_items`: users can attach items only to their own application (enforced by a composite foreign key).

All seven `public` tables have RLS, explicit grants, and ownership checks. No frontend secret key, privileged public RPC, unauthenticated write policy, or fabricated scholarship data is included.

## Verification before a PR

```bash
python database/scripts/build_migration.py --check
python -m unittest discover -s database/tests -p 'check_*.py' -v
```

These are **static checks** only; they cannot prove that PostgreSQL migrations execute or that RLS works with real sessions. Staging application and two-user RLS tests are mandatory before production.

## Team workflow

1. Contributor opens feature branch in `paleotommytechy/opportunity-lens` and pushes SQL changes.
2. Contributor opens PR to `AdebankeDev/opportunity-lens:main` (or sends review link if GitHub's integration lacks PR creation permission).
3. Adebanke reviews, tests and applies the **exact reviewed migration** from the PR to staging.
4. After approval/merge and staging validation, Adebanke promotes the migration to production. The fork syncs from upstream; Vercel (linked to the fork's `main`) deploys only approved frontend changes.
5. Future schema changes are separate versioned migrations; never edit previously deployed migration files. Maintain a small change log in each PR.

**Reference docs:** [Supabase RLS](https://supabase.com/docs/guides/database/postgres/row-level-security), [API keys](https://supabase.com/docs/guides/getting-started/api-keys), [Supabase CLI v3](https://supabase.com/docs/guides/local-development/cli/migrating-to-v3), [Deployment environments](https://supabase.com/docs/guides/deployment/managing-environments).
