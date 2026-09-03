# Monster Factory Simulator — External Visual Asset Intake 001

This file tracks external visual candidates for the first non-placeholder art pass.

The project may use Creator Store assets for presentation, but gameplay logic must remain in the repository and must not depend on unknown bundled scripts.

## Approved first candidates

### GUI Asset Pack!

Creator Store asset: `130347426228193`

Source:
https://create.roblox.com/store/asset/130347426228193/GUI-Asset-Pack

Use:
- visual reference / reusable GUI art only,
- buttons, panels and decorative UI components may be adapted,
- do not replace Monster Factory server/client gameplay logic with bundled scripts.

Intake rule:
- the model reports bundled scripting,
- remove or audit all `Script`, `LocalScript`, `ModuleScript`, package loaders and external `require(assetId)` before retaining visual objects,
- repository-owned UI logic remains authoritative.

### Low Poly Asset Pack

Creator Store asset: `7436760067`

Source:
https://create.roblox.com/store/asset/7436760067/Low-Poly-Asset-Pack

The asset description permits simulator-map use and includes environment props suitable for trees, cactus, hills, borders and general low-poly dressing.

Use priority:
- Meadow trees / bushes / hills,
- Desert cactus / border pieces,
- Frozen boundary substitutes only when stylistically appropriate,
- general simulator boundary dressing.

License note from the asset description:
- simulator-map use is allowed,
- do not resell the pack,
- do not use the pack in commissions.

### Low Poly Asset Pack — small environment set

Creator Store asset: `18723685255`

Source:
https://create.roblox.com/store/asset/18723685255/Low-Poly-Asset-Pack

Use:
- small rock / grass / simulator-border / tree set,
- candidate for low-cost boundary dressing where the larger pack is unnecessary.

## Rejected / hold candidates

### Simulator Icon Pack

Creator Store asset: `99176447965360`

Do not ingest at this stage.

Reason:
- Creator Store review discussion raises a possible third-party icon redistribution/license issue,
- until provenance is independently cleared, the pack is not acceptable as a canonical project dependency.

## Canonical import slots after Visual Rebuild 002

Each zone in `src/Workspace/MonsterFactoryWorld.model.json` now contains an `ExternalArt` folder.

Imported Creator Store visuals must be cleaned and moved into the matching zone's `ExternalArt` folder instead of replacing gameplay anchors directly.

Examples:

- `MonsterFactoryWorld/Meadow/ExternalArt`
- `MonsterFactoryWorld/Desert/ExternalArt`
- `MonsterFactoryWorld/Frozen/ExternalArt`

The following anchors must remain repository-owned and must not be renamed by external art imports:

- `FactorySpawn`
- `Generator`
- `ConveyorCore`
- `Reactor`
- `Collector`
- `ZoneMarker`
- `WorkerStations/WorkerStation_1..6`
- `MeadowCapsuleMachine`
- `DesertCapsuleMachine`
- `FrozenCapsuleMachine`

External meshes/models may visually cover or surround these anchors, but gameplay code must continue to target the stable repository-owned anchors.

## Import checklist

For every Creator Store model imported into Studio:

1. inspect every descendant,
2. delete unexpected `Script`, `LocalScript`, `ModuleScript`, package loader or external `require(assetId)`,
3. inspect attributes, constraints, welds and unusual hidden descendants,
4. keep only the visual objects actually used,
5. rename/move retained objects into the matching `ExternalArt` folder,
6. keep gameplay anchors intact,
7. record the asset ID and changed usage here,
8. never make paid/reward/data logic depend on the imported model.

## Current relationship to Visual Rebuild 002

The map itself is now canonical static Rojo data. `WorldVisualRefresh.server.lua` was removed in Visual Rebuild 002; runtime world restyling is no longer part of the normal build.

`VisualRefresh.client.lua` remains a single consolidated client presentation adapter while the underlying legacy HUD controller is progressively refactored. No additional visual overlay script should be added on top of it.

External assets are replacements/enhancements for visible art only. They must remain removable without breaking Collect, Hatch, Upgrade, Monsters, Zones, Rebirth, rewards, purchases, saving, or worker placement.
