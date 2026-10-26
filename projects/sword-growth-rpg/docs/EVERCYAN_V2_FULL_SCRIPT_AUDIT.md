# Evercyan RPG Kit V2 — Full Script Audit

Source: `SwordGrowthRPG_EvercyanV2_AuditBase.rbxlx`

SHA-256: `9c931c5a8368d1ea84cd9e11b0e1f813f7338d7eb9c53bf12411b03398eddf63`

Audit type: static source/data-model audit. This is not a substitute for Studio runtime/playtest validation.

## Inventory

- 634 total Instances
- 47 Script / LocalScript / ModuleScript sources
- 12 RemoteEvents / RemoteFunctions
- approximately 200k characters of Luau source

## Security / architecture headline

No numeric-ID `require()`, `loadstring`, `InsertService:LoadAsset`, or external HTTP request loader was found. The kit is not treated as malicious.

However, several production-critical systems trust the client too much or are outdated for Sword Growth RPG:

1. `DamageMob` verifies configured damage and cooldown on the server, but does not prove that a valid melee/ranged hit occurred in server-authoritative space. A client can nominate a tagged mob remotely.
2. `DamageLib` and mob AI assign mob network ownership to players. This is unsuitable for valuable combat state.
3. Level doors and portals are client-side. Character teleport/access must become server-authoritative.
4. `DataManager` uses `SetAsync`, lacks session locking/schema migration, and `BindToClose` only waits instead of explicitly saving players.
5. `ShareProjectile` relays arbitrary client projectile payloads to other clients without rate/shape/range validation. It is mostly visual, but is spam-able.
6. `ArmorLib` applies armor effects before verifying ownership in its Equip remote path. This is a real authorization-order bug.
7. `SFX:Play3D` has a Vector3 branch bug: it creates an Attachment but does not assign it to `Parent`, so subsequent parenting/access can fail.
8. Mob contribution currently grants drops at 25%, while Sword Growth RPG requires 5%. Contribution also records configured damage rather than capped actually-applied damage, so overkill can inflate contribution.

## Script-by-script disposition

| # | Script | Current role | Sword Growth RPG disposition |
|---|---|---|---|
| 1 | `Workspace/How-To Use (Open)` | Documentation/tutorial ModuleScript | KEEP only as reference during migration; remove from production place after relevant contracts are documented. |
| 2 | `Workspace/Healing Fountain/Server` | Server touch healing + cooldown | ADAPT. Core concept fits. Tighten server distance/contact validation and integrate project health authority. |
| 3 | `Workspace/Healing Fountain/Client` | Fountain cooldown visuals | KEEP/ADAPT. Useful presentation layer; gameplay effect remains server-side. |
| 4 | `Workspace/The Abyss/Config` | Portal config | REPLACE DATA. Pattern useful, but use sword-level requirement + permanent purchase state. |
| 5 | `Workspace/Dark Forest/Config` | Level-door config | REPLACE DATA. Keep configuration-driven gate idea, move access authority to server. |
| 6 | `Workspace/NPCs/Shop/Config` | Buy shop config | REMOVE for core game. Conventional equipment shop conflicts with one-sword design. |
| 7 | `Workspace/NPCs/Pawn/Config` | Sell shop config | REMOVE. No conventional item resale economy planned. |
| 8 | `Workspace/Mobs/Thief/MobConfig` | Mob stats/rewards/behavior config | ADAPT HEAVILY. Good data-driven monster contract; replace XP/Gold/item model with Sword EXP/Gold/effect hooks and per-mob role fields. |
| 9 | `StarterPlayer/.../ClientMain` | Client module bootstrap, click SFX, damage numbers, notifications | ADAPT. Keep bootstrap/feedback concepts; project-owned UI and damage feedback. |
| 10 | `ClientMain/Transportation` | Client level gates + portals + transition VFX | REWRITE AUTHORITY. Reuse visual transition ideas only; all access/teleport decisions move server-side. |
| 11 | `ClientMain/MobClient` | Mob overhead UI + local animations | KEEP/ADAPT. Strong reusable base for health/name/rank display; remove unused rank taxonomy and tune for production/mobile. |
| 12 | `ClientMain/PlayerListStats` | Client leaderstats mirror | OPTIONAL/ADAPT. Show Sword Level/Rebirth if desired; not authoritative. |
| 13 | `ClientMain/MeleeMobAlign` | Auto-align player toward nearest mob | KEEP/ADAPT. Fits simple grind combat, but target eligibility must agree with authoritative combat rules. |
| 14 | `StarterGui/Main/GuiScript` | Level/XP/Gold/HP/speed HUD, spawn button, support button | REPLACE/ADAPT. Reuse ideas, not skin. Spawn teleport is currently client-side and must be server-authoritative or replaced by intended death/spawn flow. Remove kit support purchase UI. |
| 15 | `StarterGui/Pawn/PawnGuiScript` | Sell UI | REMOVE. |
| 16 | `StarterGui/Shop/ShopGuiScript` | Buy UI | REMOVE from core loop. Could be mined only for modal/component patterns. |
| 17 | `StarterGui/Tooltip/TooltipController` | Generic tooltip | KEEP candidate if needed; low coupling. |
| 18 | `StarterGui/Inventory/InventoryGuiScript` | Inventory/hotbar/armor/equip persistence | REMOVE from core game. One evolving sword should not inherit this complexity. |
| 19 | `Bronze Sword/ItemConfig` | Starter melee item data | REPLACE. Use as a temporary prototype only; Sword Growth uses one evolving sword and deterministic damage. |
| 20 | `Bronze Sword/MeleeClient` | Client touch hit detection + attack animation | REWRITE HIT VALIDATION. Presentation/animation structure may be reused; client cannot decide valid mob hits. |
| 21 | `Iron Sword/MeleeClient` | Duplicate melee behavior | REMOVE DUPLICATION. One shared sword combat controller should replace per-sword copied scripts. |
| 22 | `Iron Sword/ItemConfig` | Higher melee item data | REMOVE/CONVERT TO VISUAL FORM DATA after asset audit. |
| 23 | `Crossbow/ItemConfig` | Ranged weapon data | REMOVE for initial product scope. |
| 24 | `Crossbow/RangedClient` | Client projectile casting/damage request | REMOVE initially. Revisit only if a permanent effect later needs projectiles. |
| 25 | `Iron Armor/ItemConfig` | Armor stats/appearance | REMOVE. |
| 26 | `Bronze Armor/ItemConfig` | Armor stats/appearance | REMOVE. |
| 27 | `ReplicatedStorage/Modules/Tween` | Tween helper | KEEP candidate. Small, low-risk utility. |
| 28 | `Modules/ContentLibrary` | Enumerates item catalog/configs | REMOVE/REPLACE. Current inventory catalog architecture is unnecessary; a smaller sword-form/effect registry is preferable. |
| 29 | `Modules/FormatNumber` | Large-number formatting | KEEP. Useful for uncapped sword level/stat growth, subject to display QA. |
| 30 | `Modules/Maid` | Cleanup helper | KEEP candidate. Useful and low coupling. |
| 31 | `Modules/SFX` | One-shot sound helper | FIX before reuse. Vector3 `Play3D` branch fails to assign its Attachment to `Parent`. |
| 32 | `Modules/Signal` | GoodSignal-derived signal implementation | KEEP candidate. Low-risk utility. |
| 33 | `Modules/Casting` | Client projectile simulation + cross-client visual relay | REMOVE initially. If reused later, add server/rate validation and project-owned network contract. |
| 34 | `Casting/PartCache` | Projectile part pool | KEEP only if projectile/VFX system returns later. |
| 35 | `Casting/Visualizations` | Cast debug visualization | DEV-ONLY/REMOVE from production unless needed during projectile work. |
| 36 | `GameConfig` | Max level, XP curve, starter items, support UI | REPLACE COMPLETELY with Sword Growth configuration. Current `MaxLevel=100` conflicts with uncapped Sword Level. |
| 37 | `ServerScriptService/DataManager` | DataStore + replicated pData hierarchy | REWRITE. Preserve only useful schema ideas. Needs versioned save schema, robust atomic write strategy, shutdown save, migrations, and Sword Growth fields. |
| 38 | `ServerScriptService/ServerMain` | Core bootstrap, starter items, shops, hotbar remotes | REWRITE/REDUCE. Keep centralized bootstrap principle; remove item/armor/shop/hotbar systems. |
| 39 | `ServerMain/HumanoidAttributes` | Aggregates HP/WalkSpeed/JumpPower sources | KEEP/ADAPT. Very compatible with Health Training + Aura stacking. Make project-owned stat-source contract and test health changes. |
| 40 | `ServerMain/PlayerLeveling` | Linear character level progression | REPLACE with Sword Level formula and uncapped progression. |
| 41 | `ServerStorage/Modules/ArmorLib` | Armor ownership/equip/morph/remotes | REMOVE. Also contains authorization-order flaw: `EquipArmor` effect can run before ownership validation. |
| 42 | `ArmorLib/Morph` | Welds armor appearance to character | REMOVE for current design; could be studied later for aura/cosmetic attachment techniques only. |
| 43 | `Modules/ToolLib` | Gives/removes inventory tools | REPLACE with single-sword lifecycle/equipment service. |
| 44 | `Modules/MobLib` | Mob construction, touch damage, death, respawn, contribution, drops | ADAPT HEAVILY. This is one of the best foundations in the kit. Replace 25% threshold with 5%, cap contribution to actually-applied damage, remove item drops, separate reward service, and tune combat contact model. |
| 45 | `MobLib/AI` | Simple chase/jump/idle optimization | ADAPT. Fits the desired simple AI, but remove player network ownership and validate scaling/performance with many mobs. |
| 46 | `MobLib/MobList` | Shared mob registry table | KEEP/REPLACE trivially as internal registry. |
| 47 | `Modules/DamageLib` | Server damage calculation + client-triggered mob selection | REWRITE. Keep centralized damage service idea, but use server-authoritative hit validation, deterministic base damage, 5% base crit chance, critical overflow logic, attack-range progression, PvP coefficient, and effect pipeline. |

## Remote audit

Existing remotes:

- `BuyItem` — remove with shop.
- `SellItem` — remove with pawn.
- `DamageMob` — replace with authoritative combat request/validation contract.
- `EquipArmor` / `UnequipArmor` — remove.
- `HotbarItemChanged` — remove with inventory/hotbar.
- `PlayerDamagedMob` — keep concept as server-to-client feedback only.
- `MobDamagedPlayer` — keep concept as server-to-client feedback only.
- `SendNotification` — keep concept, preferably project-owned toast system.
- `ShareProjectile` / `ReceiveProjectile` — remove initially; current server relay accepts client payload wholesale.
- fountain `Healed` — keep as server-to-client visual feedback.

## Major concrete defects / risks found

### P0 before production

- Damage request does not prove a legitimate server-observed hit/range.
- Mob physics network ownership is handed to clients.
- Portal/level-door teleport/access is client-authoritative.
- Data save architecture is not sufficient for valuable long-term progression.
- Armor equip authorization order allows applying unowned armor stats before ownership is checked.

### P1

- Contribution threshold is 25% instead of required 5%.
- Contribution uses requested/configured damage rather than capped actual damage, allowing overkill inflation.
- Projectile share remote is spam-able/unvalidated.
- `BindToClose` does not itself save players.
- `SFX:Play3D(Vector3)` parent bug.
- `MobLib` touch-damage cooldown is keyed by player globally, so contacts from multiple mobs share one 0.5s gate.
- AI uses direct `Humanoid:MoveTo` only; acceptable for simple open fields but likely fragile in cluttered maps.

## Recommended extraction strategy

Do not fork the whole kit and patch indefinitely.

Use the original RBXLX as immutable reference and build a Sword Growth RPG-owned vertical slice around the pieces that fit:

`HumanoidAttributes + MobConfig pattern + MobClient + simplified MobLib/AI + Fountain presentation + FormatNumber/Tween/Maid/Signal`

Then replace the valuable-state systems:

`Combat authority + Sword progression + Reward contribution + Save schema + Portal authority + Rebirth + Health Training + Aura`

First playable route:

`Starting Town spawn -> Healing Fountain -> first field -> 3-5-hit normal mob -> server-validated reward -> Sword Level increase -> level gate -> death -> Starting Town respawn`

Do not add inventory/armor/shop/ranged systems unless a later proven design requirement needs them.

## Validation status

- Static structure audit: DONE
- All 47 script sources inventoried and individually classified: DONE
- Security-pattern scan: DONE
- Critical combat/save/AI/transport code manually inspected: DONE
- Studio clean boot: NOT YET VERIFIED BY THIS AUDIT
- Runtime route/playtest: NOT YET VERIFIED
- Mobile behavior: NOT YET VERIFIED
- Multiplayer/security exploit replay: NOT YET VERIFIED

Therefore this audit supports an implementation decision, but does not claim the kit or resulting game is Studio-validated or production-ready.
