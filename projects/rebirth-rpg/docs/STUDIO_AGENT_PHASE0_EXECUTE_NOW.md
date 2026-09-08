# Rebirth RPG — Studio Agent PHASE 0 Execute Now

> scope: actual Roblox Studio integration + runtime smoke test only
> stop gate: report after the smoke route; do not begin production map or asset intake

## GOAL

Use the **currently open Roblox Studio place** as the source of truth, connect the current Rebirth RPG code, and prove the first structural gameplay route in Play mode.

Current repo project:
`q93503128-a11y/roblox-games/projects/rebirth-rpg`

Current Script Sync disk convention:
- ModuleScript: `*.luau`
- server Script: `*.server.luau`
- client Script: `*.client.luau`

Do not recreate old `.lua` duplicates.

## CURRENT CONTEXT

Game target:
- simple brain-off Roblox action RPG
- hunt → XP/Gold/loot → stronger weapon → boss → rebirth
- stable gameplay IDs stay visual-neutral until asset approval

This Phase 0 intentionally uses temporary R15 smoke rigs. They are test fixtures, not enemy art.

Read before acting:
- `README.md`
- `docs/DEVELOPMENT_SLICE_001_STATUS.md`
- `docs/SCRIPT_SYNC_RUNTIME_LAYOUT_001.md`
- `docs/STUDIO_CORE_SMOKE_TEST_001.md`

## DO NOT CHANGE

- do not build the production map
- do not import production environment/enemy/weapon packs yet
- do not rewrite the combat/profile/rebirth architecture unless an actual runtime failure proves it necessary
- do not add third-party gameplay scripts
- do not invent absolute coordinates from this prompt
- do not claim success without Play evidence

## STEP 1 — INSPECT THE OPEN PLACE FIRST

Before modifying anything, inspect and report:

```text
PLACE / EXPERIENCE IDENTITY
WORKSPACE TOP-LEVEL CHILDREN
FLOOR / TERRAIN STATE
SPAWNLOCATION STATE
CAMERA / FOV BASICS
ReplicatedStorage/RebirthRPG: present / absent
ServerScriptService/RebirthRPG: present / absent
StarterPlayer/StarterPlayerScripts/RebirthRPG: present / absent
UNRELATED VERIFIED PROJECT CONTENT: YES / NO
```

If this is clearly another project's verified place, STOP without changing it.

## STEP 2 — VERIFY SCRIPT SYNC RESULT

Use the existing Script Sync setup or help the user connect the three canonical roots if needed:

```text
projects/rebirth-rpg/scripts/Shared
→ ReplicatedStorage/RebirthRPG/Shared

projects/rebirth-rpg/scripts/Server
→ ServerScriptService/RebirthRPG

projects/rebirth-rpg/scripts/Client
→ StarterPlayer/StarterPlayerScripts/RebirthRPG
```

After sync, inspect exact Studio instance types.

Must be true:

```text
Protocol = ModuleScript
GameConfig = ModuleScript
ConfigValidator = ModuleScript
ProfileService = ModuleScript
RewardService = ModuleScript
CombatService = ModuleScript
EnemyService = ModuleScript
RebirthService = ModuleScript
StudioSmokeHarness = ModuleScript
StudioTestHooks = ModuleScript
ServerBootstrap = Script with Server RunContext
ClientBootstrap = Script with Client RunContext
```

Also verify there are no duplicate old `RebirthRPG` scripts elsewhere.

If Script Sync cannot be completed from the current Studio environment, STOP and report the exact UI/state blocker instead of manually retyping the repository code.

## STEP 3 — CREATE ONE EXPLICIT SMOKE ANCHOR

Inspect the actual floor and SpawnLocation first.

Choose a safe, empty floor area with enough clearance for three encounters. Do **not** use coordinates from this document.

Create one BasePart:

```text
Name = RebirthRPG_SmokeOrigin
Anchored = true
CanCollide = false
Transparency = 1
```

Set Workspace attribute:

```text
RebirthRPG_EnableSmokeHarness = true
```

Do not create any other test world geometry unless needed to provide a safe floor.

## STEP 4 — PLAY AND CHECK BOOT

Start Play as one player.

Inspect Output.

Required staged logs include:

```text
[RebirthRPG] boot: shared protocol ready
[RebirthRPG] boot: config/protocol validation passed
[RebirthRPG] boot: remote contract ready
[RebirthRPG] boot: profile/reward/combat/rebirth services ready
[RebirthRPG] boot: enemy service ready
[RebirthRPG] boot: server bootstrap ready
```

When enabled, also expect the Studio smoke harness log.

PASS only if project-attributable unexpected runtime errors = 0.

Verify:
- player spawns normally
- internal HUD appears
- Level 1 / Gold 0 / Rebirth 0
- mainhand `weapon_start_a`
- Smoke Enemy A/B/Boss exist
- each smoke rig is visibly grounded, not buried or floating

If boot fails, identify the **first real project failure**, apply the smallest coherent fix, and replay boot before continuing.

## STATIC EXPECTED NUMERIC BASELINES

These are **precomputed expectations from the current repository config**, not substitutes for Studio evidence. Use them to detect silent config/runtime drift during Phase 0.

At **Level 1 / Rebirth 0**:

```text
Enemy A max health = 38
Weapon A first basic hit = 10
Weapon A skill hit = 19
Weapon B first basic hit = 21
Weapon B skill hit = 44
Enemy A base reward = 16 XP / 6 Gold
```

At **Level 1 / Rebirth 1**, after a successful Rebirth reset:

```text
Weapon A first basic hit = 11
Weapon A skill hit = 20
Enemy A reward = 22 XP / 8 Gold
```

Important:
- actual Weapon A → Weapon B TTK comparison should be measured from the real route, because XP gained before equipping Weapon B may increase player level and therefore damage
- do not force the runtime to match these numbers by bypassing normal input/state transitions
- if observed values differ, inspect current synced `GameConfig`, player level/rebirth state, equipped weapon, and server damage/reward path before changing tuning

## STEP 5 — CORE ROUTE

Use normal player input and execute in this order.

### A. Enemy A

Test basic attack and Skill against Smoke Enemy A.

Pass:
- server damage occurs
- attack/skill spam does not bypass cooldown
- Skill is visibly stronger than a normal first hit
- enemy Windup can miss if player leaves plausible range
- wall/obstruction prevents melee damage when applicable
- one death grants XP + Gold once
- Enemy A respawns

### B. Enemy B / first upgrade

Move to Smoke Enemy B and defeat it.

Pass:
- `weapon_start_b` granted exactly once
- HUD exposes Equip Weapon B
- equip succeeds
- mainhand updates to `weapon_start_b`
- repeated Enemy B kills do not duplicate the unique weapon
- practical hit count / TTK improves materially versus Weapon A

### C. Boss

Defeat Smoke Boss using Weapon B.

Pass:
- boss is materially tougher than normal enemy
- XP/Gold awarded once
- `boss_region_01_cleared` becomes true
- boss later respawns

### D. Player respawn

Reset or allow the player to die.

Pass:
- character respawns
- same-server profile remains
- Weapon B ownership/equipped state remains
- attack/skill still work

### E. Rebirth state transition

From **server context in Studio only**, run:

```lua
local hooks = require(game.ServerScriptService.RebirthRPG.StudioTestHooks)
local player = game.Players:GetPlayers()[1]
hooks.PrepareRebirthEligible(player)
```

Then request Rebirth through the normal client control.

Pass:
- Rebirth count +1
- Level → 1
- XP → 0
- Gold → 0
- current region progress resets
- R1 milestone exists
- current provisional equipment-retention rule remains intact
- next Enemy A reward/damage reflects R1 acceleration

## STEP 6 — VISUAL/RUNTIME EVIDENCE

Before stopping, inspect from gameplay camera and capture evidence when available:

1. spawn + HUD
2. Enemy A combat
3. Weapon B equipped state
4. Boss encounter
5. Output with clean RebirthRPG boot

Do not evaluate production art quality from smoke rigs.

## FAILURE RULE

For every failure:

```text
evidence
→ root cause
→ smallest coherent fix
→ exact failed route replay
→ quick regression of earlier passed route
```

Do not stack symptom patches.
If the same subsystem fails structurally twice, STOP and report the architecture/workflow issue.

## REQUIRED FINAL REPORT

Return exactly this information with concrete evidence:

```text
STUDIO PLACE
- identity:
- existing/clean:
- unrelated verified content:

SCRIPT SYNC
- Shared mapping:
- Server mapping:
- Client mapping:
- instance types correct: YES / NO
- duplicate project scripts: 0 / <count>

RUNTIME
- BOOT: PASS / FAIL
- HUD INITIAL STATE: PASS / FAIL
- SMOKE RIG GROUNDING: PASS / FAIL
- ATTACK: PASS / FAIL
- SKILL: PASS / FAIL
- ENEMY WINDUP / LOS: PASS / FAIL
- ENEMY A REWARD: PASS / FAIL
- ENEMY A RESPAWN: PASS / FAIL
- WEAPON B GRANT: PASS / FAIL
- WEAPON B EQUIP: PASS / FAIL
- UNIQUE DROP DEDUPE: PASS / FAIL
- BOSS CLEAR: PASS / FAIL
- PLAYER RESPAWN: PASS / FAIL
- REBIRTH TRANSITION: PASS / FAIL
- R1 ACCELERATION: PASS / FAIL
- PROJECT-ATTRIBUTABLE UNEXPECTED ERRORS: <count>

FAILED & FIXED
- route:
- evidence:
- root cause:
- fix:
- replay result:

KNOWN LIMITATIONS
- ...

DECISION
- PHASE 0 PASS / PHASE 0 HOLD
```

## STOP CONDITIONS

STOP immediately if:
- wrong project place
- Script Sync would overwrite unrelated verified code
- first real boot failure cannot be isolated safely
- a core structural route remains failed after the smallest coherent fix

On success, also STOP after the report.
Do **not** continue to asset TASK 01 or production map building until the supervisor reviews the evidence.
