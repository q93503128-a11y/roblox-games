# Evercyan RPG Kit V2 — Sword Growth RPG Hardening Plan

Status: PRE-IMPLEMENTATION SECURITY / ARCHITECTURE PLAN

Source audited: `SwordGrowthRPG_EvercyanV2_AuditBase.rbxlx`

This plan narrows the Evercyan V2 kit into a safe, maintainable base for Sword Growth RPG. The original audit base should remain untouched; changes belong in the project copy.

## Overall decision

Evercyan V2 is suitable as a reference/base asset, but not safe to ship unchanged. The useful parts are its simple data-driven mob setup, melee presentation, healing fountain, UI pieces, and general RPG examples. Valuable state, combat results, travel authorization, and persistence must become server-authoritative.

## P0 — mandatory before real progression/content

### 1. Rewrite melee hit authority

Current `DamageMob` remote lets the client choose any tagged mob. The server calculates damage and checks equipped weapon/cooldown, but does not verify that the sword actually hit the target, that the target is in range, or that the player is in a valid attack window.

Risk: an exploit client can repeatedly damage arbitrary distant mobs at the legitimate cooldown rate.

Required replacement:
- client sends attack intent, not target/damage truth
- server owns attack cooldown/state
- server validates equipped sword
- server performs/validates overlap/raycast/hitbox from server-known character state
- server checks range and target alive/valid
- server calculates all damage, crit, effects, and rewards
- duplicate hit IDs rejected
- client may predict animation/VFX only

### 2. Remove mob network ownership transfer to players

Current mob AI and `DamageMob` use `SetNetworkOwner(Player)` for the mob root while following/being hit.

Risk: a client controlling mob physics can manipulate position/velocity and produce impossible physical states.

For Sword Growth RPG, prefer server-owned monster simulation unless measured performance proves another policy is needed. If client ownership is ever used later, server plausibility checks are mandatory.

### 3. Replace `Touched`-based enemy attacks

Current mob damage is caused by mob hitbox `.Touched`, with one global cooldown per player shared by every mob.

Problems:
- physics/contact is a weak combat authority boundary
- multiple mobs interfere with one another's cooldown
- behavior is hard to tune as actual melee combat

Replacement:
- each mob has `AttackRange`, `AttackInterval`, optional windup
- server AI attacks its current valid target when in range
- cooldown is per mob/target relationship as appropriate
- server applies damage directly

### 4. Rewrite persistence before player data matters

Current DataManager uses basic `GetAsync`/`SetAsync`, has no profile/session locking or schema version/migration, and `BindToClose` only waits instead of explicitly saving.

Required production save schema must support at minimum:
- SwordLevel / SwordXP
- Gold
- Rebirth
- HealthTraining
- permanent effects/stat unlocks
- permanent portal purchases
- fast-travel purchases
- aura unlock/cosmetic selection
- settings
- records

Requirements:
- server-only save authority
- schema version and migration
- validation/default fill for missing/corrupt fields
- safe retry/failure handling
- session/duplicate-session strategy
- explicit shutdown save handling
- no client-selected datastore keys or snapshots

### 5. Move monster contribution ledger server-side

Current damage contribution is stored as Attributes under a `PlayerTags` Configuration inside the live mob model. This replicates contribution data unnecessarily and records requested damage rather than clamped actual applied damage.

Replacement:
- server-only table keyed by mob identity and user ID
- add only actual applied damage: `min(requestedDamage, healthBeforeHit)`
- reward threshold: 5% of max HP
- clean ledger on death/despawn
- eligible players receive full configured kill rewards

### 6. Make travel/progression authorization server-owned

Current level doors and portals are primarily client-side and move the character locally.

Physical barriers are not security. A modified client can move its character regardless.

Replacement:
- server validates current SwordLevel for meaningful access/reward interactions
- portal purchase state checked server-side
- teleport request validated by destination catalog + level + ownership + combat restrictions if applicable
- server performs authoritative teleport
- region-gated rewards/effects independently verify progression, not just physical location

## P1 — strongly recommended cleanup

### Remove systems Sword Growth RPG does not use

Delete from the project copy after dependencies are mapped:
- Armor system and armor remotes
- Crossbow/ranged system
- projectile casting/share remotes
- Shop and Pawn systems
- conventional inventory/equipment UI
- item drop/equipment loot logic
- kit promotional/support GUI

Reason: unused code increases exploit surface, regression surface, and maintenance cost.

### Armor exploit if temporarily retained

`EquipArmor` currently applies armor stats before verifying ownership. A client can request a catalog armor it does not own and receive the stat/morph effect. Do not retain this implementation.

### Healing fountain

Keep the fountain concept/art, but replace the current permissive `Touched` + 100-stud sanity check with a short server-authoritative proximity/region check. Healing remains free and should not alter progression.

### Return-to-spawn button

The current main GUI locally pivots the character to spawn. Remove it unless Sword Growth RPG deliberately adds a Return to Town feature. If added later, server validates its use (especially PvP/combat state) and performs the teleport.

### Hotbar remote

If hotbar is removed, delete it. If retained, validate slot as an integer 1–9 and verify the item is actually owned/allowed. Add action-specific rate limiting.

### Buy/Sell remotes

They are more server-authoritative than the combat remote, but Sword Growth RPG does not need these conventional item transactions. Remove rather than harden.

## P2 — structural modernization

### Explicit service bootstrap

Current ServerMain automatically `require`s every top-level module for side effects. Replace with explicit initialization order, e.g.:

`SaveService -> PlayerStateService -> CombatService -> MobService -> TravelService -> UI/notification adapters`

Benefits:
- dependencies are visible
- initialization failures are attributable
- systems can be tested independently
- removing unused kit modules is safer

### Player state representation

Current player state is represented by many ValueObjects under `ReplicatedStorage.PlayerData`, visible to all clients. This is convenient but becomes noisy as Sword Growth RPG adds effects, portals, aura, settings, and records.

Prefer:
- authoritative server profile/table
- replicate only UI/public state that clients actually need
- public comparison stats (SwordLevel/Rebirth/etc.) can be explicitly replicated
- private/internal progression state remains server-owned

### Mob config concept can stay

The kit's per-mob data-driven configuration is useful. Adapt it to fields such as:
- Id / DisplayName
- Role: Normal/Boss/WorldBoss/EventNormal/EventBoss
- RecommendedSwordLevel / MinimumSwordLevel when needed
- MaxHealth
- Damage
- MoveSpeed
- AggroRadius
- LeashRadius
- AttackRange
- AttackInterval
- RespawnTime (independent of role)
- SwordXPReward
- GoldReward
- unlock hooks if needed

Do not hardcode role-based respawn times.

### HumanoidAttributes concept is reusable

The additive-source approach for MaxHealth/WalkSpeed is useful for Health Training + Aura + temporary effects. Rename/rework it into project-owned stat aggregation rather than keeping Armor-specific naming.

## Confirmed code defects / risks

- `DamageMob`: no server hit/range validation.
- mob network ownership is transferred to clients.
- mob attacks rely on `.Touched` and share one player cooldown across mobs.
- contribution threshold is 25%, not Sword Growth RPG's required 5%.
- contribution counts full requested damage, including overkill.
- `EquipArmor`: applies armor before ownership validation.
- `ShareProjectile`: server relays arbitrary client projectile payload to other clients without meaningful validation/rate limiting.
- `DataManager`: no session lock/schema migration; shutdown handler does not explicitly save.
- `ServerMain` character-parent timeout expression is malformed (`tick()+5 > s`) and does not implement the intended five-second timeout.
- `SFX:Play3D(Vector3)` contains a parent/reference bug in the Vector3 branch.
- client-only portal/door/spawn teleports are not authorization boundaries.

## Reuse decision

KEEP / ADAPT:
- mob config/data-driven authoring idea
- mob presentation/health UI
- simple chase behavior concept
- melee auto-align presentation
- healing fountain art/concept
- useful generic utility modules after testing (`Tween`, `FormatNumber`, `Maid`, `Signal`)
- additive humanoid-stat concept

REWRITE:
- combat authority
- mob attack authority
- contribution/reward ledger
- persistence
- portals/level gates as progression authority
- progression model (Level -> uncapped SwordLevel + Rebirth)

REMOVE:
- armor
- ranged/crossbow/casting
- conventional equipment inventory
- shop/pawn
- equipment drops
- kit promotion UI

## First hardened vertical slice

Do not build the full game immediately. First prove:

`Starting Town -> sword equip -> normal mob aggro -> 3–5 valid server-authoritative hits -> kill -> 5% contribution reward -> SwordXP/Gold -> sword level-up -> fountain heal -> death -> Starting Town respawn -> level-gated route`

Acceptance:
- exploit-style remote calls cannot hit distant mobs
- client cannot choose damage amount/reward
- mob physics cannot be arbitrarily controlled by the attacking client
- two mobs can attack independently
- rewards are awarded once and only to >=5% contributors
- no unexpected runtime errors
- desktop and mobile primary attack route works
- save/load survives rejoin and shutdown test before persistent content expands
