# Junkyard Empire — Roadmap & Current Status

> Last updated: 2026-09-06
> Current stage: **P0 — design/preproduction initialized**
> Current playable baseline: **none yet**
> Human-tested baseline: **none yet**

This file answers two questions:

1. **What actually exists right now?**
2. **What is the exact next work batch?**

Do not mark tasks complete because they were discussed. Mark them complete only when the corresponding artifact exists and the required validation has happened.

---

# 1. Status vocabulary

Use these states consistently:

- **PLANNED** — documented only
- **IMPLEMENTED** — code/Instances exist
- **INSPECTED** — implementation was structurally reviewed
- **MCP TESTED** — relevant path was exercised through Studio MCP/Play mode
- **HUMAN TESTED** — user personally played it and reported results
- **ACCEPTED** — required tests passed and the baseline is approved

A task may be implemented without being accepted.

---

# 2. Current repository baseline

Project folder:

```text
projects/junkyard-empire/
```

Created canonical docs:

- `README.md`
- `docs/GAME_DESIGN_FULL.md`
- `docs/DEVELOPMENT_RULES.md`
- `docs/MONETIZATION_AND_ECONOMY.md`
- `docs/ROADMAP_AND_STATUS.md`
- `docs/PROJECT_STATE.json`
- `docs/NEXT_CHAT_HANDOFF.md`
- `ASSET_SOURCES.md`

Initial monorepo baseline before project creation was:

```text
9a6daa1f38b68f5027648a4ae2ee923218550fe2
```

That SHA is historical context only. Always query current `main` before continuing.

---

# 3. Preproduction checklist

## Concept

- [x] working title selected: Junkyard Empire
- [x] one-line fantasy defined
- [x] core loop defined
- [x] production-efficient genre selected
- [x] target platform priority defined
- [x] active + idle hybrid direction defined
- [x] prestige direction defined
- [x] monetization boundaries documented
- [x] anti-scope rules documented

## Workflow

- [x] Roblox Studio MCP available
- [x] Codex CLI available
- [x] Studio MCP ↔ Codex CLI connection manually verified
- [x] Studio-first workflow selected
- [ ] exact project Place created/named/published
- [ ] Script Sync or equivalent source mirroring configured
- [ ] project source/module skeleton committed
- [ ] TEST vs LIVE Place strategy established

## Art

- [x] external-asset-first art strategy selected
- [x] asset sanitation policy documented
- [ ] visual reference/asset shortlist selected
- [ ] starter junk/industrial asset pack reviewed
- [ ] first accepted external asset logged

---

# 4. Production phases

## P0 — Design / setup

Goal: establish canon and safe workflow before gameplay implementation.

Status: **IN PROGRESS**

Exit criteria:

- canonical docs exist;
- exact Studio target identified;
- project DataModel/source skeleton exists;
- synchronization/recovery path is documented;
- no ambiguity about first slice.

## P1 — Core vertical slice

Goal: prove the smallest complete loop.

Required route:

```text
spawn
→ assigned yard
→ collect scrap
→ backpack updates
→ unload
→ process
→ Cash reward
→ buy first upgrade
→ visible factory improvement
→ repeat loop improved
```

Required content:

- 1 yard
- 1 starter scrap field
- 3–5 scrap definitions minimum
- Cash
- backpack
- unload/processing
- 1 purchase pad
- 1 visible machine upgrade
- minimal HUD
- no real persistence requirement until route is stable unless architecture benefits from early stub

Exit criteria:

- clean Play boot;
- P0 route passes;
- no red Output errors in normal route;
- rewards/purchases server-authoritative;
- duplicate pickup/purchase basic abuse blocked;
- MCP playtest recorded.

## P2 — Slice quality pass

Goal: make the first 5 minutes understandable and satisfying.

Add/tune:

- 8–12 scrap items;
- 3 rarity tiers;
- 6–8 purchase nodes;
- clear feedback stack;
- first yard expansion;
- first collection/index UI;
- first meaningful player/tool upgrade;
- mobile UX pass;
- coherent starter visual set.

Exit criteria:

- first action in ~10 seconds target;
- first reward under ~60 seconds target;
- first visible upgrade in 1–3 minutes target;
- player always sees next goal;
- no major visual blockers;
- first human playtest ready.

## P3 — Persistence + progression

Goal: make the game safe to return to.

Add:

- versioned save schema;
- profile/persistence service;
- upgrade restore;
- collection restore;
- zone restore;
- Company Stars scaffold;
- reconnect tests;
- save-failure handling.

Exit criteria:

- clean new profile;
- save/rejoin restore;
- schema version exists;
- failure behavior understood;
- no client-controlled save payload.

## P4 — Zone expansion + retention

Goal: turn the slice into a small real game.

Add roughly:

- zone 2: Car Graveyard or equivalent;
- zone 3: Industrial Dump or equivalent;
- 25–40 total scrap items target;
- collection milestones;
- lightweight quests;
- daily reward;
- stronger factory progression;
- social yard visibility / friend bonus.

Exit criteria:

- 10–20+ minute session has multiple goals;
- new zones feel materially different;
- collection aspiration is visible;
- content is data-driven;
- performance remains acceptable.

## P5 — Prestige

Goal: establish long-term reset/rebuild loop.

Add:

- Company Value;
- Company Sale;
- Company Stars;
- permanent multiplier/perks;
- prestige confirmation and summary;
- reset safety;
- save integration.

Exit criteria:

- first prestige timing tuned;
- no accidental permanent-data loss;
- repeated prestige works;
- prestige makes second run feel faster.

## P6 — Monetization

Goal: add a small, clear commercial layer after free progression works.

Initial candidates:

- 2× Cash Pass;
- VIP Pass;
- capacity/convenience Pass;
- timed boost Product;
- Cash products.

Exit criteria:

- Marketplace config centralized;
- server ownership checks;
- receipt idempotency;
- no purchase prompt on join;
- purchase failure path tested;
- current Roblox policy rechecked before public release.

## P7 — Analytics / launch preparation

Goal: make iteration measurable and shipping safe.

Add/verify:

- progression funnel events;
- economy telemetry;
- error monitoring strategy;
- icon/thumbnail/store metadata;
- device testing;
- multiplayer testing;
- performance pass;
- TEST/LIVE separation;
- rollback/release procedure.

## P8 — Public iteration

Goal: update from real player behavior.

Priorities after launch:

1. first-session drop-off;
2. session length / repeat play;
3. progression dead zones;
4. mobile blockers;
5. economy exploits;
6. monetization conversion without retention damage;
7. content cadence.

---

# 5. Exact next implementation batch

This is the next approved work. Do not skip ahead.

## Batch P0.1 — Studio project foundation + one-loop greybox

### A. Verify current state

- query GitHub current `main`;
- read canonical project docs;
- use MCP to list open Roblox Studio instances;
- identify intended Studio target explicitly;
- inspect Workspace, ReplicatedStorage, ServerScriptService, StarterPlayer and StarterGui.

### B. Establish clean project namespace

Create only the minimal structure required for the slice.

Expected conceptual ownership:

```text
ReplicatedStorage
  JunkyardEmpire
    Shared / Config / Remotes as appropriate

ServerScriptService
  JunkyardEmpire
    bootstrap/services

StarterPlayer / StarterGui
  client bootstrap / minimal HUD as appropriate

Workspace
  JunkyardEmpireWorld
    Plots
    ScrapZones
    Runtime
```

Exact names may change after inspecting the actual Studio hierarchy, but avoid scattering project objects across unrelated root locations.

### C. Greybox

Create:

- one simple player yard;
- one nearby starter scrap area;
- unload point;
- one machine location;
- one purchase pad;
- safe spawn/pathing.

Use Parts/primitive geometry first. Do not spend the first batch decorating.

### D. Core logic

Implement:

- server-owned Cash;
- tiny ScrapCatalog;
- scrap spawn/collect;
- backpack capacity;
- unload;
- process/value reward;
- one upgrade purchase;
- visible upgrade activation.

### E. UI

Minimal only:

- Cash;
- backpack count;
- one short objective if needed.

### F. MCP test

Run complete route from Play start.

Record:

- whether player spawned correctly;
- whether scrap could be collected;
- whether Cash was awarded exactly once;
- whether upgrade purchase was validated and visible;
- any Output errors/warnings;
- what could not be tested automatically.

### G. Documentation update

After implementation:

- update this file;
- update `PROJECT_STATE.json`;
- update README baseline if necessary;
- record any external assets if used;
- document new unresolved issues.

---

# 6. Explicitly blocked until P1 route passes

Do not implement yet:

- rebirth/company sale;
- daily rewards;
- paid products/passes;
- 25+ scrap catalog;
- second/third zone;
- offline income;
- trading;
- pets;
- combat;
- worker NPC system;
- freeform build mode;
- global leaderboards;
- elaborate UI redesign.

---

# 7. Current known risks

## Asset dependence

The game's speed advantage depends on finding coherent industrial/junk assets. Bad asset mixing could make the result look like a Toolbox dump.

Mitigation:

- pick one main visual family early;
- sanitize imports;
- recompose/recolor selectively;
- keep gameplay geometry independent of art shells.

## Repetitive loop

Collect → unload → buy can become boring quickly.

Mitigation:

- visible factory changes;
- rarity chase;
- collection index;
- short time-to-choice;
- active + automation balance;
- early zone aspiration.

## Over-aggressive monetization

Tycoon/simulator structure can tempt excessive prompts.

Mitigation:

- monetization only after core progression is fun;
- contextual surfaces;
- no forced spawn prompt;
- track retention alongside conversion.

## Studio-first continuity

Direct Studio edits can become hard to reproduce if source/state is not mirrored.

Mitigation:

- establish source synchronization early;
- update state docs every major batch;
- inspect actual Studio each new work session.

---

# 8. First human-test gate

Do not ask the user to test until AI/Codex has already verified the mechanical P0 route.

Before first human test:

- player can join/play without setup;
- no blocker Output errors;
- collect/unload/purchase works;
- visual path is understandable;
- UI fits basic desktop view and is designed for later mobile check;
- known limitations are listed.

Human test should focus on:

- whether the loop is boring;
- whether the player knows where to go;
- whether factory growth feels satisfying;
- whether scrap pickup feels too slow;
- whether next goal is obvious;
- whether they want to continue to next zone.

---

# 9. Current summary

At this exact document baseline, Junkyard Empire is **well-specified but not implemented**.

The next legitimate claim after work should be something like:

> “P0.1 core route implemented and MCP-tested.”

not:

> “game mostly finished.”
