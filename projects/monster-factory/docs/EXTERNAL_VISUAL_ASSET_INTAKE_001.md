# Monster Factory Simulator — External Visual Asset Intake 001

This file tracks external visual candidates for the first non-placeholder art pass.

Creator Store assets may be used for presentation, but gameplay logic must remain repository-owned and must not depend on unknown bundled scripts or runtime asset loading.

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

## Reference / hold candidates

### Factory low poly

Creator Store asset: `6247256567`

Source:
https://create.roblox.com/store/asset/6247256567

Use:
- industrial silhouette reference only for now.

Reason for hold:
- Creator Store acquisition is available, but explicit use/provenance language is weaker than the primary environment pack,
- do not make it a canonical dependency until manually reviewed.

### Simulator Icon Pack

Creator Store asset: `99176447965360`

Do not ingest at this stage.

Reason:
- Creator Store review discussion raises a possible third-party icon redistribution/license issue,
- until provenance is independently cleared, the pack is not acceptable as a canonical project dependency.

## Canonical source of intake status

Visual Rebuild 004 added:

`src/ReplicatedStorage/Shared/VisualAssetManifest.lua`

This records the reviewed asset IDs, intended use and current status.

Runtime external loading is explicitly forbidden.

## Studio-only sanitation helper

Visual Rebuild 004 added:

`tools/studio/IMPORT_EXTERNAL_VISUALS.lua`

This file is intentionally outside the Rojo runtime source tree.

When deliberately run from the Studio Command Bar it stages approved models under:

`ServerStorage/MonsterFactoryExternalAssetStaging`

The helper removes scripts and common interactive/gameplay objects before review and anchors retained BaseParts.

The helper does **not** automatically merge whole packs into the final game.

Only reviewed descendants should be retained.

## Canonical import slots

Each zone in `src/Workspace/MonsterFactoryWorld.model.json` contains an `ExternalArt` folder.

Imported Creator Store environment visuals must be cleaned and moved into the matching zone's `ExternalArt` folder instead of replacing gameplay anchors directly.

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
5. rename/move retained environment objects into the matching `ExternalArt` folder,
6. keep gameplay anchors intact,
7. record the asset ID and changed usage here / in `VisualAssetManifest.lua`,
8. never make paid/reward/data logic depend on the imported model,
9. do not rely on live `InsertService` / asset-ID loading in production.

## Relationship to Visual Rebuild 004

The gameplay world remains canonical static Rojo data.

`MonsterFactoryArt004.model.json` is also static Rojo data and adds stronger zone silhouettes without runtime geometry generation.

`VisualRefresh.client.lua` remains the consolidated client HUD presentation adapter.

External assets are replacements/enhancements for visible art only. They must remain removable without breaking Collect, Hatch, Upgrade, Monsters, Zones, Rebirth, rewards, purchases, saving, worker placement or zone travel.
