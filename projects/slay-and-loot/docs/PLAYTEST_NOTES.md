# Slay & Loot — Playtest Notes

Use this file for runtime evidence, not optimistic summaries.

The 2026-10-27 entries below are **RUNTIME-CHECKED, bot-driven/synthetic-input evidence** recovered from the pre-snapshot Studio session and cross-checked against the Git snapshot. They are not a human acceptance playtest and must not be labeled `PLAYTESTED` or `ACCEPTED`.

## Entry template

### YYYY-MM-DD — Test name

**Build / commit:**

**Environment:** Studio / device simulation / multiplayer mode as applicable

**Route tested:**

**Passed:**

**Failed:**

**Root cause:**

**Fix applied:**

**Regression replay:**

**Remaining limitations:**

## Required distinction

Do not treat code inspection, Studio hierarchy inspection, or an error-free edit as a playtest.

A route belongs here only when the relevant runtime/player path was actually exercised or the limitation preventing that test is explicitly recorded.

## Runtime evidence — bot-driven / synthetic input

### 2026-10-27 — First-slice P0 route

**Status:** `RUNTIME-CHECKED` — bot-driven / synthetic input, not human acceptance.

**Build / commit:** Original runtime was exercised in the pre-snapshot Studio session. The later Git source snapshot `51af92cd05dfc688b0031060ac5c381fffe11053` matches the cited Config/UI/combat fixes, but the runtime session itself predates that snapshot and should not be treated as proof that a particular published cloud version was exercised.

**Environment:** Roblox Studio, desktop viewport. Mobile and multiplayer were not validated.

**Route tested:** Hub -> Normal -> Room A -> Room B -> Room C -> Boss -> reward -> inventory/equip -> Hard -> repeated death/respawn attempts.

**Passed:**

- Normal gold progression observed: `0 -> 18 -> 46 -> 83 -> 203`.
- Room reward composition matched source tuning: Room A = 3 Grunts (+18), Room B = 2 Grunts + 2 Casters (+28), Room C = Brute + 2 Grunts (+37), Boss = +120.
- Normal route reached level 4.
- Observed Normal drops included Iron Blade (`Common`, +4) and Ember Edge (`Rare`, +15).
- Loot -> inventory -> equip path worked; equipping Iron Blade changed attack damage from 10 to 14.
- Hard unlocked and used stronger tuning: Grunt max HP 99; room gold A +30, B +47, C +62; Boss HP 1540.
- Tier-2 loot was sampled 2,000 times during runtime/module validation: Hollowfang 39.9%, Voidsteel 35.0%, Ashen 19.8%, Starfall 5.3%. The distribution is consistent with the configured 40/35/20/5 weights, but the original sample artifact was not preserved.
- Three Hard-run deaths were exercised across A/C/Boss attempts; Gold/Level/session inventory progression remained available across the death -> hub return path. Final reconstructed state was 419 Gold / level 8.
- No project-attributable unexpected runtime error was observed on the exercised route. Known base-character animation noise involving `rbxassetid://203785492` was not attributed to the project.

**Failed / limitations:**

- Hard boss was not cleared by the bot-driven route.
- Hard Room A and Room C each caused an initial death during tuning/replay.
- First Normal clear could return only Common +4; the required first-clear meaningful-upgrade protection is not implemented.
- Direct LMB -> attack was not independently validated; the alternate F attack path was used for indirect combat validation.
- Mobile controls, multiplayer behavior, combat feel, camera readability, and human telegraph readability remain unaccepted.

**Quantitative notes:**

- Equipped 14 damage equals about 31% of a 45 HP Normal Grunt and about 14.1% of a 99 HP Hard Grunt.
- Hard boss base-pattern damage scales to 25.2 for the standard hit; configured boss variants can be higher (slam 30.24, dash 27.72).
- Survival observations around melee spacing should be interpreted as kiting/telegraph evidence, not proof that 9 studs is strictly outside the melee strike boundary.

### 2026-10-27 — Graybox walkability repair

**Status:** `RUNTIME-CHECKED`.

**Failure:** The route between Room A and the safe pocket was initially blocked / not reliably traversable.

**Fix applied:**

- Added a west-wall doorway opening sized around 14 x 6 studs.
- Rebuilt the safe pocket with four readable openings, including named jamb/lintel structures.
- Raised corridor ceiling clearance where required.

**Regression replay:** Character-navigation traversal reached the intended final positions after the repair. A `Path Blocked` warning was treated as non-fatal only when the final target position was still reached correctly.

**Current evidence:** The later Studio inspection confirmed the safe-pocket opening structures still exist.

### 2026-10-27 — Graybox / UI visual defects

**Status:** `RUNTIME-CHECKED` fixes preserved in current source/Studio state.

**Failed & fixed:**

1. Ground and room floor shared the same top plane, causing z-fighting -> Ground top was moved to `Y = -0.5`.
2. Rooms read as outdoor/open because ceilings were absent -> ceiling parts were added; later inspection found 11 ceiling parts and 11 PointLights.
3. A label used `UDim2.fromScale(1, 26)`, producing an enormous height -> replaced with a fixed 26 px height.
4. Top-right LEAVE / INVENTORY controls overlapped -> layout positions were separated.
5. Enemy health bar parenting caused origin/world-position rendering -> health bar now follows the model PrimaryPart/base part path.
6. HUD was displaced/clipped by GUI inset handling -> `IgnoreGuiInset = false`.
7. EQUIP control overflowed its inventory row -> button sizing/position was corrected.
8. Loot card could remain visible after TAKE because nil state was not overwriting previous client state -> state application now clears pending loot/equipped state correctly.

**Remaining limitations:** Mobile and additional viewport sizes have not been accepted.

### 2026-10-27 — Combat / reward tuning defects

**Status:** `RUNTIME-CHECKED` fixes preserved in current source.

**Failed & fixed:**

1. Original Grunt durability made the opening combo too spongey -> active enemy tuning was reduced to Grunt 45 HP, Caster 36, Brute 240, Boss 700 on Normal.
2. Original attack cone was too narrow for expected Roblox third-person melee -> active combo arcs are 115 / 120 / 150 degrees with 9.5 / 9.5 / 11 stud ranges and a close-proximity angle exception.
3. Caster spawn placement could collapse to ground height -> spawn Y is preserved.
4. Reward-chest interaction was unreachable after the run changed out of `active` state -> cleared/reward handling was moved out of the active-only branch.
5. Re-approaching the reward could reroll repeatedly -> `lootTaken` gating prevents repeated reward rolls for the same clear.

**Regression status:** The current Git snapshot contains each of these corrected code paths. Human combat-feel acceptance is still pending.
