# Monster Factory Simulator

Factory Tycoon + Monster Collection + Simulator project managed through Rojo.

## Current baseline

Gameplay/system baseline: **MVP-005**

Visual baseline: **Visual Rebuild 002**

The first Studio smoke test confirmed that the static world boots, the player reaches Green Meadows, the HUD/data loop initializes, and the factory economy begins producing. That smoke test also exposed the original placeholder presentation as unacceptable for continued testing, so the project moved into a dedicated visual rebuild before the full checklist continues.

## Visual Rebuild 002

- `MonsterFactoryWorld.model.json` is now the canonical visual world instead of a small placeholder world plus runtime restyling.
- the three zones contain substantially expanded factory geometry, paths, portal structures, worker pads, boundary dressing and dedicated `ExternalArt` import slots.
- the old `WorldVisualRefresh.server.lua` runtime patch was removed.
- `VisualRefresh.client.lua` was consolidated into one simulator-style presentation adapter with stat chips, compact side docks, primary bottom actions, modal dim/blur and responsive scaling.
- default Studio `Baseplate` / root `SpawnLocation` cleanup remains owned by `WorldService`.
- first-pass Studio testing uses explicit ephemeral profiles so DataStore API permission noise does not block visual/core-loop testing.

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
