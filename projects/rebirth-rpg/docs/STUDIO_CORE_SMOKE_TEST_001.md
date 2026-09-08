# Rebirth RPG — Studio Core Smoke Test 001

> purpose: prove the gameplay code route before production map/art integration
> status: READY AFTER SCRIPT SYNC
> important: this is a Studio-only validation lane, not a production map

## GOAL

Prove that the current code can complete the core structural route in Roblox Studio:

```text
boot
→ attack
→ Enemy A death
→ XP/Gold
→ Enemy B death
→ guaranteed Weapon B
→ equip
→ boss death / clear flag
→ rebirth test
```

Do not judge final art from this test.

## PRECONDITIONS

1. Use a clean Rebirth RPG test place, not another verified project's place.
2. Complete `STUDIO_SCRIPT_SYNC_LAYOUT_001.md`.
3. Confirm these exist:

```text
ReplicatedStorage/RebirthRPG/Shared/Protocol
ServerScriptService/RebirthRPG/ServerBootstrap
StarterPlayer/StarterPlayerScripts/RebirthRPG/ClientBootstrap
```

4. Inspect current floor, SpawnLocation/avatar scale and camera before placing the smoke anchor.

## CREATE ONE NAMED TEST ANCHOR

In a safe empty test area with real floor underneath, create one anchored BasePart:

```text
Name: RebirthRPG_SmokeOrigin
Anchored: true
CanCollide: false
Transparency: 1
```

Place it only after inspecting the actual test place.
Do not use a guessed world coordinate copied from this document.

The runtime smoke enemies are placed using local offsets from this anchor.

## ENABLE

Set a Workspace attribute:

```text
RebirthRPG_EnableSmokeHarness = true
```

The harness is guarded by `RunService:IsStudio()`. It does not spawn in a live server.

## EXPECTED RUNTIME HIERARCHY

On Play:

```text
Workspace
└─ _RebirthRPG_SmokeHarness
   ├─ Smoke Enemy A
   ├─ Smoke Enemy B
   └─ Smoke Boss
```

These are temporary R15 debug rigs created only to exercise the normalized enemy contract.
They are not production enemy art.

Expected Output includes:

```text
[RebirthRPG] Studio smoke harness spawned relative to RebirthRPG_SmokeOrigin
[RebirthRPG] Server bootstrap ready: profile/combat/reward/enemy/rebirth core loaded
```

Any project-attributable error before these messages is a failed gate.

## TEST 01 — BOOT / STATE

Play as one player.

Pass:
- character spawns normally
- internal HUD appears
- Level 1 / Gold 0 / Rebirth 0 visible
- mainhand starts as `weapon_start_a`
- no unexpected Rebirth RPG Output errors

If HUD hangs waiting for a Remote or Protocol folder, stop and fix sync hierarchy before testing combat.

## TEST 02 — BASIC ATTACK / SKILL

Controls:
- basic attack: M1 / gamepad R2 / touch Attack
- skill: E / gamepad X / touch Skill

Fight Smoke Enemy A.

Pass:
- attack is rate-limited rather than infinitely accepted
- damage is applied by the server
- skill does visibly larger damage than a normal first hit
- enemy can damage the player after its Windup when in range
- stepping away during Windup can invalidate the hit when distance is no longer plausible
- death grants XP and Gold once
- no duplicate reward on one enemy death
- Enemy A respawns after its configured delay

Do not tune final feel from the debug rig animation; there is no approved production animation yet.

## TEST 03 — FIRST MEANINGFUL UPGRADE

Kill Smoke Enemy B.

Pass:
- `weapon_start_b` is granted exactly once
- HUD exposes the Equip Weapon B action
- equip request succeeds only because the server inventory owns the item
- mainhand changes to `weapon_start_b`
- repeated Enemy B kills do not stack duplicate copies of the unique weapon
- Weapon B reduces practical hit count / TTK versus the same target compared with Weapon A

This route is intentionally deterministic for Slice 001. The first meaningful equipment upgrade must not depend on bad luck.

## TEST 04 — BOSS CLEAR

Fight Smoke Boss with Weapon B.

Pass:
- boss has materially more health than normal enemies
- same simple combat contract works
- death grants XP/Gold once
- `boss_region_01_cleared` becomes true in profile state
- boss respawns on its longer timer

No phase 2 is expected.

## TEST 05 — DEATH / RESPAWN

Allow the player to die or reset character.

Pass:
- character respawns
- server profile is still present for the same test session
- owned Weapon B/equipped state reconstructs in HUD state
- attack/skill inputs still work after respawn

Persistence across leaving the Studio server is **not** tested yet because production DataStore persistence is intentionally not implemented in this slice core.

## TEST 06 — REBIRTH P0

Natural Level 10 grinding is not required for this smoke test.
Use the Studio-only test hook from server context:

```lua
local hooks = require(game.ServerScriptService.RebirthRPG.StudioTestHooks)
local player = game.Players:GetPlayers()[1]
hooks.PrepareRebirthEligible(player)
```

Then request Rebirth with R / gamepad Y / touch Rebirth.

Pass:
- server accepts only after level + boss clear requirements are present
- level resets to 1
- XP resets
- Gold resets
- region run progress resets
- Rebirth count increments
- permanent milestone for R1 is set
- owned equipment remains under the current provisional Slice 001 retention rule

Then compare one Enemy A reward before/after rebirth if convenient:
- XP reward should use the R1 multiplier
- Gold reward should use the R1 multiplier
- damage floor should be higher

Do not call the final rebirth balance approved from this test; this only validates state transition and acceleration wiring.

## TEST 07 — REMOTE ABUSE SANITY

Use Studio tooling/Agent to try obvious malformed calls where convenient.

Minimum observations:
- EquipItem with unknown/unowned item does not equip
- rapid equip spam is throttled
- rapid attack/skill spam does not bypass configured cooldown
- client cannot declare damage/reward values

A full exploit/security test comes later; this is structural sanity only.

## PASS REPORT

Return:

```text
BOOT: PASS / FAIL
ATTACK: PASS / FAIL
SKILL: PASS / FAIL
ENEMY DAMAGE/WINDUP: PASS / FAIL
ENEMY A REWARD: PASS / FAIL
ENEMY A RESPAWN: PASS / FAIL
WEAPON B GRANT: PASS / FAIL
WEAPON B EQUIP: PASS / FAIL
UNIQUE-DROP DEDUPE: PASS / FAIL
BOSS CLEAR FLAG: PASS / FAIL
PLAYER RESPAWN: PASS / FAIL
REBIRTH TRANSITION: PASS / FAIL
R1 ACCELERATION: PASS / FAIL
UNEXPECTED PROJECT ERRORS: <count>

FAILED ROUTE:
ROOT CAUSE:
FIX APPLIED:
EXACT ROUTE REPLAYED:
KNOWN LIMITATIONS:
```

## HARD STOP

Do not proceed to production map building when any of these fail:
- clean boot
- attack → death → reward
- Weapon B grant/equip
- boss clear
- respawn
- rebirth transition

Fix the smallest coherent root cause and replay the exact failed route first.

## CLEANUP / NEXT

After smoke testing:
- stop Play; runtime `_RebirthRPG_SmokeHarness` disappears
- set `RebirthRPG_EnableSmokeHarness = false` before production playtests
- keep or move the `RebirthRPG_SmokeOrigin` only as a clearly marked test anchor, never as a production landmark

Then continue asset intake and replace smoke rigs with approved visuals while preserving the normalized `EnemyId + tag + Humanoid` gameplay contract.
