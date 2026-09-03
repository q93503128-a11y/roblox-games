# Luau Testing Frameworks and CI

> verified: 2026-09-03

Testing advice in old Roblox tutorials ages quickly. Choose current tools based on repository state and the project workflow.

## Jest Roblox — CURRENT_RECOMMENDED

Repo: https://github.com/Roblox/jest-roblox
Maintainer: Roblox
License: MIT
Verified:
- not archived
- pushed 2026-09-02
- README states Roblox uses it for apps, CoreScripts, built-in Studio plugins and libraries
- current package example: `roblox/jest` + `roblox/jest-globals`
- supports `.spec.lua` / `.spec.luau`
- README states it can run inside Roblox, including through Roblox OCALE (Open Cloud API for Luau Execution) for CI
- Creator Store asset listed by upstream README: `16031830738` JestRoblox

Use for:
- pure/domain Luau unit tests
- schema/migration tests
- deterministic combat/economy math
- mocks/snapshots where valuable
- CI when project/tooling supports it

Do not use unit tests as a substitute for Studio integration/playtest.

## TestEZ — LEGACY_MAINTENANCE_ONLY

Repo: https://github.com/Roblox/testez
License: Apache-2.0
Verified:
- `archived=true`
- last push observed 2024-03-05

Existing projects may keep TestEZ if stable. New projects should evaluate Jest Roblox first instead of choosing TestEZ from old tutorials.

## Test taxonomy

### Pure unit
No DataModel needed when possible.
Examples:
- damage formula
- XP curve
- loot weights
- inventory capacity
- save migration
- rate-limit/token bucket
- procedural seed output

### DataModel unit/integration
Needs Roblox instances/services but not a full player session.
Examples:
- CollectionService component setup
- hitbox query filters
- model/pivot utilities
- UI component behavior

### Studio integration
Needs actual place/play mode.
Examples:
- spawn
- camera
- Input Action bindings
- networking
- physics
- character lifecycle
- Streaming

### End-to-end route
Actual gameplay sequence through Studio MCP or human playtest.
Example:
`spawn → fight → reward → equip → die → respawn → save/rejoin`

## CI recommendation

Filesystem-first project:
```text
format/lint
→ validators
→ Luau/Jest tests
→ Rojo/build
→ TEST publish where configured
→ Studio/MCP integration
```

Studio-first project:
```text
Script Sync source checks
→ pure/Jest tests where practical
→ Studio MCP boot/integration route
→ screenshot/output gate
```

## OCALE note

Jest Roblox upstream README explicitly documents OCALE, the Open Cloud API for Luau Execution, as a way to run tests on CI systems. Before production setup, verify current Open Cloud authentication, quotas, API status and security requirements in current Roblox docs.

This is attractive for Roblox-native test execution without pretending every engine behavior can be reproduced by a generic Lua runtime.

## What to test first

Priority by defect cost:
1. save migration / data corruption
2. purchase/receipt idempotency
3. economy duplication
4. permission/security rules
5. core formula/catalog validation
6. procedural deterministic invariants
7. UI/domain state transformations
8. convenience helpers

Do not chase 100% line coverage while the primary gameplay route has no automated smoke test.

## Test data rules

- deterministic seeds
- explicit fixtures
- no production DataStore writes
- test namespaces/environments
- generated fixture IDs clearly separated from live catalog IDs
- cleanup after integration tests

## Flaky tests

A test that passes only after arbitrary waits is not trustworthy.

Prefer:
- events/conditions
- bounded timeout
- deterministic clock abstraction for pure systems
- explicit server state acknowledgement

For physics/network behavior, allow realistic tolerance but record the reason.

## Assertions vs observability

Automated checks should emit useful context:
- expected/actual
- user/entity/seed/test case
- subsystem
- relevant state snapshot

A failing test saying only `false ~= true` wastes debugging time.

## Migration from TestEZ

Do not rewrite all tests merely because TestEZ is archived.

For a stable existing project:
- keep old tests green
- use current tooling for new test infrastructure only if benefits justify dual stack or migration
- migrate incrementally at subsystem boundaries

New project:
- default evaluation starts with Jest Roblox.

## Done rule

A testing framework is successful only if it catches real regressions while remaining cheap enough that developers actually run it.
