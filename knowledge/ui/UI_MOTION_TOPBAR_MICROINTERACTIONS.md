# UI Motion, Topbar, and Microinteraction Libraries

> verified: 2026-09-03

UI quality is not improved by adding motion everywhere. Libraries should provide consistent response and interruption behavior, not decorative noise.

## Ripple — CURRENT_RECOMMENDED / MOTION

Repo: https://github.com/littensy/ripple
License: MIT
Verified:
- not archived
- pushed 2026-07-18
- project describes itself as an elegant motion library for Roblox

Good fit:
- springs/tweens for UI and presentation
- interruptible motion
- consistent motion primitives

Use for:
- panel transitions
- selection/highlight response
- numbers/progress motion
- subtle camera/presentation values if architecture fits

Avoid:
- making every component bounce
- replacing simple TweenService uses that are already clear and sufficient

## TweenService — NATIVE DEFAULT

For simple one-shot transitions, Roblox TweenService remains the simplest dependency-free choice.

Use a motion library when:
- spring behavior matters
- animations are interrupted/re-targeted often
- a shared motion abstraction improves many components

## RbxUtil Spring — TARGETED OPTION

If RbxUtil is already a dependency, its Spring utility may avoid adding a second motion package. Do not stack multiple spring implementations in one UI without a clear reason.

## TopbarPlus — CONDITIONAL / LICENSE REVIEW

Repo: https://github.com/1ForeverHD/TopbarPlus
Verified:
- not archived
- repo describes dynamic topbar icons/themes/dropdowns/menus
- last push observed 2025-09-17
- GitHub license metadata is `NOASSERTION/Other` at verification, so exact license/source terms must be reviewed before adoption

Use case:
- game genuinely needs Roblox-style topbar integration/icons

Do not use simply to avoid designing an in-world/game HUD.

## Motion grammar

Project design system should define a small vocabulary:
```text
instant: state must react now
fast: button/hover/selection
normal: panel/menu transition
emphasis: rare reward/major state
spring_soft: friendly menu settle
spring_tight: gameplay-responsive state
```

Exact timings are project-specific; consistency is the key.

## Interruptibility

A player may:
- reopen a closing menu
- spam tabs
- die during reward animation
- switch input device mid-transition

Motion code must handle a new target without leaving stale state or multiple concurrent loops.

## Reduced motion / comfort

For heavy camera/UI movement games, consider settings that reduce:
- camera shake
- large zooms
- repeated UI bounce
- long parallax

Important status/action changes must remain understandable without animation.

## Motion and network

UI should generally animate from local presentation state immediately when safe, then reconcile with authoritative server result.

Example purchase:
- button press local visual response
- request sent
- loading/disabled state
- server success → success motion
- failure → error state

Never award/equip an item merely because an animation finished.

## Storybook pairing

Ripple/Tween motion should be testable in UI Labs/Flipbook stories for:
- first open
- repeated open/close
- interrupted animation
- disabled/loading transition
- small viewport

## Performance

Avoid:
- hundreds of always-running springs for hidden UI
- per-frame manual layout rebuilds
- motion that forces large expensive UI trees to update when invisible

Pause/destroy animation state with component lifecycle.

## Acceptance

- motion clarifies hierarchy/state
- primary action responds quickly
- repeated interaction does not stack broken tweens
- UI remains usable with motion minimized
- no dependency duplication for the same primitive
