# Junkyard Empire

> Working title. Roblox Studio-first tycoon/simulator project.

## Project thesis

**Junkyard Empire** is a deliberately production-efficient Roblox game: the player scavenges valuable scrap in shared junk zones, carries it back to a personal yard, processes it through increasingly automated machinery, sells the output, expands the factory, unlocks richer junk zones, and eventually sells/restarts the company for permanent progression.

This project is not trying to win through custom character art, cinematic combat, or a huge handcrafted world. It is designed around:

- a core loop that is understandable in seconds;
- heavy reuse of safe Creator Store / external visual assets;
- simple, modular Roblox systems that can be built and tested quickly;
- visible tycoon growth that feels good even with modest art resources;
- mobile-first interaction;
- strong collection/progression hooks;
- straightforward, policy-compliant monetization;
- a framework that may later be reusable for other tycoon themes **only after this game proves the loop**.

## One-line fantasy

> Pick up junk, turn a tiny scrapyard into an absurdly valuable automated recycling empire, and hunt increasingly rare scrap along the way.

## Primary genre

Hybrid:

- Tycoon / Management
- Simulator / Collection

The project intentionally does **not** start with a freeform build mode. V0.x uses authored purchase pads / upgrade nodes so the game is faster to build, easier to understand on mobile, and easier to expand with third-party art. Meaningful choices come from upgrade priorities, active scavenging, factory bottlenecks, zone unlocks, and long-term progression rather than furniture placement.

Godbase references:

- `../../knowledge/checklists/PROJECT_START_CHECKLIST.md`
- `../../knowledge/genres/TYCOON_MANAGEMENT.md`
- `../../knowledge/genres/SIMULATOR_COLLECTION.md`
- `../../knowledge/checklists/ASSET_IMPORT_CHECKLIST.md`
- `../../knowledge/workflow/STUDIO_MCP_AND_SCRIPT_SYNC.md`

## Workflow decision

### Chosen workflow

```text
Roblox Studio
+ Studio MCP
+ Codex CLI
+ GitHub main
+ project documentation / source synchronization
```

Studio MCP ↔ Codex CLI connectivity was manually verified on 2026-09-06 before this project was initialized.

This project is therefore **Studio-first** unless a later technical requirement justifies Rojo.

Current workflow state:

- Studio MCP: confirmed usable
- Codex CLI: confirmed usable
- project folder in monorepo: created
- Script Sync / source mirroring: not configured yet
- production Place / Universe IDs: not assigned yet
- gameplay code: not started yet
- map: not started yet

Do not silently convert the project to Rojo/filesystem-first. If that becomes necessary, document the reason first.

## Canonical documents

Read these before doing implementation work:

1. `docs/GAME_DESIGN_FULL.md` — complete design canon
2. `docs/DEVELOPMENT_RULES.md` — non-negotiable implementation / asset / QA rules
3. `docs/MCP_PLAYTEST_CONTRACT.md` — Studio target, P0 routes, negative tests and completion language
4. `docs/MONETIZATION_AND_ECONOMY.md` — economy, progression and monetization plan
5. `docs/ROADMAP_AND_STATUS.md` — current production stage and acceptance gates
6. `docs/PROJECT_STATE.json` — compact machine-readable state snapshot
7. `docs/NEXT_CHAT_HANDOFF.md` — exact continuation protocol for a new ChatGPT/Codex session
8. `ASSET_SOURCES.md` — imported asset provenance and sanitation log

When documents conflict, precedence is:

```text
explicit latest user decision
> GAME_DESIGN_FULL.md
> DEVELOPMENT_RULES.md
> MONETIZATION_AND_ECONOMY.md
> ROADMAP_AND_STATUS.md
> README.md
> old chat summaries / old prompts
```

Never treat a stale handoff prompt as more authoritative than current GitHub `main`.

## Core loop

```text
enter / claim yard
→ collect scrap in a nearby junk zone
→ return / unload
→ process through factory
→ receive Cash
→ buy visible machinery / capacity / efficiency upgrades
→ unlock richer zones and rarer scrap
→ complete collection and progression goals
→ sell company / prestige for permanent power
→ rebuild faster with more options
```

There are two complementary play styles:

### Active

The player personally searches for high-value/rare scrap, improves carrying capacity and collection tools, and decides which zone to farm.

### Idle / automated

The player's factory and unlocked automation produce value with less manual work. Automation must never make active play pointless; active scavenging should remain the best route to rare finds and burst progression.

## First-session experience targets

Design targets, not guarantees:

- **0–10 sec:** player understands where to go / first scrap visible
- **≤30 sec:** first scrap collected
- **≤60 sec:** first cash conversion
- **1–3 min:** first clearly visible upgrade
- **3–5 min:** rarity / collection aspiration becomes visible
- **5–8 min:** first meaningful zone or factory expansion
- **10 min:** player can identify at least two next goals without a tutorial wall
- **25–40 min target:** first prestige/company sale for an engaged new player, subject to playtest tuning

Do not ship a tutorial dialogue sequence that delays the first pickup.

## V0.1 vertical slice

The initial playable slice should prove the loop with minimal content:

- 1 personal yard template
- 1 starter scavenging zone
- 6–8 meaningful purchase/upgrade nodes
- 1 complete processing line
- 8–12 scrap items across at least 3 rarities
- backpack/carry capacity
- Cash
- one visible collection/index surface
- one zone-expansion tease
- basic save/load
- basic responsive HUD
- one social/friend visibility feature if cheap
- no real-money pressure required for slice completion

The slice is not complete because objects exist. It is complete only after the P0 route can be played from spawn to first major upgrade without blocker errors.

## Production philosophy

### Optimize for shipping speed, not sloppy code

The game intentionally uses a proven, familiar Roblox structure. That is **not** permission to paste random kit scripts or stack duplicate systems.

We want:

- fast art assembly;
- reusable data definitions;
- small server-authoritative services;
- predictable state transitions;
- clear asset provenance;
- frequent MCP playtests;
- easy content expansion.

We do not want:

- free-model backdoors;
- hidden external `require(assetId)` code;
- duplicated economy scripts;
- client-authoritative rewards;
- huge monolithic scripts;
- five currencies in the first session;
- dozens of popups on spawn;
- fake scarcity / deceptive monetization;
- a 100-item content dump before the core loop is proven.

## Art / asset strategy

This project is asset-friendly by design.

High-value external art categories:

- junk piles / scrap props
- industrial machinery shells
- conveyors
- crushers / compactors / furnaces
- cranes / forklifts / trucks
- warehouse / fence / road kits
- pipes / barrels / pallets
- car wrecks
- signage and environmental clutter

Gameplay logic remains project-owned even when visuals are external.

Every imported asset must be logged in `ASSET_SOURCES.md` and sanitized before use. Unknown scripts are not trusted.

## Current production state

**Stage: P0 — Design / preproduction initialized**

Completed:

- project concept chosen
- Roblox-focused production strategy chosen
- Studio MCP + Codex CLI connection confirmed
- Studio-first workflow chosen
- canonical project documentation initialized

Not completed:

- project Studio DataModel scaffolding
- Script Sync / Git source synchronization
- asset shortlist/import
- economy implementation
- tycoon plot implementation
- scavenging implementation
- save system
- UI
- playtest

The exact current checklist and next action live in `docs/ROADMAP_AND_STATUS.md` and `docs/PROJECT_STATE.json`.

## Immediate next action

Do **not** jump to monetization, rebirth, or 30+ items yet.

Next implementation batch:

1. inspect current GitHub `main` and this project docs;
2. inspect the exact open Roblox Studio instance through MCP;
3. establish the project DataModel/module skeleton and synchronization strategy;
4. greybox one yard + one scrap zone;
5. implement the smallest playable route: collect one scrap → unload/process → Cash → buy one visible upgrade;
6. playtest the route through Studio MCP;
7. update `ROADMAP_AND_STATUS.md` and `PROJECT_STATE.json` with what actually exists.
