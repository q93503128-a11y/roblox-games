# Slay & Loot — OpenCode / Roblox Studio MCP Rules

This file is the operating contract for autonomous OpenCode work on Slay & Loot.

## 0. Read order

Before changing the project:

1. Read this file completely.
2. Read `PLAN.md`.
3. Read `HANDOFF.md`.
4. Read `docs/VISION.md` and `docs/LIVE_DESIGN.md`.
5. Inspect the current Roblox Studio DataModel through MCP.
6. Read the relevant Godbase documents referenced by `knowledge/GODBASE_MANIFEST.json`.
7. Only then plan changes.

The current Studio/project state is authoritative over assumptions from an older chat or plan.

## 1. Core operating principle

Build the smallest coherent playable improvement, validate it in Studio, document what actually worked, then continue.

Do not treat code volume, asset count, file count, or checklist length as progress. Player-facing quality is progress.

## 2. Canonical state

Do not rely on session memory.

Use these files as persistent state:

- `AGENTS.md` — permanent working rules
- `PLAN.md` — active goal, scope, acceptance, stop conditions
- `HANDOFF.md` — exact current implementation state and unresolved issues
- `docs/LIVE_DESIGN.md` — accepted current design
- `docs/DECISIONS.md` — dated decisions and rejected alternatives when relevant
- `docs/ASSET_SOURCES.md` — every external production asset and its audit status
- `docs/PLAYTEST_NOTES.md` — actual test evidence

Update the relevant file immediately after a material decision or validated milestone. Do not postpone all documentation until the end of a long session.

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

`inspect -> plan -> change one coherent slice -> inspect result -> playtest/runtime validation -> fix -> regression check -> document`

Do not repeatedly re-fetch the entire DataModel, console, tool catalog, or screenshots when a targeted query is enough.

Use only the MCP tools needed for the current task. Reuse already-known state when still trustworthy.

For visual work, inspect the actual gameplay/Studio result at the point where visual judgment matters. If the result is wrong, fix it and re-check rather than assuming the edit succeeded.

## 5. Diagnostic / inspection-only mode

When the task is explicitly diagnosis, readiness inspection, audit, or investigation only:

- do not modify Studio/project files unless the task explicitly authorizes changes
- do not create helper files, configs, manifests, Git state, commits, or pushes merely to perform the diagnosis
- report the observed state and a clear readiness/result classification

Do not turn a read-only diagnostic request into an implementation task.

## 6. External assets are encouraged, but audited

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
- compare important assets against the Roblox avatar scale

Never adopt the first search result automatically. Preview multiple candidates when quality matters.

Do not mix individually good assets into an incoherent art direction.

## 7. Reference before invention

Do not design weapons, monsters, zones, UI, or combat in a vacuum when suitable references or existing assets are available.

For major player-facing additions:

- inspect 1 primary reference and, when useful, 2–4 secondary references
- identify transferable structure, not superficial copying
- inspect candidate assets before finalizing exact design details
- let verified asset capabilities inform the live design when that produces a better result

Do not force an old written concept onto an asset that clearly does not support it well.

## 8. Map and spatial rules

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

For 5+ player-facing objects, create a placement table or equivalent spatial plan before bulk placement.

Build maps in passes, not one-shot:

`bounds/terrain -> spawn -> main route -> landmark -> combat/activity area -> production assets -> detail -> gameplay-camera QA`

After an art pass, replay the P0 route to confirm decoration did not break pathing, collision, visibility, or camera readability.

## 9. Combat and gameplay rules

For Slay & Loot, prioritize:

1. responsive direct combat
2. readable groups of enemies
3. visible loot/equipment progression
4. satisfying power growth
5. short clear zone progression
6. rebirth/progression only after the base combat loop is fun

Do not add content breadth to compensate for weak combat feel.

Do not implement dozens of weapons that share the same animation/timing/feel with different numbers.

Server-authoritative valuable state is required. Never trust client-reported rewards, drops, currency, inventory ownership, upgrade success, or rebirth state.

## 10. Plan discipline

`PLAN.md` must contain:

- current goal
- current context
- in-scope work
- do-not-change areas
- references/assets being evaluated
- acceptance criteria
- exact test route
- stop conditions

Work autonomously inside that scope.

Do not ask for manual placement or trivial decisions unless there is a true blocking ambiguity that cannot be resolved from Studio, docs, references, or current project state.

Do not silently expand scope because another feature seems useful.

## 11. Long-session context safety

Treat context budget as a reliability constraint, not a reason to keep pushing indefinitely.

- below roughly 60% context usage: continue normally if state remains clear
- around 60–80%: finish coherent units, checkpoint important state, and refresh `PLAN.md` / `HANDOFF.md` as material facts change
- around 80–85%: do not begin another large subsystem; finish the current coherent unit, validate it, and prepare session handoff
- at 85% or above: no new feature work; enter wrap-up mode, update state/handoff documents, record remaining bugs and exact next step, then end the session cleanly

Automatic context compaction is not a substitute for explicit state documents. Treat compacted memory as potentially lossy.

For long autonomous sessions:

- finish one coherent unit before starting another
- preserve the last known-good state
- do not rework completed validated items without evidence of a regression
- if the same failure repeats, record the root cause and switch approach instead of brute-force retrying
- stop when acceptance criteria are met; do not keep polishing unrelated areas indefinitely

When context becomes unreliable, finish the current safe unit, update `HANDOFF.md`, and stop rather than improvising from partial memory.

## 12. Validation language

Keep these statuses distinct:

- CODED — code/assets were changed
- INTEGRATED — connected in the current project/Studio state
- RUNTIME-CHECKED — executed without the targeted route failing
- PLAYTESTED — the route was actually played/tested
- ACCEPTED — acceptance criteria passed

Never report `complete`, `fixed`, `verified`, or `Studio-validated` without corresponding evidence.

If an editor/runtime environment problem blocks a test, report that separately from a game-code defect.

## 13. Minimum validation before handoff

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

For performance-sensitive enemy counts, VFX, NPCs, or repeated assets, inspect performance early instead of postponing all optimization.

## 14. GitHub / repository responsibility

OpenCode's primary responsibility is local project/Studio implementation and MCP validation.

Unless the user explicitly tells OpenCode to manage GitHub directly:

- do not push to GitHub
- do not rewrite canonical GitHub project docs directly as part of ordinary implementation
- do not create branches/PRs/commits just to prove progress
- report repository-relevant changes under a clearly labeled `GitHub 반영 필요 내용` section so ChatGPT/user can update the canonical repository deliberately

Local project files may be edited when needed for implementation, but canonical repository state and live Studio validation are separate concerns.

## 15. Destructive / external actions

Do not:

- delete unrelated files/assets
- rewrite unrelated working systems
- modify account/system settings
- perform destructive shell operations outside the project
- publish the game or make irreversible live changes without explicit user instruction
- push unrelated repository changes

Git/GitHub is project history, not a substitute for Studio validation.

## 16. Final session report

End substantial work with:

### CHANGED
What actually changed.

### TESTED
Exact validation performed and its result.

### FAILED & FIXED
Failures encountered, root cause, and coherent fix.

### KNOWN LIMITATIONS
Anything not actually validated or intentionally deferred.

### GitHub 반영 필요 내용
Rules, numbers, systems added/removed, technical structure, UI/UX decisions, asset decisions, unresolved/temporary state, and other facts that should be reflected in canonical repository docs. Do not present speculative future ideas as accepted facts.

### NEXT SAFE STEP
The next coherent unit that can be started without invalidating current work.

Keep implementation claims separate from validation claims.
