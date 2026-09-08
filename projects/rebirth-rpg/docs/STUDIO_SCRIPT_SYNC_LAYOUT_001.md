# Rebirth RPG — Studio Script Sync Layout 001

> workflow: Studio-first + Roblox Script Sync + Git
> purpose: map the existing repository code into the Studio DataModel without turning the entire place into a filesystem-owned project

## Ownership

Studio owns:
- map / terrain
- imported and sanitized assets
- authored NPC/weapon models
- Lighting
- UI art hierarchy when production UI begins
- final `.rbxlx` handoff

Git + Script Sync owns the project Luau code in `projects/rebirth-rpg/scripts/`.

Do not migrate this project to Rojo unless there is a concrete later need.

## Exact DataModel mapping

Create these folders in a clean Rebirth RPG test place:

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

Then sync:

| Studio instance | Disk directory |
|---|---|
| `ReplicatedStorage/RebirthRPG/Shared` | `projects/rebirth-rpg/scripts/Shared` |
| `ServerScriptService/RebirthRPG` | `projects/rebirth-rpg/scripts/Server` |
| `StarterPlayer/StarterPlayerScripts/RebirthRPG` | `projects/rebirth-rpg/scripts/Client` |

Expected important scripts after sync:

```text
ReplicatedStorage/RebirthRPG/Shared
└─ Protocol                         # ModuleScript

ServerScriptService/RebirthRPG
├─ GameConfig                       # ModuleScript
├─ ProfileService                   # ModuleScript
├─ RewardService                    # ModuleScript
├─ CombatService                    # ModuleScript
├─ EnemyService                     # ModuleScript
├─ RebirthService                   # ModuleScript
├─ StudioTestHooks                  # ModuleScript
├─ StudioSmokeHarness               # ModuleScript
└─ ServerBootstrap                  # server Script

StarterPlayer/StarterPlayerScripts/RebirthRPG
└─ ClientBootstrap                  # client-running Script
```

`ReplicatedStorage/RebirthRPG/Remotes` is created at runtime by `ServerBootstrap`. It is intentionally **not** a synced source folder.

## File-extension setting

The repository currently uses `.lua` files.

Roblox Script Sync has a file-extension setting. Keep the project on the current Lua extension for this first integration instead of renaming every file just for style. If the Studio setting is currently Luau-only, set the Script Sync file-extension option to Lua before linking these folders.

Do not create duplicate `.luau` copies next to the existing `.lua` files.

## First sync conflict rule

Before choosing conflict resolution:
1. inspect the target Studio folders
2. confirm they contain no unrelated verified scripts
3. if they are empty/new, the repository version may become the source for the synced code
4. if Studio already contains meaningful Rebirth RPG code, STOP and compare before overwriting

Never blindly choose `Keep Disk` against an unknown existing place.

## Script Sync boundary rules

- Sync code folders only, not the whole Workspace.
- Do not attach important attributes/tags to synced script instances; Script Sync does not preserve script metadata as project source.
- Enemy tags/attributes belong on runtime/Studio enemy **models**, not on synced scripts.
- Do not place imported Creator Store gameplay scripts inside these synced folders.
- Production remotes are created by project code; do not add duplicate hand-authored RemoteEvents with the same names unless the bootstrap contract changes.

## Smoke integration gate

After sync, do **not** start production map building immediately.

Run:
`docs/STUDIO_CORE_SMOKE_TEST_001.md`

Pass the basic code route first:

```text
boot
→ player state
→ attack
→ Enemy A death/reward
→ Enemy B guaranteed Weapon B
→ equip
→ boss clear
→ rebirth test
```

Only after that route is structurally sound should approved visual rigs replace the Studio smoke rigs.
