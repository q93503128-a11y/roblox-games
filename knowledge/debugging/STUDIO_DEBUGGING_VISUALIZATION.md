# Studio Debugging and Visualization Playbook

> verified: 2026-09-03

Debugging principle: **visualize the engine state before guessing.** Roblox Studio exposes many visualization/profiling tools that should be part of normal development, not emergency-only tools.

## 1. Output first

At every Playtest start:
- unexpected errors
- warnings
- duplicate bootstrap logs
- long yields/timeouts

Do not keep playing through a boot error and then debug downstream symptoms.

## 2. Explorer + Properties

Runtime inspection:
- instance parent/duplication
- attributes
- pivot/CFrame
- network-created objects
- tags
- enabled state

If an object visually looks wrong, confirm actual DataModel state before editing code.

## 3. Network owners visualization

Roblox Studio can visualize physics network ownership with colored outlines.
Use for:
- vehicles
- balls/projectiles
- ragdolls
- physics interactables

Ask:
- who owns chassis?
- did passenger take ownership?
- did server ownership change?

## 4. Mechanisms / constraints

Visualization options can show mechanisms and constraint details.
Use for:
- vehicle assembly boundaries
- welds
- attachments
- hinge/spring setup

A visually connected model may actually be multiple assemblies.

## 5. Navigation mesh

For NPC bugs, show navmesh rather than logging only path status.
Inspect:
- agent clearance
- slope
- doorway width
- blocked areas
- path labels/cost regions

## 6. Collision visualization

When player gets snagged or raycast hits invisible geometry:
- inspect collision groups
- invisible parts
- mesh collision fidelity
- CanCollide/CanQuery/CanTouch

Separate visual meshes from collision proxies.

## 7. Hitbox/cast visualization

Project-specific debug renderer should show:
- ray/sphere/block casts
- melee volume
- active frames
- target accepted/rejected

Color by status:
- green hit
- red rejected
- yellow active volume

## 8. Streaming debug

With StreamingEnabled:
- travel quickly across map
- inspect stream-in delay
- remove assumptions about far instances
- visualize/load critical regions where current tools support it

Test low bandwidth/network simulation.

## 9. Performance Summary

Start here for broad problem class:
- frame rate
- memory
- render/physics/script indicators

Then use MicroProfiler for frame-level cause.

## 10. MicroProfiler

Workflow:
1. reproduce spike
2. freeze/capture
3. identify lane/label
4. narrow script/system
5. one optimization
6. compare capture

Add `debug.profilebegin/end` around suspicious project loops where useful.

## 11. Memory soak

Repeat lifecycle 10–20 times:
- open/close UI
- spawn/kill NPC
- die/respawn
- start/end round

Watch memory/instance/connection trends. Leaks often do not appear in one short run.

## 12. Network simulation

Studio testing modes can simulate poor networking.
Run critical realtime flow under:
- latency
- packet loss
- jitter

Watch prediction, duplicate requests, state correction.

## 13. Multi-client server test

Never treat solo Play as sufficient for:
- replication
- shared enemy
- trade
- party
- server ownership
- round lifecycle

Run server + 2+ clients at minimum for network features.

## 14. Device Emulator

UI/camera/effects:
- small phone
- common phone
- tablet
- desktop
- gamepad/console scope

A screenshot from 1080p desktop is not cross-platform QA.

## 15. Developer-only debug overlay

Useful overlay fields:
```text
build/commit
server job id
player state
current zone
ping/network class
NPC count
active effects
remote rejects
profile load state
```

Do not expose secrets or anti-cheat-sensitive details publicly.

## 16. Deterministic reproduction

Bug report includes:
- build
- exact steps
- expected
- actual
- Output
- screenshot/video
- device/network

Random "sometimes broken" bugs need a seed/state capture strategy.

## 17. Root-cause notes

After meaningful bug:
```text
symptom
root cause
why existing tests missed it
fix
new regression
```

Generalizable issues go to Failure Library.

## 18. Acceptance

A hard bug is not considered solved because error disappeared once.
- [ ] original reproduction fails before fix
- [ ] passes after fix
- [ ] neighboring lifecycle tested
- [ ] regression route documented/automated where possible
