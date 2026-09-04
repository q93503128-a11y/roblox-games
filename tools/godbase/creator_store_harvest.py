#!/usr/bin/env python3
"""Harvest Creator Store metadata into deterministic Godbase snapshots.

No third-party dependencies. Never downloads/executes asset contents.
Authentication is read from ROBLOX_OPEN_CLOUD_API_KEY only.

Current Roblox Creator Docs expose:
  /toolbox-service/v2/assets:search
  /toolbox-service/v2/assets/{id}
with creator-store-product:read scope.

The checked-in creator-docs OpenAPI still documents GET search while the live
reference recommends POST. This client supports both. `auto` tries POST first
and falls back to GET only for method/shape failures; callers should keep this
script pinned to a verified API contract.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

BASE = "https://apis.roblox.com"
SEARCH_PATH = "/toolbox-service/v2/assets:search"
DETAIL_PATH = "/toolbox-service/v2/assets/{id}"
API_KEY_ENV = "ROBLOX_OPEN_CLOUD_API_KEY"
ALLOWED_CATEGORIES = {"Audio", "Model", "Decal", "Plugin", "MeshPart", "Video", "FontFamily"}
ALLOWED_SORTS = {"Relevance", "Trending", "Top", "AudioDuration", "CreateTime", "UpdatedTime", "Ratings"}
ALLOWED_VIEWS = {"IDs", "Core", "Full"}


def now_iso() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def dump_json(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def request_json(method: str, path: str, params: dict[str, Any] | None = None, *, retries: int = 4) -> Any:
    query = urllib.parse.urlencode([(k, item) for k, value in (params or {}).items() if value is not None for item in (value if isinstance(value, list) else [value])])
    url = BASE + path + (("?" + query) if query else "")
    headers = {"Accept": "application/json", "User-Agent": "roblox-godbase-harvester/1"}
    key = os.getenv(API_KEY_ENV)
    if key:
        headers["x-api-key"] = key

    data = b"{}" if method.upper() == "POST" else None
    if data is not None:
        headers["Content-Type"] = "application/json"

    last: Exception | None = None
    for attempt in range(retries):
        try:
            req = urllib.request.Request(url, data=data, headers=headers, method=method.upper())
            with urllib.request.urlopen(req, timeout=30) as response:
                return json.loads(response.read().decode("utf-8"))
        except urllib.error.HTTPError as exc:
            body = exc.read().decode("utf-8", errors="replace")
            last = RuntimeError(f"HTTP {exc.code} {method} {url}: {body[:1000]}")
            if exc.code == 429 or 500 <= exc.code < 600:
                time.sleep(min(8, 2 ** attempt))
                continue
            raise last
        except (urllib.error.URLError, TimeoutError) as exc:
            last = exc
            time.sleep(min(8, 2 ** attempt))
    raise RuntimeError(f"request failed after {retries} attempts: {last}")


def search_assets(params: dict[str, Any], method: str) -> Any:
    if method == "get":
        return request_json("GET", SEARCH_PATH, params)
    if method == "post":
        return request_json("POST", SEARCH_PATH, params)
    try:
        return request_json("POST", SEARCH_PATH, params)
    except RuntimeError as exc:
        text = str(exc)
        if not any(code in text for code in ("HTTP 400", "HTTP 404", "HTTP 405")):
            raise
        print(f"POST search unavailable/shape mismatch; falling back to GET: {text[:240]}", file=sys.stderr)
        return request_json("GET", SEARCH_PATH, params)


def asset_details(asset_id: int) -> Any:
    return request_json("GET", DETAIL_PATH.format(id=asset_id))


def extract_assets(payload: Any) -> list[dict[str, Any]]:
    if isinstance(payload, dict):
        for key in ("assets", "data", "results", "items"):
            value = payload.get(key)
            if isinstance(value, list):
                return [x for x in value if isinstance(x, dict)]
    return []


def extract_next_token(payload: Any) -> str | None:
    if not isinstance(payload, dict):
        return None
    for key in ("nextPageToken", "nextPageCursor", "nextCursor", "pageToken"):
        value = payload.get(key)
        if isinstance(value, str) and value:
            return value
    return None


def extract_id(item: dict[str, Any]) -> int | None:
    for key in ("id", "assetId", "asset_id"):
        value = item.get(key)
        if isinstance(value, int):
            return value
        if isinstance(value, str) and value.isdigit():
            return int(value)
    asset = item.get("asset")
    if isinstance(asset, dict):
        return extract_id(asset)
    return None


def validated_params(args: argparse.Namespace) -> dict[str, Any]:
    if args.category not in ALLOWED_CATEGORIES:
        raise SystemExit(f"invalid category {args.category}; choose {sorted(ALLOWED_CATEGORIES)}")
    if args.sort not in ALLOWED_SORTS:
        raise SystemExit(f"invalid sort {args.sort}; choose {sorted(ALLOWED_SORTS)}")
    if args.view not in ALLOWED_VIEWS:
        raise SystemExit(f"invalid view {args.view}; choose {sorted(ALLOWED_VIEWS)}")
    if not 1 <= args.page_size <= 100:
        raise SystemExit("--page-size must be 1..100")
    if args.user_id and args.group_id:
        raise SystemExit("only one of --user-id and --group-id may be used")

    return {
        "searchCategoryType": args.category,
        "query": args.query,
        "maxPageSize": args.page_size,
        "sortCategory": args.sort,
        "sortDirection": args.direction,
        "includeOnlyVerifiedCreators": str(args.verified_only).lower(),
        "searchView": args.view,
        "minPriceCents": args.min_price,
        "maxPriceCents": args.max_price,
        "userId": args.user_id,
        "groupId": args.group_id,
        "includedInstanceTypes": args.instance_type or None,
        "facets": args.facet or None,
        "categoryPath": args.category_path,
    }


def cmd_search(args: argparse.Namespace) -> int:
    params = validated_params(args)
    out = Path(args.output)
    pages: list[dict[str, Any]] = []
    ids: list[int] = []
    seen: set[int] = set()
    token: str | None = None

    for page_index in range(args.pages):
        page_params = dict(params)
        if token:
            page_params["pageToken"] = token
        else:
            page_params["pageNumber"] = page_index
        payload = search_assets(page_params, args.method)
        assets = extract_assets(payload)
        pages.append({"page": page_index, "request": page_params, "response": payload})
        for item in assets:
            asset_id = extract_id(item)
            if asset_id is not None and asset_id not in seen:
                seen.add(asset_id)
                ids.append(asset_id)
        token = extract_next_token(payload)
        if not assets or (page_index > 0 and not token and len(assets) < args.page_size):
            break
        if args.sleep:
            time.sleep(args.sleep)

    snapshot = {
        "schemaVersion": 1,
        "capturedAt": now_iso(),
        "endpoint": SEARCH_PATH,
        "methodPreference": args.method,
        "query": params,
        "assetIds": ids,
        "pages": pages,
    }
    dump_json(out, snapshot)
    print(f"wrote {len(ids)} unique asset IDs to {out}")
    return 0


def cmd_details(args: argparse.Namespace) -> int:
    ids = [int(x) for x in args.asset_id]
    results = []
    for asset_id in ids:
        results.append({"assetId": asset_id, "details": asset_details(asset_id)})
        if args.sleep:
            time.sleep(args.sleep)
    dump_json(Path(args.output), {"schemaVersion": 1, "capturedAt": now_iso(), "endpoint": DETAIL_PATH, "assets": results})
    print(f"wrote {len(results)} detail records to {args.output}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)

    search = sub.add_parser("search", help="search Creator Store metadata")
    search.add_argument("--category", required=True)
    search.add_argument("--query", default="")
    search.add_argument("--page-size", type=int, default=25)
    search.add_argument("--pages", type=int, default=1)
    search.add_argument("--sort", default="Relevance")
    search.add_argument("--direction", default="None", choices=["None", "Ascending", "Descending"])
    search.add_argument("--view", default="Full")
    search.add_argument("--verified-only", action=argparse.BooleanOptionalAction, default=True)
    search.add_argument("--min-price", type=int, default=0)
    search.add_argument("--max-price", type=int)
    search.add_argument("--user-id", type=int)
    search.add_argument("--group-id", type=int)
    search.add_argument("--instance-type", action="append")
    search.add_argument("--facet", action="append")
    search.add_argument("--category-path")
    search.add_argument("--method", choices=["auto", "post", "get"], default="auto")
    search.add_argument("--sleep", type=float, default=0.15)
    search.add_argument("--output", required=True)
    search.set_defaults(func=cmd_search)

    details = sub.add_parser("details", help="fetch details for known asset IDs")
    details.add_argument("--asset-id", action="append", required=True)
    details.add_argument("--sleep", type=float, default=0.15)
    details.add_argument("--output", required=True)
    details.set_defaults(func=cmd_details)
    return parser


def main() -> int:
    args = build_parser().parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
