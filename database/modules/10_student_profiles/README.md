# 10 student profiles

**Canonical SQL:** [schema.sql](schema.sql). This module is assembled into the versioned Supabase migration by `database/scripts/build_migration.py`. Do not run this file separately after applying the bundled migration.

One authenticated user's academic profile, using the exact field names in `schemas.py` (`country`, `academic_level`, `course_of_study`, `cgpa`, `cgpa_scale`, etc.). The frontend must explicitly create a profile after login; there is no privileged auth.users trigger.

**Access policy:** Signed-in users may read, create, update and delete only their own profile. Guests cannot access.

When changing this module, add a *new* timestamped migration for the change after the initial deployment, and keep this module as a current-schema reference. Do not edit already-applied migration files or drop production tables to fix a deployment.
