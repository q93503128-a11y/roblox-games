# Monster Factory Simulator — Content Foundation v0.4

Build: MVP-003

## Added progression spine

The project now has a real three-zone progression:

1. Green Meadows
   - Unlock: free
   - Factory multiplier: x1
   - Capsule: 100 Cash after first free hatch

2. Desert Outpost
   - Unlock: 10,000 Cash
   - Factory multiplier: x4
   - Capsule: 12,000 Cash

3. Frozen Lab
   - Unlock: 250,000 Cash
   - Factory multiplier: x16
   - Capsule: 300,000 Cash

Unlocked zone multiplier applies to the player's factory globally.

## Monster content

15 free-play hatch monsters:
- 5 Meadow
- 5 Desert
- 5 Frozen

Each zone keeps the same readable rarity distribution:
- Common 45%
- Uncommon 30%
- Rare 15%
- Epic 8%
- Legendary 2%

Paid Starter Factory Bot remains deterministic and is not inside paid random rewards.

## Rebirth

First requirement:
3,000,000 Cash

Growth:
x7 requirement per Rebirth

Reset:
- Cash
- Collector balance
- Generator level
- zone progression

Retain:
- monsters
- equipped workers
- Gems
- Rebirth Tokens
- purchases
- quest claims
- permanent entitlements

Reward:
- +1 Rebirth Token
- +50% permanent production per Rebirth

## Milestone quests

Implemented:
- Collect 1,000 Cash
- Hatch 5 Monsters
- Generator Lv.10
- Unlock Desert
- Rebirth once

Rewards are deterministic Gems / Upgrade Tokens / Rebirth Tokens.

## Return loops

Daily reward:
- 7-step streak
- 20-hour claim cooldown
- streak resets after >48h inactivity

Playtime rewards:
- 5 minutes
- 15 minutes
- 30 minutes
- 60 minutes

Playtime rewards reset by UTC day and persist claimed state.

## Current monetization interaction

The project already contains:
- Starter Pack
- Auto Collect
- Extra Equip
- VIP
- Bigger Storage
- Fast Hatch
- Overdrive
- Gem packs
- Rebirth Token packs

The core free progression no longer depends on purchases.
Monetization accelerates convenience/capacity/production.

## Status

This is substantially closer to the requested content-foundation checkpoint, but I am **not yet marking it ready for the user's full test pass**.

Still required before that checkpoint:
- onboarding/tutorial milestone controller
- contextual shop surfaces instead of a generic store-only flow
- world/monster visual representation for active workers
- Zone 1–3 machine content differentiation
- achievements/index
- offline earnings
- basic social/friend bonus
- analytics event schema
- mobile layout pressure pass
- balancing/sink review
