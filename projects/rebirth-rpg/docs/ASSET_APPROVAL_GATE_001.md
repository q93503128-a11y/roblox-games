# Rebirth RPG — Asset Approval Gate 001

> purpose: block premature world/content design until Studio evidence exists

This document is a gate, not a completed approval report.

## Rule

The first production zone must not be designed from invented content requirements.
It may be designed only after Studio evidence establishes enough visual vocabulary.

## Required categories before first production-zone build

### Environment

Need:
- one approved field/nature family
- one approved structure/dungeon family or a documented decision to defer dungeon production
- R15-relative scale evidence
- pivot/collision/material evidence

Status:
`PENDING TASK 01`

### Weapons

Need:
- two coherent early weapon silhouettes
- grip/pivot and R15 scale checked
- no inherited third-party combat architecture

Status:
`PENDING TASK 02`

### Enemies

Need:
- two normal-enemy-capable visuals
- one elite/boss-capable visual
- one coherent family or explicitly compatible family
- rig/animation feasibility checked
- bundled AI scripts rejected or sanitized

Status:
`PENDING TASK 03`

### Player equipment

Need:
- 0–3 early coherent looks
- may be intentionally deferred if no good family exists

Status:
`PENDING TASK 04 / DEFERRABLE`

### Minimal VFX

Need only:
- swing/trail
- impact
- loot/reward
- obvious boss AoE telegraph

Status:
`PENDING TASK 04`

## Promotion states

Use only these states:

```text
WEB_CANDIDATE
STUDIO_QUARANTINE
PROJECT_APPROVED
PROJECT_REJECTED
DEFERRED
```

Do not call a web-discovered asset approved.

## Supervisor decision table

Fill after TASK 01–04.

| Category | Approved family/source | Actual subset | Missing | Decision |
|---|---|---|---|---|
| Field environment |  |  |  |  |
| Structure/dungeon |  |  |  |  |
| Weapon A |  |  |  |  |
| Weapon B |  |  |  |  |
| Normal enemy A |  |  |  |  |
| Normal enemy B |  |  |  |  |
| Boss-capable enemy |  |  |  |  |
| Player equipment |  |  |  |  |
| Minimal VFX |  |  |  |  |

## Content mapping rule

Only after approval may secured visuals receive gameplay identities.

Example:

```text
approved small melee rig
→ Normal Enemy A
→ then choose fitting name/theme/stats
```

Not:

```text
we need a goblin
→ search until something vaguely goblin-like appears
```

Same for weapons, structures and bosses.

## First-zone design gate

The supervisor may write the first-zone spatial plan only if all are true:

- [ ] TASK 01 environment decision is APPROVE
- [ ] at least one field vocabulary is READY
- [ ] TASK 02 has two usable weapon visuals OR one style plus documented temporary second-style plan
- [ ] TASK 03 has a coherent enemy family OR explicitly approved compatible set
- [ ] no suspicious third-party code is promoted
- [ ] missing armor is explicitly allowed to defer
- [ ] first-zone visual target can be described from real approved assets

Then create:

1. `ASSET_APPROVAL_001.md`
2. `FIRST_ZONE_SPATIAL_PLAN_001.md`
3. placement table
4. Studio Agent first-section build task

## First-zone build order after gate

```text
inspect target Studio state
→ playable bounds / floor / spawn / R15 / camera
→ named anchors
→ safe hub shell
→ main route
→ first combat pocket
→ first landmark
→ reward/progression point
→ gameplay-camera review
→ P0 walk
```

No decoration flood before route quality is proven.
