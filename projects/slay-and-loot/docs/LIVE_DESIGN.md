# Slay & Loot — Live Design

Status: FIRST PRODUCTION LOOP DEFINED / STUDIO VALIDATION PENDING

This file records the current accepted game design. Treat numbers below as production targets for the first slice until Studio playtest evidence proves they need adjustment.

## Product format

Slay & Loot is a fast Roblox dungeon-loot RPG built for immediate combat and cheap, repeatable content expansion.

Primary loop:

`Hub -> Play -> short dungeon run -> boss -> visible loot -> equip stronger gear -> replay harder difficulty or unlock next dungeon`

The game deliberately uses familiar Roblox dungeon/simulator conventions. Originality is less important than clarity, speed, satisfying growth, and a clean reusable production pipeline.

## Reference structure

Use successful external games as structural references, not as sources to copy protected identity, map layouts, art, names, or exact UI.

Current reference roles:

- Dungeon Quest Reborn: core dungeon/loot/retry structure
- Pixel Blade: immediate combat onboarding and fast first-fun
- Fabled Legacy: multiple difficulties on reusable dungeon content and retry flow
- Dungeon Heroes: inexpensive progression breadth through item rolls, realms, dailies, and later meta systems
- World // Zero: long-term world/class/progression reference only; do not match its production scope early

## First 10 minutes target

Target pacing, subject to playtest revision:

- 0:00–0:15: player can move and understands how to start combat
- <= 0:30: first enemy defeated
- <= 1:00: first useful reward/gold/XP feedback
- 1:00–3:30: first Normal dungeon run
- <= 4:00: first clearly stronger weapon equipped
- 4:00–8:00: Hard replay or stronger encounter using the improved weapon
- <= 10:00: player understands the next power goal / next dungeon unlock

No long dialogue or mandatory text tutorial before combat.

## Combat

First-slice player kit:

- primary attack: 3-hit sword combo
- dash/roll: short defensive/mobility action
- one weapon skill: broad readable cleave/AOE attack
- no stamina meter
- no mana meter
- no block/parry in the first slice
- no large skill bar in the first slice

Desktop target:

- LMB = primary attack
- Q = dash/roll
- E = weapon skill

Mobile target:

- Attack
- Dash
- Skill

The exact bindings may change if Studio/input conflicts require it, but the first-slice action count stays small.

Combat requirements:

- wide/readable hitboxes appropriate for Roblox third-person play
- hit confirmation through animation timing + sound + VFX + enemy reaction
- spam input handled intentionally
- fighting 3–5 enemies at once must remain readable
- enemy attacks require visible telegraphs
- valuable combat results and rewards remain server-authoritative

## Animation strategy

Animations are shared by weapon family rather than by individual item.

First slice needs one coherent sword animation family:

- idle/locomotion integration as needed
- M1-1
- M1-2
- M1-3
- skill
- dash/roll if custom animation improves quality
- hit reaction
- death

Do not create unique attack animation sets merely because weapon models differ.

## First dungeon

Working theme: stylized fantasy forest ruins / goblin-held ruins, chosen because strong free environment supply already exists and compatible enemy/weapon assets are abundant.

Final creature identity may change during asset procurement if a clearly better coherent family is available.

First dungeon target structure:

1. entry / orientation
2. room A: 3 melee enemies
3. room B: mixed melee + ranged enemies
4. room C: elite/brute encounter
5. boss room
6. reward moment
7. Retry / Return flow

Target first-run duration: roughly 2.5–3.5 minutes once the player understands controls.

Do not build a maze. The main route should be immediately readable.

## Enemy architecture

Use a small reusable behavior vocabulary and swap audited visual rigs/models on top.

First-slice behavior families:

- Grunt: approach + simple melee
- Ranged: maintain usable distance + readable projectile
- Brute/Elite: slower, larger telegraph, heavier attack
- Boss: 2–3 readable attacks assembled from the same combat language

Do not trust free-model AI/combat scripts for production architecture. Prefer sanitized visual rigs and project-owned AI/damage/reward systems.

## Loot and equipment

Equipment is the primary visible progression axis.

First-slice scope:

- weapon progression is mandatory
- armor can remain deferred unless a strong ready-to-use asset/UI path makes it nearly free
- boss/end reward should visibly produce loot rather than only changing a hidden number
- item comparison and equip must be obvious
- the first completed run should guarantee a meaningful upgrade if the player still has starter gear

Initial rarity ladder:

`Common -> Uncommon -> Rare -> Epic -> Legendary -> Mythic`

The first slice does not need every rarity to drop.

Initial weapon stats should remain minimal. Base Damage is mandatory. Attack Speed and Crit are allowed only if they improve the slice without muddying item readability.

Random affixes, enhancement, sets, crafting, rerolling, and mutation systems are deferred until the basic loot loop is accepted.

## Progression

Use Level + equipment power as the familiar player-facing progression model.

For the first slice:

- Level increases from combat/run completion
- better equipment creates the larger immediate combat-power jump
- completing Normal should expose/unlock a stronger replay target
- harder difficulty reuses the same dungeon art/layout with stronger enemy tuning and better reward table

Difficulty reuse is intentional. A production dungeon should support multiple difficulties rather than requiring a new map for every progression step.

Exact XP curves, damage formulas, and unlock thresholds are tuning variables, not permanent lore.

## World/content expansion

Preferred cheap expansion order after the slice is accepted:

1. more difficulties on proven dungeon
2. next compact dungeon using a new coherent asset family/biome
3. more weapon visuals and loot tables
4. daily/playtime rewards
5. additional weapon family if combat quality justifies it
6. challenge/raid/infinite mode using existing combat assets
7. pets/companions only if they materially help retention and fit the product
8. rebirth/meta acceleration after the base progression loop has enough content to reset meaningfully

Avoid building a giant seamless open world.

## UI / UX

Use audited Creator Store UI assets/components/icons aggressively when they reduce production time, then normalize them into one coherent visual system.

First-slice navigation should expose only what is needed:

- Play
- Inventory
- Shop may exist visually only when it has a real purpose; monetization is not required for the first playable slice
- HP
- Level / XP
- Gold
- current equipped weapon / power readability where useful

Inventory first-slice actions:

- inspect item
- compare against equipped item
- Equip
- Sell may be deferred until enough loot exists
- Lock may be deferred

Avoid long modal chains and unnecessary confirmation steps.

## Art / asset direction

Primary target: coherent stylized Roblox / low-poly fantasy using external assets heavily.

Current preferred environment supply starts with official/licensed Synty-style nature/dungeon assets and compatible audited medieval/fantasy additions.

Multiple creators/packs may be mixed when their scale, palette, material density, proportions, and camera readability are compatible. Do not mix obviously incompatible realistic PBR, anime, voxel, and low-poly identities merely because each asset is individually good.

Player-facing production placeholders are not acceptable once an audited production asset exists for the role.

## Monetization direction

Monetization is not required for the first vertical slice, but architecture must not block it.

Likely later products:

Passes:
- +1 loot / extra reward roll
- 2x Gold
- VIP convenience/value bundle
- extra storage

Developer Products:
- temporary luck/reward boost
- revive where appropriate
- currency bundle if the economy justifies it

External shop UI assets may be reused visually, but purchase authority, entitlement checks, receipt handling, and valuable rewards must use current project-owned Roblox-safe logic.

Do not let monetization interrupt the first combat experience.

## Retention direction

After core-loop acceptance, preferred low-cost retention systems are:

- Daily Login
- Playtime Gifts
- Daily Quests
- Group/community reward if appropriate
- rotating cosmetic/value shop only after the core inventory/economy exists

Do not build retention UI before there is a game worth returning to.

## Multiplayer

The core game should be naturally compatible with multiple players, but the first slice does not require complex parties, matchmaking, trading, guilds, or dedicated-server orchestration.

Do not add a complex multiplayer architecture solely to imitate larger reference games before the combat/loot loop is accepted.

Valuable progression state remains server-authoritative.

## Rebirth / long-term progression

Rebirth or equivalent acceleration remains a long-term direction, not a first-slice requirement.

When added, it must:

- materially accelerate early progression
- unlock or strengthen future progression options
- make previously difficult content feel conquered

Do not add rebirth merely as a percentage reset button before the game has enough progression to justify resetting.

## Implemented tuning — source-verified baseline

Status: `CODED + INTEGRATED (source-verified)` unless a runtime note explicitly says otherwise. These values describe the current snapshot, not final accepted balance.

### Player / combat

- Max HP: 120
- Base damage: 10
- Combo multipliers: 1.00 / 1.15 / 2.00
- Combo ranges: 9.5 / 9.5 / 11 studs
- Combo arcs: 115 / 120 / 150 degrees
- Combo cooldowns: 0.44 / 0.42 / 0.66 seconds
- Dash: 24 studs / 0.20 s duration / 1.5 s cooldown / 0.32 s invulnerability window
- Skill: x2.6 damage / 17 stud range / 6.5 s cooldown
- Room-clear heal: 45% of max HP in the active run flow

### Enemy baseline

- Grunt: 45 HP / 9 damage
- Caster: 36 HP / 11 damage
- Brute: 240 HP / 18 damage
- Boss: 700 HP / 14 base damage
- Boss behavior currently contains three attack variants; exact human readability remains unaccepted.

### Difficulty

Normal:

- HP x1.0
- damage x1.0
- Gold x1.0
- XP x1.0
- loot tier 1

Hard:

- HP x2.2
- damage x1.8
- Gold x1.7
- XP x1.8
- loot tier 2

### Current room rewards / first-run arithmetic

- Room A: +18 Gold
- Room B: +28 Gold
- Room C: +37 Gold
- Boss: +120 Gold
- A full Normal clear from zero therefore reaches 203 Gold under current tuning.
- Current XP arithmetic reaches level 4 after that full route.

### Spatial shell observations

The current graybox/runtime shell has been observed with approximately:

- 11-stud room ceilings in the repaired sections
- 9-stud doorway/opening treatment in the safe-pocket repair
- Ground top at `Y = -0.5` after the z-fighting fix

These are current implementation facts, not permanent art-direction dimensions. Production art may change visual geometry only if route clearance, camera, navigation, and combat readability remain valid.
