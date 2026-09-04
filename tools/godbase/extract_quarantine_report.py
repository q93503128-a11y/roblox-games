#!/usr/bin/env python3
"""Extract GODBASE_QUARANTINE_AUDIT JSON from Studio/MCP console text."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

BEGIN = "GODBASE_QUARANTINE_AUDIT_BEGIN"
END = "GODBASE_QUARANTINE_AUDIT_END"


def extract(text: str) -> dict:
    start = text.find(BEGIN)
    if start < 0:
        raise ValueError(f"missing marker {BEGIN}")
    start += len(BEGIN)
    end = text.find(END, start)
    if end < 0:
        raise ValueError(f"missing marker {END}")
    payload = text[start:end].strip()
    if not payload:
        raise ValueError("empty quarantine audit payload")

    # Studio loggers may prefix each line. First try the raw block, then fall
    # back to locating the outermost JSON object in the marked region.
    try:
        value = json.loads(payload)
    except json.JSONDecodeError:
        left = payload.find("{")
        right = payload.rfind("}")
        if left < 0 or right < left:
            raise
        value = json.loads(payload[left : right + 1])
    if not isinstance(value, dict):
        raise ValueError("quarantine audit payload must be a JSON object")
    return value


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", help="Studio/MCP log text file")
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    value = extract(Path(args.input).read_text(encoding="utf-8", errors="replace"))
    out = Path(args.output)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(value, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"extracted quarantine audit -> {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
