# Rebirth RPG — Studio Agent Start Here

Use this file as the Studio execution entrypoint.

## RUN NOW

For the current Phase 0, use the executable field task:

`STUDIO_AGENT_PHASE0_EXECUTE_NOW.md`

That file is the authoritative Studio action prompt for:

```text
inspect place
→ Script Sync/type verification
→ explicit smoke anchor
→ Play
→ Enemy A
→ Enemy B / Weapon B
→ Boss
→ player respawn
→ Rebirth
→ evidence / root-cause fix / exact route replay
→ STOP
```

If the operator is using Roblox Studio Assistant and needs a **single block to paste into Assistant**, use:

`STUDIO_AGENT_PHASE0_PASTE_PROMPT.md`

The paste prompt is only an operator bridge. `STUDIO_AGENT_PHASE0_EXECUTE_NOW.md` remains canonical if the two ever differ.

Do not skip directly to production assets or map building.

## Current state

The project is in **active development**.

Project-owned gameplay core code exists under:

```text
projects/rebirth-rpg/scripts/
```

It includes the current profile/progression/combat/reward/enemy/rebirth shell, but it is still:

```text
CODE WRITTEN
NOT STUDIO TESTED
```

Do not build the final map yet.
Do not rewrite the gameplay core unless an actual Studio failure provides evidence.

Read first:
- `STUDIO_AGENT_PHASE0_EXECUTE_NOW.md`
- `STUDIO_AGENT_PHASE0_PASTE_PROMPT.md` when operating through Roblox Studio Assistant
- `DEVELOPMENT_SLICE_001_STATUS.md`
- `SCRIPT_SYNC_RUNTIME_LAYOUT_001.md`
- `STUDIO_CORE_SMOKE_TEST_001.md`

---

# PHASE 0 SUMMARY — CODE INTEGRATION + CORE SMOKE TEST

## GOAL

Connect the existing code to a clean Rebirth RPG Studio test place and prove one structural gameplay route before production asset work.

This phase does **not** choose final enemy/weapon/environment art.

## 0A — INSPECT PLACE

Before syncing or creating anything, report:

```text
PLACE IDENTITY
WORKSPACE TOP-LEVEL
SPAWN / FLOOR STATE
EXISTING RebirthRPG CODE FOLDERS
UNRELATED VERIFIED PROJECT CONTENT: YES / NO
```

If unrelated verified project content exists, STOP.

## 0B — DISK PREFLIGHT + SCRIPT SYNC

Before linking folders, confirm the repository side uses the canonical current Script Sync names:

```text
scripts/Shared/Protocol.luau
scripts/Server/ServerBootstrap.server.luau
scripts/Client/ClientBootstrap.client.luau
```

Server service modules should use plain `.luau` names such as `GameConfig.luau`, `CombatService.luau`, and `EnemyService.luau`.

If parallel legacy `.lua` copies appear in these folders, STOP and report rather than syncing duplicates.

Then follow exactly:

`SCRIPT_SYNC_RUNTIME_LAYOUT_001.md`

Expected mapping:

```text
scripts/Shared → ReplicatedStorage/RebirthRPG/Shared
scripts/Server → ServerScriptService/RebirthRPG
scripts/Client → StarterPlayer/StarterPlayerScripts/RebirthRPG
```

Resolve initial sync conflicts deliberately. Do not overwrite unknown Studio code blindly.

After sync, verify in Studio that:
- `Protocol` is a ModuleScript
- `ServerBootstrap` is a Script with Server RunContext
- `ClientBootstrap` is a Script with Client RunContext
- service files are ModuleScripts
- duplicate RebirthRPG scripts do not exist elsewhere

## 0C — CREATE SMOKE ANCHOR

Inspect actual floor/spawn/camera first.

Then create one explicit test BasePart in a safe empty test area:

```text
Name = RebirthRPG_SmokeOrigin
Anchored = true
CanCollide = false
Transparency = 1
```

Do not copy a guessed world coordinate from documentation.

Set Workspace attribute:

```text
RebirthRPG_EnableSmokeHarness = true
```

## 0D — PLAY / TEST

Run the complete route from:

`STUDIO_CORE_SMOKE_TEST_001.md`

Minimum required:

```text
clean boot
→ Attack/Skill damage
→ Enemy A death → XP/Gold
→ Enemy B death → Weapon B guaranteed
→ equip Weapon B
→ practical TTK improvement
→ Boss death → clear flag
→ player death/respawn
→ Studio-only rebirth state transition
```

The smoke rigs are temporary sanitized R15 debug rigs. They are **not production enemy art**.

## 0E — REPORT AND STOP

Do not proceed to asset intake if a core structural route failed.
Use:

`evidence → root cause → smallest coherent fix → exact failed route replay → regression`

---

# AFTER PHASE 0 PASSES — ASSET RUN ORDER

Disable the smoke harness for production-oriented playtests:

```text
RebirthRPG_EnableSmokeHarness = false
```

Then run one asset task at a time:

1. `STUDIO_AGENT_TASK_01_ENVIRONMENT.md`
2. supervisor review
3. `STUDIO_AGENT_TASK_02_WEAPONS.md`
4. supervisor review
5. `STUDIO_AGENT_TASK_03_ENEMIES.md`
6. supervisor review
7. `STUDIO_AGENT_TASK_04_ARMOR_VFX.md`
8. `ASSET_APPROVAL_001.md`
9. `SUPERVISOR_POST_ASSET_INPUT_001.md`
10. first-zone spatial plan
11. build one coherent production section
12. gameplay-camera / P0 regression

## Hard rules

- debug smoke rigs never become production enemies
- no third-party enemy gameplay scripts
- approved enemy models must contain zero Script/LocalScript/ModuleScript descendants before binding
- do not create the full map one-shot
- do not replace stable gameplay IDs just because visual assets have different names
- do not call a code-written route implemented until actual Studio Play passes
