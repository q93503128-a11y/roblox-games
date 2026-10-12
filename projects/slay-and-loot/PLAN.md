# Slay & Loot — Active Plan

Status: NOT STARTED IN STUDIO

## Current goal

Create and validate the first playable vertical slice for Slay & Loot using Roblox Studio + OpenCode + Studio MCP.

The first slice should prove the core loop before broader content production:

`spawn -> fight a readable enemy group -> receive visible loot -> equip/use improved gear -> fight a stronger encounter -> understand the next progression target`

## Current context

The project direction is intentionally lightweight at the start. Exact weapon, monster, environment, animation, and VFX designs may be chosen from audited external assets during implementation and then promoted into the live design after they prove suitable.

## In scope for the first implementation pass

- inspect the actual blank/current Studio project
- confirm avatar scale, camera, spawn, and usable bounds
- inspect references and search audited external asset candidates
- select one coherent visual direction
- implement one compact combat zone
- implement one polished primary weapon family
- implement 2–3 enemy archetypes with readable behavior
- implement visible loot pickup/equipment progression
- implement one stronger encounter or mini-boss
- create the minimum HUD needed for the loop
- validate desktop and basic mobile usability

## Do not change / do not add yet

- no giant open world
- no large quest system
- no trading
- no guilds
- no large skill tree
- no multiple currencies unless the slice proves a second currency is necessary
- no large rebirth system before the base combat/loot loop is accepted
- no content flooding to hide weak combat
- no production use of unaudited free-model scripts

## Reference and asset approach

Use Roblox references and audited Creator Store/external assets before inventing detailed art from scratch.

For the first slice, evaluate candidates for:

- one environment kit/style family
- one weapon family
- one enemy/monster family or visually compatible set
- one attack animation family
- one compact VFX language

Record accepted production assets in `docs/ASSET_SOURCES.md`.

## Acceptance criteria

The slice is accepted only if:

- player spawns correctly
- the first meaningful action is obvious without a long tutorial
- combat input is responsive and readable
- fighting multiple enemies feels intentional rather than chaotic/broken
- at least one equipment drop is visually understandable and usable
- upgraded equipment produces noticeable power/feel change
- one stronger encounter can be completed
- the P0 route has no project-attributable unexpected runtime errors
- map scale, collision, path, and camera are acceptable from gameplay view
- the slice works on desktop and has a viable mobile control/UI route

## Exact P0 test route

To be filled after the first Studio inspection establishes the real spawn/zone layout.

Expected structure:

1. clean boot
2. spawn
3. acquire/use starter weapon
4. enter first combat area
5. defeat first enemy group
6. collect/equip loot
7. defeat stronger group/elite
8. reach and complete stronger encounter or mini-boss
9. confirm next progression target is readable
10. repeat the route after the art/asset pass

## Stop conditions

Stop implementation and reassess if:

- the same subsystem fails structurally twice
- selected external assets cannot be made visually coherent without heavy rework
- enemy count/performance cannot meet the intended combat feel on target devices
- the core combat loop remains weak after one focused combat-feel revision
- Studio/MCP state is not trustworthy enough to validate the current step

Do not expand into more zones until this slice passes acceptance.
