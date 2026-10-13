# Button Layers — Agent / OpenCode Working Rules

This file defines **how to build**. Gameplay facts belong in the canonical design/data files.

## Inspect before changing

Before implementation or a major phase:
- inspect latest GitHub `main`
- inspect current project source/docs
- inspect current Roblox Studio/DataModel through MCP
- identify Studio id if multiple Studios are open
- inspect floor/bounds, spawn, avatar scale, camera/FOV, scripts/remotes/UI/map
- preserve unrelated or already validated work

Never infer current implementation state from old chat memory.

## Work to release-candidate scope

A vertical slice is a quality gate, not the endpoint.

```text
inspect → plan → implement one coherent phase → Play → actual player route
→ Output + visual review → root cause fix → replay failed route → regression
→ next safe phase
```

Do not require the user to type `next` after every safe phase.

## Map building

Never mass-place guessed absolute coordinates.

Use:
`Experience → Map → Area → Route/Cluster → Reusable Module → Part`.

Before placement measure playable bounds/floor, spawn, avatar scale, camera/FOV, routes and landmarks. Use named anchors + local placement. For 5+ player-facing objects, make a placement table first. Validate with gameplay camera.

## Server authority

Client sends intent. Server validates player/character, unlock, distance, resources, cooldown, transaction ownership, reset state, numeric validity and manual/automation races.

Manual and Auto use the same authoritative transaction/reset functions.

## No junk code / patch stacking

Bug workflow:
`evidence → root cause → fix owning code → remove superseded code → replay exact failed route → regression`.

Do not leave duplicate systems, abandoned remotes/listeners, Hotfix/Patch/Override layers or dead implementations.

If the same subsystem structurally fails twice, stop patching and reassess architecture/workflow.

## No developer junk in player builds

No DEBUG/TEST/TODO/WIP labels, dev notes/logs, AI/generated/prototype wording, test buttons/NPCs/UI or player-facing placeholder explanations.

## Quality hierarchy

```text
actually runs → actually safe → actually fun/usable → readable/good-looking
→ maintainable → content quantity
```

## Assets

External asset order:
1. Roblox official
2. verified Roblox Package
3. audited Creator Store
4. generated/custom or approved internal/OSS

Audit source, scripts, dependencies, pivot, scale, collision and style fit. Never spend Robux without explicit approval.

## Canonical project owners

- `docs/LIVE_DESIGN.md` — gameplay/product/UI/world rules
- `docs/CONTENT_CATALOG.md` — buttons/areas/achievement/secret content
- `data/BALANCE_CONFIG.json` — machine-readable economy/button values
- `data/META_CONTENT.json` — machine-readable achievements/secrets/meta
- `docs/DECISIONS.md` — accepted decisions/rationale
- `docs/PLAYTEST_NOTES.md` — actual runtime evidence
- `PLAN.md` — current phase/status
- `HANDOFF.md` — current handoff state

Do not create duplicate design diaries.

## Validation language

Use distinct states:
`DESIGN / IMPLEMENTED / BOOT_VERIFIED / ROUTE_TESTED / READY_FOR_USER_TEST / RELEASE_CANDIDATE / PUBLISHED`.

## Stop conditions

Stop/report if MCP cannot reliably validate, a paid/publish/account action needs approval, unexpected valuable Studio work has unclear ownership, a subsystem structurally fails twice, or a design ambiguity materially changes the game.

## Reporting

Use factual sections:
`CHANGED / TESTED / FAILED & FIXED / KNOWN LIMITATIONS / NEXT SAFE STEP`.

Never claim tests that were not actually run.
