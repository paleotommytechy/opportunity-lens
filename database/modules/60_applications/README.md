# 60 applications

**Canonical SQL:** [schema.sql](schema.sql). This module is assembled into the versioned Supabase migration by `database/scripts/build_migration.py`. Do not run this file separately after applying the bundled migration.

Per-user application tracker. One row per user and opportunity. Status is self-reported, not proof of an official application.

**Access policy:** A signed-in user may manage only their own application for an opportunity they can see.

When changing this module, add a *new* timestamped migration for the change after the initial deployment, and keep this module as a current-schema reference. Do not edit already-applied migration files or drop production tables to fix a deployment.
