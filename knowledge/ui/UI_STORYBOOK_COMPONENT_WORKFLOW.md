# UI Storybook and Component Workflow

> verified: 2026-09-03

The goal is to stop discovering basic UI defects only after entering a full play session.

## Why stories

A component story isolates one UI state in a controlled sandbox.

Useful states:
- default
- hover
- pressed
- selected
- disabled
- loading
- empty
- error
- long localized text
- gamepad focused
- small phone width
- huge numeric value

## Current candidates

### UI Labs
Repo: https://github.com/PepeElToro41/ui-labs
Status: active developer tool candidate
License: GPL-3.0 repository

Strengths:
- Storybook-like real-time component visualization
- supports common Roblox UI workflows
- useful for quickly iterating responsive states

### Flipbook
Repo: https://github.com/flipbook-labs/flipbook
Status: active developer tool candidate
License: MIT

Strengths:
- sandboxed stories
- supports React/Roact/Fusion and generic Roblox GUI patterns through its story ecosystem

## Selection rule

Pick **one primary storybook tool** unless a migration requires both.

Choose based on:
- current UI framework
- team/toolchain familiarity
- Studio-first vs filesystem-first workflow
- license/distribution policy
- hot reload/integration needs

## Component definition of done

A reusable component is not done until its relevant states can be inspected without rebuilding an entire gameplay route.

Button example:
- label normal
- long label
- icon+label
- loading
- disabled
- insufficient currency
- gamepad focus
- touch size
- 360px-ish viewport

Inventory slot example:
- empty
- common item
- rare item
- selected
- equipped
- locked
- count 1 / 99 / 9999
- missing icon fallback

## Design tokens first

Stories become much more valuable when components share tokens:
- spacing
- type scale
- corner radius
- surfaces
- strokes
- semantic colors
- motion durations

Do not fix each story with unrelated magic numbers.

## Screenshot regression

For high-value UI:
1. open story
2. fixed viewport/device
3. screenshot
4. compare after changes

Studio MCP screen capture can automate parts of this workflow when available.

## UI + gameplay integration

Stories validate presentation and local interaction states. They do **not** replace integration tests.

Still test:
- network request
- server rejection
- latency/loading
- duplicate click
- purchase success/failure
- respawn
- ScreenGui lifecycle
- actual gamepad focus transitions across screens

## Recommended Godbase workflow

`reference UI → design tokens → component → stories → device states → integration → full vertical slice`

Not:
`full game UI built in one LocalScript → user finds clipping → patch coordinates`.

## Story naming

Use discoverable names:
```text
Button/Primary
Button/Purchase
Inventory/Slot
Inventory/Tooltip
HUD/Health
Quest/Tracker
```

Include pathological states, not only pretty showcase states.

## Performance

Storybook is also useful for stress cases:
- 100 inventory slots
- 50 notifications
- long scrolling list
- animated gradients/ViewportFrames

Profile the actual production screen too; sandbox performance is not identical to full-game load.
