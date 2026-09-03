# Monster Factory Simulator — MVP-006 Visual Rebuild 001

## Purpose

The MVP-005 runtime proved the core systems boot and operate in Studio, but the presentation was still prototype-grade. Visual Rebuild 001 replaces the giant text-heavy HUD layout and the sparse colored-block world presentation without changing the server-authoritative gameplay contracts.

## UI rebuild

Added `src/StarterPlayer/StarterPlayerScripts/VisualRefresh.client.lua`.

The existing gameplay HUD remains the behavior owner. The visual refresh layer reuses the already-connected controls and state labels so no Remote or economy logic is duplicated.

New presentation:

- compact six-card top resource/status strip,
- small left navigation dock,
- small right monetization/progression dock,
- bottom-center primary action bar for Collect / Hatch / Upgrade,
- dark simulator-style panel theme,
- consistent button hover treatment,
- modal restyling for Shop / Monsters / Zones / Quests / Rewards / Achievements / Index,
- responsive scaling for narrow displays,
- existing event connections survive because controls are reparented rather than recreated.

## World rebuild

Added `src/ServerScriptService/WorldVisualRefresh.server.lua`.

Critical world anchors remain owned by the static Rojo model:

- `MonsterFactoryWorld`
- `Meadow`, `Desert`, `Frozen`
- `FactorySpawn`
- `Generator`
- `ConveyorCore`
- `Reactor`
- zone capsule machines
- `Collector`
- `ZoneMarker`
- `WorkerStations`

The visual layer now:

- removes leftover Studio `Baseplate` / root `SpawnLocation`,
- restyles the three zone floors and factory pads,
- builds factory trim, entry paths and neon guide strips,
- expands Generator / Conveyor / Reactor presentation,
- adds capsule and collector visual assemblies,
- adds zone portal frames and world labels,
- adds worker-pad glow markers,
- adds zone-specific lamps and decoration,
- moves the canonical FactorySpawn to the Meadow entry path.

The static world still provides the safe floor and gameplay anchors if the visual script fails.

## External asset policy

This pass deliberately does **not** execute scripts from free models or make third-party assets part of the gameplay dependency chain.

Creator Store / external low-poly environment and UI art can be used in the next art intake pass after:

1. license/source is recorded,
2. bundled scripts are removed or audited,
3. logical anchor names are preserved,
4. the asset can be replaced without changing game logic.

The code-based Visual Rebuild 001 is therefore the fallback presentation and layout contract, not the final art ceiling.

## Next verification

Do not repeat the full MVP-005 checklist yet. First run a short visual smoke test after pulling this pass:

1. no default Baseplate / root SpawnLocation remains during Play,
2. UI no longer covers large portions of the screen,
3. Collect / Hatch / Upgrade remain functional after reparenting,
4. Shop / Monsters / Zones / Quests / Rewards / Achievements / Index still open,
5. all three world zones receive the new visual layer,
6. no new red Output errors appear.

After this smoke test passes, continue external art intake and then resume the full gameplay checklist.
