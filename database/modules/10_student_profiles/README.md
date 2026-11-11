# 10 student profiles

**Canonical SQL:** [schema.sql](schema.sql). This module is assembled into the versioned Supabase migration by `database/scripts/build_migration.py`. Do not run this file separately after applying the bundled migration.

One authenticated user's academic profile, using the exact field names in `schemas.py` (`country`, `academic_level`, `course_of_study`, `cgpa`, `cgpa_scale`, etc.). The frontend must explicitly create a profile after login; there is no privileged auth.users trigger.

**Access policy:** Signed-in users may read, create, update and delete only their own profile. Guests cannot access.

This file documents the **immutable initial baseline**. Once the initial migration has been applied, do not edit this SQL or its bundled migration. For future changes to this table/function, create a new versioned file in `supabase/migrations/` and a focused note under `database/changes/<version>/<table>/` instead. See `database/changes/README.md`. Never drop production data to correct a migration.
