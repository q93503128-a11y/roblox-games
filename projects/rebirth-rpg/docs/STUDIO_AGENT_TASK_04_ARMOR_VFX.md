# Rebirth RPG — Studio Agent Task 04: Armor + Minimal VFX

> run after TASK 01–03 evidence exists
> scope: visible equipment progression + minimal combat feedback only
> stop after report

## GOAL

Determine whether the first Vertical Slice can support:
- 2–3 coherent early player equipment looks
- one small consistent VFX vocabulary for basic combat/reward feedback

Do not create a giant armor catalog or VFX library.

## CURRENT CONTEXT

Target game:
- simple Roblox fantasy action RPG
- brain-off farming/progression
- kill → loot → equip → area → boss → rebirth
- visual identity follows secured assets, not AI-invented taxonomy

Read:
- approved TASK 01 environment evidence
- approved TASK 02 weapon evidence
- approved TASK 03 enemy evidence
- `projects/rebirth-rpg/docs/ASSET_APPROVAL_GATE_001.md`

## ARMOR CHECK

Need at most 2–3 coherent early looks.

Inspect:
- creator/source
- Script / LocalScript / ModuleScript count
- external dependencies
- R15 / layered compatibility
- attachment/binding approach
- clipping during idle/walk/basic attack
- gameplay-camera readability
- style fit with environment/weapons/enemies
- performance concern

If no good family exists, return `ARMOR VISUALS DEFERRED`.
Do not fabricate primitive Part armor.

## VFX CHECK

Secure only enough material for:
- weapon swing/trail
- hit impact
- loot/reward burst
- obvious boss AoE telegraph

Inspect:
- source/creator
- scripts/dependencies
- particle/beam/trail structure
- brightness/readability
- duration/scale suitability
- mobile/performance concern
- style fit with approved visual family

Do not keep a large effect library in runtime hierarchy.
Do not normalize final palette/timing in this task; only identify usable source material.

## REQUIRED REPORT

```text
ARMOR FAMILY / SOURCE
SCRIPT/DEPENDENCY
R15 COMPATIBILITY
CLIPPING
STYLE FIT
PERFORMANCE
APPROVE / HOLD / DEFER

VFX SOURCE
SWING/TRAIL
IMPACT
LOOT/REWARD
BOSS TELEGRAPH
SCRIPT/DEPENDENCY
STYLE FIT
PERFORMANCE
APPROVE / HOLD / MISSING
```

## ACCEPTANCE

Task succeeds if:
- armor is approved or honestly deferred
- minimal VFX source is approved or honestly reported missing
- no unrelated giant catalog is imported
- no unsafe executable code is accepted
- all judgments come from actual Studio inspection

## STOP CONDITIONS

STOP if:
- prior task evidence is missing
- current place is wrong/contaminated
- suspicious executable behavior appears
- visual family becomes incoherent
- paid purchase is required

STOP after report. Do not begin final map construction.
