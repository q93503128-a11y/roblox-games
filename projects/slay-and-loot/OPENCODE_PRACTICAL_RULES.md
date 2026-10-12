# Slay & Loot — OpenCode Practical Rules

These are hard rules for actual implementation and reporting.

## 1. Do not put developer junk into the game

Player-facing builds must not contain development chatter or implementation TMI.

Do not leave visible:

- developer logs
- developer notes
- internal explanations
- DEBUG / TEST / TODO / WIP labels
- temporary test UI
- test buttons
- test NPCs or test objects
- placeholder messages explaining unfinished systems
- "made by AI", "generated", "prototype", "dev build" style wording unless explicitly requested for a private diagnostic screen

If something is unfinished, either keep it out of the player-facing route or report it outside the game as a known limitation.

## 2. No patch stacking / junk-code accumulation

Do not solve problems by endlessly adding Hotfix/Patch/Override layers around bad code.

When a bug is found:

`evidence -> root cause -> fix the owning code/system -> replay exact failed route -> regression check`

Required cleanup behavior:

- modify the real source of the problem when practical
- remove dead code made obsolete by the fix
- remove duplicate implementations
- remove abandoned temporary handlers/listeners/remotes
- remove superseded test assets and scripts
- do not keep legacy branches "just in case" when they are no longer used
- do not create a second system beside a broken first system unless replacement/migration is deliberate and the old one is removed afterward
- do not hide failures behind silent pcall/fallbacks unless the fallback is part of the intended architecture

Temporary instrumentation used for diagnosis must be removed after the issue is resolved unless it has legitimate ongoing QA value.

## 3. Keep project output clean

Do not add files, objects, folders, docs, comments, or config purely because they look organized if they do not serve the game or maintenance workflow.

Do not produce meaningless development diaries or verbose internal TMI inside the project.

Comments should explain non-obvious invariants, contracts, or reasons — not narrate every line of code.

## 4. Final report must be directly copy-pastable

At the end of substantial work, send the entire result as ONE code block so the user can copy it directly into ChatGPT without cleanup.

Do not scatter the report across prose outside the block.

The report should be concise but complete and include, when applicable:

- what changed
- important files/scripts/instances changed
- Studio scene/DataModel changes
- external assets selected/rejected
- actual tests performed
- exact errors found and fixes made
- anything not validated
- remaining limitations
- next safe step

Do not claim completion for anything not actually validated.

## 5. GitHub handoff is mandatory

OpenCode does not normally edit the canonical GitHub docs directly.

Every substantial final report must contain a section exactly named:

`GitHub 반영 필요 내용`

Put in that section every material fact ChatGPT should copy into the canonical repository, including:

- systems added/removed/changed
- exact important numbers or rules that became canonical
- architecture changes
- UI/UX decisions
- map/zone structure decisions
- asset IDs/sources/creators and audit results
- animation/VFX/audio selections
- content that was accepted or rejected
- known temporary states
- unresolved bugs
- technical limitations
- files/docs that should be updated

Write this section itself in ready-to-copy factual form. Do not make the user reconstruct it from the rest of the report.

Do not put speculative ideas here as if they were implemented facts.

## 6. Player-facing quality beats implementation convenience

Do not expose implementation shortcuts to the player merely because they are easier for the agent.

Examples:

- do not use ugly primitive placeholders as production assets
- do not keep generic default UI because it is already wired
- do not keep a bad animation because replacing it would require reconnecting markers
- do not leave obvious test geometry in the map
- do not use a technically functional but visually broken asset when a compatible audited alternative exists

A feature being coded is not enough. It must be usable and coherent in actual play.

## 7. Preserve good work, replace bad work coherently

Do not rewrite validated systems without a concrete reason.

But when a system is genuinely structurally bad, do not preserve it merely to avoid deleting code. Replace it coherently and remove the superseded implementation so the project has one clear source of truth.

## 8. Reporting format

Use this structure inside the single final code block when relevant:

CHANGED
- ...

TESTED
- ...

FAILED & FIXED
- ...

KNOWN LIMITATIONS
- ...

GitHub 반영 필요 내용
- ...

NEXT SAFE STEP
- ...

Keep statements factual and distinguish implementation from validation.
