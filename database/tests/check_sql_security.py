#!/usr/bin/env python3
"""Static safety checks; runtime RLS must also be tested against actual Supabase."""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[2]
MIGRATION = (ROOT / "supabase/migrations/20261111220000_opportunitylens_database_foundation.sql").read_text()
TABLES = [
    "student_profiles", "opportunity_sources", "opportunities",
    "saved_opportunities", "eligibility_assessments", "applications",
    "application_checklist_items",
]

class SchemaSecurityTests(unittest.TestCase):
    def test_every_exposed_table_has_rls(self):
        for name in TABLES:
            with self.subTest(name=name):
                self.assertRegex(MIGRATION, rf"alter table public\.{name} enable row level security;")

    def test_ownership_policies_cover_inserts(self):
        for name in TABLES:
            if name == "opportunity_sources":
                continue
            with self.subTest(name=name):
                section = MIGRATION.split(f"create table public.{name} (", 1)[1]
                section = section.split("-- END database/modules/", 1)[0]
                self.assertIn("for insert to authenticated", section)
                self.assertIn("auth.uid()", section)

    def test_no_anonymous_writes(self):
        self.assertNotRegex(MIGRATION, r"(?i)grant\s+(?:all|insert|update|delete)\b[^;]*\bto\s+anon\b")

    def test_no_public_definer_functions(self):
        self.assertNotIn("security definer", MIGRATION.lower())
        self.assertNotRegex(MIGRATION, r"(?i)create function public\.")

    def test_private_opportunities_cannot_self_publish(self):
        section = MIGRATION.split("create table public.opportunities (", 1)[1]
        section = section.split("-- END database/modules/", 1)[0]
        self.assertIn("visibility = 'private' and verified_at is null", section)

    def test_checklist_cannot_attach_to_other_owner(self):
        self.assertIn("foreign key (application_id, user_id)", MIGRATION)
        self.assertIn("references public.applications(id, user_id)", MIGRATION)

if __name__ == "__main__":
    unittest.main()
