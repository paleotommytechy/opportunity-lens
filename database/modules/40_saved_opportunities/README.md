# 40 saved opportunities

**Canonical SQL:** [schema.sql](schema.sql). This module is assembled into the versioned Supabase migration by `database/scripts/build_migration.py`. Do not run this file separately after applying the bundled migration.

Personal opportunity bookmarks; the foreign key links them to user-private or verified-public opportunity records.

**Access policy:** Signed-in users can bookmark only opportunities visible to their session, and read/delete only their own bookmarks.

When changing this module, add a *new* timestamped migration for the change after the initial deployment, and keep this module as a current-schema reference. Do not edit already-applied migration files or drop production tables to fix a deployment.
