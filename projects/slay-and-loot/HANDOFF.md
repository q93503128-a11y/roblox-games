# Slay & Loot — Session Handoff

Last updated: 2026-10-21

## Current state

- GitHub project space initialized.
- Codex/OpenCode/Studio MCP operating rules are in `AGENTS.md` and `CODEX_PRACTICAL_RULES.md`.
- External Roblox game reference analysis has been translated into the current production design.
- `docs/LIVE_DESIGN.md` now defines the first dungeon-loot loop, combat ceiling, loot progression, asset-heavy art/UI strategy, and expansion order.
- `PLAN.md` now defines the first Studio build in ordered phases with acceptance criteria and the P0 test route.
- No Roblox Studio implementation has yet been confirmed or validated for the current plan.
- No production external asset has yet been approved in `docs/ASSET_SOURCES.md`.

## Current confirmed direction

Slay & Loot is a fast Roblox dungeon-loot RPG using familiar successful Roblox conventions deliberately.

Core loop:

`Hub -> short dungeon -> boss -> visible loot -> equip stronger weapon -> replay harder difficulty / unlock next target`

First-slice combat:

- 3-hit sword primary combo
- dash/roll
- one broad weapon skill
- simple mobile Attack/Dash/Skill controls
- no stamina, mana, block/parry, large skill bar, pets, trading, crafting, rebirth, or large quest system yet

Production strategy:

- design/reference decisions are owned by ChatGPT/project docs
- OpenCode + MiniMax + Roblox Studio MCP performs Studio inspection, asset procurement, placement, implementation, and runtime checks
- use audited external assets heavily for environment, weapons, enemies/rigs, animations, VFX, SFX, UI/UX, icons, and later shop presentation
- own valuable-state gameplay/backend logic in-project
- reuse one animation family per meaningful weapon archetype
- multiply proven dungeon content through difficulty/reward reuse before building many unique maps

Current working first-dungeon theme: stylized fantasy forest ruins / goblin-held ruins, subject to change only if Studio asset procurement finds a clearly stronger coherent family.

## Next safe step

1. Open/create the Roblox Studio place intended for Slay & Loot.
2. Connect OpenCode (MiniMax) to Roblox Studio MCP and the repository.
3. Read the canonical project/Godbase files in the order required by `AGENTS.md`.
4. Inspect the actual Studio/DataModel before editing.
5. Run the asset procurement/quarantine pass defined in `PLAN.md`.
6. Select the smallest coherent environment/weapon/enemy/animation/VFX/SFX/UI stack.
7. Build the first route in validated passes rather than one-shot map generation.
8. Implement the first combat/loot loop and exercise the P0 route.
9. Update `docs/ASSET_SOURCES.md`, `docs/CONTENT_CATALOG.md`, `docs/PLAYTEST_NOTES.md`, `PLAN.md`, and this handoff only with actual accepted/validated facts.

## Known limitations

- No current Studio evidence yet.
- No combat feel has been validated.
- No production asset has been approved.
- No mobile route has been validated.
- No performance baseline exists yet.
- No persistence/economy save route has been validated.
- Monetization is intentionally deferred from the first vertical slice.

Do not report the game as implemented, playable, or Studio-validated until those claims are supported by actual Studio evidence.
