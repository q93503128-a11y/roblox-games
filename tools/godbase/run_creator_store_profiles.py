#!/usr/bin/env python3
"""Run Godbase Creator Store search profiles as a reproducible batch.

The runner delegates network access to creator_store_harvest.py and cheap risk
triage to creator_store_metadata_score.py. It never downloads asset binaries and
never inserts assets into Studio.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_PROFILES = ROOT / "knowledge/assets/CREATOR_STORE_SEARCH_PROFILES.json"
HARVESTER = ROOT / "tools/godbase/creator_store_harvest.py"
TRIAGE = ROOT / "tools/godbase/creator_store_metadata_score.py"


def stamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")


def load_profiles(path: Path) -> dict[str, Any]:
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data.get("profiles"), list):
        raise ValueError("profile file must contain a profiles array")
    return data


def build_search_command(profile: dict[str, Any], defaults: dict[str, Any], output: Path, method: str) -> list[str]:
    category = profile.get("searchCategoryType")
    if not isinstance(category, str) or not category:
        raise ValueError(f"profile missing searchCategoryType: {profile}")
    query = profile.get("query", "")
    pages = int(profile.get("pages", 1))
    page_size = int(profile.get("maxPageSize", defaults.get("maxPageSize", 100)))
    sort = str(profile.get("sortCategory", defaults.get("sortCategory", "Ratings")))
    direction = str(profile.get("sortDirection", defaults.get("sortDirection", "Descending")))
    view = str(profile.get("searchView", defaults.get("searchView", "Full")))
    verified = bool(profile.get("includeOnlyVerifiedCreators", defaults.get("includeOnlyVerifiedCreators", True)))

    cmd = [
        sys.executable,
        str(HARVESTER),
        "search",
        "--category", category,
        "--query", str(query),
        "--page-size", str(page_size),
        "--pages", str(pages),
        "--sort", sort,
        "--direction", direction,
        "--view", view,
        "--method", method,
        "--output", str(output),
    ]
    cmd.append("--verified-only" if verified else "--no-verified-only")

    for name, flag in (("minPriceCents", "--min-price"), ("maxPriceCents", "--max-price"), ("userId", "--user-id"), ("groupId", "--group-id")):
        value = profile.get(name, defaults.get(name))
        if value is not None:
            cmd.extend([flag, str(value)])
    for value in profile.get("includedInstanceTypes", []):
        cmd.extend(["--instance-type", str(value)])
    for value in profile.get("facets", []):
        cmd.extend(["--facet", str(value)])
    category_path = profile.get("categoryPath")
    if category_path:
        cmd.extend(["--category-path", str(category_path)])
    return cmd


def selected_profiles(data: dict[str, Any], requested: set[str]) -> list[dict[str, Any]]:
    profiles = [p for p in data["profiles"] if isinstance(p, dict)]
    if not requested:
        return profiles
    found = {str(p.get("id")) for p in profiles}
    missing = requested - found
    if missing:
        raise ValueError(f"unknown profile IDs: {sorted(missing)}")
    return [p for p in profiles if str(p.get("id")) in requested]


def run_checked(cmd: list[str], dry_run: bool) -> None:
    print("$ " + " ".join(cmd))
    if not dry_run:
        subprocess.run(cmd, check=True)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--profiles", default=str(DEFAULT_PROFILES))
    parser.add_argument("--profile", action="append", default=[], help="profile ID; repeat to select a subset")
    parser.add_argument("--output-dir", default=None)
    parser.add_argument("--method", choices=["auto", "post", "get"], default="auto")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    profile_path = Path(args.profiles)
    data = load_profiles(profile_path)
    defaults = data.get("defaults", {}) if isinstance(data.get("defaults"), dict) else {}
    profiles = selected_profiles(data, set(args.profile))
    batch_dir = Path(args.output_dir) if args.output_dir else ROOT / "tmp/godbase/creator-store" / stamp()
    batch_dir.mkdir(parents=True, exist_ok=True)

    manifest: dict[str, Any] = {
        "schemaVersion": 1,
        "profileSource": str(profile_path),
        "batchDir": str(batch_dir),
        "dryRun": args.dry_run,
        "profiles": [],
    }

    for profile in profiles:
        profile_id = str(profile.get("id", "unnamed"))
        profile_dir = batch_dir / profile_id
        profile_dir.mkdir(parents=True, exist_ok=True)
        search_out = profile_dir / "search.json"
        triage_out = profile_dir / "triage.json"
        search_cmd = build_search_command(profile, defaults, search_out, args.method)
        run_checked(search_cmd, args.dry_run)
        triage_cmd = [sys.executable, str(TRIAGE), str(search_out), "--output", str(triage_out)]
        if not args.dry_run:
            run_checked(triage_cmd, False)
        else:
            print("$ " + " ".join(triage_cmd))
        manifest["profiles"].append({
            "id": profile_id,
            "role": profile.get("role"),
            "search": str(search_out),
            "triage": str(triage_out),
        })

    manifest_path = batch_dir / "batch-manifest.json"
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"batch manifest -> {manifest_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
