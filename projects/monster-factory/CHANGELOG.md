# Changelog

## Visual Rebuild 003

### Worker characters
- Added `WorkerCharacters.client.lua` as the canonical worker presentation layer.
- Replaced the visible orb placeholders with small procedural character models while preserving the existing worker-state contract.
- Added distinct visual families for slime, mushroom, bee, beast, golem, scarab, humanoid, sphinx, snowball, penguin, yeti, dragon and factory-bot workers.
- Added rarity-aware nameplates, production bonus text, shiny highlighting and subtle idle bob/turn animation.
- Worker character visuals are still client-only and cannot affect production, inventory or reward logic.

### In-world factory interaction
- Added `WorldInteractionGuide.client.lua`.
- Added current-zone BillboardGui guidance for Generator, Collector, Capsule and Worlds anchors.
- Added ProximityPrompt actions for Upgrade, Collect and Hatch so the factory can be operated from the 3D world as well as the HUD.
- Added a Worlds prompt that opens the existing Zones window.
- Prompt availability follows the player's current logical zone; server-side validation remains authoritative for all state-changing actions.
- Dynamic subtitles show generator level/cost, pending collector Cash and current hatch price/free-first-hatch state.

### Architecture
- Reused existing RemoteEvents and static world anchors; no new economy or progression authority was introduced on the client.
- External art remains optional and replaceable through the existing per-zone `ExternalArt` folders.

## Visual Rebuild 002

### Canonical world
- Replaced the small placeholder static world with a substantially expanded canonical Rojo world.
- Added factory foundations, entry paths, generator/conveyor/reactor detailing, capsule areas, collector structures, portal frames, worker pads and zone boundary dressing.
- Added dedicated `ExternalArt` folders to Meadow, Desert and Frozen for sanitized Creator Store art.
- Preserved all gameplay anchor names used by current services.
- Removed `WorldVisualRefresh.server.lua`; visual world construction is no longer performed as a runtime patch.

### UI
- Replaced Visual Refresh 001 with one consolidated Visual Refresh 002 adapter instead of stacking another overlay.
- Added simulator-style stat chips and compact collection/progression side docks.
- Kept Collect / Hatch / Upgrade as the three primary bottom actions.
- Added modal dimming and client-side world blur.
- Enforced one major modal at a time.
- Added hover/press feedback and tighter responsive scaling.

### Studio workflow
- Added explicit ephemeral Studio profile mode for first-pass visual/core-loop testing.
- Updated Rojo launcher to recognize the existing `Desktop\Rojo\rojo.exe` installation used by the development machine.
- `WorldService` removes legacy root Baseplate / SpawnLocation objects when the canonical world exists.

### External art
- Defined stable `ExternalArt` intake slots and preserved logical anchors.
- Updated Creator Store candidate/sanitization documentation.
- Runtime gameplay is not allowed to depend on imported model scripts.

## MVP-005

### Security
- Added centralized SecurityService.
- Added action-specific server rate limits.
- Added safe string-ID validation.
- Added zone integer validation.
- Applied validation/rate limiting to all state-changing gameplay remotes.

### Worker visuals
- Moved equipped worker visuals from player orbit to factory Worker Stations.
- Worker visual state now carries current zone.
- Zone travel refreshes worker placement.

### World
- Added six Worker Stations per zone.
- Added distinct Meadow trees, Desert cacti, Frozen crystals.
- Added zone-specific machine palettes/scales.

### UX / Monetization
- Retained explicit VIEW OFFER / NO THANKS contextual offers.
- Added first-session flow audit.
- Formalized monetization pacing constraints.

### Testing
- Added Remote security audit.
- Added full Studio test checklist.
- Content foundation was formally approved for first end-to-end Studio playtest.

### MVP-005 final integration patch
- Worker Station visuals now refresh immediately after zone unlock.
- Worker Station visuals now refresh after Rebirth returns the player to Meadow.
- Added responsive HUD scaling for <=600px and <=900px viewport widths.
- Added narrow-screen test cases to Studio checklist.

### MVP-005 local-place boot hotfix
- Fixed unpublished/local `.rbxlx` boot failure caused by eager DataStore initialization.
- PlayerDataService now lazily acquires DataStore and falls back to ephemeral Studio data.
- WorldService now boots before data/economy service requires.
- Added boot sentinel messages to Studio Output.
- Studio place file gained a static world/floor/spawn path so script errors cannot cause endless void deaths.
