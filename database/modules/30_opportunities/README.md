# 30 opportunities

**Canonical SQL:** [schema.sql](schema.sql). This module is assembled into the versioned Supabase migration by `database/scripts/build_migration.py`. Do not run this file separately after applying the bundled migration.

User-pasted/manually entered opportunities are private by default. A human reviewer may publish records with `visibility='public'` and `verified_at` only using trusted database privileges. This avoids fabricated 'open now' claims.

**Access policy:** Verified public records are readable by everyone; signed-in users may CRUD their own unverified private records only.

When changing this module, add a *new* timestamped migration for the change after the initial deployment, and keep this module as a current-schema reference. Do not edit already-applied migration files or drop production tables to fix a deployment.
