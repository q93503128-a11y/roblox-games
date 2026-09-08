# Rebirth RPG — Studio Agent Presentation Recovery 001

> status: READY TO RUN
> scope: inspect + plan + quarantine only
> current problem: runtime core mostly works, but the smoke build is not a credible RPG presentation
> STOP after report; do not one-shot implement the whole recovery

## GOAL

Inspect the currently open Rebirth RPG test place and prepare the next coherent Vertical Slice presentation pass.

We need evidence for:
- corrected control scheme
- real inventory/equipment UI structure
- visible equipped weapon path
- usable free/audited attack animation source
- clear active-skill presentation
- Rebirth menu/testing UX

This task does NOT build the final map.

## CURRENT CONTEXT / OBSERVED HUMAN TEST

The user opened the embedded Phase 0 rbxlx and directly observed:
- server boot sequence runs
- HUD appears
- smoke enemies spawn
- non-Rebirth core routes generally work
- Rebirth was NOT tested because natural leveling was too slow

Human presentation feedback:
- current HUD is ugly/internal
- no real inventory UI
- acquired/equipped weapon is not visibly represented on the character
- current E skill is visually indistinguishable from another attack
- production Rebirth on R is inappropriate
- no attack animation / weapon swing presentation

Treat these as real feedback, not hypothetical issues.

Canonical structure direction:
- `projects/rebirth-rpg/docs/REFERENCE_STRUCTURE_MATRIX_001.md`
- `knowledge/gameplay/INVENTORY_EQUIPMENT_ARCHITECTURE.md`
- `knowledge/production/REUSABLE_PACKAGE_AND_QA_SYSTEM.md`
- current Rebirth RPG source under `projects/rebirth-rpg/scripts/`

## TARGET CONTROL DIRECTION

Do not blindly apply until inspecting current conflicts, but plan around:

```text
M1 = basic attack
Q = dash / combat mobility
E = interact / talk / chest / portal / world action
1 = first active weapon skill
2–4 = future skill slots, not mandatory now
Rebirth = progression UI/menu only; remove production R hotkey
Inventory = visible bag button + one conflict-safe keyboard shortcut after inspection
```

If Studio/Roblox default controls create a conflict, report it and recommend the least surprising alternative.

## DO NOT CHANGE

During this task:
- do not build the production map
- do not rewrite Profile/Reward/Enemy/Rebirth server architecture
- do not rebalance progression
- do not add pets/gacha/currencies
- do not import giant UI kits
- do not keep third-party gameplay scripts
- do not bind a random animation before visually inspecting it
- do not claim a weapon/animation approved without Studio evidence

## PASS A — INSPECT CURRENT PLACE

Report actual current state:

```text
PLACE / FILE IDENTITY
WORKSPACE TOP-LEVEL
CURRENT GUIS
CURRENT INPUT BINDS
CURRENT CLIENT SCRIPTS
CURRENT SERVER SCRIPTS
CURRENT PLAYER EQUIPMENT VISUALS
CURRENT INVENTORY REPRESENTATION
CURRENT ENEMY HEALTH PRESENTATION
CURRENT BOSS PRESENTATION
CURRENT REBIRTH ACCESS
PROJECT-ATTRIBUTABLE OUTPUT ERRORS/WARNINGS
```

Confirm specifically whether:
- M1 works
- E currently triggers SkillIntent
- R currently triggers RequestRebirth
- any default Roblox Backpack/hotbar is active
- Weapon B ownership/equip has any runtime Tool/Model representation

## PASS B — UI ARCHITECTURE PLAN

Do not implement yet. Produce a concrete first-slice UI hierarchy plan.

Minimum expected user-facing states:

### Persistent HUD
- HP
- Level + XP bar
- Gold
- bottom action/skill slots
- cooldown display
- inventory/bag button
- objective/progression cue

### Inventory
- item grid
- equipped highlight
- mainhand slot
- item details
- Weapon A/B comparison
- Equip action
- empty/loading state
- touch/gamepad consideration

### Contextual
- enemy health/name
- boss HP
- loot/reward toast
- level-up feedback
- interaction prompt

### Rebirth
- requirements
- reset list
- retained list
- permanent bonus
- next milestone unlock
- confirmation

Studio-only testing must have a fast eligibility route that is clearly separated from production UI.

For every planned panel/module, mark whether it can use/graduate toward a reusable Godbase component:
- InventoryCell
- EquipmentSlot
- ItemTooltip
- Toast
- ConfirmModal
- CurrencyDisplay
- MobileActionButton
- HealthBar
- InteractionShell

## PASS C — WEAPON VISUAL QUARANTINE

Use an isolated structure only, e.g.:

```text
Workspace
└─ _PresentationQuarantine
   ├─ Weapons
   ├─ AnimationsReference
   └─ R15ReferenceRig
```

Start with current safe candidate:
- Sword Pack `10226464132`

If unsuitable, search for one small coherent free alternative family.

For at least two candidate weapon silhouettes inspect:
- creator/source
- Script / LocalScript / ModuleScript counts
- external dependencies / requires
- model/mesh structure
- pivot/grip
- R15 scale
- third-person readability
- style fit with the current intended low-poly fantasy family
- animation feasibility

Do not adopt bundled combat scripts.

## PASS D — ATTACK ANIMATION QUARANTINE

Search Studio/Creator Store for free R15-compatible sword/basic melee animation candidates.

Prefer:
- clear creator/source
- animation-only or easily isolated animation assets
- no bundled combat framework
- readable basic slash motion
- at least enough coverage to support a 3-hit basic chain OR a coherent plan using one/two reusable clips

For every candidate record:
- asset ID
- creator/source
- rig compatibility
- animation priority recommendation
- approximate length/timing
- root motion concern
- weapon-hand compatibility
- whether it visually fits brain-off farming combat
- APPROVE / HOLD / REJECT

Do NOT trust an animation merely because it is free.

## PASS E — ACTIVE SKILL PRESENTATION PLAN

The current SkillIntent can remain structurally for now, but it must not look like a duplicate M1.

Plan one simple distinction based on actual weapon/animation availability, e.g.:
- heavier/larger swing
- short lunge
- broad cleave

Need:
- separate slot `1`
- visible cooldown
- distinct animation/readability
- server hit timing remains authoritative

Do not invent flashy anime effects if the approved source vocabulary does not support them.

## PASS F — REBIRTH TEST UX PLAN

Production:
- no R hotkey
- Rebirth accessed through progression/menu UI
- confirm before reset
- show requirement/reset/keep/bonus/unlock

Studio-only:
- one clearly marked developer/test action to call existing Studio test hook or equivalent
- tester can become eligible in seconds
- then tester uses the NORMAL production Rebirth menu/button

The developer action must never appear in live production.

## REQUIRED REPORT

```text
CURRENT PLACE
- identity:
- output errors/warnings:

CURRENT CONTROLS
- M1:
- Q:
- E:
- R:
- numeric keys:
- inventory shortcut:
- Roblox/default conflicts:

PRESENTATION GAPS
- HUD:
- inventory:
- equipment visual:
- combat animation:
- health bars:
- loot feedback:
- rebirth UX:

UI IMPLEMENTATION PLAN
- persistent HUD hierarchy:
- inventory hierarchy:
- contextual UI:
- rebirth UI:
- reusable component candidates:

WEAPON QUARANTINE
- candidate A:
- candidate B:
- creator/source:
- scripts/dependencies:
- grip/scale:
- style/readability:
- decision:

ANIMATION QUARANTINE
- candidate IDs:
- creator/source:
- R15 compatibility:
- timing:
- root motion:
- decision:

TARGET CONTROLS AFTER REVIEW
- M1:
- Q:
- E:
- 1:
- 2–4:
- inventory:
- rebirth:

FIRST COHERENT IMPLEMENTATION SECTION
- exact objects/scripts/UI to change:
- exact objects/scripts/UI NOT to change:
- acceptance criteria:
- test route:

KNOWN LIMITATIONS
- ...

DECISION
- READY FOR PRESENTATION IMPLEMENTATION / HOLD
```

## ACCEPTANCE

This inspection pass succeeds when:
- current Studio state was actually inspected
- the current E/R problem is confirmed from DataModel/input code, not guessed
- inventory/equipment presentation architecture is concrete
- two weapon visuals are inspected or missing vocabulary is reported
- at least one viable animation direction is inspected or missing vocabulary is reported
- no unsafe external scripts are adopted
- one coherent next implementation section is defined

## STOP CONDITIONS

STOP and report if:
- wrong place/project
- suspicious asset code/dependency
- no usable free weapon/animation source is found
- fixing presentation would require rewriting the authoritative server core
- the current rbxlx differs materially from the expected Rebirth RPG code

STOP after the report. Do not implement the whole UI/combat/map automatically.
