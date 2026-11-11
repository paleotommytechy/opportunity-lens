# 70 application checklist items

**Canonical SQL:** [schema.sql](schema.sql). This module is assembled into the versioned Supabase migration by `database/scripts/build_migration.py`. Do not run this file separately after applying the bundled migration.

Checklist items belong to an application. The composite foreign key `(application_id, user_id)` guarantees that a user cannot attach checklist items to another user's application, even if a UUID is leaked.

**Access policy:** Only each owner can read and change items; inserts that reference another user's application are blocked by the foreign key.

This file documents the **immutable initial baseline**. Once the initial migration has been applied, do not edit this SQL or its bundled migration. For future changes to this table/function, create a new versioned file in `supabase/migrations/` and a focused note under `database/changes/<version>/<table>/` instead. See `database/changes/README.md`. Never drop production data to correct a migration.
