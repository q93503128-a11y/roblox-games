# Rebirth RPG — Studio Quarantine Result 002

> date: 2026-09-09
> source: actual Roblox Studio Agent quarantine inspection in current Rebirth RPG test place
> status: WEAPON B RESOLVED / PRODUCTION ANIMATION IDS NOT YET PUBLISHED

## Confirmed weapon result

- original Sword Pack `10226464132` was rejected as raw/unstructured MeshPart content
- coherent replacement family: Medieval Weapons Pack `101295938004405` by RenderFixX
- Weapon A direction: Longsword
- Weapon B direction: Greatsword
- Greatsword is visibly longer/heavier than Longsword and better matches current `weapon_start_b` gameplay role
- both weapon candidates still require implementation-time Handle/PrimaryPart/grip setup
- third-party scripts were stripped from quarantine copies

## Animation quarantine result

Inspected candidate packs include:
- Fancy Cat Games `77935648543779`
- jordanrupert `8408518444`
- earlier R15 sword animation packs already present in quarantine

Studio Agent found:
- total Animation instances: 0
- available combat clips are KeyframeSequence content, not published Animation assets
- jordanrupert `SwordSlice_1_Dummy`, `SwordSlice_2_Dummy`, `SwordSlice_3_Dummy` are the preferred current 3-hit visual direction
- approximate durations: 0.733s / 0.750s / 0.750s
- all inspected sequences animate HumanoidRootPart, so root-motion handling is required

## Important correction to Studio-only blocking interpretation

For a **Studio-local Vertical Slice preview**, published numeric AnimationIds are not a hard blocker.

Current Roblox Creator Hub API documentation confirms `AnimationClipProvider:RegisterActiveAnimationClip()` / `RegisterAnimationClip()` can generate temporary IDs for localized Studio animation testing. These temporary IDs cannot be used outside Studio and therefore do not replace production publishing.

Safe temporary test route:
1. clone the selected KeyframeSequence / AnimationClip into an isolated runtime-test container
2. strip or neutralize HumanoidRootPart motion before registration
3. set clip priority to Action where applicable
4. register the sanitized clip through `AnimationClipProvider`
5. use the returned temporary ID only during Studio test
6. later, once the motion is approved, publish production animations to Roblox and replace temporary IDs

This keeps the human tester from needing to publish animations before combat feel is proven.

## Production limitation

Before any live/public build, the approved attack animations still need cloud-published Roblox animation asset IDs. Official Roblox documentation requires publishing for reusable/live AnimationId references.

## Decision

READY FOR STUDIO-LOCAL RUNTIME PRESENTATION IMPLEMENTATION.

Next coherent section:
- M1 attack retained
- Q dash
- E reserved for interaction
- 1 active skill
- remove production R Rebirth bind
- visible Longsword / Greatsword equipped representation
- Studio-local 3-hit temporary animation playback using sanitized clips
- attack/skill readability test
- no production map work yet
