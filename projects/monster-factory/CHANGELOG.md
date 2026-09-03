# Changelog

## Visual Rebuild 007

### Canonical HUD architecture
- Replaced the 28k+ line/character legacy `ClientBootstrap.client.lua` UI/controller monolith with a minimal launcher.
- Added `Client/HUDView.lua` as the canonical HUD tree and presentation owner.
- Added `Client/HUDController.lua` as the canonical client state/action controller.
- Deleted `VisualRefresh.client.lua`; the HUD is now created in final simulator-style form instead of being searched, reparented and restyled after creation.
- Preserved stable GUI/window names (`MonsterFactoryHUD`, Shop, Monsters, Zones, Quests, Rewards, Achievements, Index) for current in-world integration.

### Legacy cleanup
- Physically removed the old Bootstrap placeholder left/right/top UI creation code with the monolith replacement.
- Physically removed the old Bootstrap worker-orb creation path.
- Removed text-search/reparent visual adaptation from the runtime by deleting VisualRefresh.
- Visual Rebuild 006 direct worker rendering through `WorkerVisualFactory.lua` remains canonical.

### UI contract
- Promoted `UIVisualContract.lua` to version 2.
- Added normalized legacy lowercase stat-slot aliases while retaining canonical semantic slot keys.
- Runtime Creator Store loading remains prohibited.

### Authority / behavior
- Existing state-changing RemoteEvents remain unchanged.
- Cash, monsters, zones, upgrades, rewards and purchases remain server-authoritative.
- Marketplace prompts, claims, zone actions and monster Equip/Fuse callbacks moved into the dedicated HUD controller without changing server contracts.

### Documentation
- Added `docs/VISUAL_REBUILD_007_AUDIT.md`.
- Promoted README visual baseline to Visual Rebuild 007.

## Visual Rebuild 006

### Worker presentation architecture
- Added `WorkerVisualFactory.lua` as the shared procedural monster visual source.
- Rewrote `WorkerCharacters.client.lua` to render equipped workers directly from canonical Monster/Zone state.
- Removed the active runtime dependency on colored orb placeholders and orb parsing.
- Retired `WorkerVisualService` into a compatibility no-op so existing service calls remain harmless while the old visual bridge is no longer published.
- Kept the old worker compatibility function in `ClientBootstrap.client.lua` inert until the larger client-controller decomposition pass; Visual Rebuild 007 later removed it physically.

### Hatch reveal
- Added `HatchReveal.client.lua` with a centered rarity-aware reveal card and ViewportFrame monster preview.
- Reused `WorkerVisualFactory` so hatch previews and in-world workers use the same visual definitions.
- Added rarity-colored burst/border treatment and stronger Epic/Legendary headlines.
- Added queued click/tap dismissal for successive real hatches.
- Added responsive card scaling for narrow mobile viewports.
- Reveal detection requires a real server-published HatchCount increase plus a newly observed non-Shiny inventory item, avoiding Shiny-fusion false positives.

### Authority / safety
- No new state-changing RemoteEvent was introduced.
- Hatch odds, Cash spending, inventory grants, equip state, Shiny fusion and zone state remain server-authoritative.

### Documentation
- Added `docs/VISUAL_REBUILD_006_AUDIT.md`.
- Promoted README visual baseline to Visual Rebuild 006.

## Visual Rebuild 005

### UI contract / external-art readiness
- Added `UIVisualContract.lua` with semantic icon slots for stats, navigation, primary actions and modal/card content.
- Kept Creator Store runtime loading disabled; icon slots use repository fallback glyphs until a sanitized Studio-side GUI-art intake provides approved project-owned image assets.
- Kept existing gameplay callbacks and Remote names independent from presentation assets.

### HUD hierarchy
- Promoted `VisualRefresh.client.lua` in-place to Visual Rebuild 005 instead of stacking another visual overlay script.
- Added icon+label side navigation and stronger top stat cards.
- Kept Collect / Hatch / Upgrade as the dominant primary actions with larger icon slots and clearer hierarchy.
- Added live value pulse feedback on stat-chip changes.

### Modal / card presentation
- Added semantic header icons and contextual subtitles to Shop, Monsters, Zones, Quests, Rewards, Achievements and Index.
- Added common gradient card treatment for scrolling entries.
- Added compact semantic entry icons and status badges such as DEV/BUY, HERE/GO/LOCK, CLAIM/DONE and FOUND/? where applicable.
- Retained one-major-modal-at-a-time dim/blur behavior.

### Action feedback
- Added client-only button pulse / ring feedback for Collect, Hatch and Upgrade.
- Observed existing authoritative state events to display result feedback after real generator upgrades, successful collects and hatch-count increases.
- Added larger presentation feedback for world unlock, insufficient Cash and Shiny creation using existing server toast/state contracts.
- No Cash, monster, reward, zone, upgrade or purchase authority was moved to the client.

### Documentation
- Added `docs/VISUAL_REBUILD_005_AUDIT.md`.
- Updated project README baseline to Visual Rebuild 005.

## Visual Rebuild 004

### Static art / zone identity
- Added `MonsterFactoryArt004.model.json` as a static Rojo art layer with 75 non-colliding visual instances.
- Added a stronger landmark gantry / backbone silhouette to all three zones.
- Pushed Green Meadows toward a bio-industrial visual language with bio spires, wings and energy accents.
- Pushed Desert Outpost toward a refinery visual language with asymmetric stacks and heat accents.
- Pushed Frozen Lab toward a cryogenic research visual language with cryo spires, antenna structure and elevated lab bridging.
- Kept gameplay anchors in `MonsterFactoryWorld.model.json`; Art004 owns no economy/progression authority.

### Lighting / atmosphere
- Moved the experience's baseline Lighting, Atmosphere, Bloom and ColorCorrection configuration into `default.project.json`.
- Added `ZoneMood.client.lua` for per-zone atmosphere/tint/bloom transitions using the existing zone-state contract.

### External visual intake
- Added `VisualAssetManifest.lua` with explicit Creator Store provenance and runtime-loading prohibition.
- Approved the free Low Poly Asset Pack (`7436760067`) for sanitized environment intake.
- Approved the free GUI Asset Pack (`130347426228193`) for design/presentation intake only; bundled scripts must be removed.
- Kept Factory low poly (`6247256567`) as reference-only pending stronger provenance/use review.
- Added `tools/studio/IMPORT_EXTERNAL_VISUALS.lua`, a Studio Command Bar helper that loads candidate assets into ServerStorage staging and strips scripts/interactivity before review.
- Raw Creator Store binary packs are not claimed as vendored Git assets in this pass.

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
