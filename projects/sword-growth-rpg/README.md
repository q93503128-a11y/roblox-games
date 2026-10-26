# Sword Growth RPG

Status: PRE-PRODUCTION / DESIGN

## Core idea

Sword Growth RPG is a simple Roblox growth RPG centered on one sword that levels indefinitely, changes appearance at asset-driven milestones, and becomes visibly stronger over time.

Core loop:

1. kill monsters
2. gain sword EXP and gold only from kills
3. level the sword and reach new sword-form milestones
4. enter higher-level hunting areas
5. unlock permanent cumulative sword effects through dedicated effect-unlock content
6. train HP with gold during the current rebirth cycle
7. rebirth at an increasing sword-level requirement
8. repeat faster with permanent rebirth bonuses
9. push toward 50 rebirths and post-50 endgame such as an Endless Tower

The game intentionally does not aim for complex boss-pattern combat. Growth, visible sword evolution, accumulated effects, fast farming, and power disparity are the main fantasy.

## Canonical design

`docs/LIVE_DESIGN.md` is the current accepted design record. Values may still be tuned after actual Studio playtests, but rejected ideas should not be reintroduced without a new decision.

## Shared Roblox knowledge

Before implementation, use the repository Godbase beginning with `knowledge/GODBASE_MANIFEST.json` and the relevant combat, RPG, world-design, asset, persistence, security, and testing documents.

## Development principle

Do not invent production sword, aura, map, or UI art in isolation. Inspect usable Roblox assets/packages first, then fit exact visual milestones and world themes to the audited assets that are actually available.
