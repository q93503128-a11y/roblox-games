# Slay & Loot — Active Plan

Status: VERTICAL SLICE IMPLEMENTED / SOURCE SNAPSHOTTED / ACCEPTANCE PLAYTEST PENDING

## Current goal

Preserve the working first slice, reconcile it with the asset-heavy production strategy, and validate it in actual Roblox Studio play before expanding scope.

The intended loop remains:

`spawn/hub -> start dungeon -> fight readable groups -> boss -> visible loot -> equip upgrade -> replay stronger difficulty -> understand next target`

Target play length remains 5–10 minutes including the first stronger replay.

## Current implementation baseline

Git snapshot commit: `51af92cd05dfc688b0031060ac5c381fffe11053`.

Current Git-owned Luau mirrors these Studio containers:

- `ServerScriptService.SlayAndLootMain`
- `ReplicatedStorage.SlayAndLoot.Config`
- `ReplicatedStorage.SlayAndLoot.Shared`
- `ReplicatedStorage.SlayAndLoot.PlayerState`
- `ReplicatedStorage.SlayAndLoot.LootService`
- `ReplicatedStorage.SlayAndLoot.CombatService`
- `ReplicatedStorage.SlayAndLoot.EnemyService`
- `ReplicatedStorage.SlayAndLoot.RunService`
- `StarterPlayer.StarterPlayerScripts.SlayAndLootClient`

Snapshot verification at capture time: 9/9 Studio source == Git file hash, 1,642 total lines.

The current source already contains the first combat/dungeon/loot/UI shell. Do not duplicate these systems or restart the project from the old pre-build plan.

## Source-of-truth rule

GitHub owns project-written Luau/config/docs and the source hash baseline.

Roblox Studio / Roblox Cloud owns scene geometry, external models/meshes/rigs, lighting, and Studio-native placement state.

`generated/world-layout.snapshot.json` is reference evidence, not the authoritative map.

Until a deliberate Git -> Studio apply workflow exists, do not independently edit the same Git-managed script on two PCs.

## Phase A — source review before new implementation

Review the snapshotted source directly and distinguish:

- code that is already valid and should be preserved
- actual missing acceptance requirements
- visual placeholders that should be replaced by audited external assets
- project-owned authority logic that must remain in-project

Known source facts:

- inventory UI exists in the client source
- loot card and equip presentation exist in the client source
- `LootService.roll()` is currently pure weighted random
- therefore the first-Normal-clear guaranteed meaningful upgrade rule is still missing
- Config currently defines Common / Uncommon / Rare / Epic / Legendary; Mythic is not implemented in the active tables
- boss visual construction depends on `ServerStorage.Quarantine.Goblin_Q`

Do not treat old planning reports as more authoritative than the current Git snapshot.

## Phase B — first production asset integration pass

The project remains asset-heavy by design.

External assets should carry most player-facing production value where they are audited and coherent:

1. environment / ruins / nature modules
2. weapon visuals
3. enemy / boss visual rigs
4. shared sword animation family
5. VFX
6. SFX
7. icons and UI presentation components

Keep damage, valuable rewards, inventory ownership, progression, currency, purchases, save data, and authority-sensitive logic project-controlled.

Current environment starting point:

- `ServerStorage.Quarantine.SyntyDungeon_Q` is quarantined and should be audited module-by-module before promotion
- the current gameplay shell / named anchors remain the spatial reference while production art is integrated
- do not copy the whole asset library into the live route

Build art in coherent sections:

`Hub -> Entry -> Room A -> safe/vista pocket -> Room B -> Room C/Elite -> Boss -> Reward`

For each section:

`inspect -> placement plan -> place -> gameplay-camera check -> collision/path check -> fix -> next section`

Do not guess touching geometry with independent raw coordinates; use anchors, pivots, bounds, faces, and relative placement.

## Phase C — combat presentation

Preserve the current combat authority/timing unless evidence shows a defect.

Production tasks:

- replace/fix the current sword presentation so the held weapon reads correctly
- obtain or create one coherent sword animation family
- do not assume arbitrary cross-experience animation IDs will be reusable in this experience; use an experience-owned, permitted, or otherwise valid animation source and verify actual playback in Studio before approval
- replace obvious primitive enemy visuals where audited rigs are available
- improve hit/slash/boss/reward VFX and SFX using audited external resources where stronger than custom placeholders

Do not rewrite combat logic merely to adopt a free RPG kit.

## Phase D — guaranteed first upgrade

Current `LootService.roll()` is weighted random only.

Implement the design invariant:

If the player is still on starter-level gear when completing the first Normal run, the reward must be a clearly stronger weapon.

Constraints:

- server authoritative
- not a guaranteed highest-tier drop
- not repeated on every clear
- normal random loot should remain intact after the protection condition has been consumed

Validate:

`Starter -> Normal clear -> reward -> inventory -> equip -> measurable damage increase`.

## Phase E — acceptance playtest

Recovered evidence in `docs/PLAYTEST_NOTES.md` shows a bot-driven/synthetic-input runtime pass through the first slice, including Normal clear, loot/equip, Hard tuning, death/respawn attempts, and multiple repaired defects. That evidence is `RUNTIME-CHECKED`, not human `PLAYTESTED` or `ACCEPTED`.

Do not call the slice accepted until actual Studio evidence is recorded.

Minimum P0 route:

1. clean boot
2. spawn in hub
3. start Normal
4. primary attack
5. dash
6. skill
7. clear room A
8. clear room B
9. clear room C / elite
10. defeat boss
11. receive/take loot
12. open inventory and equip upgrade
13. verify combat power increase
14. start Hard
15. verify stronger enemies and better reward target
16. die / respawn / reset once
17. replay after final art/UI changes

Record evidence in `docs/PLAYTEST_NOTES.md`.

Acceptance requires, where applicable:

- project-attributable unexpected runtime errors = 0
- route cannot be trivially sequence-broken
- melee/ranged/elite/boss attacks remain readable
- loot/equip flow works
- first-clear upgrade protection works
- death/respawn does not corrupt run/progression state
- camera/collision/path remain acceptable after the art pass
- valuable state remains server-authoritative
- desktop route works, including direct LMB -> primary attack validation
- production audio/SFX exists where required for combat/reward readability
- mobile route exists and is actually validated before mobile acceptance is claimed

## Multi-PC rule

Before switching active development PCs:

Previous PC:

`Studio save/publish -> git status -> commit -> push`

New PC:

`git fetch/pull -> read HANDOFF -> confirm intended Roblox Cloud place -> inspect before editing`

Do not make simultaneous independent edits to the same Git-managed source or the same Studio place.

## OpenCode usage

Prefer Plan mode for investigation, source review, design, patch planning, code preparation, asset selection planning, and test design.

Use Build only for necessary file/Studio writes, asset insertion/placement, integration, playtest, save, and commit/push work that cannot be handled directly through GitHub.

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

## Stop conditions

Stop and reassess instead of patch stacking if:

- the same combat/inventory/dungeon subsystem fails structurally twice
- asset dressing repeatedly breaks the route/collision/camera
- selected assets cannot be made coherent without major rework
- sword presentation is being repaired through repeated arbitrary CFrame offsets rather than a root-cause fix
- enemy count/VFX causes unacceptable target-device performance
- Studio/MCP state cannot be trusted enough to validate the current step
- a free/template kit requires unsafe or opaque authority code to remain functional

Do not expand to Dungeon 2 until this slice passes acceptance.
