# Changelog

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
- Content foundation is now formally approved for first end-to-end Studio playtest.

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
- Studio place file now contains a static emergency floor and spawn so script errors cannot cause endless void deaths.
