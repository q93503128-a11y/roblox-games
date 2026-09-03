# Open Source Ecosystem Audit — 2026-09-03

> scope: Roblox/Luau libraries, frameworks, developer tools. This is a decision aid, not an automatic dependency list.

## Status vocabulary

- `CURRENT_RECOMMENDED`: healthy candidate for new work when the problem fits.
- `CURRENT_CONDITIONAL`: valid, but only when architecture/use case clearly needs it.
- `TRANSITION`: maintained, but API/branch/rewrite is in motion; pin version and re-check before adoption.
- `LEGACY_MAINTENANCE_ONLY`: existing projects may keep it, new projects should not default to it.
- `EXPERIMENTAL`: interesting, but project itself warns about production maturity or evidence is insufficient.
- `TOOL_ONLY`: developer tooling; not runtime game architecture.

## Strong current candidates

### Cmdr — CURRENT_RECOMMENDED
Repo: https://github.com/evaera/Cmdr
License: MIT
Verified repo status: not archived; pushed 2026-09-02.

Use for:
- developer/admin command console
- internal QA/debug commands
- controlled moderation workflows
- typed argument parsing and validation

Why useful:
- extensible command/type model
- client + server validation design
- avoids building ad-hoc admin command parsing

Rules:
- permissions remain server-owned
- do not expose destructive commands to ordinary players
- commands calling economy/data systems still use those systems' normal authorization paths

### Charm — CURRENT_RECOMMENDED / STATE
Repo: https://github.com/littensy/charm
License: MIT
Verified: not archived, active ecosystem.

Use for:
- fine-grained reactive state
- shared server/client state architecture
- complex UI/game state that benefits from signals/computed/effects

Good fit:
- reactive UI
- synchronized state views
- medium/large state graph

Avoid when:
- a few local UI booleans/values would be simpler

### NevermoreEngine packages — CURRENT_RECOMMENDED SELECTIVELY
Repo: https://github.com/Quenty/NevermoreEngine
License: MIT
Verified: not archived; pushed 2026-09-03.

Nevermore is a very large mature package ecosystem, not merely one framework module. Code from it has long production history.

Godbase default:
- prefer evaluating individual packages (`Maid`, Rx-related utilities, camera/input/math/etc.) rather than adopting the whole ecosystem by reflex
- check npm/pnpm/Rojo workflow cost before use

### UI Labs — TOOL_ONLY / CURRENT_RECOMMENDED
Repo: https://github.com/PepeElToro41/ui-labs
License: GPL-3.0 for the plugin repository
Verified: pushed 2026-08-13, not archived.

Use for:
- storybook-style UI component preview
- testing default/hover/pressed/disabled/loading/error states without playing the whole game
- fast visual iteration

License note:
- it is development tooling; if modifying/redistributing its GPL code, review GPL obligations
- using a developer tool does not mean project runtime code should be copied from it

### Flipbook — TOOL_ONLY / CURRENT_RECOMMENDED
Repo: https://github.com/flipbook-labs/flipbook
License: MIT
Verified: pushed 2026-08-27, not archived.

Use for:
- sandboxed UI stories
- component state review
- React/Roact/Fusion/generic GUI workflows

UI Labs and Flipbook overlap. Pick one per project instead of installing both without a reason.

## Networking

### ByteNet — CURRENT_CONDITIONAL / STRONG CANDIDATE
Repo: https://github.com/ffrostfall/ByteNet
License: MIT
Verified: not archived. README describes buffer-based typed networking. BridgeNet2's own README recommends ByteNet instead of BridgeNet2.

Use when:
- network volume is genuinely meaningful
- typed schemas + buffer serialization reduce bandwidth/CPU complexity
- you have measured native RemoteEvent payload cost or need a consistent packet layer

Do not use merely because it is 'faster'. Native RemoteEvent/UnreliableRemoteEvent is often simpler and good enough.

Still required:
- server authority
- gameplay validation
- rate limits
- no client-owned reward/damage truth

Serialization validation is not complete game security.

### Zap — TRANSITION
Repo: https://github.com/red-blox/zap
License: MIT
Verified: not archived; default branch is `0.6.x`; repository states a rewrite is underway while 0.6.x is maintained.

Use only after:
- choosing the exact maintained branch/version
- checking current docs for that branch
- benchmarking against ByteNet/native remotes for the project's actual traffic

Do not blindly follow rewrite docs while installing 0.6.x.

### BridgeNet2 — LEGACY_MAINTENANCE_ONLY
Repo: https://github.com/ffrostfall/BridgeNet2
License: MIT
Verified: not archived, but its README explicitly recommends ByteNet over BridgeNet2.

Existing game:
- no emergency migration solely for fashion
- profile first, plan migration if ByteNet/native gives real benefit

New game:
- do not default to BridgeNet2

## ECS / architecture

### Matter — CURRENT_CONDITIONAL
Repo: https://github.com/matter-ecs/matter
License: MIT
Verified: not archived; repository remains public and documented, but last push observed was 2024-12-31 and open issue count is substantial.

Use when:
- many homogeneous entities/components
- systems benefit from data-oriented iteration
- project team understands ECS

Examples:
- projectile swarms
- large NPC/simulation populations
- highly composable entity behavior

Avoid when:
- small RPG with dozens of ordinary object-oriented/domain modules
- ECS would just wrap Instances in more boilerplate

Godbase does not make ECS the default architecture.

## Data persistence

### ProfileStore — CURRENT_RECOMMENDED CANDIDATE
See canonical catalog entry. Strong default candidate for player profile/session locking when its data model fits.

### Lapis — EXPERIMENTAL / CONDITIONAL
Repo: https://github.com/nezuo/lapis
License: MIT
Verified: not archived.

Strengths documented by project:
- session locking
- validation
- migrations
- retries/throttling
- promise API
- save batching/autosave

Critical caveat:
- project README explicitly warns it has not been battle-tested in a large production game and may contain obscure bugs.

Therefore:
- excellent study/reference candidate
- can be chosen for controlled projects after isolated tests
- not Godbase's universal persistence default

## State management

### Reflex — CURRENT_CONDITIONAL
Repo: https://github.com/littensy/reflex
License: MIT
Verified: not archived; last push observed 2025-12-21.

Use for:
- producer/action style state container
- state syncing and derived state
- teams already using Reflex/React bindings

For new projects, compare with Charm before choosing. Do not layer Charm + Reflex together without a deliberate boundary.

## Frameworks

### Knit — LEGACY_MAINTENANCE_ONLY
Repo: https://github.com/Sleitnick/Knit
License: MIT
Verified: archived=true; last push 2024-07-31.

Rules:
- existing stable Knit projects can keep it
- new projects must not select Knit because old tutorials call it standard
- migrate only when there is a concrete maintenance/feature reason; unnecessary rewrites create risk

### Flamework — CURRENT_CONDITIONAL / ROBLOX-TS
Org/docs: https://github.com/rbxts-flamework

Use when:
- project is intentionally roblox-ts
- compile-time metadata/dependency framework benefits the team

Avoid forcing TypeScript/Flamework into a Luau-first solo Studio workflow.

## General utilities

### RbxUtil — CURRENT_RECOMMENDED SELECTIVELY
Use Trove/Component/Signal/Comm/Spring/etc. only when each solves an explicit problem.

### GoodSignal — CURRENT_CONDITIONAL UTILITY
Repo: https://github.com/stravant/goodsignal
License: MIT
Purpose: RBXScriptSignal-like pure Lua signal.

Useful when a standalone Signal is needed. If RbxUtil Signal or another existing dependency already solves it, avoid duplicate signal abstractions.

### Promise — CURRENT_RECOMMENDED WHEN ASYNC COMPLEXITY EXISTS
Do not wrap every yield. Use for composition, cancellation, timeout, retry and structured async chains.

## Toolchain watch

### selene — CURRENT_RECOMMENDED
Latest releases observed include 0.31.0 (2026-05-20), with current Luau/Roblox updates. Keep version pinned.

### roblox-ts — CURRENT_CONDITIONAL
Repo: https://github.com/roblox-ts/roblox-ts
License: MIT
Powerful for TypeScript teams; not a mandatory upgrade over Luau.

### TestEZ / Jest Lua / testing tools
Choose based on language/toolchain and maintained status. Pure game logic should remain testable without requiring a full world boot.

## Dependency anti-patterns

- using networking middleware before measuring traffic
- installing a full framework to gain one utility
- mixing multiple state containers
- mixing multiple cleanup abstractions in the same subsystem
- depending on archived framework because an old YouTube tutorial used it
- benchmarking empty remote calls and assuming same result for real game payloads
- treating typed serialization as anti-cheat
- copying library internals instead of importing with license/version history

## Adoption checklist

Before adding any OSS dependency:
1. exact repo + license
2. archived/disabled status
3. last meaningful push/release
4. current docs match installed version
5. runtime realms (server/client/shared)
6. transitive dependencies
7. removal/migration cost
8. security boundary
9. measured need
10. isolated prototype
11. version pin/lockfile
12. record in project architecture docs

## Refresh policy

This audit is time-sensitive. Re-check before adoption if more than ~90 days old or if Roblox introduced a native replacement.