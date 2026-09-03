# Monster Factory Simulator — Visual Rebuild 002 Audit

## Purpose

Visual Rebuild 002 converts the project away from runtime visual patch stacking and establishes a cleaner visual baseline before the remaining MVP-005 Studio checklist continues.

## World result

Canonical source:

`src/Workspace/MonsterFactoryWorld.model.json`

The static world now contains an expanded three-zone factory layout with hundreds of repository-owned Parts/Folders rather than the original small placeholder map.

Preserved gameplay anchors:

- `FactorySpawn`
- per-zone `Generator`
- per-zone `ConveyorCore`
- per-zone `Reactor`
- per-zone `Collector`
- per-zone `ZoneMarker`
- `WorkerStations/WorkerStation_1..6`
- `MeadowCapsuleMachine`
- `DesertCapsuleMachine`
- `FrozenCapsuleMachine`

New visual categories include:

- island foundations and boundary blocks,
- factory pad and entry path,
- generator housings and utility banks,
- multi-piece conveyor line,
- reactor towers and cores,
- capsule platform/chamber pieces,
- collector platform/bin pieces,
- portal frame/glow geometry,
- worker station glow pads,
- Meadow tree/flower dressing,
- Desert cactus/rock dressing,
- Frozen crystal/ice-rock dressing,
- `ExternalArt` slot per zone.

`WorldVisualRefresh.server.lua` was deleted after its useful layout concepts were folded into the canonical static model.

## UI result

Canonical presentation adapter:

`src/StarterPlayer/StarterPlayerScripts/VisualRefresh.client.lua`

Visual Refresh 002 replaces Visual Refresh 001 in-place. No second visual overlay script was added.

Key changes:

- six top HUD values are converted into compact simulator-style stat chips,
- collection/progression navigation is separated into left/right docks,
- Collect/Hatch/Upgrade remain the primary bottom CTA group,
- modal windows are restyled consistently,
- only one major modal should remain visible at once,
- modal dimmer and local blur improve hierarchy,
- button hover/press feedback added,
- responsive scale bands cover narrow/mobile/tablet/desktop widths,
- legacy oversized HUD containers are hidden after their live controls are reparented.

## Studio smoke-test findings carried forward

Observed before this rebuild:

- Rojo static world synchronized into Studio,
- character spawned in the Meadow/green zone,
- server found `MonsterFactoryWorld`,
- economy/HUD state initialized and collector value increased,
- original UI/map presentation was not acceptable for continued validation,
- Studio DataStore API permission error appeared before explicit ephemeral mode was added.

Visual Rebuild 002 intentionally does not mark the full MVP-005 checklist complete. A grouped Studio retest is still required later.

## DataStore test policy

`GameConfig.STUDIO_USE_EPHEMERAL_DATA = true` remains the first-pass test setting.

This prevents persistence/API permissions from polluting visual and core-loop smoke tests. Persistence must be tested separately by explicitly switching this flag off and enabling Studio API access for the correct test experience.

## External art contract

See:

`EXTERNAL_VISUAL_ASSET_INTAKE_001.md`

External Creator Store models may be imported only after sanitization. Retained art belongs under the matching zone's `ExternalArt` folder and must not replace or rename gameplay anchors.

## Next development pass

Before the next user Studio pull/test, continue grouped development rather than forcing a pull after every commit.

Recommended next work:

1. replace temporary geometric environment props with sanitized approved Creator Store art where it materially improves quality,
2. improve monster/worker presentation beyond orb placeholders,
3. add in-world interaction signage/feedback for generator, collector and capsule areas,
4. then perform one grouped Studio visual/core-loop retest.
