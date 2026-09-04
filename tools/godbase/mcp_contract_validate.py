#!/usr/bin/env python3
"""Validate a project-specific Roblox Studio MCP playtest contract.

The validator checks structure and safety gates only. It does not run Studio.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

REQUIRED_TOP = {
    "project",
    "studioTarget",
    "boot",
    "routes",
    "visualStates",
    "deviceMatrix",
    "multiplayer",
    "completion",
}
VALID_PRIORITIES = {"P0", "P1", "P2"}
VALID_FINAL = {"INTERNAL_PROTOTYPE", "READY_FOR_USER_TEST"}


def validate_contract(data: dict[str, Any]) -> list[str]:
    errors: list[str] = []

    missing = sorted(REQUIRED_TOP - set(data))
    if missing:
        errors.append("missing top-level keys: " + ", ".join(missing))
        return errors

    project = data.get("project")
    if not isinstance(project, dict) or not str(project.get("name", "")).strip():
        errors.append("project.name must be non-empty")
    if not isinstance(project, dict) or not str(project.get("primaryLoop", "")).strip():
        errors.append("project.primaryLoop must be non-empty")

    target = data.get("studioTarget")
    if not isinstance(target, dict):
        errors.append("studioTarget must be an object")
    elif target.get("requireExplicitStudioId") is not True:
        errors.append("studioTarget.requireExplicitStudioId must be true")

    boot = data.get("boot")
    if not isinstance(boot, dict):
        errors.append("boot must be an object")
    else:
        timeout = boot.get("spawnTimeoutSeconds")
        if not isinstance(timeout, (int, float)) or timeout <= 0 or timeout > 120:
            errors.append("boot.spawnTimeoutSeconds must be >0 and <=120")

    routes = data.get("routes")
    if not isinstance(routes, list) or not routes:
        errors.append("routes must contain at least one route")
    else:
        ids: set[str] = set()
        has_p0 = False
        for i, route in enumerate(routes):
            if not isinstance(route, dict):
                errors.append(f"routes[{i}] must be an object")
                continue
            rid = str(route.get("id", "")).strip()
            if not rid:
                errors.append(f"routes[{i}].id must be non-empty")
            elif rid in ids:
                errors.append(f"duplicate route id: {rid}")
            ids.add(rid)
            priority = route.get("priority")
            if priority not in VALID_PRIORITIES:
                errors.append(f"route {rid or i} has invalid priority")
            if priority == "P0":
                has_p0 = True
            steps = route.get("steps")
            if not isinstance(steps, list) or not steps:
                errors.append(f"route {rid or i} must contain steps")
            expected = route.get("expected")
            if not isinstance(expected, list) or not expected:
                errors.append(f"route {rid or i} must contain expected outcomes")
        if not has_p0:
            errors.append("at least one P0 route is required")

    visual = data.get("visualStates")
    if not isinstance(visual, list) or not any(isinstance(x, dict) and x.get("required") is True for x in visual):
        errors.append("at least one required visual state is required")

    devices = data.get("deviceMatrix")
    if not isinstance(devices, list) or not devices:
        errors.append("deviceMatrix must contain at least one profile")
    else:
        for i, device in enumerate(devices):
            if not isinstance(device, dict):
                errors.append(f"deviceMatrix[{i}] must be an object")
                continue
            for key in ("width", "height"):
                value = device.get(key)
                if not isinstance(value, int) or value < 1:
                    errors.append(f"deviceMatrix[{i}].{key} must be a positive integer")

    multiplayer = data.get("multiplayer")
    if not isinstance(multiplayer, dict):
        errors.append("multiplayer must be an object")
    else:
        max_clients = multiplayer.get("maxClients", 8)
        if not isinstance(max_clients, int) or not 1 <= max_clients <= 8:
            errors.append("multiplayer.maxClients must be between 1 and 8")
        if multiplayer.get("required") is True and not multiplayer.get("scenarios"):
            errors.append("multiplayer.scenarios required when multiplayer.required=true")

    completion = data.get("completion")
    if not isinstance(completion, dict):
        errors.append("completion must be an object")
    else:
        states = completion.get("allowedFinalStates")
        if not isinstance(states, list) or not states or any(s not in VALID_FINAL for s in states):
            errors.append("completion.allowedFinalStates contains invalid state")
        ready = completion.get("readyRequires")
        if not isinstance(ready, list) or "allP0RoutesPass" not in ready or "zeroUnexpectedRuntimeErrors" not in ready:
            errors.append("completion.readyRequires must include allP0RoutesPass and zeroUnexpectedRuntimeErrors")

    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("contract", help="Path to project MCP playtest contract JSON")
    args = parser.parse_args()

    path = Path(args.contract)
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        print("ERROR: contract root must be an object", file=sys.stderr)
        return 1

    errors = validate_contract(data)
    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1

    print(f"MCP playtest contract valid: {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
