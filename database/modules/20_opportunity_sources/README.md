# 20 opportunity sources

**Canonical SQL:** [schema.sql](schema.sql). This module is assembled into the versioned Supabase migration by `database/scripts/build_migration.py`. Do not run this file separately after applying the bundled migration.

Curated portal directory. No provider is marked active by default. Adebanke manages URLs and verification directly in Supabase, not through a browser admin key.

**Access policy:** Guests and signed-in users may read active rows only; only trusted administrators can insert or edit.

This file documents the **immutable initial baseline**. Once the initial migration has been applied, do not edit this SQL or its bundled migration. For future changes to this table/function, create a new versioned file in `supabase/migrations/` and a focused note under `database/changes/<version>/<table>/` instead. See `database/changes/README.md`. Never drop production data to correct a migration.
