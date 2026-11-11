# 50 eligibility assessments

**Canonical SQL:** [schema.sql](schema.sql). This module is assembled into the versioned Supabase migration by `database/scripts/build_migration.py`. Do not run this file separately after applying the bundled migration.

Immutable eligibility snapshots using the existing Pydantic `EligibilityAssessment` contract. App saves new snapshots rather than updating past decisions.

**Access policy:** Signed-in users may store an assessment of a visible opportunity and read/delete only their own history.

When changing this module, add a *new* timestamped migration for the change after the initial deployment, and keep this module as a current-schema reference. Do not edit already-applied migration files or drop production tables to fix a deployment.
