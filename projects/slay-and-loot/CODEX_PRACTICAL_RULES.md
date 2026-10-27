# Slay & Loot — Codex Practical Rules

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

If something is unfinished, keep it out of the player-facing route or report it outside the game as a known limitation.

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

## 4. Keep canonical GitHub docs current directly

Codex is connected to the repository, so do not ask the user to manually relay project-state changes back into GitHub.

When an implementation/design fact becomes accepted, update the canonical owner directly in the same task when appropriate:

- `docs/LIVE_DESIGN.md` for accepted gameplay/design rules
- `docs/DECISIONS.md` for material decisions and rationale
- `docs/ASSET_SOURCES.md` for approved/rejected external assets and audit results
- `docs/CONTENT_CATALOG.md` for accepted weapons/enemies/bosses/zones/content
- `docs/PLAYTEST_NOTES.md` for actual runtime/playtest evidence
- `PLAN.md` and `HANDOFF.md` for current work state

Do not create duplicate summary docs for information already owned by one of these files.

## 5. Final report must be directly copy-pastable

At the end of substantial work, send the entire result as ONE code block so the user can copy it directly without cleanup.

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

NEXT SAFE STEP
- ...

Keep statements factual and distinguish implementation from validation.

## 9. Prefer Plan for reasoning; keep Build execution-focused

OpenCode Build usage is expensive and should be minimized.

Use Plan mode for as much non-destructive work as practical, including:

- reading repository/docs/source
- inspecting current architecture and requirements
- external asset/reference research
- deciding exact files/instances to change
- preparing complete Luau code, patches, placement tables, test routes, and acceptance criteria
- identifying likely failure cases before implementation

Switch to Build only when actual mutation or Studio execution is required, such as:

- editing files
- applying prepared code
- inserting/auditing assets in Studio
- changing the DataModel or map
- running Playtest/device/runtime validation
- saving/committing the accepted result

Do not spend Build-mode budget rediscovering requirements or doing open-ended design work that could have been completed in Plan first.

## 10. GitHub is the canonical source for important code and machine-readable project state

Do not leave important Luau source existing only inside the live Studio session when it can reasonably be represented in Git.

For project-owned gameplay code, config, data definitions, reusable helpers, and other text source:

- keep a corresponding canonical file under the project repository
- preserve one clear ownership/source-of-truth path
- avoid maintaining two independently edited copies
- after Studio-side changes, reconcile the canonical Git source before ending the task

Roblox Cloud/Studio may remain the canonical home for visual scene composition, imported meshes/models, lighting, terrain, and other editor-native state that is impractical to represent directly in Git. Record important asset IDs, anchors, layout contracts, and verified Studio-only facts in the existing canonical docs rather than inventing duplicate summaries.

A `.rbxl/.rbxlx` handoff should not be required for ordinary planning/review when Git source + canonical docs contain the needed implementation facts. Use place files or screenshots only when actual scene state/visual inspection is necessary.

## 11. Save and commit before ending a coherent task

Do not end a substantial implementation task with important accepted work existing only in memory, an unsaved Studio session, or an uncommitted working tree when the available tools permit persistence.

At a coherent boundary:

- save/publish the Studio place when possible
- check `git status`
- reconcile canonical Git source/docs with the actual accepted implementation
- commit stable related changes
- report the commit SHA when available

If Studio save/publish requires user interaction or cannot be performed through available tools, explicitly warn the user before ending the task. If a commit cannot safely be made, state the exact reason and leave a precise handoff.
