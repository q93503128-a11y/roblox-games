# Slay & Loot — LIVE DESIGN
Date: 2026-10-30. Status: DESIGN; Foundation pass only.

## Product
Slay & Loot is a **Roblox Combat Loot Simulator** in a persistent shared world.
Core loop: kill standing enemies → earn Coins + weapon drops → duplicate copies level the same weapon → hatch/equip Pets → damage improves → fight stronger enemies → unlock the next Zone.

Primary reference: Sword Fighters Simulator's connected combat/weapon/pet/zone loop.
Secondary: Anime Fighters for target/collection UX, Weapon Fighting Simulator for duplicate value, Pet Simulator-style egg/team/zone conventions.
See [research](references/SIMULATOR_RESEARCH.md). Generated images are secondary art references: Image 1 combat HUD, Image 2 pets/eggs, Image 3 spatial progression. Copy common grammar, never protected identity or exact maps/art.

## V1 contract
- One persistent shared Place; target first-slice concurrency: 8 players.
- One authored safe service area, one farming area, one visible functional personal Zone Gate and a small safe landing/preview beyond it.
- Normal A, Normal B, Strong, Mini-Boss: stable sockets, shared HP, timed respawn, personal eligible-participant rewards. No complex pursuit or MMO AI.
- Coins only.
- Three weapon definitions, one owned entry per definition, one equipped weapon, Equip / Equip Best.
- One Egg, six pet definitions, Hatch 1, three equipped slots, pet inventory and Equip Best. Basic manual release of unequipped pets supports storage capacity.
- Pets add an additive percentage bonus to direct player attacks. Pet models follow visually; no independent pet combat simulation in V1.
- LMB / Attack. Target by click/tap; mobile Attack can acquire nearest valid target in range. One target per attack, no cleave.
- No enemy retaliation/player combat-health progression in this slice. Enemy flinch/death/HP and player weapon contact carry the feedback.
- Persistence architecture is part of V1; no claim of persistence completion until isolated real save/rejoin/session-conflict tests pass.

## Weapon identity
Start with Rusty Sword Lv.1, granted once to a genuinely new profile; show STARTER WEAPON / NEW WEAPON once.
Every eligible Moss Slime reward yields Rusty Sword. First duplicate immediately reaches Lv.2 and raises real damage.
A weapon's first copy creates Lv.1 with zero duplicate XP; later copies add +1 Weapon XP to that same entry, even if not equipped.
Increasing XP thresholds, overflow and deterministic MAX conversion are specified in [catalog](specs/first-slice.catalog.json) and [content](CONTENT_CATALOG.md).
Equip Best compares actual effective DPS at current level; equal performance keeps current weapon, then stable ID order.

## UI grammar
Persistent HUD: Coins, equipped weapon/current effective ATK, next Zone goal, Weapons/Pets buttons, Attack.
Context: selected enemy HP/name, Egg panel, Zone unlock panel.
One nonblocking reward card location. NEW / DUPLICATE / LEVEL UP / MAX and rarity combine within it; common repeats coalesce. Do not open two large reward panels.
Inventory: card rarity text + frame, level/XP, equipped mark, actual stats, Equip Best.
No unimplemented Quests/Rewards/Shop/Auto Fight buttons. No player XP bar: weapon XP is the progression being taught.
All player-facing language is English, organized in localization-ready keys. Korean is for collaboration/docs.
Mobile: reserve Roblox movement/jump/system regions, target 48 logical-pixel hit areas, validate landscape 667×375 and 844×390 plus desktop 720p/1080p. Central combat view stays clear.

## World grammar
Safe services are next to the farming entry. The next biome and price gate are visible before unlocking.
Normal targets sit beside the clear main route; stronger targets are deeper; Mini-Boss has a side pocket.
Coin gates are personal progression. One player's unlock must not open access or charge currency for another player.
Ordinary Zone unlock: Coins only. Final World Boss/world transition is later content, not a dungeon run.

World 1 expansion plan, not this build:
1. Greenvale — safe start and first farm.
2. Goblin Camp — next zone, stronger farm and later themed Egg.
3. Ruined Keep — later escalation.
4. Goblin Citadel — later World Boss/transition.
No additional enemies/Eggs/prices for these later areas are authorized by this foundation. The first build only previews Zone 2.

## Pacing targets
Initial values are project-owned hypotheses, not copied or measured reference constants.
- First enemies visible at spawn.
- First solo baseline Moss Slime kill roughly 5–12 seconds after engaging.
- First duplicate level-up within the first minute; normally first kill.
- First useful new weapon early; unowned Goblin Blade is guaranteed by the fourth eligible Scout reward.
- First Egg early; 30 Coins, three base Slime rewards afford one hatch.
- First Zone gate approximately 3–5 minutes in an ordinary first session, tune after actual route timing.

## Explicitly deferred
Auto Fight; active abilities; Hatch 3/10; Auto Hatch/Delete; Index UI; Golden/Rainbow/Shiny; Rebirth; Trading; Guilds; PvP; crafting trees; extra currencies; huge quests; raids; events; battle pass; monetization; World 2.
Persist basic discovery now to avoid future schema dependence, but do not build an Index screen yet.

## Deprecated
Old lobby → dungeon selection → instanced rooms → boss → difficulty replay. DungeonSession, room encounters, run-specific barriers, dungeon party matchmaking and the old RunService architecture are HISTORICAL only.
A new Zone Gate means persistent progression; it does not revive the deprecated encounter-room gate system.
