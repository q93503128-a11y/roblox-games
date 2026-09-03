# Monster Factory Simulator

Factory Tycoon + Monster Collection + Simulator project managed through Rojo.

## Current baseline

Gameplay/system baseline: **MVP-005**

Visual baseline: **Visual Rebuild 003**

The first Studio smoke test confirmed that the static world boots, the player reaches Green Meadows, the HUD/data loop initializes, and the factory economy begins producing. That smoke test also exposed the original placeholder presentation as unacceptable for continued testing, so the project moved into a dedicated visual rebuild before the full checklist continues.

## Visual Rebuild 003

- `MonsterFactoryWorld.model.json` remains the canonical static visual world from Visual Rebuild 002.
- equipped worker presentation now converts the former visible orb placeholder into distinct small character workers with rarity nameplates, shiny treatment and idle motion.
- slime, mushroom, bee, beast, golem, scarab, humanoid, sphinx, snowball, penguin, yeti, dragon and factory-bot visual families are present.
- current-zone Generator, Collector, Capsule and Worlds anchors now have compact 3D guidance.
- Upgrade / Collect / Hatch can be triggered through ProximityPrompt as well as the existing HUD while server-side security and costs remain authoritative.
- the Worlds in-world prompt opens the existing Zones window.
- `VisualRefresh.client.lua` remains the consolidated simulator-style HUD presentation adapter from Visual Rebuild 002.
- default Studio `Baseplate` / root `SpawnLocation` cleanup remains owned by `WorldService`.
- first-pass Studio testing uses explicit ephemeral profiles so DataStore API permission noise does not block visual/core-loop testing.

Detailed audit:

`docs/VISUAL_REBUILD_003_AUDIT.md`

## External art policy

Creator Store art may replace/enhance visible geometry and UI presentation, but must never own gameplay logic.

Read:

`docs/EXTERNAL_VISUAL_ASSET_INTAKE_001.md`

Imported models must be sanitized and retained under the matching zone's `ExternalArt` folder while stable gameplay anchors remain repository-owned.

## Next validation point

Do not pull/test after every development commit.

Continue development in GitHub, then pull once when a grouped visual/content pass is ready for Studio validation. At that point resume the checklist from:

`docs/MVP_005_STUDIO_TEST_CHECKLIST.md`

Real Pass/Product IDs are still configured only in:

`src/ReplicatedStorage/Shared/MonetizationConfig.lua`
