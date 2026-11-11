#!/usr/bin/env python3
"""Reproduce/check the initial bundled migration from per-table SQL modules.

After the migration is applied to a shared/production project, DO NOT regenerate
that historical file; create a new versioned migration for any future change.
"""
from pathlib import Path
import argparse

ROOT = Path(__file__).resolve().parents[2]
MODULES = ROOT / "database" / "modules"
TARGET = ROOT / "supabase" / "migrations" / "20261111220000_opportunitylens_database_foundation.sql"
HEADER = "-- GENERATED FROM database/modules/*/schema.sql\n-- DO NOT EDIT: change source modules before first deployment, then generate a NEW migration for future changes.\n-- Run database/scripts/build_migration.py --check to verify this snapshot.\n\n"

def build():
    paths = sorted(MODULES.glob("*/schema.sql"))
    if len(paths) != 8:
        raise RuntimeError(f"Expected eight SQL modules, found {len(paths)}")
    blocks = []
    for path in paths:
        rel = path.relative_to(ROOT).as_posix()
        blocks.append(f"-- BEGIN {rel}\n{path.read_text().rstrip()}\n-- END {rel}\n\n")
    return HEADER + "".join(blocks)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="Do not write; fail if files differ")
    args = parser.parse_args()
    actual = build()
    if args.check:
        if TARGET.read_text() != actual:
            raise SystemExit("Bundled migration differs from source modules.")
        print("Migration matches all eight source modules.")
    else:
        TARGET.parent.mkdir(parents=True, exist_ok=True)
        TARGET.write_text(actual)
        print("Updated:", TARGET)

if __name__ == "__main__":
    main()
