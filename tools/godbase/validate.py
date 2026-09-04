#!/usr/bin/env python3
"""Validate the Roblox Godbase without third-party dependencies."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
KNOWLEDGE = ROOT / "knowledge"
MANIFEST = KNOWLEDGE / "GODBASE_MANIFEST.json"

errors: list[str] = []
warnings: list[str] = []

LOCAL_PREFIXES = ("knowledge/", "tools/", ".github/")
LOCAL_EXTENSIONS = (".md", ".json", ".py", ".luau", ".yml", ".yaml")
MARKDOWN_LINK_RE = re.compile(r"\]\(([^)]+)\)")
INLINE_LOCAL_RE = re.compile(
    r"`((?:(?:\.\./)+|\./|knowledge/|tools/|\.github/)[^`\s]+(?:\.md|\.json|\.py|\.luau|\.yml|\.yaml)(?:#[^`\s]+)?)`"
)


def fail(message: str) -> None:
    errors.append(message)


def warn(message: str) -> None:
    warnings.append(message)


def collect_root_paths(value: Any):
    if isinstance(value, dict):
        for child in value.values():
            yield from collect_root_paths(child)
    elif isinstance(value, list):
        for child in value:
            yield from collect_root_paths(child)
    elif isinstance(value, str) and value.startswith(LOCAL_PREFIXES):
        yield value


def normalize_reference(source: Path, raw: str) -> Path | None:
    value = raw.strip().strip("<>")
    value = value.split("#", 1)[0].split("?", 1)[0]
    if not value or value.startswith(("http://", "https://", "mailto:", "#")):
        return None
    if value.startswith(LOCAL_PREFIXES):
        return ROOT / value
    if value.startswith(("./", "../")):
        return (source.parent / value).resolve()
    return None


def validate_markdown_references(path: Path, text: str) -> None:
    candidates: set[str] = set()
    for match in MARKDOWN_LINK_RE.finditer(text):
        candidates.add(match.group(1).strip())
    for match in INLINE_LOCAL_RE.finditer(text):
        candidates.add(match.group(1).strip())

    for raw in sorted(candidates):
        target = normalize_reference(path, raw)
        if target is None:
            continue
        try:
            target.relative_to(ROOT)
        except ValueError:
            fail(f"markdown reference escapes repository: {path.relative_to(ROOT)} -> {raw}")
            continue
        if not target.exists():
            fail(f"broken local reference: {path.relative_to(ROOT)} -> {raw}")


if not MANIFEST.exists():
    fail("missing knowledge/GODBASE_MANIFEST.json")
    manifest: dict[str, Any] = {}
else:
    try:
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    except Exception as exc:
        fail(f"manifest JSON invalid: {exc}")
        manifest = {}

# Every local path routed by the manifest must exist.
for rel in sorted(set(collect_root_paths(manifest))):
    if not (ROOT / rel).exists():
        fail(f"manifest references missing path: {rel}")

# Every JSON artifact must parse, and every root-relative repository path inside
# it must resolve. This catches machine-readable routing drift outside Manifest.
json_files = sorted(KNOWLEDGE.rglob("*.json")) if KNOWLEDGE.exists() else []
parsed_json: dict[Path, Any] = {}
for path in json_files:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
        parsed_json[path] = data
    except Exception as exc:
        fail(f"invalid JSON {path.relative_to(ROOT)}: {exc}")
        continue
    for rel in sorted(set(collect_root_paths(data))):
        if not (ROOT / rel).exists():
            fail(f"JSON references missing path: {path.relative_to(ROOT)} -> {rel}")

# Markdown must be non-empty and its explicit local links/backtick paths must
# resolve. Freshness markers are warnings for historical documents.
md_files = sorted(KNOWLEDGE.rglob("*.md")) if KNOWLEDGE.exists() else []
for path in md_files:
    text = path.read_text(encoding="utf-8").strip()
    rel = path.relative_to(ROOT)
    if len(text) < 80:
        fail(f"knowledge document suspiciously empty: {rel}")
    freshness_tokens = ("verified:", "검증 기준일", "established:", "started:", "검증일")
    if not any(token.lower() in text.lower() for token in freshness_tokens):
        warn(f"no explicit freshness marker: {rel}")
    validate_markdown_references(path, text)

# Basic manifest/catalog schema checks.
if manifest:
    if not isinstance(manifest.get("schemaVersion"), int):
        fail("GODBASE_MANIFEST schemaVersion must be an integer")
    if manifest.get("status") != "ACTIVE_CANONICAL_NOT_COMPLETE":
        warn("manifest status is not ACTIVE_CANONICAL_NOT_COMPLETE")

catalog_dir = KNOWLEDGE / "catalogs"
for path in sorted(catalog_dir.glob("*.json")) if catalog_dir.exists() else []:
    data = parsed_json.get(path)
    if isinstance(data, dict) and not isinstance(data.get("schemaVersion"), int):
        fail(f"catalog missing integer schemaVersion: {path.relative_to(ROOT)}")

# Genre recipes are a first-class routing surface. Every recipe document must be
# routed exactly through STARTER_RECIPE_MATRIX.json, and each entry needs a
# minimum usable contract.
genre_dir = KNOWLEDGE / "genres"
genre_matrix_path = genre_dir / "STARTER_RECIPE_MATRIX.json"
if genre_matrix_path.exists():
    matrix = parsed_json.get(genre_matrix_path)
    if isinstance(matrix, dict):
        genres = matrix.get("genres")
        if not isinstance(genres, dict) or not genres:
            fail("genre matrix must contain a non-empty genres object")
        else:
            routed_recipes: set[Path] = set()
            for key, entry in genres.items():
                if not isinstance(entry, dict):
                    fail(f"genre entry must be object: {key}")
                    continue
                recipe = entry.get("recipe")
                if not isinstance(recipe, str):
                    fail(f"genre entry missing recipe: {key}")
                else:
                    routed_recipes.add(ROOT / recipe)
                if not isinstance(entry.get("firstSlice"), list) or not entry["firstSlice"]:
                    fail(f"genre entry missing firstSlice: {key}")
                if not isinstance(entry.get("godbase"), list) or not entry["godbase"]:
                    fail(f"genre entry missing godbase routing: {key}")
                if not isinstance(entry.get("qualityGate"), str) or not entry["qualityGate"]:
                    fail(f"genre entry missing qualityGate: {key}")

            recipe_docs = set(genre_dir.glob("*.md")) - {genre_dir / "README.md"}
            unrouted = sorted(recipe_docs - routed_recipes)
            missing_docs = sorted(routed_recipes - recipe_docs)
            for path in unrouted:
                fail(f"genre recipe not routed by matrix: {path.relative_to(ROOT)}")
            for path in missing_docs:
                fail(f"genre matrix routes non-recipe document: {path.relative_to(ROOT)}")

print(f"Godbase: {len(md_files)} markdown docs, {len(json_files)} JSON files")
for message in warnings:
    print(f"WARNING: {message}")

if errors:
    for message in errors:
        print(f"ERROR: {message}", file=sys.stderr)
    sys.exit(1)

print("Godbase validation passed")
