# Rebirth RPG — Script Sync Runtime Layout 001

> status: IMPLEMENTATION CONTRACT
> verified against current Roblox Script Sync docs: 2026-09-08

The project remains **Studio-first**. Studio owns map, terrain, models, approved assets, authored UI, and the final `.rbxlx`. Git owns the gameplay scripts under `projects/rebirth-rpg/scripts/`.

Roblox Script Sync is the intended bridge for this project because it synchronizes Studio script/folder instances to disk while leaving non-script world instances Studio-owned.

## Disk → DataModel mapping

Create these three Studio folders and sync them to the matching repository folders:

```text
ReplicatedStorage
└─ RebirthRPG
   └─ Shared
      ↔ projects/rebirth-rpg/scripts/Shared/

ServerScriptService
└─ RebirthRPG
   ↔ projects/rebirth-rpg/scripts/Server/

StarterPlayer
└─ StarterPlayerScripts
   └─ RebirthRPG
      ↔ projects/rebirth-rpg/scripts/Client/
```

Expected runtime scripts after sync:

```text
ReplicatedStorage/RebirthRPG/Shared/Protocol
ServerScriptService/RebirthRPG/GameConfig
ServerScriptService/RebirthRPG/ProfileService
ServerScriptService/RebirthRPG/RewardService
ServerScriptService/RebirthRPG/CombatService
ServerScriptService/RebirthRPG/EnemyService
ServerScriptService/RebirthRPG/RebirthService
ServerScriptService/RebirthRPG/ServerBootstrap
StarterPlayer/StarterPlayerScripts/RebirthRPG/ClientBootstrap
```

`ServerBootstrap` creates only the small project-owned `ReplicatedStorage/RebirthRPG/Remotes` runtime folder and RemoteEvent/RemoteFunction objects. It does not generate the map.

## Current disk extension

The repository currently uses `.lua` files. Studio Script Sync exposes a configurable disk file-extension setting; keep the chosen extension consistent for all three synced roots. Do not rename the whole project merely for aesthetics while the first slice is being integrated.

## Enemy runtime contract

An approved sanitized enemy visual becomes gameplay-active only when the Studio-owned Model satisfies all of these:

```text
CollectionService tag: RebirthRPG_Enemy
Attribute: EnemyId = one of
  enemy_field_a_01
  enemy_field_b_01
  boss_region_01

Model contains:
  Humanoid
  coherent root/pivot suitable for Model:GetPivot()
  unbroken rig/attachments
```

Project code, not imported scripts, owns:
- health
- movement speed
- aggro
- attacks
- damage
- death reward
- XP/Gold/loot
- boss clear flag

Do not leave third-party NPC AI running beside `EnemyService`.

## Weapon runtime contract

The authoritative equipped state stores only stable IDs:

```text
weapon_start_a
weapon_start_b
```

Approved weapon visuals will later map to the same `visualKey`. Replacing a prototype mesh must not change combat/reward/save IDs.

Current first-slice combat values are tuning placeholders and must be fitted after real Studio TTK measurements.

## First integration smoke test

After Script Sync and TASK 01–03 provide approved visuals:

1. Confirm all expected synced scripts exist in the intended DataModel locations.
2. Confirm no duplicate old version of the same project scripts exists elsewhere.
3. Add one sanitized enemy model to a disposable combat pocket.
4. Tag it `RebirthRPG_Enemy` and set `EnemyId = enemy_field_a_01`.
5. Play.
6. Confirm Output contains the RebirthRPG bootstrap-ready line and no project-attributable red error.
7. Attack the enemy from valid range.
8. Confirm server-owned health decreases.
9. Kill it once.
10. Confirm XP/Gold HUD state changes exactly once.
11. Spam attack Remote through normal input and confirm cooldown prevents extra server hits.
12. Die/reset player and confirm in-memory profile/equipment state reconstructs for the same server session.

## Not yet claimed

The source currently represents **CODE WRITTEN** only.

Until the above route is run in Studio, do not mark:
- FEATURE IMPLEMENTED
- STUDIO TESTED
- RBXLX EXPORTED

## Official current source

- Roblox Script Sync: https://create.roblox.com/docs/scripting/sync
- Roblox server authority/security guidance: https://create.roblox.com/docs/scripting/security/security-tactics
