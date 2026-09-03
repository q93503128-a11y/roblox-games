# Monster Factory Simulator — MVP-005

MVP-005 is the first build formally approved for a full Studio playtest.

## Main changes

- centralized Remote security / rate limiting
- stricter Remote argument validation
- factory Worker Stations
- equipped worker visuals moved from player orbit to factory stations
- zone-specific machine/decor differentiation
- first-session pacing audit
- monetization UX audit
- full Studio test checklist

## Status

**CONTENT FOUNDATION READY FOR FIRST FULL STUDIO PLAYTEST**

Read:
`docs/MVP_005_STUDIO_TEST_CHECKLIST.md`

Do not create real purchase items until the core loop has been tested.

When real Pass/Product IDs exist, configure only:
`src/ReplicatedStorage/Shared/MonetizationConfig.lua`
