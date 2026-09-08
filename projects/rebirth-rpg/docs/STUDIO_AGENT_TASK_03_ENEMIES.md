# Rebirth RPG — Studio Agent Task 03: Enemy Family Discovery

> run only after environment approval
> scope: enemy visuals/rig feasibility only
> stop after report

## GOAL

Find **one coherent enemy visual family** that can supply:
- Normal Enemy A
- Normal Enemy B
- one larger Elite/Boss-capable silhouette

Do not begin with required labels such as goblin/orc/wolf/skeleton. The actual approved visual family determines the enemy identity.

## CURRENT CONTEXT

Game direction:
- common Roblox fantasy RPG
- intentionally low-cognitive-load farming
- enemies should be readable, repeatable, and quick to understand
- bosses remain simple; no complicated prestige-specific phases

Read:
- `projects/rebirth-rpg/README.md`
- `projects/rebirth-rpg/ASSET_SOURCES.md`
- `projects/rebirth-rpg/docs/ASSET_APPROVAL_GATE_001.md`
- approved environment evidence

## SEARCH PRIORITY

1. safe/official or already-audited coherent families
2. one creator/style family with multiple usable silhouettes
3. rigged visual assets with no scripts or minimal removable scripts
4. animation-ready Humanoid/Animator or clearly usable custom rig

Do not collect random monsters from unrelated creators.

## DO NOT CHANGE

- final map
- final enemy names/lore
- combat architecture
- progression/balance
- boss mechanics
- paid assets without approval

Bundled enemy AI is not project authority and should not be adopted by default.

## AUDIT EACH CANDIDATE

- asset id / creator / source
- Script / LocalScript / ModuleScript count
- external/numeric requires
- Humanoid / Animator / bones / Motor6D organization
- model pivot integrity
- scale beside R15 reference rig
- idle feasibility
- walk/run feasibility
- basic attack feasibility
- hit reaction feasibility
- death feasibility
- collision/hitbox feasibility
- gameplay-camera silhouette
- fit with approved environment/weapon family
- repetition/performance concern

## WEB PREFILTER REJECT/HOLD

- legacy Goblin `462605` — REJECT
- generic Goblin `13968291587` — HOLD unless actual Studio evidence justifies it
- Armored Dev Monster `89665288942186` — HOLD; bundled AI/paid/style fit not established

## REQUIRED REPORT

```text
FAMILY / CREATOR
SOURCE IDS
NORMAL A
NORMAL B
BOSS-CAPABLE
SCRIPT COUNTS
DEPENDENCIES
RIG ORGANIZATION
ANIMATION FEASIBILITY
PIVOT / SCALE
COLLISION / HITBOX FEASIBILITY
GAMEPLAY-CAMERA READABILITY
STYLE FIT
REPETITION/PERFORMANCE
APPROVE / HOLD / REJECT
REASON
```

Then summarize:

```text
APPROVED FAMILY:
NORMAL A VISUAL:
NORMAL B VISUAL:
BOSS-CAPABLE VISUAL:
MISSING VOCABULARY:
```

Do not assign final names until supervisor maps the secured visuals to content roles.

## ACCEPTANCE

Task succeeds if either:
- one coherent family supports all three roles, OR
- missing enemy vocabulary is explicitly reported with evidence.

Never lower the art-quality bar just to return three assets.

## STOP CONDITIONS

STOP if:
- current place is contaminated with unrelated project content
- suspicious executable behavior appears
- no coherent family exists
- rigs are technically unusable without major rebuild
- a paid purchase is required

STOP after report. Do not proceed to armor/VFX automatically.
