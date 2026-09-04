#!/usr/bin/env python3
"""Merge metadata triage + Studio quarantine report into a canonical review draft."""

from __future__ import annotations

import argparse
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


def now_iso() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def load(path: str) -> Any:
    return json.loads(Path(path).read_text(encoding="utf-8"))


def first_entry(payload: Any) -> dict[str, Any]:
    if isinstance(payload, dict):
        entries = payload.get("entries")
        if isinstance(entries, list) and entries and isinstance(entries[0], dict):
            return entries[0]
        return payload
    raise ValueError("expected JSON object")


def build_record(asset_id: int, source_url: str, creator: str, triage: dict[str, Any], studio: dict[str, Any]) -> dict[str, Any]:
    counts = studio.get("counts", {}) if isinstance(studio.get("counts"), dict) else {}
    return {
        "schemaVersion": 1,
        "assetId": asset_id,
        "sourceUrl": source_url,
        "creator": creator,
        "capturedAt": now_iso(),
        "metadataTriage": {
            "status": triage.get("triageStatus", "UNKNOWN"),
            "riskScore": triage.get("riskScore"),
            "reasons": triage.get("reasons", []),
        },
        "studioAudit": {
            "placeIsQuarantineOnly": True,
            "scriptsDisabledBeforeInspection": counts.get("baseScriptsDisabled", 0) > 0 or (
                counts.get("scripts", 0) == 0 and counts.get("localScripts", 0) == 0
            ),
            "descendantCount": counts.get("totalDescendants"),
            "classHistogram": counts.get("classes", {}),
            "scriptCount": counts.get("scripts"),
            "localScriptCount": counts.get("localScripts"),
            "moduleScriptCount": counts.get("moduleScripts"),
            "suspiciousSourceFindings": studio.get("scriptFindings", []),
            "assetDependencies": studio.get("assetDependencies", []),
            "meshPartCount": counts.get("meshParts"),
            "partCount": counts.get("parts"),
            "particleEmitterCount": counts.get("particleEmitters"),
            "soundCount": counts.get("sounds"),
            "animationCount": counts.get("animations"),
            "pivotOkay": None,
            "collisionOkay": None,
            "rigOkay": None,
            "unexpectedOriginParts": None,
            "warnings": studio.get("warnings", []),
        },
        "visualReview": {
            "screenshots": [],
            "silhouette": None,
            "materialQuality": None,
            "styleFit": None,
            "scaleFit": None,
            "readabilityNear": None,
            "readabilityFar": None,
            "notes": [],
        },
        "productionFit": {
            "mobileMeasured": False,
            "repetitionCountTested": None,
            "streamingTested": False,
            "pathfindingTested": False,
            "combatCameraTested": False,
            "vfxWorstCaseTested": False,
            "performanceNotes": [],
        },
        "decision": {
            "grade": "PENDING",
            "allowedUse": [],
            "requiredModifications": [],
            "sourceAttributionRecord": None,
            "reviewer": None,
            "reviewedAt": None,
        },
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--asset-id", type=int, required=True)
    parser.add_argument("--source-url", required=True)
    parser.add_argument("--creator", required=True)
    parser.add_argument("--triage", required=True)
    parser.add_argument("--studio-audit", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    triage = first_entry(load(args.triage))
    studio = first_entry(load(args.studio_audit))
    record = build_record(args.asset_id, args.source_url, args.creator, triage, studio)
    out = Path(args.output)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(record, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"wrote canonical audit draft -> {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
