# Rebirth RPG — Studio Agent Task 02: Weapon Visual Intake

> run only after TASK 01 environment evidence is reviewed
> scope: weapon visuals only
> stop after report

## GOAL

Identify **two early weapon silhouettes** that visually fit the approved environment family and are suitable for simple brain-off Roblox RPG combat.

Start with:
- Sword Pack `10226464132`

The goal is not to build the combat system or item catalog. It is only to secure a small, coherent visual vocabulary.

## CURRENT CONTEXT

Core loop:
`kill → XP/Gold/loot → equip → stronger area → boss → rebirth`

Design rules:
- combat should be simple but responsive
- visual/content identity follows secured assets
- do not invent mandatory weapon families first
- avoid asset soup

Read:
- `projects/rebirth-rpg/README.md`
- `projects/rebirth-rpg/ASSET_SOURCES.md`
- `projects/rebirth-rpg/docs/ASSET_APPROVAL_GATE_001.md`
- TASK 01 result/evidence

## DO NOT CHANGE

- final map
- enemy roster
- progression formulas
- server combat architecture
- weapon stats/balance
- paid assets without approval

Do not adopt third-party combat scripts.

## INSPECT

For each candidate:
- creator/source shown by Studio
- Script / LocalScript / ModuleScript count
- external/numeric requires or dependencies
- MeshPart/model structure
- pivot / grip orientation
- scale on R15 reference avatar
- whether basic swing animation can plausibly use it
- readability from normal third-person gameplay distance
- style fit with approved environment
- obvious mobile/performance concern

Need only two distinct roles, e.g.:
- faster / shorter reach
- slower / longer reach

These are role labels only. Do not canonize names or stats.

If `10226464132` does not fit, search for **one small coherent alternative family**. Do not assemble unrelated individual weapons.

## REJECT / DEFER

- DemonSword 10Set `82026628729754`
- giant scripted weapon kits
- 100+ weapon catalogs
- visually incompatible anime/neon weapons

## REQUIRED REPORT

```text
CANDIDATE
ASSET ID
CREATOR
SCRIPT COUNTS
DEPENDENCIES
MESH STRUCTURE
GRIP/PIVOT
R15 SCALE
ANIMATION FEASIBILITY
GAMEPLAY-CAMERA READABILITY
STYLE FIT
PERFORMANCE CONCERN
APPROVE / HOLD / REJECT
REASON
```

Then summarize:

```text
APPROVED WEAPON A:
APPROVED WEAPON B:
MISSING:
```

## ACCEPTANCE

Task succeeds only if:
- evidence comes from actual Studio inspection
- two usable silhouettes are approved, or missing vocabulary is explicitly reported
- no third-party combat logic is inherited
- no final stats/names/progression are invented

## STOP CONDITIONS

STOP if:
- environment evidence is not available
- candidate requires unsafe/opaque code
- style mismatch is obvious
- scale/grip would require destructive re-authoring
- only paid asset can satisfy the requirement

STOP after the weapon report. Do not proceed to enemies automatically.
