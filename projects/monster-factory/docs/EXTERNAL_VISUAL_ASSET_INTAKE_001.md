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
- the model currently reports one bundled script,
- remove or audit that script before any asset is retained,
- keep `VisualRefresh.client.lua` as the functional layout fallback.

### Low Poly Asset Pack

Creator Store asset: `7436760067`

Source:
https://create.roblox.com/store/asset/7436760067/Low-Poly-Asset-Pack

The asset description explicitly permits use for simulator maps and includes trees, pine trees, palm trees, cactuses, hills/mountains, borders, fountains and other environment props.

Use priority:
- Meadow trees / bushes / hills,
- Desert cactus / border pieces,
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
- recent Creator Store review discussion raises a possible third-party icon redistribution/license issue,
- until provenance is independently cleared, the pack is not acceptable as a canonical project dependency.

## Import checklist

For every Creator Store model imported into Studio:

1. inspect every descendant,
2. delete unexpected `Script`, `LocalScript`, `ModuleScript`, package loader or external `require(assetId)`,
3. inspect attributes and unusual constraints,
4. keep only the visual objects actually used,
5. rename/move them under a dedicated visual folder,
6. preserve Monster Factory logical anchor names,
7. record the asset ID and changed usage here,
8. never make paid/reward/data logic depend on the imported model.

## Current relationship to Visual Rebuild 001

`VisualRefresh.client.lua` and `WorldVisualRefresh.server.lua` are the repository-owned visual fallback and layout contract.

External assets are replacements/enhancements for visible art only. They must remain removable without breaking Collect, Hatch, Upgrade, Monsters, Zones, Rebirth, rewards, purchases, saving, or worker placement.
