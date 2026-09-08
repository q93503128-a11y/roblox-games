# Rebirth RPG — Studio Agent Start Here

Use this file as the Studio execution entrypoint.

## Current state

The project is now in **active development**.

Project-owned gameplay core code already exists under:

```text
projects/rebirth-rpg/scripts/
```

Current code covers the first server-owned profile/combat/reward/enemy/rebirth shell, but it is **NOT STUDIO TESTED**.

Do not build the final map yet.
Do not rewrite the gameplay core during the visual asset audit unless an actual integration failure proves a change is required.

Read implementation status:
- `DEVELOPMENT_SLICE_001_STATUS.md`
- `SCRIPT_SYNC_RUNTIME_LAYOUT_001.md`

## Asset run order

Run exactly one asset task at a time:

1. `STUDIO_AGENT_TASK_01_ENVIRONMENT.md`
2. supervisor reviews evidence
3. `STUDIO_AGENT_TASK_02_WEAPONS.md`
4. supervisor reviews evidence
5. `STUDIO_AGENT_TASK_03_ENEMIES.md`
6. supervisor reviews evidence
7. `STUDIO_AGENT_TASK_04_ARMOR_VFX.md`
8. supervisor creates `ASSET_APPROVAL_001.md`
9. supervisor fills `SUPERVISOR_POST_ASSET_INPUT_001.md`
10. first-zone spatial plan
11. one coherent Studio build section

## Run now

**Only TASK 01 — environment audit.**

Open/copy:
`projects/rebirth-rpg/docs/STUDIO_AGENT_TASK_01_ENVIRONMENT.md`

Expected result:
- current place safety inspection
- Synty Nature `6933438443` actual Studio inspection
- Synty Dungeon `6934021345` actual Studio inspection
- R15-relative scale evidence
- pivot/collision/material/dependency evidence
- curated environment subset
- APPROVE / HOLD / REJECT

Use:
`STUDIO_AGENT_TASK_01_RESULT_TEMPLATE.md`

## What NOT to do during TASK 01

- do not make the production map
- do not bulk-place environment props
- do not invent monster or equipment art
- do not replace current profile/combat/rebirth architecture
- do not import a third-party combat/NPC system
- do not claim the existing repository code works in Studio without Play evidence

## After asset approval

Only after TASK 01–04 evidence is approved:

```text
set up Script Sync per SCRIPT_SYNC_RUNTIME_LAYOUT_001.md
→ sync current project scripts into the inspected place
→ bind ONE sanitized Enemy A rig using RebirthRPG_Enemy + EnemyId
→ clean Play boot
→ attack → kill → XP/Gold → loot/equip smoke test
→ Studio-only Rebirth eligible profile test
→ fix only evidenced failures
→ first-zone spatial plan
```

## Hard stop

After TASK 01 report, STOP.
Do not automatically continue to TASK 02 or alter the current code just because the audit found a visually different asset family.

The next step is selected only after the supervisor reviews the Studio evidence.
