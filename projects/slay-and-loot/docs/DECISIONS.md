# Slay & Loot — Decisions

Record only decisions that should constrain later work or explain why the project differs from an obvious alternative.

## 2026-10-12 — Project name

Decision: use `Slay & Loot` as the game name and `slay-and-loot` as the repository project folder.

## 2026-10-12 — Live-design workflow

Decision: do not freeze a giant GDD before implementation.

Use:

`direction -> reference/asset search -> implementation -> playtest -> accept/reject -> update live design`

Reason: the project intends to use high-quality external Roblox/Creator Store assets heavily, so detailed art/content should be informed by real available assets and actual Studio results.

## 2026-10-12 — External art/assets

Decision: external models, animations, environment kits, VFX, audio, and UI resources are encouraged when audited and stylistically coherent.

Game logic, valuable state, rewards, inventory/progression authority, and core architecture remain project-controlled rather than trusting arbitrary free-model scripts.

## 2026-10-12 — First production target

Decision: prove a compact combat + loot vertical slice before adding broad progression systems or many zones.

Reason: content volume must not hide weak combat or weak item feedback.

## 2026-10-21 — Reference-driven commodity RPG direction

Decision: Slay & Loot intentionally uses familiar Roblox dungeon/loot/simulator conventions instead of spending production time inventing a novel core genre structure.

Reference roles:

- Dungeon Quest Reborn: dungeon -> boss -> loot -> retry progression skeleton
- Pixel Blade: immediate combat onboarding / first-fun pacing
- Fabled Legacy: multiple difficulties on reused dungeon content
- Dungeon Heroes: cheap breadth through randomized loot/progression/retention layers
- World // Zero: long-term scope reference only

Transfer structural patterns, pacing, information hierarchy, and production lessons. Do not copy protected art, maps, names, branding, exact UI, or distinctive content identity.

Reason: the project goal is to reach a playable, understandable, commercially familiar Roblox RPG quickly and then improve based on actual playtest evidence.

## 2026-10-21 — Asset-heavy production model

Decision: player-facing art, environment, weapon visuals, monster visuals/rigs, animation source material, VFX, SFX, icons, UI frames/components, and shop presentation should use audited external Roblox assets wherever that is faster and visually stronger than custom creation.

Multiple packs/creators may be combined when the result remains coherent in gameplay camera view. Compatibility is judged by scale, palette, material/detail density, proportions, readability, and performance rather than by creator identity alone.

Important boundary: external visual/gameplay kits do not become authority for damage, loot, inventory ownership, currency, purchases, save data, or other valuable state.

## 2026-10-21 — Shared animation families

Decision: individual weapon models do not receive unique animation sets by default.

The first slice uses one coherent sword animation family. Later weapon categories may receive one shared family per meaningful combat archetype.

Reason: weapon appearance can scale cheaply while combat timing remains maintainable and consistent.

## 2026-10-21 — Difficulty reuse before map proliferation

Decision: a proven dungeon should support multiple difficulties with stronger tuning and better reward tables before the project builds many unique maps.

Reason: this multiplies progression content at far lower production cost and keeps map quality higher.

## 2026-10-21 — First-slice complexity ceiling

Decision: first-slice controls are primary attack + dash/roll + one weapon skill. No stamina, mana, block/parry, large skill bar, pets, trading, guilds, crafting, reroll systems, large quest chains, or rebirth are required before the combat/loot loop is accepted.

Reason: these systems increase surface area without proving the core reason to play.
