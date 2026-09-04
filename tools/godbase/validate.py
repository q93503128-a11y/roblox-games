#!/usr/bin/env python3
"""Validate the Roblox Godbase without third-party dependencies."""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
KNOWLEDGE = ROOT / "knowledge"
MANIFEST = KNOWLEDGE / "GODBASE_MANIFEST.json"

errors: list[str] = []
warnings: list[str] = []


def fail(message: str) -> None:
    errors.append(message)


def warn(message: str) -> None:
    warnings.append(message)


def collect_paths(value):
    if isinstance(value, dict):
        for child in value.values():
            yield from collect_paths(child)
    elif isinstance(value, list):
        for child in value:
            yield from collect_paths(child)
    elif isinstance(value, str) and value.startswith(("knowledge/", "tools/", ".github/")):
        yield value


if not MANIFEST.exists():
    fail("missing knowledge/GODBASE_MANIFEST.json")
    manifest = {}
else:
    try:
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    except Exception as exc:
        fail(f"manifest JSON invalid: {exc}")
        manifest = {}

# Every local path routed by the manifest must exist. This covers both canonical
# knowledge and executable/tooling paths so documentation cannot point to a
# missing automation component.
for rel in sorted(set(collect_paths(manifest))):
    if not (ROOT / rel).exists():
        fail(f"manifest references missing path: {rel}")

# Every JSON knowledge artifact must parse.
json_files = sorted(KNOWLEDGE.rglob("*.json")) if KNOWLEDGE.exists() else []
for path in json_files:
    try:
        json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:
        fail(f"invalid JSON {path.relative_to(ROOT)}: {exc}")

# Markdown should never be empty; freshness markers are warnings so historical
# docs do not break CI merely because their wording differs.
md_files = sorted(KNOWLEDGE.rglob("*.md")) if KNOWLEDGE.exists() else []
for path in md_files:
    text = path.read_text(encoding="utf-8").strip()
    rel = path.relative_to(ROOT)
    if len(text) < 80:
        fail(f"knowledge document suspiciously empty: {rel}")
    freshness_tokens = ("verified:", "검증 기준일", "established:", "started:", "검증일")
    if not any(token.lower() in text.lower() for token in freshness_tokens):
        warn(f"no explicit freshness marker: {rel}")

# Basic schema checks for catalogs/manifest.
if manifest:
    if not isinstance(manifest.get("schemaVersion"), int):
        fail("GODBASE_MANIFEST schemaVersion must be an integer")
    if manifest.get("status") != "ACTIVE_CANONICAL_NOT_COMPLETE":
        warn("manifest status is not ACTIVE_CANONICAL_NOT_COMPLETE")

catalog_dir = KNOWLEDGE / "catalogs"
for path in sorted(catalog_dir.glob("*.json")) if catalog_dir.exists() else []:
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data.get("schemaVersion"), int):
        fail(f"catalog missing integer schemaVersion: {path.relative_to(ROOT)}")

print(f"Godbase: {len(md_files)} markdown docs, {len(json_files)} JSON files")
for message in warnings:
    print(f"WARNING: {message}")

if errors:
    for message in errors:
        print(f"ERROR: {message}", file=sys.stderr)
    sys.exit(1)

print("Godbase validation passed")
