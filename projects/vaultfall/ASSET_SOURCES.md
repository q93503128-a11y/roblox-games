# Vaultfall external asset sources

Last checked: 2026-09-03

Vaultfall treats third-party Creator Store models as **visual material only**. No third-party executable script is part of the canonical game logic. `tools/INSTALL_VISUAL_ASSETS.server.lua` removes `Script`, `LocalScript`, `ModuleScript`, `RemoteEvent`, `RemoteFunction`, `ClickDetector`, and `ProximityPrompt` instances from imported packs before they are stored under `ServerStorage/VaultfallAssets`.

## Current packs

### DungeonKit
- Asset: `The Ultimate Low Poly Asset Pack`
- Creator: `@FaDoLuanSantana`
- Asset ID: `9492405836`
- Creator Store: `https://create.roblox.com/store/asset/9492405836/The-Ultimate-Low-Poly-Asset-Pack`
- DevForum resource: `https://devforum.roblox.com/t/free-the-ultimate-low-poly-asset-pack-added-more-assets/1772603`
- Use: modular dungeon pieces and dungeon props/decorative geometry only
- Store state checked 2026-09-03: free model, 95% with 70+ votes
- Pack documentation states it contains 11 modular dungeon assets (walls, floors, flags, detailed windows) plus a complete sample dungeon build; game use is explicitly permitted and credit is appreciated but not required.

### WeaponPack
- Asset: `Weapon pack`
- Creator: `@TANORV`
- Asset ID: `17351010368`
- Creator Store: `https://create.roblox.com/store/asset/17351010368/Weapon-pack`
- Use: weapon visual candidates only
- Store state checked 2026-09-03: free model

### MonsterPack
- Asset: `FREE MONSTER NO NEED CREDITS`
- Creator: `@im_notbmgo9001`
- Asset ID: `14483015744`
- Creator Store: `https://create.roblox.com/store/asset/14483015744/FREE-MONSTER-NO-NEED-CREDITS`
- Use: monster visual shell candidates only
- Store state checked 2026-09-03: free model; listing explicitly states no credit required

### NaturePack
- Asset: `[FREE] Low polly asset pack`
- Creator: `@Jax0nStream201042`
- Asset ID: `79195618410265`
- Creator Store: `https://create.roblox.com/store/asset/79195618410265/FREE-Low-polly-asset-pack`
- Use: hub trees/rocks/bush visual candidates
- Store state checked 2026-09-03: free model

## Considered but intentionally not embedded

### Evercyan / ej0w RPG kits
The Evercyan RPG Kit and ej0w modified kit were researched as reference foundations. Their public listings explicitly permit game use/modification, and the modified kit provides combat, crafting, quests/dialogue, zones, chests/loot, and weapons. They are **not copied into Vaultfall v0.1**, because Vaultfall keeps its own server-authoritative logic and uses third-party assets only for presentation. This avoids coupling the project to unknown internal script contracts.

References:
- `https://create.roblox.com/store/asset/1498988226/Evercyans-RPG-Kit`
- `https://create.roblox.com/store/asset/17514739217/ej0ws-Modified-Evercyans-RPG-Kit-v107`

## Replacement rule

Any of these packs may be replaced later without rewriting the combat/run/save systems. If a replacement is chosen:
1. record the new source here,
2. update the installer manifest,
3. keep third-party scripts stripped,
4. test bounding scale and prop classification,
5. do not silently change unrelated gameplay while replacing visuals.
