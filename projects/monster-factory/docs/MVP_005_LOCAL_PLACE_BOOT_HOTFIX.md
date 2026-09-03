# MVP-005 Local Place Boot Hotfix

## Symptom
- Workspace appeared empty before play.
- Play mode repeatedly dropped the character into the void.
- Output stack ended at `ServerScriptService.ServerBootstrap`, line 6.

## Root cause
The original package initialized DataStore at ModuleScript import time.
A local/unpublished Studio place can reject DataStore access, which caused
`PlayerDataService` to fail while `ServerBootstrap` was still requiring modules.

Because `WorldService.Init()` had not run yet, the generated map never existed.

## Fix
1. DataStore acquisition is now lazy and protected by `pcall`.
2. Local Studio files use ephemeral session data when DataStore is unavailable.
3. `WorldService.Init()` executes before data/economy modules are required.
4. The `.rbxlx` contains a static emergency floor + SpawnLocation.
5. Output now prints:
   - `[MonsterFactory] WorldService boot: generating world`
   - `[MonsterFactory] WorldService boot: complete`

## Expected local test behavior
Saving is temporary until the experience is published / Studio API access is available.
Gameplay itself should boot normally.
