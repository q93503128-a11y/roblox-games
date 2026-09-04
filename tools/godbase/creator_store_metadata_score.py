#!/usr/bin/env python3
"""Heuristic triage for Creator Store metadata snapshots.

This is NOT a security scanner and never promotes an asset to production-ready.
It converts cheap metadata signals into a quarantine priority so Studio audits
can spend time on the highest-value candidates first.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any, Iterable

RISK_KEYWORDS = {
    "backdoor": 100,
    "virus": 100,
    "malware": 100,
    "logger": 90,
    "steal": 60,
    "stolen": 60,
    "reupload": 35,
    "reuploaded": 35,
    "broken": 20,
    "deleted texture": 30,
    "removed texture": 30,
}
SPAM_TOKENS = {
    "brookhaven", "blox fruits", "doors", "adopt me", "pet simulator",
    "murder mystery", "anime defenders", "toilet tower", "dress to impress",
}


def walk(value: Any) -> Iterable[tuple[str, Any]]:
    if isinstance(value, dict):
        for key, child in value.items():
            yield key, child
            yield from walk(child)
    elif isinstance(value, list):
        for child in value:
            yield from walk(child)


def number_by_keys(value: Any, *keys: str) -> float | None:
    wanted = {k.lower() for k in keys}
    for key, child in walk(value):
        if key.lower() in wanted and isinstance(child, (int, float)):
            return float(child)
    return None


def bool_by_keys(value: Any, *keys: str) -> bool | None:
    wanted = {k.lower() for k in keys}
    for key, child in walk(value):
        if key.lower() in wanted and isinstance(child, bool):
            return child
    return None


def text_blob(value: Any) -> str:
    parts: list[str] = []
    if isinstance(value, dict):
        for _, child in value.items():
            if isinstance(child, str):
                parts.append(child)
            else:
                parts.append(text_blob(child))
    elif isinstance(value, list):
        for child in value:
            parts.append(text_blob(child))
    return " ".join(parts).lower()


def asset_id(value: Any) -> int | None:
    for key, child in walk(value):
        if key.lower() in {"assetid", "asset_id", "id"}:
            if isinstance(child, int):
                return child
            if isinstance(child, str) and child.isdigit():
                return int(child)
    return None


def score_record(record: dict[str, Any]) -> dict[str, Any]:
    text = text_blob(record)
    reasons: list[str] = []
    hard_reject = False
    risk = 0

    for word, weight in RISK_KEYWORDS.items():
        if word in text:
            risk += weight
            reasons.append(f"text-risk:{word}")
            if word in {"backdoor", "virus", "malware", "logger"}:
                hard_reject = True

    spam_hits = sorted(token for token in SPAM_TOKENS if token in text)
    if len(spam_hits) >= 3:
        risk += 50
        reasons.append(f"discovery-keyword-spam:{','.join(spam_hits[:6])}")

    scripts = number_by_keys(record, "scriptCount", "scripts", "numberOfScripts")
    if scripts is not None:
        if scripts >= 50:
            risk += 55
            reasons.append(f"very-large-script-surface:{int(scripts)}")
        elif scripts >= 20:
            risk += 35
            reasons.append(f"large-script-surface:{int(scripts)}")
        elif scripts >= 4:
            risk += 15
            reasons.append(f"scripted-kit:{int(scripts)}")

    triangles = number_by_keys(record, "triangleCount", "triangles", "numberOfTriangles")
    meshes = number_by_keys(record, "meshPartCount", "meshParts", "numberOfMeshParts")
    if triangles is not None and triangles >= 500_000:
        risk += 20
        reasons.append(f"huge-geometry-source:{int(triangles)}")
    if meshes is not None and meshes >= 750:
        risk += 20
        reasons.append(f"huge-mesh-library:{int(meshes)}")

    verified = bool_by_keys(record, "isVerifiedCreator", "verifiedCreator", "creatorVerified")
    if verified is True:
        reasons.append("verified-creator-signal")
        risk = max(0, risk - 5)

    # Metadata can reject/hold but cannot prove clean code, provenance or visual fit.
    if hard_reject:
        status = "REJECT_METADATA_RED_FLAG"
    elif risk >= 60:
        status = "QUARANTINE_HIGH"
    elif risk >= 30:
        status = "QUARANTINE_MEDIUM"
    else:
        status = "QUARANTINE_NORMAL"

    return {
        "assetId": asset_id(record),
        "triageStatus": status,
        "riskScore": risk,
        "reasons": reasons,
        "requiresStudioAudit": True,
        "productionReady": False,
        "raw": record,
    }


def extract_records(payload: Any) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    if isinstance(payload, dict):
        if isinstance(payload.get("assets"), list):
            records.extend(x for x in payload["assets"] if isinstance(x, dict))
        if isinstance(payload.get("pages"), list):
            for page in payload["pages"]:
                if not isinstance(page, dict):
                    continue
                response = page.get("response")
                if isinstance(response, dict):
                    for key in ("assets", "data", "results", "items"):
                        value = response.get(key)
                        if isinstance(value, list):
                            records.extend(x for x in value if isinstance(x, dict))
                            break
        if not records and any(k in payload for k in ("id", "assetId", "asset_id")):
            records.append(payload)
    elif isinstance(payload, list):
        records.extend(x for x in payload if isinstance(x, dict))
    return records


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input")
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    source = json.loads(Path(args.input).read_text(encoding="utf-8"))
    scored = [score_record(record) for record in extract_records(source)]
    result = {
        "schemaVersion": 1,
        "source": args.input,
        "policy": "metadata triage only; Studio quarantine is mandatory before promotion",
        "entries": scored,
    }
    Path(args.output).parent.mkdir(parents=True, exist_ok=True)
    Path(args.output).write_text(json.dumps(result, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"triaged {len(scored)} Creator Store records -> {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
