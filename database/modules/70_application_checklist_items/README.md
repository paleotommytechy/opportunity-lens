# 70 application checklist items

**Canonical SQL:** [schema.sql](schema.sql). This module is assembled into the versioned Supabase migration by `database/scripts/build_migration.py`. Do not run this file separately after applying the bundled migration.

Checklist items belong to an application. The composite foreign key `(application_id, user_id)` guarantees that a user cannot attach checklist items to another user's application, even if a UUID is leaked.

**Access policy:** Only each owner can read and change items; inserts that reference another user's application are blocked by the foreign key.

When changing this module, add a *new* timestamped migration for the change after the initial deployment, and keep this module as a current-schema reference. Do not edit already-applied migration files or drop production tables to fix a deployment.
