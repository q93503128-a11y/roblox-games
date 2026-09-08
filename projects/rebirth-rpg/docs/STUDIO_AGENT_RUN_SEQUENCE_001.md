# Rebirth RPG — Studio Agent Run Sequence 001

> verified planning date: 2026-09-08
> purpose: execute asset-first preproduction without one-shot Studio work

Use these tasks **in order** with Roblox Studio Assistant/Agent.

Do not run all four as one giant build request. Each task ends with evidence and a stop gate.

---

# TASK 01 — Studio Inspect + Environment Quarantine

## GOAL

Inspect the current Studio place and create an isolated asset quarantine for environment-only review.

Then inspect these two source packs first:

- Synty Nature Pack `6933438443`
- Synty Dungeon Pack `6934021345`

Do not build the final RPG map.

## CURRENT CONTEXT

Project: Rebirth RPG

Game direction:
- simple Roblox fantasy action RPG
- brain-off farming/progression
- kill → XP/Gold/loot → equip → stronger area → boss → rebirth
- content visuals follow secured assets; AI does not invent mandatory enemy/item designs first

Canonical docs:
- `projects/rebirth-rpg/README.md`
- `projects/rebirth-rpg/ASSET_SOURCES.md`
- `projects/rebirth-rpg/docs/ASSET_WEB_PREFILTER_002.md`
- `projects/rebirth-rpg/docs/VERTICAL_SLICE_001.md`

## DO NOT CHANGE

- unrelated verified project content
- progression/combat architecture
- final world
- final lighting/art direction
- paid assets

Do not retain source-pack scripts or demo scaffolding in a trusted hierarchy.

## INSPECT FIRST

Report before importing:

```text
place identity / whether clean
Workspace top-level children
spawn state
Lighting basics
existing scripts/packages
whether unrelated project content exists
```

If this is another project place, STOP.

## QUARANTINE STRUCTURE

Create only an isolated structure such as:

```text
Workspace
└─ _AssetQuarantine
   ├─ Environment
   └─ ReferenceRig
```

Add an R15 reference rig.

## ENVIRONMENT AUDIT

For each pack:
- verify creator/source shown by Studio
- count Script / LocalScript / ModuleScript descendants
- inspect requires/external dependencies
- inspect representative tree/rock/foliage assets
- inspect representative cave/castle/bridge/tunnel assets
- compare major pieces to R15 rig
- inspect pivot
- inspect collision
- inspect texture/material health
- view from approximate gameplay-camera distance
- identify a **small curated subset** sufficient for one first field and one compact cave/dungeon section

Do not keep the full source pack as production content.

## ACCEPTANCE

Return:

```text
PACK
SOURCE VERIFIED
SCRIPT COUNTS
DEPENDENCIES
REPRESENTATIVE SUBSET
SCALE
PIVOT
COLLISION
TEXTURE/MATERIAL
VISUAL FIT
PERFORMANCE CONCERN
APPROVE / HOLD / REJECT
```

Task succeeds only if evidence is based on actual Studio inspection.

## STOP CONDITIONS

- wrong Studio place
- suspicious execution
- broken critical dependencies
- severe scale/collision mismatch
- environment family clearly cannot support the target

STOP after the environment report. Do not proceed to weapons or enemies automatically.

---

# TASK 02 — Weapon Visual Intake

Run only after TASK 01 environment family is reviewed.

## GOAL

Find two usable early weapon silhouettes that visually fit the approved environment family.

Start with:
- Sword Pack `10226464132`

## DO NOT CHANGE

- combat architecture
- weapon stats/progression balance
- final map
- enemy roster

Do not adopt bundled third-party combat code.

## CHECK

- actual source/creator
- scripts/dependencies
- MeshPart structure
- grip/pivot
- visual R15 scale
- basic animation feasibility
- gameplay-camera silhouette
- style match to approved environment

Need only enough visual vocabulary for two early combat roles.

Example role language only:
- faster/shorter
- slower/longer

Do not canonize weapon names yet.

If `10226464132` clashes, search for **one small coherent family**, not random individual weapons.

Explicitly avoid:
- DemonSword 10Set `82026628729754`
- giant scripted combat kits
- 100+ weapon catalogs before slice proof

## RETURN

```text
CANDIDATE
SOURCE
SCRIPT/DEPENDENCY
GRIP/PIVOT
R15 SCALE
SILHOUETTE READABILITY
STYLE FIT
APPROVE / HOLD / REJECT
```

STOP after report.

---

# TASK 03 — Enemy Family Discovery

Run only after environment vocabulary is approved.

## GOAL

Identify one coherent visual family capable of filling:
- two normal-enemy roles
- one larger elite/boss role

Do not start by requiring goblins, orcs, wolves, skeletons, etc.

Actual good available visuals determine the content identity.

## SEARCH PRIORITY

1. safe/official or known coherent character families if available
2. one consistent Creator Store creator/style family
3. rigged visuals with no scripts or minimal removable scripts
4. animation-ready rigs

## AUDIT EACH CANDIDATE

- creator/source
- script/module/local scripts
- numeric/remote requires
- Humanoid/Animator/custom rig organization
- idle/walk/attack/hit/death feasibility
- pivot/model integrity
- scale beside R15
- collision/hitbox feasibility
- visual fit with environment
- repetition cost

Do not retain bundled enemy AI architecture by default.

Explicit web-prefilter holds/rejects:
- legacy goblin `462605` — reject
- generic goblin `13968291587` — hold unless independently justified
- Armored Dev Monster `89665288942186` — hold; paid + bundled AI + fit unknown

## RETURN

```text
FAMILY / CREATOR
NORMAL A
NORMAL B
BOSS-CAPABLE
SCRIPT/DEPENDENCY
RIG
ANIMATION FEASIBILITY
STYLE FIT
PERFORMANCE
APPROVE / HOLD / REJECT
```

If no coherent family is good enough, say `MISSING ENEMY VOCABULARY` instead of filling the gap with weak art.

STOP after report.

---

# TASK 04 — Armor + Minimal VFX Check

Run after TASK 01–03 decisions.

## GOAL

Determine whether the first slice can support:
- visible player equipment progression
- simple consistent combat feedback

Do not build a giant armor/VFX collection.

## ARMOR

Need at most 2–3 coherent early looks.

Check:
- R15/layered compatibility
- clipping during locomotion and basic attacks
- style fit
- readability
- script/dependency surface

If no good armor family exists, defer armor visuals. Do not fabricate primitive production armor.

## VFX

Only secure visual material for:
- swing/trail
- impact
- loot/reward burst
- obvious boss AoE telegraph

Normalize later to one palette/timing system.

## RETURN

```text
ARMOR: approve/hold/missing
VFX: approve/hold/missing
source ids
script/dependency notes
style fit
technical issues
```

STOP after report.

---

# SUPERVISOR GATE AFTER TASK 04

Do not build the first production zone until the evidence is summarized as:

```text
APPROVED ENVIRONMENT VOCABULARY
APPROVED STRUCTURE VOCABULARY
APPROVED WEAPON VOCABULARY
APPROVED ENEMY VOCABULARY
APPROVED/DEFERRED ARMOR
APPROVED MINIMAL VFX
MISSING ITEMS
```

Then the supervisor creates:
- `ASSET_APPROVAL_001.md`
- first-zone spatial plan
- placement table
- first Agent build task

Only then proceed:

```text
terrain/bounds
→ spawn/safe hub
→ main route
→ first combat pocket
→ landmark
→ reward/progression
→ gameplay-camera QA
```
