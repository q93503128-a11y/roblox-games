# System Architecture 001

> status: PRE-IMPLEMENTATION CONTRACT
> purpose: keep gameplay logic independent from whatever visual asset family Studio approves

## 1. Architecture principle

Visual assets are replaceable presentation.

Authoritative gameplay state is project-owned.

```text
Approved visual asset
→ project catalog entry
→ runtime visual representation

NOT

third-party model script
→ authoritative combat/progression logic
```

## 2. Core domains

### PlayerProfile / Progression
Server owns:
- Level / XP
- Gold
- Rebirth count
- milestone unlock flags
- inventory ownership
- equipped item IDs
- region/boss completion flags

### Combat
Client:
- input intent
- immediate local animation/presentation when safe

Server:
- attack validation
- cooldown/state validation
- hit/damage result
- enemy death
- XP/Gold/loot award

### Inventory / Equipment
Data layers:

```text
ItemCatalog
PersistentInventory
EquipmentState
RuntimeVisual
```

A Tool/model existing in Backpack/Character is not proof of ownership.

### Enemy
Enemy visuals/rigs are selected after Asset Intake.

Project code owns:
- target acquisition rules
- chase/attack state
- damage
- health
- reward table
- respawn

Third-party bundled AI is not canonical by default.

### Rebirth
Server validates:
- requirement level
- required clear flags
- current profile state

Server performs one atomic/coherent transition:
- calculate permanent new state
- reset selected run state
- retain allowed permanent state
- save/version state
- rebuild runtime character/equipment presentation

Client only requests Rebirth and shows confirmation/result.

## 3. Data-driven content boundary

Do not hardcode Enemy A as `Goblin` or a weapon as `IronSword` before asset approval.

Initial schemas should support stable IDs such as:

```text
enemy_field_a_01
boss_region_01
weapon_start_a
weapon_start_b
```

After asset approval, display names and runtime asset mappings can change without redesigning progression architecture.

## 4. Suggested catalogs

When implementation starts, prefer centralized definitions for:

```text
ItemCatalog
EnemyCatalog
RegionCatalog
LootTables
ProgressionConfig
RebirthConfig
```

No same numbers copied into UI/server/client scripts independently.

## 5. Remote surface baseline

Keep narrow.

Likely intents:

```text
AttackIntent
SkillIntent
EquipItem
UnequipItem
RequestRebirth
InteractObjective
```

Replication/events for presentation can be separate, but valuable results come from server state.

Validation includes:
- type
- range
- ownership
- current state
- distance where relevant
- cooldown/rate limit
- region/progression eligibility

## 6. Save schema baseline

Initial conceptual shape:

```text
schemaVersion
progression:
  level
  xp
  gold
  rebirths
  milestoneFlags
  regionProgress
inventory:
  items
  equipped
meta:
  collection/index later
  cosmetics later
```

Exact persistence wrapper/tool is not selected here.

Do not create migrations until an actual schema implementation exists.

## 7. Runtime visual adapter

Needed because asset-first design may change meshes/rigs.

Gameplay catalogs should reference project-owned visual keys, for example:

```text
visualKey = "weapon_start_a"
```

A project visual registry maps that key to the current approved model/package.

This makes it possible to replace a prototype sword with a better approved sword without rewriting damage, loot or save logic.

## 8. Enemy rig adapter requirements

Whatever enemy family is approved must expose a normalized project contract:
- root/pivot
- health-bearing entity root
- Animator/Humanoid or project-supported custom animation path
- attack origin/socket if needed
- hit volume reference
- ground contact/pivot rule

Do not make combat code depend on arbitrary descendant names from an imported model.

## 9. UI contract

HUD displays server-derived state:
- HP
- Level / XP
- Gold
- Rebirth count
- objective

Inventory presents catalog + ownership state.

Rebirth confirm screen must explicitly show:
- what resets
- what remains
- next permanent gain
- newly unlocked milestone if applicable

## 10. Deferred systems

Do not implement before core slice passes:
- trading
- guilds
- pets
- PvP
- complicated crafting
- reroll affix economy
- battle pass
- multiple prestige tiers
- large class tree

## 11. First implementation order after Asset Pass 001

```text
1. project skeleton / sync workflow
2. server profile in test-safe form
3. player movement/combat input shell
4. one weapon visual adapter
5. one Enemy A rig adapter
6. one complete attack → death → reward route
7. loot/equip
8. Enemy B
9. Boss A
10. Rebirth test route
11. mobile route
12. art/route regression
```

Do not implement 20 content definitions before step 6 proves the loop.
