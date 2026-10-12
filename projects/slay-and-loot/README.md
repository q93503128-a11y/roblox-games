# Slay & Loot

Status: PRE-PRODUCTION / INTERNAL PROTOTYPE

## Core idea

Slay & Loot is a Roblox action-growth game built around:

- direct, readable combat against groups of monsters
- visible equipment drops and equipment-driven power growth
- compact zone progression instead of a large empty open world
- strong replay speedup through rebirth/progression
- externally sourced, audited art/assets when they improve quality and speed

The exact content catalog is intentionally not frozen up front. The project uses a live-design workflow: inspect references/assets, build a small coherent slice, playtest it, then promote only proven decisions into the canonical design docs.

## Canonical project docs

- `AGENTS.md` — Codex/MCP operating rules. Read first.
- `CODEX_PRACTICAL_RULES.md` — implementation cleanliness and reporting rules.
- `PLAN.md` — current work plan and stop conditions.
- `HANDOFF.md` — current implementation state for session recovery.
- `docs/VISION.md` — stable product direction and non-goals.
- `docs/LIVE_DESIGN.md` — current game rules that have actually been accepted.
- `docs/ASSET_SOURCES.md` — external asset provenance, audit, and modifications.
- `docs/DECISIONS.md` — dated design/technical decisions.
- `docs/PLAYTEST_NOTES.md` — evidence from actual Studio/playtest checks.

## Shared Roblox knowledge

Before major implementation decisions, use the repository Godbase in `knowledge/`, beginning with `knowledge/GODBASE_MANIFEST.json` and the relevant specialist documents.

## Development mode

Primary workflow: Roblox Studio + Codex + Roblox Studio MCP + Git/GitHub.

Codex keeps relevant canonical project docs current directly in the connected repository. Do not call a feature complete until it has been validated in Studio on the exact route it is meant to support.
