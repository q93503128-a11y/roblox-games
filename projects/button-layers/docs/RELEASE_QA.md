# Button Layers — Release QA

Status labels:
- DESIGN
- IMPLEMENTED
- BOOT_VERIFIED
- ROUTE_TESTED
- RELEASE_CANDIDATE
- PUBLISHED

Never skip directly from IMPLEMENTED to RELEASE_CANDIDATE.

## A. Boot / runtime
- [ ] Clean server/client boot
- [ ] Project-attributable unexpected runtime error = 0
- [ ] Correct spawn
- [ ] No missing critical map
- [ ] No player-facing DEBUG/TODO/WIP/test content

## B. Core economy
- [ ] All 50 button IDs unique and reachable
- [ ] Costs/rewards finite and positive
- [ ] Reset hierarchies correct
- [ ] Locked buttons cannot be invoked remotely
- [ ] Manual and Auto use the same authoritative transaction functions
- [ ] No duplicate reward from occupancy/touch races
- [ ] Number formatter never shows NaN/Inf/blank

## C. Pacing
- [ ] First button 3–8 sec
- [ ] First Rebirth 1.5–2.5 min Normal
- [ ] First Ultra 8–13 min Normal
- [ ] First Prestige 25–40 min Normal
- [ ] First Ascension 90–150 min Normal
- [ ] No unexplained >90 sec dead stretch
- [ ] Reset recovery feels materially faster
- [ ] No required manual same-button grind >20 activations

## D. Spatial
- [ ] Studio bounds/spawn/avatar/camera measured
- [ ] Named anchors used
- [ ] 5+ object placements have placement plan/table
- [ ] Spawn → first button 2–5 sec
- [ ] Reset → useful row 2–5 sec
- [ ] No empty straight walk >8 sec
- [ ] P0 route not blocked by art/secrets
- [ ] Gameplay camera readable at Area entry/center/corners/buttons
- [ ] No z-fighting/floating/buried production geometry
- [ ] Mobile camera does not turn labels into unreadable overlap

## E. Automation
- [ ] Auto Multi
- [ ] Auto Rebirth
- [ ] Auto Ultra
- [ ] Auto Prestige
- [ ] On/Off works
- [ ] Target mode works
- [ ] Waiting/invalid states readable
- [ ] Auto/manual race test
- [ ] Reset loop can always be stopped

## F. Meta
- [ ] 48 Achievements
- [ ] 8 Secrets
- [ ] 50-button Collection
- [ ] Records
- [ ] Star rewards
- [ ] Secret rewards
- [ ] Hidden achievement states
- [ ] Multi-award summary toast
- [ ] No meta system required for Main progression
- [ ] Badge failure cannot break internal award

## G. Save
- [ ] Fresh profile
- [ ] Normal leave/rejoin
- [ ] Rapid rejoin
- [ ] Leave after reset
- [ ] Leave after achievement
- [ ] Leave after secret
- [ ] Leave during automation
- [ ] Save retry/backoff
- [ ] Corrupt/default fallback
- [ ] Schema migration
- [ ] Known-good save not overwritten by clearly invalid state

## H. Security
- [ ] Remote spoof
- [ ] Locked button spoof
- [ ] Locked area teleport attempt
- [ ] Impossible distance
- [ ] Negative/NaN/Inf
- [ ] transaction spam
- [ ] simultaneous reset
- [ ] replayed request
- [ ] fake achievement
- [ ] manual/auto race

## I. UI / input
- [ ] 720p
- [ ] 1080p
- [ ] small phone
- [ ] modern phone
- [ ] tablet
- [ ] gamepad navigation for full-screen menus where relevant
- [ ] no clipping
- [ ] safe areas respected
- [ ] text remains readable without global TextScaled hacks
- [ ] no hover-only critical information
- [ ] reduced effects setting
- [ ] reset confirmation setting

## J. Art / audio
- [ ] One coherent button kit
- [ ] Five Areas visually distinct by architecture, not recolor only
- [ ] Production materials/trim/lighting
- [ ] Tier color + symbol + shape
- [ ] No raw placeholder hero assets
- [ ] Press/cannot-afford/unlock/reset/achievement/secret/UI SFX
- [ ] Occupancy-repeat audio does not clip/spam
- [ ] Reset feedback hierarchy clear

## K. Performance
- [ ] No per-button frame loops
- [ ] UI update batching/event-driven refresh
- [ ] automation scheduler centralized
- [ ] transient VFX cleaned
- [ ] mobile Performance Summary baseline
- [ ] Scene Analysis if evidence says needed
- [ ] MicroProfiler only if evidence says needed

## L. Release surface
- [ ] Final title re-checked
- [ ] Icon
- [ ] 2+ thumbnails
- [ ] Description
- [ ] No dev/AI/TODO wording
- [ ] English strings
- [ ] Korean strings where planned
- [ ] localization-safe layout
- [ ] known limitations documented outside player route

Only after every release-critical item is passed or explicitly accepted as a known limitation may the project be called `RELEASE_CANDIDATE`.
