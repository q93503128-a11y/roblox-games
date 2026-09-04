#!/usr/bin/env python3
"""Promote a fully-reviewed Creator Store audit into a supply-catalog proposal.

The tool never edits GitHub and never auto-grades an asset. It only accepts a
review record whose human/AI review already assigned S or A and whose hard gates
are complete. Output should be reviewed/diffed before replacing the canonical
catalog.
"""

from __future__ import annotations

import argparse
import json
from datetime import date
from pathlib import Path
from typing import Any

ALLOWED_GRADES = {"S", "A"}


def load(path: str | Path) -> dict[str, Any]:
    value = json.loads(Path(path).read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise ValueError(f"expected JSON object: {path}")
    return value


def require(condition: bool, message: str, errors: list[str]) -> None:
    if not condition:
        errors.append(message)


def validate_review(review: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    decision = review.get("decision") if isinstance(review.get("decision"), dict) else {}
    meta = review.get("metadataTriage") if isinstance(review.get("metadataTriage"), dict) else {}
    studio = review.get("studioAudit") if isinstance(review.get("studioAudit"), dict) else {}
    visual = review.get("visualReview") if isinstance(review.get("visualReview"), dict) else {}
    prod = review.get("productionFit") if isinstance(review.get("productionFit"), dict) else {}

    grade = decision.get("grade")
    require(grade in ALLOWED_GRADES, "decision.grade must be S or A", errors)
    require(isinstance(review.get("assetId"), int), "assetId must be an integer", errors)
    require(bool(review.get("sourceUrl")), "sourceUrl is required", errors)
    require(bool(review.get("creator")), "creator is required", errors)
    require(bool(decision.get("reviewer")), "decision.reviewer is required", errors)
    require(bool(decision.get("reviewedAt")), "decision.reviewedAt is required", errors)
    require(bool(decision.get("sourceAttributionRecord")), "decision.sourceAttributionRecord is required", errors)

    status = str(meta.get("status", ""))
    require(not status.startswith("REJECT"), f"metadata triage is rejected: {status}", errors)
    require(studio.get("placeIsQuarantineOnly") is True, "Studio audit must come from a quarantine place", errors)
    require(studio.get("scriptsDisabledBeforeInspection") is True, "scripts must be disabled before inspection", errors)
    require(not studio.get("suspiciousSourceFindings"), "unresolved suspicious source findings remain", errors)
    require(isinstance(studio.get("assetDependencies"), list), "assetDependencies must be recorded", errors)
    require(studio.get("pivotOkay") is True, "pivot review must pass", errors)
    require(studio.get("collisionOkay") is True, "collision review must pass", errors)
    require(studio.get("unexpectedOriginParts") is False, "unexpected origin parts must be cleared", errors)

    for key in ("silhouette", "materialQuality", "styleFit", "scaleFit", "readabilityNear", "readabilityFar"):
        require(visual.get(key) is not None, f"visualReview.{key} is required", errors)
    require(bool(visual.get("screenshots")), "visualReview.screenshots must contain evidence", errors)

    # S means fully proven for intended production role. A may intentionally skip
    # irrelevant checks, but must explicitly record performance notes.
    if grade == "S":
        require(prod.get("mobileMeasured") is True, "S grade requires mobile measurement", errors)
        require(prod.get("streamingTested") is True, "S grade requires Streaming test", errors)
        require(prod.get("repetitionCountTested") is not None, "S grade requires repetition-count test", errors)
    else:
        require(bool(prod.get("performanceNotes")), "A grade requires explicit production-fit/performance notes", errors)

    return errors


def promotion_entry(review: dict[str, Any]) -> dict[str, Any]:
    decision = review["decision"]
    visual = review["visualReview"]
    studio = review["studioAudit"]
    prod = review["productionFit"]
    grade = decision["grade"]
    return {
        "assetId": review["assetId"],
        "name": decision.get("catalogName") or review.get("name") or f"Asset {review['assetId']}",
        "creator": review["creator"],
        "category": decision.get("categories", []),
        "status": f"AUDITED_{grade}",
        "audit": {
            "reviewedAt": decision["reviewedAt"],
            "reviewer": decision["reviewer"],
            "sourceAttributionRecord": decision["sourceAttributionRecord"],
            "styleFit": visual.get("styleFit"),
            "descendants": studio.get("descendantCount"),
            "scripts": (studio.get("scriptCount") or 0) + (studio.get("localScriptCount") or 0) + (studio.get("moduleScriptCount") or 0),
            "mobileMeasured": prod.get("mobileMeasured"),
            "repetitionCountTested": prod.get("repetitionCountTested"),
        },
        "strengths": decision.get("strengths", []),
        "cautions": decision.get("requiredModifications", []),
        "allowedUse": decision.get("allowedUse", []),
        "source": review["sourceUrl"],
    }


def update_catalog(catalog: dict[str, Any], review: dict[str, Any]) -> dict[str, Any]:
    errors = validate_review(review)
    if errors:
        raise ValueError("review is not promotable:\n- " + "\n- ".join(errors))
    entries = catalog.get("entries")
    if not isinstance(entries, list):
        raise ValueError("catalog.entries must be an array")
    entry = promotion_entry(review)
    asset_id = entry["assetId"]
    replaced = False
    new_entries: list[Any] = []
    for old in entries:
        if isinstance(old, dict) and old.get("assetId") == asset_id:
            if not replaced:
                new_entries.append(entry)
                replaced = True
        else:
            new_entries.append(old)
    if not replaced:
        new_entries.append(entry)
    catalog = dict(catalog)
    catalog["entries"] = new_entries
    legend = dict(catalog.get("statusLegend", {}))
    legend["AUDITED_S"] = "Fully audited production-grade asset for recorded allowed use; revalidate when project/runtime assumptions change"
    legend["AUDITED_A"] = "Audited strong asset with explicit modifications/conditions before or during production use"
    catalog["statusLegend"] = legend
    catalog["verifiedDate"] = date.today().isoformat()
    return catalog


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--review", required=True)
    parser.add_argument("--catalog", default="knowledge/assets/CREATOR_STORE_SUPPLY_CATALOG.json")
    parser.add_argument("--output", required=True)
    args = parser.parse_args()
    catalog = load(args.catalog)
    review = load(args.review)
    try:
        result = update_catalog(catalog, review)
    except ValueError as exc:
        raise SystemExit(str(exc))
    out = Path(args.output)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"promotion proposal written -> {out}")
    print("Review the diff before replacing the canonical catalog.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
