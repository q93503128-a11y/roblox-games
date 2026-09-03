# Monster Factory Simulator

Factory Tycoon + Monster Collection + Simulator project managed through Rojo.

## Current baseline

Gameplay/system baseline: **MVP-005**

Visual baseline: **Visual Rebuild 007**

The first Studio smoke test confirmed that the static world boots, the player reaches Green Meadows, the HUD/data loop initializes, and the factory economy begins producing. That smoke test exposed the original placeholder presentation as unacceptable, so the project moved through a dedicated visual rebuild before the full checklist resumes.

## Visual Rebuild 007

- the legacy two-stage HUD architecture is gone.
- `ClientBootstrap.client.lua` is now only a minimal launcher for the canonical client HUD controller.
- `Client/HUDView.lua` creates the final simulator-style HUD directly instead of first building placeholder UI.
- `Client/HUDController.lua` owns state binding, marketplace prompts and existing Remote actions.
- `VisualRefresh.client.lua` was deleted; no search/reparent/restyle adapter remains.
- the old Bootstrap worker-orb code disappeared with the monolith replacement.
- `UIVisualContract.lua` remains the semantic icon contract and is now version 2.
- Shop / Monsters / Zones / Quests / Rewards / Achievements / Index keep stable GUI names for compatibility with current in-world guidance.
- Visual Rebuild 006 still owns direct worker rendering and Hatch reveal through `WorkerVisualFactory.lua`.
- `MonsterFactoryWorld.model.json` remains the gameplay-anchor world and `MonsterFactoryArt004.model.json` remains the non-colliding static art layer.
- canonical Lighting / Atmosphere / Bloom / ColorCorrection remain owned by `default.project.json`.
- `ZoneMood.client.lua` transitions the scene palette by logical zone.
- current-zone Generator, Collector, Capsule and Worlds anchors retain 3D guidance / ProximityPrompt interaction.
- default Studio `Baseplate` / root `SpawnLocation` cleanup remains owned by `WorldService`.
- first-pass Studio testing uses explicit ephemeral profiles so DataStore API permission noise does not block visual/core-loop testing.

Detailed audits:

- `docs/VISUAL_REBUILD_003_AUDIT.md`
- `docs/VISUAL_REBUILD_004_AUDIT.md`
- `docs/VISUAL_REBUILD_005_AUDIT.md`
- `docs/VISUAL_REBUILD_006_AUDIT.md`
- `docs/VISUAL_REBUILD_007_AUDIT.md`

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

## Next validation point

Do not pull/test after every development commit.

Continue development in GitHub, then pull once when a grouped visual/content pass is ready for Studio validation. At that point resume the checklist from:

`docs/MVP_005_STUDIO_TEST_CHECKLIST.md`

The next Studio pass must also validate the new canonical HUD architecture and Visual Rebuild 006 Hatch reveal.

Real Pass/Product IDs are still configured only in:

`src/ReplicatedStorage/Shared/MonetizationConfig.lua`
