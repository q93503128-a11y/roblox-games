# Slay & Loot — Session Handoff

Last updated: 2026-10-27

## Current state

- The first playable vertical slice exists in Roblox Studio and has been snapshotted into GitHub.
- Studio source snapshot commit: `51af92cd05dfc688b0031060ac5c381fffe11053`.
- Project-local `.gitattributes` pins `*.luau` and `*.json` to LF so source hashes remain stable across PCs.
- GitHub now contains the 9 project-owned Luau containers under `src/`, plus `sync-manifest.json`, source hashes, and a reference-only world-layout snapshot.
- Current Studio place inspected on 2026-10-27: PlaceId `121055730304610`, UniverseId `10773222778`, title `베고 약탈하기`.
- The inspected Studio DataModel contained the combat/loot vertical slice, a 131-descendant `Workspace.SlayAndLoot` shell, and quarantined external assets in `ServerStorage.Quarantine`.
- The current Git snapshot is a preservation baseline. It does not yet define an automatic Git -> Studio apply workflow.
- Cloud save/publish equivalence is still unverified: the inspected session reported `game.PlaceVersion == 0`, so do not assume the live cloud version equals the captured Edit DataModel until the user confirms Studio save/publish state.

## Source-of-truth split

### GitHub canonical

- project-owned Luau source
- gameplay/config data represented in source
- `sync-manifest.json`
- source hash baseline
- project docs / handoff / asset audit records
- reference snapshots used to detect drift

### Roblox Studio / Roblox Cloud canonical

- actual scene geometry
- external models / meshes / rigs
- lighting and Studio-native scene state
- runtime/editor object placement not represented as project-owned source

`generated/world-layout.snapshot.json` is a reference snapshot only, not the authoritative map source.

## Current source inventory

Git paths mirror these Studio containers:

- `ServerScriptService.SlayAndLootMain`
- `ReplicatedStorage.SlayAndLoot.Config`
- `ReplicatedStorage.SlayAndLoot.Shared`
- `ReplicatedStorage.SlayAndLoot.PlayerState`
- `ReplicatedStorage.SlayAndLoot.LootService`
- `ReplicatedStorage.SlayAndLoot.CombatService`
- `ReplicatedStorage.SlayAndLoot.EnemyService`
- `ReplicatedStorage.SlayAndLoot.RunService`
- `StarterPlayer.StarterPlayerScripts.SlayAndLootClient`

Snapshot verification at capture time:

- 9/9 Studio source == Git file hash
- 1,642 total lines
- no Studio writes during capture

## Current confirmed gameplay implementation

The current source contains:

- 3-hit sword primary combat
- dash with invulnerability window
- one cleave/AOE skill
- server-authoritative combat/reward handling
- Normal / Hard run state
- room A / B / C / boss / reward flow
- enemy melee/ranged/telegraph behavior
- XP / Gold / level state
- weighted weapon loot
- client-built HUD
- inventory panel and equipped item display
- loot reward card
- item equip flow

Do not infer that every acceptance criterion has been human-playtested. Source presence is not equivalent to acceptance.

## External asset state

- `ServerStorage.Quarantine.SyntyDungeon_Q`: quarantined environment/prop kit, no scripts observed in the inspected copy, not yet promoted to production environment use.
- `ServerStorage.Quarantine.Goblin_Q`: visual boss dependency currently referenced by `EnemyService`; its presence in the live boss path does not by itself mean the asset is fully production-approved.
- The current map remains primarily a gameplay shell/graybox and still needs a production art pass.

## Current working direction

Slay & Loot remains an asset-heavy Roblox dungeon-loot RPG.

Core loop:

`Hub -> short dungeon -> boss -> visible loot -> equip stronger weapon -> replay harder difficulty / unlock next target`

Production rule:

- use audited external assets aggressively for environment, weapons, rigs, animations, VFX, SFX, icons, and UI presentation
- keep damage, valuable rewards, inventory ownership, progression, currency, purchases, save data, and other authority-sensitive logic project-controlled
- do not rewrite validated project-owned gameplay logic merely to adopt a free RPG kit

## Multi-PC workflow

Until a Git -> Studio apply path is deliberately chosen, use sequential ownership rather than simultaneous editing.

When changing PCs:

1. Previous PC: save/publish Studio if Studio changed.
2. Previous PC: `git status` -> commit -> push.
3. New PC: `git fetch` / pull latest `main`.
4. Read this handoff and the latest source/hash baseline.
5. Open the same Roblox Cloud place and confirm it is the intended current place before editing.

Never edit the same Git-managed script independently on both PCs.

## OpenCode usage rule

Prefer Plan mode for:

- investigation
- source review
- design
- exact patch planning
- code preparation
- asset selection planning
- test design

Use Build mode only when needed for:

- actual file modifications that cannot be done directly through GitHub
- Roblox Studio MCP writes
- asset insertion/placement
- runtime/playtest validation
- Studio-side integration

Do not spend Build usage on long research or speculative planning.

## Next safe step

1. Review the newly snapshotted Git source directly before changing architecture.
2. Keep the current source baseline intact while resolving any real contradictions found by source review.
3. Confirm the Studio place has been saved/published to Roblox Cloud before switching the active development PC.
4. Then perform the first production asset integration pass: promote only audited pieces from the quarantined environment stack, fix sword presentation/animation, and replay the P0 route after art changes.
5. Add a Git -> Studio sync/apply mechanism only if it is actually needed; do not introduce Rojo or custom tooling solely for organizational appearance.

## Known limitations

- Cloud save/publish equivalence has not yet been proven.
- No standardized Git -> Studio apply path exists yet.
- Mobile route is not yet accepted.
- Multiplayer route is not yet validated.
- Persistence/DataStore route is not yet validated.
- Production environment art, animation, VFX/SFX, and final UI presentation are incomplete.
- A human acceptance playtest is still required before calling the slice accepted.
