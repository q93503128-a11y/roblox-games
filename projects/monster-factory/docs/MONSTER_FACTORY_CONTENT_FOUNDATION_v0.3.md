# Monster Factory Simulator — Content Foundation v0.3

Build: MVP-002

## Implemented core loop

Factory generates value
-> value accumulates in Collector
-> player manually collects Cash
-> generator upgrade increases production
-> first Meadow Capsule hatch is free
-> later Meadow hatches cost Cash
-> monsters are unique inventory instances
-> best monsters can be equipped as active factory workers
-> active workers increase production
-> duplicates can be fused into Shiny
-> Shiny has 2.5x worker bonus
-> monetization services remain server-authoritative

## Zone 1 launch data

Meadow Capsule:
- Slime 45%
- Mushroom 30%
- Worker Bee 15%
- Meadow Wolf 8%
- Nature Golem 2%

Hatch price:
- first hatch: free
- later hatches: 100 Cash

Monster production bonus:
- Slime +10%
- Mushroom +18%
- Worker Bee +32%
- Meadow Wolf +55%
- Nature Golem +100%
- Starter Factory Bot +75% guaranteed paid-exclusive worker

## Monetization integration

Auto Collect now has a real gameplay function:
- without pass: produced Cash waits in Collector
- with pass: Collector transfers produced Cash automatically

Other implemented entitlement hooks:
- Starter Pack: 250 Gems + 3 upgrade tokens + guaranteed Factory Bot + 1 worker slot
- +3 Equip: +3 active worker slots
- VIP: +15% factory production
- Fast Hatch: reduced server hatch cooldown
- Bigger Storage: +150 monster storage
- Overdrive products: 2x production while active

Product IDs remain intentionally blank until the experience has real Roblox monetization items.

## Data schema v2

Added:
- Factory.PendingCash
- Monsters.Inventory
- Monsters.Equipped
- Monsters.HatchCount
- StarterPackMonsterGranted
- TotalCashCollected
- TotalHatches

DataStore name remains the same and the schema uses recursive reconciliation so MVP-001 profiles migrate forward.

## Runtime world

Zone 1 placeholder world is generated entirely from Roblox primitives:
- meadow floor
- factory pad
- spawn
- Generator
- Conveyor Core
- Reactor
- Meadow Capsule machine
- Cash Collector
- boundary trees

The visuals are placeholders, but names/anchors form the future art replacement contract.

## Not yet test-ready by project standard

MVP-002 establishes the first complete economy/monster loop, but the project is **not yet being handed to the user for full playtesting**.

Before the requested "content foundation is ready" checkpoint, still required:
- Zone 2 and Zone 3 real progression/data
- zone unlock service
- rebirth system
- quests
- daily/playtime rewards
- onboarding milestone system
- contextual monetization surfaces
- better factory/monster visuals
- mobile layout pass
- analytics instrumentation
- content balancing pass
