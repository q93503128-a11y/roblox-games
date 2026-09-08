# Rebirth RPG — Studio Assistant Phase 0 Paste Prompt

> Operator bridge only. Canonical execution contract remains `STUDIO_AGENT_PHASE0_EXECUTE_NOW.md`.
> If this bridge and the canonical task ever differ, STOP and follow the canonical task.

Paste the block below into **Roblox Studio Assistant** while the intended Rebirth RPG place is open.

Before running, keep `STUDIO_PHASE0_RESULT_TEMPLATE.md` available. The Assistant must use that template as the evidence contract for the final result. A PASS based only on code inspection or memory is invalid.

```text
GOAL
Run Rebirth RPG Phase 0 only: inspect the currently open place, connect/verify the existing Script Sync code, create one explicit smoke anchor based on the real floor, run the core Play route, report evidence, then STOP.

CURRENT CONTEXT
Project code is in the local checkout of q93503128-a11y/roblox-games under projects/rebirth-rpg/scripts/.
Canonical Script Sync roots are:
- scripts/Shared -> ReplicatedStorage/RebirthRPG/Shared
- scripts/Server -> ServerScriptService/RebirthRPG
- scripts/Client -> StarterPlayer/StarterPlayerScripts/RebirthRPG
Disk naming is already normalized:
- *.luau = ModuleScript
- *.server.luau = Script with Server RunContext
- *.client.luau = Script with Client RunContext

DO NOT CHANGE
- Do not build a production map.
- Do not import production environment/enemy/weapon packs.
- Do not rewrite gameplay architecture without an observed runtime failure.
- Do not add third-party gameplay scripts.
- Do not guess world coordinates.
- Do not overwrite unrelated verified project content.
- Do not claim Studio tested without actual Play evidence.
- Do not mark an unobserved item PASS; use NOT OBSERVED / HOLD.

STEP 1 — INSPECT BEFORE EDITING
Report:
- place/experience identity
- Workspace top-level children
- floor/terrain state
- SpawnLocation state
- camera/FOV basics
- whether each RebirthRPG sync root already exists
- whether unrelated verified project content exists
If this is clearly another project's place, STOP without modifying anything.

STEP 2 — SCRIPT SYNC / TYPES
Use the existing Script Sync setup if already connected.
If local folder selection requires user interaction, STOP at that UI blocker and tell the user exactly which of the three repo folders must be selected; do not manually retype repository code.
After sync, verify:
- Protocol = ModuleScript
- GameConfig, ConfigValidator, ProfileService, RewardService, CombatService, EnemyService, RebirthService, StudioSmokeHarness, StudioTestHooks = ModuleScript
- ServerBootstrap = Script with Server RunContext
- ClientBootstrap = Script with Client RunContext
- duplicate RebirthRPG project scripts elsewhere = 0
Resolve any Script Sync conflict deliberately; do not blindly overwrite unknown Studio code.

STEP 3 — SMOKE ANCHOR
Inspect the actual floor and SpawnLocation first.
Choose a safe empty floor area with enough clearance for three encounters.
Create exactly one BasePart:
Name = RebirthRPG_SmokeOrigin
Anchored = true
CanCollide = false
Transparency = 1
Set Workspace attribute RebirthRPG_EnableSmokeHarness = true.
Do not invent additional world geometry unless a safe floor is genuinely required.

STEP 4 — PLAY / BOOT
Start normal one-player Play.
Check Output for the staged RebirthRPG boot logs and require project-attributable unexpected runtime errors = 0.
Verify player spawn, internal HUD, Level 1 / XP 0 / Gold 0 / Rebirth 0, mainhand weapon_start_a, three smoke enemies, and visibly grounded rigs.
If boot fails: evidence -> root cause -> smallest coherent fix -> exact boot replay before continuing.

STEP 5 — NORMAL PLAYER ROUTE
A) Smoke Enemy A
- basic Attack and Skill both cause server damage
- spam cannot bypass cooldown/busy state
- Skill is stronger than first basic hit
- enemy windup can miss after moving out of plausible range
- wall/obstruction blocks melee when applicable
- death grants XP/Gold once
- enemy respawns

B) Smoke Enemy B
- defeat it normally
- weapon_start_b granted exactly once
- Equip Weapon B appears and equip succeeds
- repeated kills do not duplicate the unique weapon
- practical TTK/hit count improves versus Weapon A

C) Smoke Boss
- defeat it with Weapon B
- boss is materially tougher
- reward occurs once
- boss_region_01_cleared becomes true
- boss later respawns

D) Player respawn
- reset or die
- respawn succeeds
- same-session profile survives
- Weapon B ownership/equipped state survives
- Attack/Skill still work

E) Rebirth
From SERVER context in Studio only run:
local hooks = require(game.ServerScriptService.RebirthRPG.StudioTestHooks)
local player = game.Players:GetPlayers()[1]
hooks.PrepareRebirthEligible(player)
Then request Rebirth through the normal client Rebirth control.
Verify Rebirth +1, Level 1, XP 0, Gold 0, current region progress reset, R1 milestone present, provisional equipment retention intact, and R1 acceleration visible on the next Enemy A interaction.

CURRENT CONFIG BASELINES FOR DRIFT CHECK
At Level 1 / R0:
- Enemy A HP 38
- Weapon A first basic 10
- Weapon A skill 19
- Weapon B first basic 21
- Weapon B skill 44
- Enemy A reward 16 XP / 6 Gold
At Level 1 / R1 after reset:
- Weapon A first basic 11
- Weapon A skill 20
- Enemy A reward 22 XP / 8 Gold
These numbers are drift checks, not permission to bypass normal state/input.

FAILURE RULE
For every failure:
evidence -> root cause -> smallest coherent fix -> exact failed-route replay -> quick regression of earlier passed route.
If the same subsystem structurally fails twice, STOP and report the architecture/workflow issue instead of stacking patches.

EVIDENCE CONTRACT
Use docs/STUDIO_PHASE0_RESULT_TEMPLATE.md for the final result.
- Record observed values, not only PASS/FAIL.
- Use NOT OBSERVED when direct evidence is missing.
- Record the first project-attributable Output error/warning when relevant.
- Record actual player level during Weapon B comparison because progression can change damage.
- Keep each failed route as a separate evidence -> root cause -> fix -> replay block.
- Capture when available: spawn+HUD, Enemy A combat, Weapon B equipped, Boss/clear state, and Output.

FINAL REPORT MINIMUM
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
- BOOT: PASS / FAIL / NOT OBSERVED
- HUD INITIAL STATE: PASS / FAIL / NOT OBSERVED
- SMOKE RIG GROUNDING: PASS / FAIL / NOT OBSERVED
- ATTACK: PASS / FAIL / NOT OBSERVED
- SKILL: PASS / FAIL / NOT OBSERVED
- ENEMY WINDUP / LOS: PASS / FAIL / NOT OBSERVED
- ENEMY A REWARD: PASS / FAIL / NOT OBSERVED
- ENEMY A RESPAWN: PASS / FAIL / NOT OBSERVED
- WEAPON B GRANT: PASS / FAIL / NOT OBSERVED
- WEAPON B EQUIP: PASS / FAIL / NOT OBSERVED
- UNIQUE DROP DEDUPE: PASS / FAIL / NOT OBSERVED
- BOSS CLEAR: PASS / FAIL / NOT OBSERVED
- PLAYER RESPAWN: PASS / FAIL / NOT OBSERVED
- REBIRTH TRANSITION: PASS / FAIL / NOT OBSERVED
- R1 ACCELERATION: PASS / FAIL / NOT OBSERVED
- PROJECT-ATTRIBUTABLE UNEXPECTED ERRORS: <count / NOT OBSERVED>

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

PASS is allowed only when every P0 structural route was directly observed and project-attributable unexpected runtime errors = 0.
STOP after this report. Do not begin asset intake or production map work.
```
