# 20 opportunity sources

**Canonical SQL:** [schema.sql](schema.sql). This module is assembled into the versioned Supabase migration by `database/scripts/build_migration.py`. Do not run this file separately after applying the bundled migration.

Curated portal directory. No provider is marked active by default. Adebanke manages URLs and verification directly in Supabase, not through a browser admin key.

**Access policy:** Guests and signed-in users may read active rows only; only trusted administrators can insert or edit.

When changing this module, add a *new* timestamped migration for the change after the initial deployment, and keep this module as a current-schema reference. Do not edit already-applied migration files or drop production tables to fix a deployment.
