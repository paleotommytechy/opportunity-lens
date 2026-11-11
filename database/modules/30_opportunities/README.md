# 30 opportunities

**Canonical SQL:** [schema.sql](schema.sql). This module is assembled into the versioned Supabase migration by `database/scripts/build_migration.py`. Do not run this file separately after applying the bundled migration.

User-pasted/manually entered opportunities are private by default. A human reviewer may publish records with `visibility='public'` and `verified_at` only using trusted database privileges. This avoids fabricated 'open now' claims.

**Access policy:** Verified public records are readable by everyone; signed-in users may CRUD their own unverified private records only.

This file documents the **immutable initial baseline**. Once the initial migration has been applied, do not edit this SQL or its bundled migration. For future changes to this table/function, create a new versioned file in `supabase/migrations/` and a focused note under `database/changes/<version>/<table>/` instead. See `database/changes/README.md`. Never drop production data to correct a migration.
