# Monster Factory Simulator — Balance Pass v0.1

Build: MVP-004

## Current progression targets

### Green Meadows
- First hatch: free
- Normal hatch: 100 Cash
- Zone 2 unlock: 10,000 Cash

Intent:
- first worker within first minute,
- first meaningful multiplier immediately visible,
- Zone 2 in the first short session without requiring purchases.

### Desert Outpost
- Capsule: 12,000 Cash
- Zone 3 unlock: 250,000 Cash
- production multiplier: x4

Intent:
- Desert unlock should sharply accelerate the factory,
- player gets enough income to hatch several Desert monsters before Frozen.

### Frozen Lab
- Capsule: 300,000 Cash
- production multiplier: x16
- first Rebirth target: 3,000,000 Cash

Intent:
- Frozen is the first major exponential jump,
- first Rebirth should be reachable inside one meaningful session.

## Permanent acceleration

- +50% production per Rebirth
- VIP +15%
- friend bonus +5% per friend, capped at +20%
- Overdrive x2
- worker bonuses stack additively before global multipliers

## Monetization pressure points

- Starter Pack: after first hatch
- Auto Collect: after repeated collection / 5,000 lifetime Cash
- Extra Equip: when inventory begins to exceed active worker slots
- Bigger Storage: when inventory approaches base capacity

Context offers are server-cooldown controlled:
- max one evaluated offer per 12 minutes

## Offline

- max credited duration: 8 hours
- base efficiency: 25%
- VIP offline bonus: +10 percentage points

Offline earnings use current production snapshot and do not simulate hatches, quests, or zone unlocks.

## Known balance risks

1. Zone multiplier + strong workers may accelerate too quickly after lucky Legendary pulls.
2. Rebirth x7 requirement scaling may become too steep past early rebirths.
3. Shiny fusion may remove too many useful low-rarity workers if storage is still small.
4. Friend bonus cap is intentionally conservative to avoid making solo play feel punished.
5. Current Gem sinks are not yet deep enough for long-term economy.

These should be measured after the first real Studio playtest.
