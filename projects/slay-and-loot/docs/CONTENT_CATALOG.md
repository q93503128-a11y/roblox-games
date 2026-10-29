# First-slice content catalog
Authoritative IDs/numbers: [first-slice.catalog.json](specs/first-slice.catalog.json).
Status: DESIGN. All values are tunable validation targets, not final economy.

## Weapons
| ID | Name | Rarity | Base ATK | MAX duplicate Coins |
|---|---|---|---:|---:|
| weapon_rusty_sword | Rusty Sword | Common | 10 | 12 |
| weapon_goblin_blade | Goblin Blade | Rare | 18 | 30 |
| weapon_chieftain_cleaver | Chieftain Cleaver | Legendary | 32 | 120 |

One permanent map entry per ID: {level, duplicateXp}. No randomized affixes, weapon variants, inventory copies, manual fusion or player level requirement.
Starter Rusty Sword is awarded exactly once on confirmed new-profile creation. Never use load failure as proof of newness.

XP needed Lv.1→2 through Lv.9→10: 1, 2, 3, 5, 8, 12, 18, 27, 40.
First copy: Lv.1 / XP 0. Duplicate: XP +1; repeatedly subtract the current threshold and level up; carry remainder.
At Lv.10, XP is 0. Each remaining duplicate becomes that definition's fixed Coins value.
Example: Rusty Sword Lv.9 / XP39 + 5 copies → Lv.10 / XP0 + 48 Coins.
Total duplicates required to cap a fresh Lv.1 weapon: 116; including first copy: 117. MAX is not an onboarding requirement.
Never give XP and MAX conversion for the same copy.

Unrounded weapon ATK = Base ATK × (1 + 0.2 × (level−1)).
Effective hit damage = floor(weapon ATK × (1 + sum(equipped pet bonus basis points)/10000)), minimum 1.
All weapons attack once per 0.6 seconds. Equip Best compares effective hit damage / 0.6; tie keeps current, then ID order. UI must use the same derived value.
Rusty Lv.1→2: damage 10→12 without pets. Rusty Lv.2 + Sprout Slime: damage 13.

## Enemies and drop tables
Each eligible participant independently receives the full Coins reward and exactly ONE weighted weapon. Entries in each table sum to 100.
| Role / ID | HP | Coins | Respawn | Weapon weights |
|---|---:|---:|---:|---|
| Normal A / enemy_moss_slime | 100 | 12 | 3s | Rusty 100 |
| Normal B / enemy_goblin_scout | 180 | 24 | 3s | Rusty 75 / Goblin 25 |
| Strong / enemy_goblin_guard | 650 | 90 | 6s | Rusty 40 / Goblin 58 / Cleaver 2 |
| Mini-Boss / enemy_goblin_chieftain | 2200 | 250 | 20s | Goblin 90 / Cleaver 10 |

The first Goblin Blade is guaranteed no later than the fourth eligible Scout reward while unowned. The counter persists across rejoin; any acquisition of Goblin Blade clears it. At threshold the one weighted result is replaced, not supplemented. Display base chance + guarantee condition honestly. No pity applies after ownership.
Baseline solo Slime: 10 hits, about 5.58s from first input with 0.18s windup / 0.6s interval, excluding input/latency effects. This arithmetic is not a measured gameplay result.

## Pets / Egg
Meadow Egg costs 30 Coins and hatches one pet. No paid currency or paid luck.
| Pet | Rarity | Weight / base chance | Damage bonus |
|---|---|---:|---:|
| Sprout Slime | Common | 38 / 38% | +10% |
| Moss Bunny | Common | 30 / 30% | +12% |
| Ember Fox | Uncommon | 18 / 18% | +18% |
| Pebble Drake | Rare | 9 / 9% | +25% |
| Grove Spirit | Epic | 4 / 4% | +35% |
| Sun Cub | Legendary | 1 / 1% | +50% |

Each pet copy has a server-created UID. Three copies of the same pet can fill three slots; a UID cannot fill two slots.
Capacity 100. Hatch at capacity fails before charging or rolling. Manual Release only accepts owned unequipped UID, previews the named pet and confirms; no refund. Equip Best selects highest bonuses, stable definition-ID then UID tie break. Hatch does not secretly replace equipment.
No pet levels, variants or independent damage timers in V1.

## Weapon feedback
NEW WEAPON: add one collection card and optional Equip action.
DUPLICATE · +1 Weapon XP: same card's progress fills, no additional inventory slot.
WEAPON LEVEL UP: one combined result shows same weapon, Lv.before→after, ATK.before→after.
MAX LEVEL: first cap event emphasized once; later duplicate shows exact Coins conversion.
Rare acquisition is an emphasis on the underlying NEW/DUPLICATE/LEVEL result, not a second modal.
Batch gains combine +N XP / level changes / converted Coins into one result. A short local beam/loot flight is presentation; rewards are already assigned, not stealable pickups.

## Zones
zone_greenvale: initially unlocked, safe services and 11 farming sockets.
zone_goblin_camp: 600 Coins, previous zone Greenvale, personally unlocked.
First Build: gate works and grants access to a small safe landing/preview. No Zone 2 farming content yet.
