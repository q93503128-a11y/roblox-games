# Slay & Loot — Codex / Roblox Studio MCP Rules

This file is the operating contract for Codex work on Slay & Loot.

## 0. Read order

Before changing the project:

1. Read this file completely.
2. Read `CODEX_PRACTICAL_RULES.md`.
3. Read `PLAN.md`.
4. Read `HANDOFF.md`.
5. Read `docs/VISION.md` and `docs/LIVE_DESIGN.md`.
6. Inspect the current Roblox Studio DataModel through MCP.
7. Read the relevant Godbase documents referenced by `knowledge/GODBASE_MANIFEST.json`.
8. Only then plan changes.

The current repository and Studio state are authoritative over assumptions from older chats or plans.

## 1. Core operating principle

Build the smallest coherent playable improvement, validate it in Studio, clean up the implementation, update canonical project docs, then continue.

Do not treat code volume, asset count, file count, or checklist length as progress. Player-facing quality is progress.

## 2. Canonical state

Do not rely on session memory.

Use these files as persistent state:

- `AGENTS.md` — permanent working rules
- `CODEX_PRACTICAL_RULES.md` — implementation cleanliness and reporting rules
- `PLAN.md` — active goal, scope, acceptance, stop conditions
- `HANDOFF.md` — exact current implementation state and unresolved issues
- `docs/LIVE_DESIGN.md` — accepted current design
- `docs/DECISIONS.md` — dated design/technical decisions
- `docs/ASSET_SOURCES.md` — external production assets and audit status
- `docs/PLAYTEST_NOTES.md` — actual test evidence
- `docs/CONTENT_CATALOG.md` — accepted production-facing content

When a material implementation/design fact becomes accepted, update the relevant canonical file directly. Do not make the user manually copy project-state updates back into GitHub.

Do not create development diaries or redundant documentation. Update the minimum canonical file that owns the information.

## 3. Never invent the current state

Before editing:

- inspect existing scripts, instances, hierarchy, tags, attributes, packages, assets, and important settings
- inspect the exact scene/zone/system you intend to change
- preserve working systems unless the requested change requires touching them
- do not create a duplicate subsystem when a working equivalent already exists

Do not delete, replace, or rewrite a working subsystem merely because a cleaner architecture exists.

If a subsystem has suffered repeated structural failures, stop patch stacking and reassess the architecture.

## 4. MCP-first Studio workflow

Use Roblox Studio MCP as the field worker whenever it can inspect or validate the real Studio state.

Preferred loop:

`inspect -> plan -> change one coherent slice -> inspect result -> playtest/runtime validation -> fix -> regression check -> cleanup -> document`

Do not repeatedly re-fetch the entire DataModel, console, tool catalog, or screenshots when a targeted query is enough.

Use only the MCP tools needed for the current task. Reuse already-known state while it remains trustworthy.

For visual work, inspect the actual gameplay/Studio result where visual judgment matters. If it is wrong, fix it and re-check instead of assuming the edit succeeded.

## 5. External assets are encouraged, but audited

Prefer this supply order:

1. Roblox official/template/package assets
2. verified Roblox creator assets
3. audited Creator Store assets
4. licensed external assets/packages
5. custom creation only when needed

For every production asset:

- record source, asset ID/URL, creator, intended use, and modifications in `docs/ASSET_SOURCES.md`
- inspect descendants for `Script`, `LocalScript`, `ModuleScript`, suspicious `require(number)`, `loadstring`, runtime insertion/loading, HTTP usage, obfuscated strings, and unexpected dependencies
- if only visual art is needed, use a sanitized script-free copy
- verify pivot, scale, rig, collision, texture/material cost, and gameplay-camera appearance
- compare important assets against Roblox avatar scale

Never adopt the first search result automatically when quality matters. Preview multiple plausible candidates.

Do not mix individually good assets into an incoherent art direction.

## 6. Reference before invention

Do not design weapons, monsters, zones, UI, or combat in a vacuum when suitable references or existing assets are available.

For major player-facing additions:

- inspect a strong primary reference and useful secondary references when needed
- identify transferable structure rather than superficial copying
- inspect candidate assets before finalizing detailed design
- let verified asset capabilities inform the live design when that produces a better result

Do not force an old written concept onto an asset that clearly does not support it well.

## 7. Map and spatial rules

Never guess a production map from raw world coordinates.

Before placement, inspect at minimum:

- playable bounds
- floor/terrain
- spawn transform
- avatar scale
- gameplay camera/FOV
- existing zone bounds
- main route
- landmarks and interactables

Use named anchors and relative placement. For connected geometry use actual faces, pivots, bounding boxes, offsets, raycasts, or attachment relationships.

For 5+ player-facing objects, make a placement table or equivalent spatial plan before bulk placement.

Build maps in passes, not one-shot:

`bounds/terrain -> spawn -> main route -> landmark -> combat/activity area -> production assets -> detail -> gameplay-camera QA`

After an art pass, replay the P0 route to confirm decoration did not break pathing, collision, visibility, or camera readability.

## 8. Combat and gameplay priorities

For Slay & Loot, prioritize:

1. responsive direct combat
2. readable groups of enemies
3. visible loot/equipment progression
4. satisfying power growth
5. short clear zone progression
6. rebirth/progression only after the base combat loop is fun

Do not add content breadth to compensate for weak combat feel.

Do not implement many weapons that share the same animation/timing/feel with only different numbers.

Valuable state must be server-authoritative. Never trust client-reported rewards, drops, currency, inventory ownership, upgrade success, or rebirth state.

## 9. Plan discipline

`PLAN.md` must contain the current goal, scope, do-not-change areas, references/assets being evaluated, acceptance criteria, exact test route, and stop conditions.

Work autonomously inside that scope.

Do not ask the user for manual placement or trivial decisions when the answer can be resolved from Studio, docs, references, or current project state.

Do not silently expand scope because another feature seems useful.

## 10. Validation language

Keep these statuses distinct:

- CODED — code/assets were changed
- INTEGRATED — connected in the current project/Studio state
- RUNTIME-CHECKED — executed without the targeted route failing
- PLAYTESTED — the route was actually exercised as a player/runtime path
- ACCEPTED — acceptance criteria passed

Never report `complete`, `fixed`, `verified`, or `Studio-validated` without corresponding evidence.

If an editor/runtime environment problem blocks a test, report that separately from a game-code defect.

## 11. Minimum validation before handoff

When relevant, check:

- clean boot
- normal spawn
- project-attributable unexpected runtime errors = 0 on tested route
- exact P0 route
- core visual states
- desktop controls/UI
- mobile controls/UI when touched
- multiplayer route when touched
- valuable state server authority

After code changes, check the relevant runtime/console path and self-fix attributable errors before reporting success.

For performance-sensitive enemy counts, VFX, NPCs, or repeated assets, inspect performance early rather than postponing all optimization.

## 12. Repository discipline

Codex is allowed to keep the connected repository's canonical project files current as part of the same task.

- update only relevant project/Godbase files
- do not create branches or PRs unless explicitly requested
- do not produce commits or churn merely to prove activity
- do not touch unrelated projects
- do not leave temporary docs/configs after they have served their purpose
- preserve useful Git history and avoid destructive repository actions unrelated to the task

GitHub state is not a substitute for Studio validation.

## 13. Destructive / external actions

Do not:

- delete unrelated files/assets
- rewrite unrelated working systems
- modify account/system settings
- perform destructive shell operations outside the project
- publish the game or make irreversible live changes without explicit user instruction
- push unrelated repository changes

## 14. Final session report

Follow `CODEX_PRACTICAL_RULES.md`.

Keep the report concise, directly copy-pastable, and factual. Do not include a separate `GitHub 반영 필요 내용` section; canonical repository docs should already have been updated when necessary.

Always distinguish implementation from validation.
