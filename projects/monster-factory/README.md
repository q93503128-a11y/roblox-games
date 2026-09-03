# Monster Factory Simulator

Factory Tycoon + Monster Collection + Simulator project managed through Rojo.

## Current baseline

Gameplay/system baseline: **MVP-005**

Visual baseline: **Visual Rebuild 004**

The first Studio smoke test confirmed that the static world boots, the player reaches Green Meadows, the HUD/data loop initializes, and the factory economy begins producing. That smoke test also exposed the original placeholder presentation as unacceptable for continued testing, so the project moved into a dedicated visual rebuild before the full checklist continues.

## Visual Rebuild 004

- `MonsterFactoryWorld.model.json` remains the gameplay-anchor world.
- `MonsterFactoryArt004.model.json` adds a static non-colliding silhouette layer for Meadow / Desert / Frozen instead of a runtime world-restyling script.
- Meadow now leans toward a bio-industrial factory silhouette, Desert toward an asymmetric refinery silhouette, and Frozen toward a cryogenic lab silhouette.
- canonical Lighting / Atmosphere / Bloom / ColorCorrection are now owned by `default.project.json` rather than inherited from an arbitrary Studio place.
- `ZoneMood.client.lua` transitions visual atmosphere by the player's current logical zone.
- equipped workers use the Visual Rebuild 003 character presentation with rarity nameplates, shiny treatment and idle motion.
- current-zone Generator, Collector, Capsule and Worlds anchors retain 3D guidance / ProximityPrompt interaction.
- `VisualRefresh.client.lua` remains the consolidated simulator-style HUD presentation adapter from Visual Rebuild 002.
- default Studio `Baseplate` / root `SpawnLocation` cleanup remains owned by `WorldService`.
- first-pass Studio testing uses explicit ephemeral profiles so DataStore API permission noise does not block visual/core-loop testing.

Detailed audits:

- `docs/VISUAL_REBUILD_003_AUDIT.md`
- `docs/VISUAL_REBUILD_004_AUDIT.md`

## External art policy

Creator Store art may replace/enhance visible geometry and UI presentation, but must never own gameplay logic.

Read:

`docs/EXTERNAL_VISUAL_ASSET_INTAKE_001.md`

The reviewed source IDs and status are also recorded in:

`src/ReplicatedStorage/Shared/VisualAssetManifest.lua`

A Studio-only sanitation helper exists at:

`tools/studio/IMPORT_EXTERNAL_VISUALS.lua`

Imported models must be sanitized before use. Whole packs should not be retained by default, and gameplay anchors must remain repository-owned.

## Next validation point

Do not pull/test after every development commit.

Continue development in GitHub, then pull once when a grouped visual/content pass is ready for Studio validation. At that point resume the checklist from:

`docs/MVP_005_STUDIO_TEST_CHECKLIST.md`

Real Pass/Product IDs are still configured only in:

`src/ReplicatedStorage/Shared/MonetizationConfig.lua`
