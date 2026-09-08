# Rebirth RPG — Studio Phase 0 Result Template

> purpose: capture evidence from the actual Roblox Studio Phase 0 run without turning memory/impression into a PASS
> canonical execution task: `STUDIO_AGENT_PHASE0_EXECUTE_NOW.md`
> use only after or during the real Studio run

## RULE

Do not fill a row as PASS from code inspection alone.
Every PASS below requires direct Studio evidence from the current run.
If evidence is unavailable, use `NOT OBSERVED`, not PASS.

## RUN IDENTITY

```text
DATE/TIME:
PLACE NAME:
PLACE ID / EXPERIENCE ID (if visible):
STUDIO VERSION (if visible):
CURRENT GIT MAIN HEAD USED FOR SYNC:
OPERATOR: Roblox Studio Assistant / human / other
```

## PLACE PREFLIGHT

```text
WORKSPACE TOP-LEVEL CHILDREN:
FLOOR / TERRAIN:
SPAWNLOCATION:
CAMERA / FOV:
ReplicatedStorage/RebirthRPG present before sync: YES / NO
ServerScriptService/RebirthRPG present before sync: YES / NO
StarterPlayerScripts/RebirthRPG present before sync: YES / NO
UNRELATED VERIFIED PROJECT CONTENT: YES / NO
PREFLIGHT DECISION: CONTINUE / STOP
```

Evidence notes:

```text
...
```

## SCRIPT SYNC

```text
Shared mapping: PASS / FAIL / NOT OBSERVED
Server mapping: PASS / FAIL / NOT OBSERVED
Client mapping: PASS / FAIL / NOT OBSERVED
Protocol = ModuleScript: PASS / FAIL / NOT OBSERVED
Server service modules = ModuleScript: PASS / FAIL / NOT OBSERVED
ServerBootstrap = Script + Server RunContext: PASS / FAIL / NOT OBSERVED
ClientBootstrap = Script + Client RunContext: PASS / FAIL / NOT OBSERVED
Duplicate RebirthRPG project scripts: 0 / <count> / NOT OBSERVED
```

Exact blocker/conflict if any:

```text
...
```

## SMOKE ANCHOR / WORLD

```text
RebirthRPG_SmokeOrigin created from inspected floor: PASS / FAIL / NOT OBSERVED
RebirthRPG_EnableSmokeHarness = true: PASS / FAIL / NOT OBSERVED
Smoke Enemy A grounded: PASS / FAIL / NOT OBSERVED
Smoke Enemy B grounded: PASS / FAIL / NOT OBSERVED
Smoke Boss grounded: PASS / FAIL / NOT OBSERVED
Unexpected clipping/floating/burial affecting route: YES / NO / NOT OBSERVED
```

## BOOT / OUTPUT

Required logs observed:

```text
[RebirthRPG] boot: shared protocol ready                       YES / NO
[RebirthRPG] boot: config/protocol validation passed          YES / NO
[RebirthRPG] boot: remote contract ready                      YES / NO
[RebirthRPG] boot: profile/reward/combat/rebirth services ready YES / NO
[RebirthRPG] Studio smoke harness spawned relative to RebirthRPG_SmokeOrigin YES / NO
[RebirthRPG] boot: Studio smoke harness ready                 YES / NO
[RebirthRPG] boot: enemy service ready                        YES / NO
[RebirthRPG] boot: server bootstrap ready                     YES / NO
```

```text
PROJECT-ATTRIBUTABLE UNEXPECTED ERRORS: <count>
FIRST PROJECT ERROR IF ANY:
BOOT: PASS / FAIL / NOT OBSERVED
```

Paste the first relevant Output error/warning text or summarize it precisely:

```text
...
```

## INITIAL PLAYER STATE

```text
PLAYER SPAWN: PASS / FAIL / NOT OBSERVED
HUD VISIBLE: PASS / FAIL / NOT OBSERVED
LEVEL: observed <value> / expected 1
XP: observed <value> / expected 0
GOLD: observed <value> / expected 0
REBIRTH: observed <value> / expected 0
MAINHAND: observed <value> / expected weapon_start_a
HUD INITIAL STATE: PASS / FAIL / NOT OBSERVED
```

## ENEMY A

Current-config Level 1 / R0 drift baselines:

```text
Enemy A HP = 38
Weapon A first basic hit = 10
Weapon A skill hit = 19
Enemy A reward = 16 XP / 6 Gold
```

Observed:

```text
FIRST BASIC DAMAGE:
SKILL DAMAGE:
ATTACK SPAM BYPASSES COOLDOWN: YES / NO / NOT OBSERVED
SKILL SPAM BYPASSES COOLDOWN: YES / NO / NOT OBSERVED
WINDUP MISS AFTER LEAVING RANGE: PASS / FAIL / NOT OBSERVED
LOS / WALL BLOCKING: PASS / FAIL / NOT OBSERVED / NOT APPLICABLE IN TEST SPACE
XP ON ONE KILL:
GOLD ON ONE KILL:
DUPLICATE REWARD ON SAME DEATH: YES / NO / NOT OBSERVED
RESPAWN: PASS / FAIL / NOT OBSERVED
ATTACK: PASS / FAIL / NOT OBSERVED
SKILL: PASS / FAIL / NOT OBSERVED
ENEMY A REWARD: PASS / FAIL / NOT OBSERVED
```

## ENEMY B / WEAPON B

Current-config Level 1 damage baselines before other progression modifiers:

```text
Weapon B first basic hit = 21
Weapon B skill hit = 44
```

Observed:

```text
WEAPON B GRANTED ON FIRST B KILL: PASS / FAIL / NOT OBSERVED
WEAPON B QUANTITY AFTER FIRST KILL:
WEAPON B QUANTITY AFTER REPEAT KILL:
UNIQUE DROP DEDUPE: PASS / FAIL / NOT OBSERVED
EQUIP BUTTON VISIBLE: PASS / FAIL / NOT OBSERVED
EQUIP SUCCEEDS: PASS / FAIL / NOT OBSERVED
MAINHAND AFTER EQUIP:
WEAPON A COMPARISON HIT COUNT / TTK:
WEAPON B COMPARISON HIT COUNT / TTK:
PRACTICAL UPGRADE OBSERVED: PASS / FAIL / NOT OBSERVED
```

Note: player level may have changed before Weapon B testing. Record the actual level instead of forcing Level 1.

## BOSS

```text
BOSS MATERIALLY TOUGHER THAN NORMAL ENEMY: PASS / FAIL / NOT OBSERVED
BOSS DEATH REWARD ONCE: PASS / FAIL / NOT OBSERVED
boss_region_01_cleared: TRUE / FALSE / NOT OBSERVED
BOSS RESPAWN: PASS / FAIL / NOT OBSERVED
BOSS CLEAR: PASS / FAIL / NOT OBSERVED
```

## PLAYER RESPAWN

```text
CHARACTER RESPAWN: PASS / FAIL / NOT OBSERVED
SAME-SESSION PROFILE RETAINED: PASS / FAIL / NOT OBSERVED
WEAPON B OWNERSHIP RETAINED: PASS / FAIL / NOT OBSERVED
WEAPON B EQUIPPED STATE RETAINED: PASS / FAIL / NOT OBSERVED
ATTACK WORKS AFTER RESPAWN: PASS / FAIL / NOT OBSERVED
SKILL WORKS AFTER RESPAWN: PASS / FAIL / NOT OBSERVED
PLAYER RESPAWN ROUTE: PASS / FAIL / NOT OBSERVED
```

## REBIRTH

Prepare eligibility only through Studio server context using `StudioTestHooks.PrepareRebirthEligible`, then request Rebirth through the normal client control.

Observed after successful request:

```text
REBIRTH COUNT: before <value> -> after <value>
LEVEL AFTER: expected 1 / observed <value>
XP AFTER: expected 0 / observed <value>
GOLD AFTER: expected 0 / observed <value>
REGION PROGRESS RESET: PASS / FAIL / NOT OBSERVED
R1 MILESTONE unlock_dungeon: TRUE / FALSE / NOT OBSERVED
PROVISIONAL EQUIPMENT RETENTION: PASS / FAIL / NOT OBSERVED
REBIRTH TRANSITION: PASS / FAIL / NOT OBSERVED
```

Current-config Level 1 / R1 drift baselines:

```text
Weapon A first basic hit = 11
Weapon A skill hit = 20
Enemy A reward = 22 XP / 8 Gold
```

Observed R1 Enemy A:

```text
FIRST BASIC DAMAGE:
SKILL DAMAGE:
XP REWARD:
GOLD REWARD:
R1 ACCELERATION: PASS / FAIL / NOT OBSERVED
```

## REMOTE / SERVER-AUTHORITY SANITY

```text
UNKNOWN/UNOWNED EQUIP REJECTED: PASS / FAIL / NOT OBSERVED
RAPID EQUIP SPAM THROTTLED: PASS / FAIL / NOT OBSERVED
RAPID ATTACK/SKILL SPAM THROTTLED: PASS / FAIL / NOT OBSERVED
CLIENT CAN DIRECTLY DECLARE DAMAGE/REWARD: NO / YES / NOT OBSERVED
```

## FAILED & FIXED

For every actual failure, add one block. Do not combine unrelated failures.

```text
FAILED ROUTE:
EVIDENCE:
FIRST REAL FAILURE:
ROOT CAUSE:
SMALLEST COHERENT FIX:
FILES / STUDIO OBJECTS CHANGED:
EXACT FAILED ROUTE REPLAYED: YES / NO
REPLAY RESULT: PASS / FAIL
EARLIER PASSED ROUTE REGRESSION CHECK:
```

If the same subsystem structurally fails twice, stop patch stacking and mark:

```text
ARCHITECTURE / WORKFLOW REASSESSMENT REQUIRED: YES
```

## REQUIRED EVIDENCE SET

Capture when available:

```text
1. spawn + initial HUD
2. Enemy A combat state
3. Weapon B equipped state
4. Boss encounter / clear result
5. Output showing clean staged boot or first project failure
```

Screenshots are useful but do not replace state/output evidence.

## FINAL DECISION

A Phase 0 PASS requires all P0 structural routes to be directly observed as passing and project-attributable unexpected runtime errors = 0.

```text
SCRIPT SYNC TYPES: PASS / HOLD
BOOT: PASS / HOLD
HUD INITIAL STATE: PASS / HOLD
ATTACK / SKILL: PASS / HOLD
ENEMY A REWARD + RESPAWN: PASS / HOLD
WEAPON B GRANT + EQUIP + DEDUPE: PASS / HOLD
BOSS CLEAR: PASS / HOLD
PLAYER RESPAWN: PASS / HOLD
REBIRTH TRANSITION: PASS / HOLD
R1 ACCELERATION: PASS / HOLD
PROJECT-ATTRIBUTABLE UNEXPECTED ERRORS: <count>

DECISION: PHASE 0 PASS / PHASE 0 HOLD
```

## NEXT ACTION

If `PHASE 0 HOLD`:

```text
stop asset intake
→ isolate first failed route
→ root cause
→ smallest coherent fix
→ replay exact failed route
→ regression
```

If `PHASE 0 PASS`:

```text
RebirthRPG_EnableSmokeHarness = false
→ supervisor reviews this evidence
→ only then STUDIO_AGENT_TASK_01_ENVIRONMENT.md
```
