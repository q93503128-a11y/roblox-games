# Rebirth RPG — Studio Agent Run Sequence 001

> verified planning date: 2026-09-08
> purpose: keep Studio work evidence-driven and prevent one-shot map/game construction

This file is the **sequence index**. Detailed instructions live in the standalone task files.

Do not execute multiple major phases blindly in one request. Each phase ends with evidence and a supervisor gate.

## PHASE 0 — Current code integration / smoke validation

Run first because gameplay core code already exists but has never been Play-tested in Studio.

```text
inspect exact Studio place
→ Script Sync current repository code
→ create explicit RebirthRPG_SmokeOrigin anchor after inspecting floor/spawn
→ enable Studio-only smoke harness
→ clean Play
→ attack / reward / equip / boss / respawn / rebirth route
→ report
→ STOP
```

Canonical docs:
- `STUDIO_AGENT_START_HERE.md`
- `SCRIPT_SYNC_RUNTIME_LAYOUT_001.md`
- `STUDIO_CORE_SMOKE_TEST_001.md`

Hard gate:
- if clean boot or core reward/equip/rebirth route fails, fix the smallest coherent root cause and replay the exact failed route before asset or map work
- smoke rigs are debug-only and never become production art

## PHASE 1 — Environment intake

After PHASE 0 is structurally sound:

Run:
`STUDIO_AGENT_TASK_01_ENVIRONMENT.md`

Scope:
- current place safety inspection
- Synty Nature `6933438443`
- Synty Dungeon `6934021345`
- R15 scale / pivot / collision / materials / camera fit
- curated subset only

Then supervisor reviews evidence.

## PHASE 2 — Weapon visuals

Run:
`STUDIO_AGENT_TASK_02_WEAPONS.md`

Goal:
- two coherent early weapon silhouettes
- no inherited third-party combat system
- actual grip/pivot/scale/style evidence

Then supervisor reviews evidence.

## PHASE 3 — Enemy family

Run:
`STUDIO_AGENT_TASK_03_ENEMIES.md`

Goal:
- two normal-enemy-capable visuals
- one boss-capable visual
- coherent family
- rig/animation feasibility
- zero executable descendants in the sanitized production copy

Project `EnemyService` owns AI/damage/reward/respawn.

Then supervisor reviews evidence.

## PHASE 4 — Armor + minimal VFX

Run:
`STUDIO_AGENT_TASK_04_ARMOR_VFX.md`

Only secure enough for the first slice:
- 0–3 coherent early equipment looks
- swing/trail
- hit impact
- loot/reward feedback
- obvious boss AoE telegraph

Do not dump giant packs into production hierarchy.

## PHASE 5 — Asset approval

Supervisor fills:
- `ASSET_APPROVAL_GATE_001.md`
- `SUPERVISOR_POST_ASSET_INPUT_001.md`

Required summary:

```text
APPROVED ENVIRONMENT VOCABULARY
APPROVED STRUCTURE VOCABULARY
APPROVED WEAPON VOCABULARY
APPROVED ENEMY VOCABULARY
APPROVED/DEFERRED ARMOR
APPROVED MINIMAL VFX
MISSING ITEMS
```

No first production zone before this gate.

## PHASE 6 — First-zone spatial plan

Only now inspect actual approved asset bounds and current Studio world, then create:
- playable bounds
- spawn transform
- named anchors
- main route
- first combat pocket
- landmarks
- boss approach/arena
- reward/return route
- placement table for 5+ player-facing objects

Never start from guessed raw world coordinates.

## PHASE 7 — One coherent production section

Build in passes:

```text
terrain/bounds
→ spawn/safe hub
→ main route
→ first combat pocket
→ one landmark
→ reward/progression connection
→ gameplay-camera QA
→ exact route replay
```

Do not build the whole RPG map one-shot.

## PHASE 8 — Vertical Slice gate

Required P0 evidence eventually includes:

```text
spawn
→ first enemy
→ reward
→ meaningful equipment upgrade
→ stronger encounter
→ boss
→ major reward
→ death/respawn
→ rebirth test profile
→ mobile primary route
```

Only after the first 5–10 minute slice is actually good should region 2 or large content breadth begin.
