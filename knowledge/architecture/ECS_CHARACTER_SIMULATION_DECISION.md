# ECS, Character Simulation, and Framework Selection

> verified: 2026-09-03

Do not select an architecture because it is fashionable. Select the smallest model that matches the simulation pressure.

## jecs — CURRENT_RECOMMENDED WHEN ECS FITS

Repo: https://github.com/Ukendio/jecs
License: MIT
Verified:
- not archived
- pushed 2026-07-28
- 464 GitHub stars at verification
- Luau, no-dependencies ECS focus

Good fit:
- large numbers of similar entities
- projectiles/status effects/simulation objects
- systems that benefit from tight component iteration
- data-oriented gameplay

Avoid when:
- 20 ordinary NPCs + a few domain services
- project team does not understand ECS ownership/query lifecycle

Current Godbase ECS preference for a new project: **evaluate jecs before Matter**, but benchmark/fit still decides.

## Matter — CURRENT_CONDITIONAL / ESTABLISHED

Repo: https://github.com/matter-ecs/matter
License: MIT
Verified:
- not archived
- docs remain available
- current README documents Wally `matter-ecs/matter@0.8.4`
- last observed push 2024-12-31

Matter remains a valid established Roblox ECS and may be the right choice for existing architecture/team knowledge. jecs currently shows more recent repository activity, so new projects should compare both rather than assuming Matter is the only Roblox ECS.

## Native domain modules — DEFAULT FOR MANY GAMES

Most RPG/simulator/tycoon games do not automatically need ECS.

Simple architecture:
```text
Catalogs
Domain modules
Server services
Client controllers
Bootstrap
```

is often easier to debug and enough for hundreds of gameplay features if entity counts are moderate.

## Chickynoid — SPECIALIZED / CONDITIONAL

Repo: https://github.com/easy-games/chickynoid
License: MIT
Description: server-authoritative networking character controller for Roblox.
Verified:
- not archived
- last push observed 2024-05-27

Value:
- study/reference for server authoritative movement, prediction and reconciliation
- specialized games needing custom movement/network model

Caution:
Roblox now has current native **Server Authority** work with prediction/rollback. Therefore new projects must evaluate native Roblox authority first before adopting a large custom character networking stack.

Do not replace Humanoid/default character controller for a casual RPG merely to gain theoretical anti-cheat.

## Roblox native Server Authority — PLATFORM FIRST

Current Godbase default order for competitive movement:
1. understand current Roblox `Workspace.AuthorityMode`/Server Authority support and beta/current requirements
2. prototype native behavior
3. test network simulation and resimulation side effects
4. only then compare specialized custom controller stacks such as Chickynoid

Native platform support reduces custom maintenance surface when it meets design needs.

## Flamework — CURRENT_CONDITIONAL / ROBLOX-TS

Repo: https://github.com/rbxts-flamework/core
License: MIT
Verified:
- not archived
- TypeScript-based
- framework provides dependency/metadata architecture for roblox-ts projects

Use when:
- project intentionally chooses roblox-ts
- decorators/DI/framework conventions genuinely help the team
- filesystem/compile pipeline is already desired

Avoid when:
- Studio-first Luau is preferred
- introducing TypeScript only to use Flamework

Framework selection should follow language/workflow choice, not cause an unnecessary language migration.

## Architecture complexity ladder

### Level 0 — direct modules
Small prototype/vertical slice.

### Level 1 — domain services/controllers
Most medium Roblox games.

### Level 2 — state/reactivity layer
Charm/Reflex/UI framework if state pressure appears.

### Level 3 — ECS
jecs/Matter when entity/system query pressure justifies it.

### Level 4 — custom simulation/netcode
Chickynoid-like architecture only for games whose movement/network requirements justify ownership of that complexity.

Do not start at Level 4 because the planned game might someday be large.

## ECS performance rule

ECS is not magic optimization.

Measure:
- entity count
- queries/systems per frame
- component churn
- Roblox Instance sync cost
- serialization/network cost
- GC allocations

A fast pure-Luau ECS can still be surrounded by slow physics/pathfinding/render work.

## Hybrid model

Common good pattern:
- server domain services own progression/economy
- ECS owns transient high-count combat entities
- Roblox Models/Instances act as presentation/physics adapters
- UI state uses separate reactive layer

Do not force DataStore profiles or shop products into ECS merely for architectural purity.

## Migration rule

Before moving existing OOP/service code to ECS:
- name the actual pain
- create benchmark/prototype
- migrate one entity family
- preserve external service interfaces
- compare debugging and code complexity, not only microbenchmark speed

## Decision checklist

- [ ] actual entity/system counts estimated
- [ ] team understands chosen model
- [ ] debugger/inspection plan
- [ ] save/network boundaries independent of ECS internals
- [ ] current Roblox native capabilities checked
- [ ] performance measured, not guessed
- [ ] migration/removal path understood
