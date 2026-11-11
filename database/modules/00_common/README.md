# 00 common

**Canonical SQL:** [schema.sql](schema.sql). This module is assembled into the versioned Supabase migration by `database/scripts/build_migration.py`. Do not run this file separately after applying the bundled migration.

Private utilities for maintaining timestamps. No privileged RPC functions are exposed.

**Access policy:** No browser-accessible functions or grants. The trigger is SECURITY INVOKER.

When changing this module, add a *new* timestamped migration for the change after the initial deployment, and keep this module as a current-schema reference. Do not edit already-applied migration files or drop production tables to fix a deployment.
