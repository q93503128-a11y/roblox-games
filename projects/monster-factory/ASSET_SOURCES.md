# Asset Sources — Monster Factory Simulator

## MVP-002

External assets used: **none**.

The current canonical environment is stored as Roblox-native Part geometry in
`src/Workspace/MonsterFactoryWorld.model.json` and synchronized through Rojo.

`WorldService.lua` keeps an emergency fallback that can rebuild the minimum world only when the canonical static world is missing. It is not the normal map source.

This is intentional during the systems/content-foundation phase:
- no hidden scripts from free models,
- no unknown licensing,
- no external package dependency,
- art can be replaced without changing game logic.

## Art replacement contract

Future art must preserve these logical anchors/names or be mapped through a dedicated visual layer:
- Generator
- ConveyorCore
- Reactor
- MeadowCapsuleMachine
- Collector
- FactorySpawn

No gameplay service may depend on MeshId or TextureId.

When external assets are added, record:
- source URL / Creator Store asset ID,
- creator,
- license/usage status,
- imported object names,
- scripts removed during intake,
- modifications made.


## MVP-003

External assets used: **none**.

Added Desert and Frozen environments using Roblox-native Parts only. These environments are now included in the canonical Rojo-managed static world model.
No MeshId, TextureId, package, or external script dependency was introduced.


## MVP-004

External assets used: **none**.

Worker visuals use Roblox-native Parts only.
No new MeshId, TextureId, PackageId, or external script dependency was introduced.


## MVP-005

External assets used: **none**.

Added:
- factory Worker Station pads,
- Meadow tree primitives,
- Desert cactus primitives,
- Frozen crystal primitives,
- differentiated machine palettes/scales.

All remain Roblox-native Part geometry and are represented in the Rojo-managed static world where applicable.
