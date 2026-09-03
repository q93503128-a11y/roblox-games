# Monster Factory Simulator — Visual Rebuild 004 Audit

Date: 2026-09-03

## Goal

Visual Rebuild 004 reduces the remaining block-prototype look without reintroducing runtime world-restyling patches.

The pass also turns external Creator Store use into an explicit, reviewable intake workflow rather than allowing runtime asset loading or unknown scripts to enter gameplay.

## 1. Static silhouette art

Added:

`src/Workspace/MonsterFactoryArt004.model.json`

This is a static Rojo model, not a runtime generator.

It adds 75 non-gameplay visual instances across the three existing zone coordinates.

### Meadow

Identity target: eco-industrial / bright bio-factory.

Added:
- elevated landmark gantry,
- angled canopy ribs,
- perimeter towers,
- overhead backbone structure,
- paired bio spires / wings,
- energy bridge accent.

### Desert

Identity target: refinery / heat-processing outpost.

Added:
- elevated landmark gantry,
- angular structural ribs,
- perimeter towers,
- overhead service backbone,
- tall asymmetric refinery stacks,
- heat bridge accent.

### Frozen

Identity target: cryogenic research factory.

Added:
- elevated landmark gantry,
- sharper purple/cyan ribs,
- perimeter towers,
- overhead lab backbone,
- paired cryo spires,
- tall antenna mast,
- elevated cryo bridge.

All Art004 geometry is non-colliding and owns no gameplay authority.

Existing logical anchors in `MonsterFactoryWorld` remain the only objects services should depend on.

## 2. Canonical Lighting

`default.project.json` now owns the experience Lighting presentation.

Added/tuned:
- Lighting brightness and exposure,
- ambient / outdoor ambient,
- Atmosphere,
- Bloom,
- ColorCorrection.

This prevents the project from relying on whatever default lighting happens to exist in a Studio place.

## 3. Per-zone mood

Added:

`src/StarterPlayer/StarterPlayerScripts/ZoneMood.client.lua`

The script only changes visual post-processing and Atmosphere values.

Green Meadows:
- warm daylight tint,
- slightly clearer air,
- moderate saturation.

Desert Outpost:
- warm amber tint,
- stronger haze,
- slightly stronger saturation/contrast.

Frozen Lab:
- cool blue tint,
- cleaner/cooler atmosphere,
- stronger bloom/contrast.

ZoneMood listens to the existing ZoneStateUpdated contract and requests the existing zone state at boot.

No zone progression state is owned by this script.

## 4. External asset provenance

Added:

`src/ReplicatedStorage/Shared/VisualAssetManifest.lua`

Runtime loading of external Creator Store IDs is explicitly forbidden.

Primary reviewed candidates:

### Environment

Low Poly Asset Pack — `7436760067`

Creator Store:
https://create.roblox.com/store/asset/7436760067/Low-Poly-Asset-Pack

Reason for priority:
- free Creator Store model,
- strong rating history,
- description explicitly allows simulator-map use,
- includes useful trees, bushes, hills, borders and cacti.

Restrictions recorded from creator description:
- do not resell,
- do not use in commissions.

### UI

GUI Asset Pack! — `130347426228193`

Creator Store:
https://create.roblox.com/store/asset/130347426228193/GUI-Asset-Pack

Reason for priority:
- free GUI pack,
- useful as design/presentation source,
- current Creator Store technical details report one bundled script.

Intake rule:
- remove bundled scripts before any visual descendants are retained,
- do not replace Monster Factory gameplay logic with asset scripts.

### Hold reference

Factory low poly — `6247256567`

Creator Store:
https://create.roblox.com/store/asset/6247256567

This remains reference-only until provenance/use review is stronger.

## 5. Studio-only sanitized intake helper

Added:

`tools/studio/IMPORT_EXTERNAL_VISUALS.lua`

This file is outside the Rojo runtime source tree.

When intentionally run from the Studio Command Bar it:
- loads the approved candidate IDs through InsertService,
- removes LuaSourceContainer descendants,
- removes RemoteEvents / RemoteFunctions / Bindables / Tools / ClickDetectors / ProximityPrompts / Humanoids / AnimationControllers,
- anchors and disables collision/touch on retained BaseParts,
- places sanitized candidates only in `ServerStorage/MonsterFactoryExternalAssetStaging`,
- prints a sanitation count.

It does **not** automatically merge whole packs into the game.

Only reviewed descendants should later be retained under zone `ExternalArt` slots or the future canonical UI-art area.

## 6. Explicit non-goals

Visual Rebuild 004 does not:
- change Cash formulas,
- change hatch odds,
- change zone costs,
- change Rebirth requirements,
- change Remote security,
- dynamically require/load Creator Store assets in a live server,
- make imported model scripts authoritative,
- claim that the raw Creator Store binary packs are already vendored in Git.

## 7. Validation before next Studio checkpoint

At the next grouped Studio validation verify:
- Art004 syncs with no Rojo property errors,
- WedgePart CFrame orientation is correct,
- landmark structures do not cover interaction billboards,
- zone mood transitions occur on travel,
- Bloom/Atmosphere do not reduce UI readability,
- mobile/low graphics still keep gameplay anchors obvious.

Full MVP checklist remains:

`docs/MVP_005_STUDIO_TEST_CHECKLIST.md`
