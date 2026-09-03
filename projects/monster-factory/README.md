# Monster Factory Simulator

Factory Tycoon + Monster Collection + Simulator project managed through Rojo.

## Current baseline

Gameplay/system baseline: **MVP-005**

Visual baseline: **Visual Rebuild 006**

The first Studio smoke test confirmed that the static world boots, the player reaches Green Meadows, the HUD/data loop initializes, and the factory economy begins producing. That smoke test also exposed the original placeholder presentation as unacceptable for continued testing, so the project moved into a dedicated visual rebuild before the full checklist continues.

## Visual Rebuild 006

- `MonsterFactoryWorld.model.json` remains the gameplay-anchor world.
- `MonsterFactoryArt004.model.json` remains the static non-colliding zone-silhouette layer.
- canonical Lighting / Atmosphere / Bloom / ColorCorrection remain owned by `default.project.json`.
- `ZoneMood.client.lua` transitions the scene palette by the player's current logical zone.
- `VisualRefresh.client.lua` remains the Visual Rebuild 005 simulator-style HUD/card presentation adapter.
- `UIVisualContract.lua` keeps semantic icon slots ready for sanitized external GUI art.
- `WorkerVisualFactory.lua` is now the shared procedural monster visual source used by both factory workers and Hatch previews.
- `WorkerCharacters.client.lua` now derives equipped workers directly from canonical Monster/Zone state and renders final models at Worker Stations.
- the old runtime orb-to-character handoff is retired; `WorkerVisualService` remains only as an inert compatibility dependency.
- `HatchReveal.client.lua` adds a rarity-aware ViewportFrame reveal card driven by actual server-published HatchCount/inventory changes.
- Hatch reveal scales down for narrow mobile screens and queues successive real hatches.
- Shiny fusion is not treated as a normal Hatch reveal.
- current-zone Generator, Collector, Capsule and Worlds anchors retain 3D guidance / ProximityPrompt interaction.
- default Studio `Baseplate` / root `SpawnLocation` cleanup remains owned by `WorldService`.
- first-pass Studio testing uses explicit ephemeral profiles so DataStore API permission noise does not block visual/core-loop testing.

Detailed audits:

- `docs/VISUAL_REBUILD_003_AUDIT.md`
- `docs/VISUAL_REBUILD_004_AUDIT.md`
- `docs/VISUAL_REBUILD_005_AUDIT.md`
- `docs/VISUAL_REBUILD_006_AUDIT.md`

## External art policy

Creator Store art may replace/enhance visible geometry and UI presentation, but must never own gameplay logic.

Read:

`docs/EXTERNAL_VISUAL_ASSET_INTAKE_001.md`

The reviewed source IDs and status are recorded in:

`src/ReplicatedStorage/Shared/VisualAssetManifest.lua`

The UI replacement contract is:

`src/ReplicatedStorage/Shared/UIVisualContract.lua`

A Studio-only sanitation helper exists at:

`tools/studio/IMPORT_EXTERNAL_VISUALS.lua`

Imported models must be sanitized before use. Whole packs should not be retained by default, and gameplay anchors must remain repository-owned.

## Known client cleanup boundary

`ClientBootstrap.client.lua` still contains inert legacy worker compatibility code. The server no longer feeds that path, so it does not create worker orbs at runtime. Physically removing that dead code should happen together with the next ClientBootstrap decomposition instead of another large in-place visual patch.

## Next validation point

Do not pull/test after every development commit.

Continue development in GitHub, then pull once when a grouped visual/content pass is ready for Studio validation. At that point resume the checklist from:

`docs/MVP_005_STUDIO_TEST_CHECKLIST.md`

Real Pass/Product IDs are still configured only in:

`src/ReplicatedStorage/Shared/MonetizationConfig.lua`
