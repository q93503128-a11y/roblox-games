# Junkyard Empire — Next Chat / Agent Handoff

Use this file when continuing the project in a new ChatGPT conversation, Codex session, or other AI coding session.

This is **not a new project**. Do not redesign it from scratch unless the user explicitly changes direction.

---

# 0. Identity and repository

Project:

```text
Junkyard Empire
```

Repository:

```text
q93503128-a11y/roblox-games
```

Branch:

```text
main
```

Project path:

```text
projects/junkyard-empire/
```

The project is a Roblox **Tycoon / Management + Simulator / Collection** hybrid designed for fast production using Studio MCP, Codex CLI, modular code and audited external visual assets.

---

# 1. First action in every new session

Do **not** trust the SHA or status written in this handoff as the newest state.

Immediately query current GitHub `main`, then read the project from the repository.

Minimum read order:

1. `projects/junkyard-empire/README.md`
2. `projects/junkyard-empire/docs/GAME_DESIGN_FULL.md`
3. `projects/junkyard-empire/docs/DEVELOPMENT_RULES.md`
4. `projects/junkyard-empire/docs/MONETIZATION_AND_ECONOMY.md`
5. `projects/junkyard-empire/docs/ROADMAP_AND_STATUS.md`
6. `projects/junkyard-empire/docs/PROJECT_STATE.json`
7. `projects/junkyard-empire/ASSET_SOURCES.md`

Also use the shared Roblox Godbase when needed, especially:

- `knowledge/checklists/PROJECT_START_CHECKLIST.md`
- `knowledge/genres/TYCOON_MANAGEMENT.md`
- `knowledge/genres/SIMULATOR_COLLECTION.md`
- `knowledge/checklists/ASSET_IMPORT_CHECKLIST.md`
- `knowledge/workflow/STUDIO_MCP_AND_SCRIPT_SYNC.md`

---

# 2. Reconstruct actual state before editing

After reading GitHub:

1. determine the latest documented stage;
2. inspect what source files currently exist;
3. if implementation is expected in Studio, use Studio MCP to list currently open Studio instances;
4. explicitly select the correct Studio target;
5. inspect the actual DataModel and existing scripts;
6. compare Studio reality with `PROJECT_STATE.json` / `ROADMAP_AND_STATUS.md`;
7. only then continue the next unfinished task.

Never create a duplicate system because a stale prompt said it was missing.

---

# 3. Core game canon

One-line fantasy:

> Pick up junk, turn a tiny scrapyard into an automated recycling empire, and hunt increasingly rare scrap.

Primary loop:

```text
collect scrap
→ carry it
→ return to personal yard
→ process it
→ earn Cash
→ buy visible upgrades
→ unlock richer zones / rarities
→ progress collection
→ eventually sell company for permanent Company Stars
→ rebuild faster
```

Key production choice:

- V0.x uses **authored purchase pads / upgrade nodes**, not complex freeform building.
- external industrial/junk assets are encouraged for art;
- external free-model gameplay scripts are untrusted until audited;
- all valuable progression is server-authoritative;
- mobile is the primary interaction constraint.

---

# 4. Non-negotiable rules

Do not violate these unless the user explicitly changes the project:

1. Inspect before modifying.
2. Server owns Cash, rewards, purchases, zone unlocks, prestige, saves and monetization fulfillment.
3. Scrap/zone/machine/upgrades should be data-driven rather than one script per content item.
4. Do not stack `Old/New/New2/FinalFix` replacement systems; cleanly replace obsolete paths.
5. Creator Store/external assets must be sanitized and logged in `ASSET_SOURCES.md`.
6. Do not trust unknown `Script`, `LocalScript`, `ModuleScript`, numeric `require(assetId)` or hidden loader code from free models.
7. Do not report a feature as finished because code exists; run the required Studio playtest.
8. Do not ask the user to do basic structural QA that Codex/MCP can already perform.
9. Do not expand to dozens of items/zones before the core route passes.
10. After meaningful work, update `ROADMAP_AND_STATUS.md` and `PROJECT_STATE.json`.

---

# 5. Initial project baseline at handoff creation

At the time this handoff was first created:

- design documentation existed;
- Studio MCP ↔ Codex CLI connection had been manually verified;
- no Junkyard Empire gameplay implementation had yet been created;
- no production/test Place IDs had been assigned in project docs;
- no source synchronization had yet been configured;
- no assets had yet been accepted into `ASSET_SOURCES.md`.

This baseline can become stale. Current GitHub and Studio always win.

---

# 6. Originally scheduled next batch

If current GitHub still says P0/P0.1, the next batch is:

## P0.1 — Studio project foundation + one-loop greybox

1. query current GitHub main;
2. inspect current Studio via MCP;
3. establish clean project namespace/module skeleton;
4. establish source synchronization/recovery plan;
5. greybox one yard and one starter scrap field;
6. implement server-authoritative Cash;
7. implement tiny ScrapCatalog;
8. implement scrap collection + backpack;
9. implement unload/process → Cash;
10. implement one purchase pad;
11. make purchase create one obvious 3D factory improvement;
12. implement minimal Cash/backpack HUD;
13. Play-test the full route through MCP;
14. inspect Output;
15. update status docs.

Do not automatically run this old batch if current status shows it already completed.

---

# 7. Features intentionally blocked during initial slice

Until the P1 route is proven, avoid:

- Company Sale/prestige implementation;
- daily rewards;
- Game Passes / Developer Products;
- large scrap catalog;
- multiple extra zones;
- offline income;
- pets;
- combat;
- trading;
- clans;
- complex worker NPCs;
- freeform build mode;
- global leaderboard work;
- elaborate UI screens.

The project is meant to ship quickly, but shipping quickly means proving the loop first—not building everything at once.

---

# 8. Required status language

Always distinguish:

- planned;
- implemented;
- inspected;
- MCP tested;
- human tested;
- accepted.

Example good report:

> `P0.1 collect → unload → first purchase route is implemented and MCP-tested in solo Play. Multiplayer ownership and human mobile feel are not yet tested.`

Example bad report:

> `Everything is done.`

---

# 9. After every implementation batch

Update the repository before handing off again:

- `docs/ROADMAP_AND_STATUS.md`
- `docs/PROJECT_STATE.json`
- `README.md` if baseline changes materially
- `ASSET_SOURCES.md` if assets changed
- design/economy docs if actual decisions changed

The goal is that the next chat can reconstruct the project **without needing the old conversation transcript**.

---

# 10. Copy-paste prompt for a new ChatGPT/Codex planning session

```text
Continue the existing Roblox project “Junkyard Empire”. This is not a new project and you must not redesign it from memory.

Repository: q93503128-a11y/roblox-games
Branch: main
Project path: projects/junkyard-empire/

First query the current GitHub main and reconstruct the latest canonical state. Read, at minimum, the project README, GAME_DESIGN_FULL.md, DEVELOPMENT_RULES.md, MONETIZATION_AND_ECONOMY.md, ROADMAP_AND_STATUS.md, PROJECT_STATE.json and ASSET_SOURCES.md.

If Studio implementation/testing is needed, list the currently open Roblox Studio instances through MCP, explicitly identify the correct target, and inspect the existing DataModel/scripts before modifying anything. Do not assume an old handoff status is still current.

Follow the documented design and development rules. Do not create duplicate replacement systems, do not trust external free-model code, keep valuable economy/progression server-authoritative, and do not claim completion without the required playtest.

Then continue from the first genuinely unfinished task in the current ROADMAP_AND_STATUS.md. After the work, update the project status documents so another new session can continue without prior chat context.
```
