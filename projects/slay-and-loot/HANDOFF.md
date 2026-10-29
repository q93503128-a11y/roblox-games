# Slay & Loot — handoff
Date: 2026-10-30.
Foundation status: documented/validated; game status: **DESIGN — NOT IMPLEMENTED**.

## Start
[Live design](docs/LIVE_DESIGN.md) → [catalog](docs/specs/first-slice.catalog.json) → [architecture/persistence](docs/ARCHITECTURE.md) → [acceptance](docs/ACCEPTANCE.md).
[Current audit](docs/CURRENT_STATE_AUDIT.md) / [assets](docs/ASSET_SOURCES.md) / [plan](PLAN.md).

## New product
Persistent-world Combat Loot Simulator:
Kill → Coins + weapon → same-weapon duplicate XP/level → hatch/equip pet → stronger damage → unlock next Zone.

Next slice only: safe start + one farm + visible personal Zone2 gate/preview; 2 Normal types, Strong, Mini-Boss; 3 weapons; 1 Egg / 6 pets / Hatch1 / 3 slots; both Equip Best flows; server authority; durable persistence gate.

## Observed state
Repo: C:/Users/skanya/Documents/GitHub/roblox-games, main.
Studio: Place121055730304610 / Experience10773222778, 베고 약탈하기.
Studio ID52d5ccd7-f746-4d59-b8e0-7a5a26820c90 was confirmed; relist before future use.
Blank baseline: Baseplate128×128/top0, Spawn(0,0.5,0), Camera/Terrain; zero scripts/remotes/UI/storage assets. No game implementation or runtime sync manifest exists.
No Studio changes made in Foundation; cloud save/publish unknown.

## Prior cleanup
27 project file deletions were already pending at intake. Old runtime and generated metadata stay removed. Active docs are rewritten, not restored from old dungeon plans.
Old source/audit metadata retained in Git history at58746a05d609e3e061c5acba72e1eaaa760240d2. Former Synty/Goblin Studio binaries are absent; source history is not a binary backup.
Unrelated Junkyard Empire changes must remain untouched.

## First safe implementation milestone
Reinspect exact target and calibrate authored floor/avatar/camera → audit asset subset → integrate reviewed pinned persistence adapter → one enemy/weapon/duplicate loop → pet/gate/UI → full acceptance.
No complete World1, World2, extra currencies, Auto Fight, advanced hatch or variants.
English game / Korean collaboration. No computer use.

## Verification / Git
Foundation verification is recorded in [acceptance](docs/ACCEPTANCE.md); it does not pass runtime gates.
Final commit hash and push result are reported in the task's final response and discoverable with git log; this document does not invent a future self-referential commit hash.
