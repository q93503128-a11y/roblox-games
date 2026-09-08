# Rebirth RPG — Script Sync Runtime Layout 001

> status: IMPLEMENTATION CONTRACT
> verified against current Roblox Script Sync docs: 2026-09-08
> workflow: Studio-first + Script Sync + Git

The project remains **Studio-first**. Studio owns map, terrain, models, approved assets, authored production UI, Lighting, and the final `.rbxlx`. Git owns gameplay code under `projects/rebirth-rpg/scripts/`.

Do not migrate to Rojo unless a concrete later need appears.

## Exact DataModel mapping

Create these three Studio folders in a clean Rebirth RPG test place:

```text
ReplicatedStorage
└─ RebirthRPG
   └─ Shared

ServerScriptService
└─ RebirthRPG

StarterPlayer
└─ StarterPlayerScripts
   └─ RebirthRPG
```

Sync them to:

| Studio instance | Disk directory |
|---|---|
| `ReplicatedStorage/RebirthRPG/Shared` | `projects/rebirth-rpg/scripts/Shared` |
| `ServerScriptService/RebirthRPG` | `projects/rebirth-rpg/scripts/Server` |
| `StarterPlayer/StarterPlayerScripts/RebirthRPG` | `projects/rebirth-rpg/scripts/Client` |

Expected synced code:

```text
ReplicatedStorage/RebirthRPG/Shared
└─ Protocol

ServerScriptService/RebirthRPG
├─ GameConfig
├─ ProfileService
├─ RewardService
├─ CombatService
├─ EnemyService
├─ RebirthService
├─ StudioTestHooks
├─ StudioSmokeHarness
└─ ServerBootstrap

StarterPlayer/StarterPlayerScripts/RebirthRPG
└─ ClientBootstrap
```

`ServerBootstrap` creates `ReplicatedStorage/RebirthRPG/Remotes` at runtime. It does **not** generate the production world.

## Current disk extension

The repository currently uses `.lua` files.

Roblox Script Sync exposes a file-extension setting and supports Lua/Luau choices. Keep the repository on the current Lua extension for this first integration rather than creating duplicate `.luau` copies or renaming the codebase only for aesthetics.

Use one extension consistently across all synced roots.

## First sync conflict rule

Before choosing conflict resolution:
1. inspect the exact Studio place
2. inspect the three target code folders
3. confirm they contain no unrelated verified scripts
4. if they are new/empty, sync repository code into them
5. if Studio already contains meaningful Rebirth RPG code, STOP and compare before overwriting

Never blindly choose `Keep Disk` against an unknown place.

## Script Sync boundaries

- Sync code folders only, not Workspace/map content.
- Do not depend on attributes/tags attached to synced script instances as canonical metadata.
- Enemy tags/attributes belong on Studio/runtime enemy **models**.
- Do not place Creator Store gameplay scripts into project sync roots.
- Do not hand-create duplicate project Remotes beside the runtime contract unless architecture changes intentionally.
- Studio remains source of truth for map/assets and user-facing `.rbxlx` output.

## Enemy runtime contract

An enemy becomes gameplay-active only when its Studio-owned Model satisfies:

```text
CollectionService tag: RebirthRPG_Enemy
Attribute: EnemyId = one of
  enemy_field_a_01
  enemy_field_b_01
  boss_region_01

Model contains:
  Humanoid
  coherent root/pivot usable by Model:GetPivot()
  intact rig/attachments
  ZERO Script / LocalScript / ModuleScript descendants
```

`EnemyService` now refuses unsanitized tagged models containing executable descendants.

Project code owns:
- health
- movement speed
- aggro
- windup/attack timing
- damage
- death/respawn
- XP/Gold/loot
- boss clear flag

Do not leave third-party NPC AI running beside project `EnemyService`.

## Weapon runtime contract

Authoritative equipped state stores stable IDs only:

```text
weapon_start_a
weapon_start_b
```

Approved visual assets later map to these visual keys. Replacing a prototype mesh must not rewrite combat/reward/profile IDs.

Current numbers are tuning placeholders until real Studio TTK measurements exist.

## First code validation — BEFORE production asset binding

After Script Sync, run:

`docs/STUDIO_CORE_SMOKE_TEST_001.md`

The Studio-only smoke harness uses temporary sanitized R15 rigs and an explicit named anchor. This proves the structural gameplay route without pretending the debug rigs are production art.

Required route:

```text
clean boot
→ player state
→ Enemy A attack/death/reward
→ Enemy B guaranteed Weapon B
→ equip
→ boss clear
→ death/respawn
→ rebirth state transition
```

Only after this route is structurally sound should asset intake and approved visual binding continue.

## Studio smoke harness contract

The harness runs only when both are true:
- `RunService:IsStudio()`
- Workspace attribute `RebirthRPG_EnableSmokeHarness = true`

It also requires one explicit BasePart anchor:

```text
RebirthRPG_SmokeOrigin
```

The code does not guess a world coordinate if the anchor is missing.

The harness is optional. Bootstrap isolates it with `pcall`; failure of the debug harness must not stop the core server boot.

## Not yet claimed

Current source is still:

```text
CODE WRITTEN
NOT STUDIO TESTED
```

Until the smoke route actually runs in Studio, do not mark:
- FEATURE IMPLEMENTED
- STUDIO TESTED
- RBXLX EXPORTED

## Official current references

- Roblox Script Sync: https://create.roblox.com/docs/scripting/sync
- Roblox security/server boundary: https://create.roblox.com/docs/scripting/security/security-tactics
