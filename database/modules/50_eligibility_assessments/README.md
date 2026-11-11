# 50 eligibility assessments

**Canonical SQL:** [schema.sql](schema.sql). This module is assembled into the versioned Supabase migration by `database/scripts/build_migration.py`. Do not run this file separately after applying the bundled migration.

Immutable eligibility snapshots using the existing Pydantic `EligibilityAssessment` contract. App saves new snapshots rather than updating past decisions.

**Access policy:** Signed-in users may store an assessment of a visible opportunity and read/delete only their own history.

This file documents the **immutable initial baseline**. Once the initial migration has been applied, do not edit this SQL or its bundled migration. For future changes to this table/function, create a new versioned file in `supabase/migrations/` and a focused note under `database/changes/<version>/<table>/` instead. See `database/changes/README.md`. Never drop production data to correct a migration.
