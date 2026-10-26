# Sword Growth RPG — Evercyan RPG Kit V2 Static Audit

Status: STATIC AUDIT ONLY / NOT YET STUDIO-RUNTIME-VALIDATED

Audited source:
- `SwordGrowthRPG_EvercyanV2_AuditBase.rbxlx`
- SHA-256: `9c931c5a8368d1ea84cd9e11b0e1f813f7338d7eb9c53bf12411b03398eddf63`
- Evercyan kit release text in the place: `2023/07/14`

This document records what is actually present in the uploaded `.rbxlx` and how it maps to Sword Growth RPG. Do not treat this as Studio validation; the place has not yet been executed by ChatGPT in Roblox Studio.

## 1. Static inventory

The uploaded place contains approximately:
- 634 instances
- 47 scripts total
  - 4 `Script`
  - 8 `LocalScript`
  - 35 `ModuleScript`
- 12 remotes
  - 7 `RemoteEvent`
  - 5 `RemoteFunction`

Major included systems:
- melee sword tools
- ranged crossbow example
- mob runtime / basic AI / respawn
- mob health UI and floating damage numbers
- player level / XP / gold
- DataStore save/load
- inventory / hotbar
- armor
- shop / pawn shop
- level door
- portal / teleport presentation
- healing fountain
- basic HUD
- melee auto-facing for nearby mobs

The importer has already unpacked the kit into normal Roblox services. No `PackageLink` was found in the uploaded place.

## 2. External-code / loader check

No dynamic third-party code loader was found in the kit source during this static pass:
- no `require(<numeric asset id>)`
- no `loadstring`
- no `InsertService:LoadAsset`
- no `game:GetObjects`
- no external HTTP GET/POST/Request calls

`HttpService` is used by the projectile casting module only for GUID generation.

One Marketplace call exists for the optional Evercyan support/kit button. Sword Growth RPG should remove that production-facing support button.

Conclusion: the uploaded base does **not** look like an unsafe free-model loader bundle. It is reasonable to use as source material after the security and architecture changes below.

## 3. Strong reuse candidates

### Keep concept and adapt

- `MobConfig` data-driven monster configuration
- `MobLib` lifecycle concept: initialize → fight → die → reward → respawn
- simple chase-oriented mob AI
- per-mob `RespawnTime`
- client mob health bar presentation
- floating damage-number presentation
- melee auto-facing / mobile-friendly targeting assistance
- healing fountain world object and presentation
- portal / level-door visual concepts
- common utility modules such as Tween / Maid / Signal / number formatting where still useful

These fit Sword Growth RPG's intentionally simple farming combat well.

## 4. Must be rewritten or hardened

### P0 — melee damage authority

Current `DamageMob` is server-side for damage calculation, which is better than trusting a client-supplied damage number, but the client can invoke the remote with any tagged mob instance. The server does not prove that a legitimate sword hit actually occurred at the requested target, nor does it validate practical hit range / overlap / line of sight.

Result: an exploiter could repeatedly request damage against remote mobs while respecting only the tool cooldown.

Required Sword Growth RPG change:
- server-authoritative hit eligibility
- validate equipped sword and attack state
- validate target distance / server-side hitbox or equivalent spatial evidence
- reject impossible targets
- server owns final damage, crit, permanent effects and reward contribution

### P0 — mob network ownership

The current damage path can call `HumanoidRootPart:SetNetworkOwner(Player)` for the mob that the player attacked.

Do not keep this behavior as the combat authority model. Client ownership of an enemy's physics should not give a client leverage over valuable combat state.

### P0 — portal and level-gate authority

The included transportation module performs level-door opening and character teleport behavior on the client.

For Sword Growth RPG:
- current sword-level requirement must be checked on the server
- permanent portal purchase state must be checked on the server
- destination must be selected/approved on the server
- the client should only handle presentation/transition visuals

### P0/P1 — persistence

The included `DataManager` uses a beginner-oriented Instance/ValueObject data model and `DataStore:SetAsync`.

It has no Sword Growth RPG schema, no explicit migration version, no rebirth-specific contracts, and no robust session/rollback architecture. `BindToClose` itself only waits rather than explicitly iterating players and saving them.

Do not ship Sword Growth RPG on this persistence layer unchanged.

Required data includes at minimum:
- SwordLevel
- SwordXP
- Gold
- RebirthCount
- HealthTraining
- permanent effect/stat unlocks
- aura unlock/cosmetic selection
- permanent portal/fast-travel purchases
- settings
- records such as highest sword level / rebirth / endgame record
- schema version and migration path

### P1 — healing fountain validation

The fountain heals on the server and includes a distance sanity check, which is useful. However it still relies on touch behavior and a permissive distance guard.

Keep the fountain as a gameplay/world concept, but use a clean project-owned interaction/zone contract before production.

## 5. Existing rules that differ from Sword Growth RPG

The kit currently uses:
- normal player `Level`
- `XPPerLevel`
- hard `MaxLevel = 100`
- conventional Tools + Armor inventory
- crossbow/ranged example
- buy/sell shops
- item drops
- 25% max-HP contribution requirement for mob rewards
- optional kit support UI

Sword Growth RPG requires instead:
- `SwordLevel` with no maximum
- `SwordXP` with the project formula
- one evolving sword identity
- no conventional armor/equipment progression
- gold and sword EXP only from kills
- permanent cumulative sword effects rather than equipment builds
- **5% max-HP contribution requirement** for full eligible kill rewards
- rebirth and aura progression
- Health Training
- PvP toggle/combat-state rules

## 6. Remove from the production design

Unless later required for a separate purpose, remove after dependencies are mapped:
- Armor system
- Armor inventory UI
- Crossbow and ranged-example path
- Pawn shop
- ordinary equipment shop
- generic equipment buy/sell flow
- conventional item-drop progression
- kit support/Marketplace button
- hard max-level presentation

Do not delete these blindly before implementation work begins; first detach dependencies so removal does not create patch-stacking failures.

## 7. Current design decisions to preserve during conversion

- Default game language: **English**.
- On death, players respawn at the **Starting Town**, not at the most recent checkpoint.
- No meaningful death penalty.
- Healing fountains are a standard world/service element and should be retained.
- Normal same-level mobs target roughly **3–5 ordinary sword hits to kill**.
- Mob respawn time is configured per mob and is not determined by mob role.
- Reward eligibility threshold is 5% of monster max HP dealt by that player.

## 8. Adoption decision

**Decision: use Evercyan RPG Kit V2 as a donor/base framework, not as the Sword Growth RPG architecture unchanged.**

The kit is especially useful for accelerating:
- melee feel prototype
- simple mob prototype
- health/damage feedback
- fountain prototype
- portal/level-gate presentation
- basic Roblox RPG world conventions

Project-owned code should become authoritative for:
- combat validation
- damage/effects
- progression
- rebirth
- economy
- persistence
- valuable teleport/gate state
- PvP

## 9. Next safe implementation sequence

1. Preserve the uploaded audit base unchanged.
2. Create the real Sword Growth RPG source/project structure from latest `main`.
3. Port only the minimum kit systems required for a vertical slice.
4. Replace Level/XP with SwordLevel/SwordXP and remove the hard max level.
5. Harden melee hit validation before adding progression depth.
6. Convert mob reward contribution from 25% to 5% and remove conventional item drops.
7. Establish versioned Sword Growth RPG save schema.
8. Make Starting Town the only normal death respawn destination.
9. Retain a healing fountain as a first-town service/world element.
10. Make level gates/portals server-authoritative.
11. Build one compact first-region vertical slice and validate actual Studio runtime before adding further regions.

## 10. Validation still required

Not yet validated from this static file audit:
- clean boot in current Roblox Studio
- runtime errors/warnings
- DataStore behavior with Studio API access
- actual sword hit feel and animation timing
- mob pathing under real geometry
- mobile control usability
- fountain runtime behavior
- portal / level-door runtime behavior
- multiplayer contribution handling
- performance baseline

Do not label the kit integration or game implementation complete until these routes are tested in Studio.
