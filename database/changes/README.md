# Later schema changes (after initial deployment)

The `database/modules/*/schema.sql` files are frozen **initial migration inputs**, not editable definitions of the live database. A history of applied SQL is an append-only contract.

For every later change:

1. Start from the latest upstream `main` to avoid conflicting migrations. Use `supabase migration new <descriptive_name>` to generate the next timestamped migration file under `supabase/migrations/` (Supabase CLI v3).
2. Add a matching directory, e.g. `database/changes/20261201123000_add_application_notes/applications/`, containing a `README.md` describing the affected table, prerequisites, forward SQL migration, RLS implications and safe recovery procedure. Keep executable migration SQL only in `supabase/migrations/` to avoid dual sources of truth.
3. Never modify or overwrite `20261111220000_opportunitylens_database_foundation.sql` or the baseline module files after they are applied.
4. Validate on a separate Supabase **staging project**, run security/advisor checks, and test with two authenticated users and an anonymous browser.
5. Open a PR from the fork to Adebanke's repository; the DB owner reviews and applies after approval. Do not add a GitHub Action that auto-pushes migrations to production.
6. Coordinate with Vercel frontend deployment: additive schema changes are generally easier to deploy first; destructive changes require a separate compatibility window and backfill plan.

The baseline `database/scripts/build_migration.py --check` intentionally covers only the frozen initial eight modules. It will continue passing for later migrations, which need their **own** tests and deployment verification.
