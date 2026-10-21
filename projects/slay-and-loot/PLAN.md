# Slay & Loot — Active Plan

Status: READY FOR FIRST STUDIO BUILD / RUNTIME VALIDATION PENDING

## Current goal

Build and validate the first production-style vertical slice using Roblox Studio + OpenCode (MiniMax) + Studio MCP.

The slice must prove this loop:

`spawn/hub -> start dungeon -> fight readable groups -> boss -> visible loot -> equip upgrade -> replay stronger difficulty -> understand next target`

Target play length: 5–10 minutes including the first stronger replay.

## Current design authority

Read `docs/LIVE_DESIGN.md` before implementation. It now defines the accepted first production loop, combat ceiling, loot direction, reference roles, and expansion priorities.

## Phase 0 — inspect before editing

Before creating content, inspect the real Studio/DataModel state and record enough evidence to trust it.

Confirm:

- current Place / DataModel hierarchy
- existing scripts/remotes/UI/assets
- spawn transform
- avatar rig/scale
- camera/FOV
- Lighting
- terrain/floor/playable bounds
- unexpected Output/runtime errors
- whether any previous Slay & Loot implementation exists in Studio but not GitHub

Do not duplicate an existing valid subsystem.

## Phase 1 — asset procurement / quarantine

Use Creator Store and the Godbase supply catalog aggressively.

Search/inspect multiple candidates where quality matters, then select the smallest coherent stack needed for the first slice.

Priority categories:

1. environment: stylized nature + dungeon/ruins modules
2. weapon: coherent sword family / starter + upgrade visuals
3. enemies: compatible goblin/fantasy creature rigs or another stronger coherent family
4. animation: one sword combat family shared across weapon visuals
5. VFX: slash, hit, skill, boss telegraph, loot rarity feedback
6. SFX: swing, impact, enemy hit/death, loot/reward, UI confirm
7. UI: HUD, inventory/grid, item tooltip/compare, Play/dungeon selection, reward/result presentation
8. monetization/shop UI may be collected as a future candidate but must not delay the slice

Preferred known starting candidates from Godbase include Synty Nature, compatible official/licensed dungeon/medieval assets, simple script-free weapon packs, and the audited-candidate VFX library. These are starting points, not automatic approvals.

For every candidate actually evaluated in Studio:

- inspect descendants/scripts/dependencies
- quarantine or remove scripts when only visuals are needed
- inspect scale/pivot/rig/collision
- inspect gameplay-camera appearance
- inspect mobile/performance implications at intended repetition
- record approved/rejected production candidates in `docs/ASSET_SOURCES.md`

Do not ship a giant asset library wholesale.

## Phase 2 — first spatial shell

After asset selection, build only the coherent first route.

Use named anchors and relative placement. Do not guess raw world coordinates independently.

Required authored spaces:

- compact hub/spawn camp
- obvious Play/start focal point
- first dungeon entry
- room A
- room B
- room C / elite
- boss room
- reward/result area/state

First dungeon working theme: stylized forest ruins / goblin-held ruins unless procurement finds a clearly stronger coherent alternative.

Target encounter structure:

- room A: 3 melee
- room B: mixed melee + ranged
- room C: elite/brute encounter
- boss room: one boss with 2–3 readable attacks

Do not create a maze or a giant decorative hub.

## Phase 3 — combat foundation

First-slice player kit:

- 3-hit sword primary combo
- dash/roll
- one broad readable cleave/AOE skill

Target desktop bindings:

- LMB attack
- Q dash
- E skill

Target mobile:

- Attack
- Dash
- Skill

Requirements:

- animation active frames and hit timing match
- hit sound/VFX/reaction readable
- server validates damage/reward results
- 3–5 enemies remain readable
- spam input does not break state
- death/respawn/reset route works

Do not add block/parry, stamina, mana, or a large skill bar in this pass.

## Phase 4 — enemy behavior

Own the AI/combat logic in-project. Use external assets primarily for visual rigs/models/animation source material.

Required behavior families:

- Grunt
- Ranged
- Brute/Elite
- Boss

Do not preserve arbitrary free-model AI merely because it came with a visually useful creature.

## Phase 5 — loot / progression / UI

First-slice progression:

- starter sword
- combat rewards grant XP/Gold as appropriate
- boss/end reward visibly produces loot
- first Normal completion guarantees a meaningful weapon upgrade if still on starter gear
- item can be inspected/compared/equipped clearly
- improved weapon must produce a noticeable combat-power change
- Normal completion exposes/unlocks a stronger replay target
- Hard reuses the same dungeon art/layout with stronger tuning and improved reward table

Initial rarity ladder:

`Common -> Uncommon -> Rare -> Epic -> Legendary -> Mythic`

The slice does not need all tiers to drop.

Keep first-slice item stats minimal. Base Damage is mandatory. Do not add affix/reroll/crafting/set complexity yet.

UI should use audited external assets/components/icons where useful and be normalized into one coherent style. Do not accept default/debug-looking UI merely because it is wired.

## First 10-minute pacing target

- <= 0:15: player can move and understands how to start combat
- <= 0:30: first enemy defeated
- <= 1:00: first useful reward feedback
- 1:00–3:30: first Normal run
- <= 4:00: clearly stronger weapon equipped
- 4:00–8:00: Hard replay / stronger encounter
- <= 10:00: next progression target is obvious

These are tuning targets, not claims until playtested.

## Do not add yet

- giant open world
- large quest system
- pets
- trading
- guilds
- crafting
- reroll/affix system
- large skill tree
- many currencies
- rebirth
- raids/infinite mode
- production monetization backend
- large content batches
- unique animation sets per individual weapon

## Acceptance criteria

The first slice is accepted only when actual Studio evidence shows:

- clean boot
- normal spawn
- first objective obvious without long tutorial
- first attack route works on desktop
- viable mobile combat controls/UI exist
- room progression cannot be trivially sequence-broken
- melee/ranged/elite/boss attacks are readable
- one full run can be completed
- visible loot reward works
- item comparison/equip works
- equipped upgrade noticeably improves combat
- stronger replay target works
- death/respawn does not corrupt the run/progression state
- project-attributable unexpected runtime errors = 0 on the P0 route
- camera/collision/path remain acceptable after art pass
- valuable rewards/inventory/currency remain server-authoritative

## P0 test route

Fill exact names/anchors after Studio implementation, but preserve this sequence:

1. clean boot
2. spawn in hub
3. start first Normal dungeon
4. use primary attack
5. use dash
6. use skill
7. clear room A
8. clear room B
9. defeat elite encounter
10. defeat boss
11. collect/receive loot
12. inspect and equip upgrade
13. verify power increase in combat
14. start stronger replay/difficulty
15. verify stronger enemies + better reward target are readable
16. die/respawn/reset once
17. replay the same route after final art/UI pass

## Stop conditions

Stop and reassess instead of patch stacking if:

- the same combat/inventory/dungeon subsystem fails structurally twice
- selected assets cannot be made visually coherent without heavy rework
- enemy count/VFX causes unacceptable target-device performance
- combat remains weak after one focused feel revision
- Studio/MCP state cannot be trusted enough to validate the current step
- a free/template kit requires adopting unsafe or opaque authority code to remain functional

Do not expand to Dungeon 2 until this slice passes acceptance.
