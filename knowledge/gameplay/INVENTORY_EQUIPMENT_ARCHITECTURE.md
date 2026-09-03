# Inventory and Equipment Architecture

> verified: 2026-09-03

Official Tool/Backpack reference:
- https://create.roblox.com/docs/players/tools

## 1. Separate persistent inventory from Roblox Backpack

`Backpack`/`Tool` is a useful runtime equip/input presentation mechanism, but it should not automatically become the authoritative persistent inventory model.

Recommended layers:
```text
ItemCatalog (shared definitions)
Persistent Inventory (server profile)
Equipment State (server authoritative)
Runtime Representation (Tool/model/UI)
```

A Tool being cloned into Backpack is not proof the player owns it permanently.

## 2. Stable item definition

Catalog definition example:
```luau
{
 id = "weapon_iron_sword",
 category = "weapon",
 equipSlot = "mainhand",
 rarity = "common",
 stackMax = 1,
 baseStats = {...},
 runtimeAssetId = ...
}
```

Display name/localization is not the ID.

## 3. Stackable vs unique instances

Stackable:
```text
itemId + quantity
```

Unique:
```text
instanceId
itemId
rolls/upgrades/durability
bound/locked state
```

Trading/upgrades/custom rolls generally require unique instance IDs.

## 4. Server ownership

Server decides:
- add/remove item
- quantity
- equip eligibility
- slot conflicts
- consume
- trade
- sell
- upgrade

Client sends intent:
`Equip(instanceId)` / `Use(instanceId)`.

## 5. Equipment slots

Define slots centrally:
- mainhand
- offhand
- armor slots
- accessory slots
- pet/companion if relevant

Validation:
- item exists
- owner
- category allowed
- level/class requirement
- mutually exclusive states
- item not locked in trade/crafting

## 6. Runtime Tool

Roblox Tools can:
- live in StarterPack/Backpack
- equip to character
- use Handle/Grip behavior

For custom action games, Tool can still be used or you can implement a custom equipment controller. Choose based on game needs; don't fight Tool semantics without reason.

If using Tools:
- runtime clone from trusted server asset
- no authoritative data inside client-editable Tool value objects
- death/respawn reconstruction from equipment state
- clean Tool scripts/connections

## 7. Character visual equipment

Equipment visual is derived state.

```text
server equipment state
→ replicated equipped item ID/state
→ character model/socket visual
```

On respawn, rebuild visuals rather than trusting old character instances.

## 8. Inventory capacity

Capacity policy:
- slots
- weight
- category caps
- unlimited with pagination

Full inventory behavior must be explicit:
- drop remains in world
- mailbox/overflow
- conversion
- reject pickup

Never silently destroy a valuable reward.

## 9. Item locks

Lock item while involved in:
- trade
- crafting
- upgrade
- market/listing
- quest turn-in transaction

Prevents same unique item being spent twice through concurrent systems.

## 10. Atomic domain operations

Example craft:
```text
validate ingredients
→ lock/consume server-side
→ generate output
→ commit inventory mutation
→ unlock
→ notify client
```

Do not make UI remove ingredient locally and hope save catches up.

## 11. Inventory UI

Client receives a safe replicated/view model:
- item IDs
- quantities
- display stats
- equipped state

UI requirements:
- sorting/filtering
- empty/loading/error
- compare/equipped highlight
- gamepad/touch
- large inventory virtualization if needed

## 12. Item tooltip

Separate:
- base catalog stat
- instance modifiers
- final effective stat

Player should understand why two same-base weapons differ.

## 13. Item removal reasons

Every mutation should carry reason for analytics/debugging:
```text
loot
quest_reward
craft_input
craft_output
sell
trade
admin_recovery
migration
```

## 14. Save format

Avoid serializing Instances.
Persist IDs/data only.
Runtime models are rebuilt from catalog.

## 15. Catalog migration

If item definition changes/removed:
- legacy mapping
- stat migration
- replacement/refund
- grandfather behavior

Never leave old save IDs causing join crash.

## 16. Security abuse cases

Test client attempts:
- equip item not owned
- duplicate instance ID
- negative quantity
- consume zero/invalid item
- equip while trading
- sell equipped/locked item
- spam equip/use remote

## 17. Acceptance

- [ ] persistent inventory separate from Backpack representation
- [ ] stable item IDs
- [ ] unique instance IDs where needed
- [ ] server authoritative mutation/equip
- [ ] death/respawn rebuild
- [ ] capacity/overflow defined
- [ ] transaction item locks
- [ ] removed catalog migration
- [ ] mobile/gamepad UI
- [ ] mutation reason taxonomy
