# Minimal architecture / persistence
Status: DESIGN, not implemented. Catalog: [spec](specs/first-slice.catalog.json). Profile example: [schema v1](specs/profile-v1.example.json).

## Five server domain modules
| Module | Owns |
|---|---|
| ProfileService | Provider adapter, load/validate/session lock/save/close, per-player mutation queue, profile revisions |
| EnemyService | Socket registry, shared HP, spawn generation, Alive→Dying→Respawning lifecycle, contributor ledger |
| CombatService | Intent validation, cooldown/windup, one target damage, hit acknowledgement |
| ProgressionService | Death reward transaction, Coins, weapons/duplicate levels/equipment, personal Zone unlock |
| PetService | Egg validation/roll/grant, pet UID ownership, equip/Equip Best/release |

One server bootstrap wires modules and network handlers; no generic framework/service discovery/container. It never generates the essential floor at runtime.
Shared modules: Catalog + English Strings + Protocol definitions/derived-stat pure helpers.
Three thin client controllers: Input/Target, UI state, Presentation (weapon/pet visuals/VFX/audio). UI components may be local helpers; do not create a service per button.

Future tree:
- Workspace/SlayAndLoot/Worlds/World1/Zones/{Greenvale,GoblinCampPreview}/...
- ServerScriptService/SlayAndLoot/{Bootstrap,ProfileService,EnemyService,CombatService,ProgressionService,PetService}
- ServerStorage/SlayAndLoot/ApprovedAssets — sanitized project subset only
- ReplicatedStorage/SlayAndLoot/{Catalog,Strings,Protocol,Remotes}
- StarterPlayerScripts/SlayAndLootClient and StarterGui/SlayAndLootUI

Names describe planned ownership, not instances already present. No runtime source or sync manifest is created in this Foundation pass.

## Authority
Server: HP, valid damage, cooldown, RNG, participation, all inventory/Coins/XP, equipment, Zone access, durable state.
Client: input intent, target highlight, predicted swing, render-only pets, panels and local cosmetic reward flight.
Do not accept client damage, enemy death, pet bonus, price, rarity roll, owner user ID or full save payload.
Tool/model appearance is derived from server equipment. Respawn rebuilds it; neither Backpack contents nor cloned model values prove ownership.
Shared catalog visibility is safe; changing a local copy cannot change server evaluation.

## Intent protocol
Native reliable RemoteEvents: Request (client→server), State (server→owner), Event (server→owner or scoped observers for combat).
No server InvokeClient, custom networking package, per-frame full profile broadcast, or client-chosen player ID.

Request envelope: {sessionNonce, seq, action, payload}.
Server creates per-join nonce; seq is a strictly increasing safe integer. Cache recent 32 processed request results. A replay returns its cached acknowledgement or REPLAY_EXPIRED; never reruns a mutation. A seq gap requests resync. Old-session nonce is rejected, including after rejoin.
Sequence validation and reservation occur before async work; ordered per-player queue prevents hatch/unlock/leave races. Old nonce/session caches are released at close. Finite values, shallow payload depth, ≤8 keys, bounded ID strings ≤64 chars.

| Action | Payload | Server context |
|---|---|---|
| Attack | enemyId + generation | active profile/character, owned equipped weapon, target alive/unlocked zone, distance/LOS, cooldown |
| EquipWeapon | weaponId | owns definition |
| EquipBestWeapon | empty | recompute current effective DPS |
| Hatch | eggId | unlocked zone, ≤12 studs, capacity, 30 Coins, server roll |
| EquipPet / UnequipPet | petUid | ownership, unique slot, ≤3 |
| EquipBestPets | empty | derive top 3 bonuses from owned UIDs |
| ReleasePet | petUid | ownership, unequipped, user has confirmed in UI |
| UnlockZone | zoneId | valid prerequisite, ≤12 studs from gate, Coins or already unlocked |
| Resync | empty | rate limit, owner-only snapshot |

Initial ingress budgets per player: Attack 5/sec burst5 (actual swings still ≥0.6s); Hatch/Unlock 2/sec burst2; equipment/release 8/sec burst8; Resync 1/sec burst2. These are tunable guards, not monetization or game speed.
Reject unknown actions/payload keys, malformed/oversized values and nonfinite numbers before expensive work. Return typed error codes with English UI strings; rejection creates no Coins/item changes.

State packets: full owner snapshot on ready/rejoin and resync, then revisioned deltas. Client applies only next revision; a gap triggers resync. Reopening UI renders current state, not a saved panel copy.
Enemy state uses enemy ID+generation+version separately from per-profile revisions. Enemy HP presentation can batch at ≤10Hz; personal reward results must remain reliable.
Predicted swing does not predict/grant inventory. Hits are acknowledged by attack ID for one effect; repeated acknowledgements do not replay rewards.

## Enemy / combat lifecycle
Each authored socket has a stable socket ID. Each spawn gets a new generation. Requests for dead/stale generations fail.
Basic attack: one target, 0.6s interval, 0.18s active window start. Reserve attack on server, then recheck target generation, ownership, distance ≤9 studs, vertical separation ≤6, zone access and LOS at the active frame. Derived damage uses the same catalog formula as UI.
No client-reported latency time can expand distance/cooldown. Current server-observed player position is a plausibility input, not an assertion of a complete movement anti-cheat solution.
Targets stay near their authored sockets; visual flinch is non-authoritative. Static anchored hit proxies and server-owned HP avoid client enemy physics authority. Models do not physically obstruct main paths.

Ledger key: (server session, socketId, generation, userId). Credit actual HP removed, cap overkill at remaining HP.
On death eligible players need:
- active profile + living character;
- ≥2% of that enemy's max HP credited;
- last valid hit ≤15s ago;
- within 80 studs and allowed zone at death.
Every eligible player gets full Coins + an independent personal one-weapon roll. No last-hit priority.
Mark generation Dying/reward-claimed once before grants; serialize each owner's reward mutation without yielding. Reentrant death/hit events cannot grant twice. Leave/close cancels eligibility; never change another player's profile.
This is once-per-death within the active server session, not a promise of crash-proof distributed exactly-once storage.

## Atomic domain transitions
Single active per-player profile owner:
- Kill: calculate eligible result → mutate Coins + weapon XP/pity/discovery together → bump revision → notify.
- Hatch: validate → roll server-side → assign UID → deduct Coins + add pet/discovery together → revision/result.
- Unlock: validate → deduct Coins + set unlock together → revision/result; already unlocked returns ALREADY_UNLOCKED with zero charge.
- Invalid/replayed requests: no partial mutation or RNG reward.
No network/DataStore await inside the in-memory commit. Actual durability follows the provider save lifecycle; a revision acknowledgement means applied in session, not necessarily saved to disk.

## Personal Zone Gate
For the first single gate, server-controlled character collision groups distinguish Zone2Locked/Zone2Unlocked against GateZone2; players do not collide with each other. Derive membership again on respawn. Local gate transparency/animation may differ per player, physical global gate state must not be toggled for everyone.
Server zone membership/progression checks still deny locked players' combat/service requests after clipping/teleport exploits. Add boundary recovery to the approach anchor for locked entrants; log/reject, no automatic permanent ban.
Do not call UnlockZone from merely walking into its trigger. Show cost and explicit Unlock action.

## Persistence provider / dependency
Selected integration candidate: [MadStudioRoblox/ProfileStore](https://github.com/MadStudioRoblox/ProfileStore).
Upstream metadata verified 2026-10-30: non-archived, Apache-2.0, observed main commit **45c9847cbcf1fc260369c50eb335aba7c35aecdd**, pushed 2025-07-31.
This pins the review target; source integration/audit and runtime tests are PENDING. Keep LICENSE/NOTICE obligations when vendoring; never runtime require an asset ID.
Prefer its session lifecycle behind ProfileService over inventing a new locking algorithm. No ProfileService legacy package, Knit, ECS or event-bus framework.
Built-in DataStoreService/native remotes/Input Action System/Tools/ProximityPrompt/UI layouts were considered first. Feature Packages for missions, season passes, bundles or login rewards do not solve the present duplicate-weapon loop; do not import them merely for reuse.

## Profile schema and storage
One player key: player:<UserId>, one profile document for Coins/weapons/pets/zones/discovery. Never split balances and inventory across independently saved keys.
Schema v1:
- integer Coins 0..1e12;
- unlocked zone ID map;
- weapon map keyed by definition, {level 1..10, duplicateXp}; XP below next threshold, MAX XP=0;
- equipped weapon ID must be owned;
- pet UID map to pet definition, equipped UID array ≤3 and unique;
- discovery maps;
- starter/tutorial flags and first-copy pity counter.
No Instances/CFrames, damage cache, active enemy targets, transient HP, nonce/seq or VFX timers saved.
Weapon levels belong to definition-level ownership by product design; pet copies need unique IDs. No future weapon-trading schema is implied.

Namespaces: Studio mock default; separate TEST Experience + SLAY_LOOT_TEST_V1 for durable tests; live SLAY_LOOT_PROD_V1 only after release gates. A second Place in the same Experience is not sufficient isolation because DataStores are shared per Experience.
No Studio API enablement/production reads or writes in this pass. Before any production adoption, inspect whether older namespaces actually contain data; do not infer absence from a blank DataModel. Old dungeon data never silently migrates into the new namespace.

Lifecycle: Loading → Active → Closing → Closed; load/schema/provider failure → Failed.
- Start profile session with cancellation if player leaves during load.
- Reconcile only known missing defaults; verify schema/types/finite values, IDs, XP invariants, UID ownership before enabling actions.
- Future/unknown schema: fail closed with DATA_UNAVAILABLE; do not overwrite. Unknown item IDs: retain raw evidence for a versioned migration/recovery, disable affected gameplay; never silently delete them.
- Another live session owns the key: wait/retry according to pinned provider lifecycle; never casually force-steal. Session lost: stop actions immediately, close/disconnect safely.
- Server owns an in-memory profile and uses provider autosave; no per-hit DataStore calls and no additional overlapping save loop.
- Listen for actual save failure/critical status, show appropriate save status and retry according to provider. Do not label in-memory changes Saved.
- Removing/BindToClose: stop new transactions, drain accepted in-memory work, end session and allow provider flush within platform time limits. No guaranteed save on machine crash.
- Ordinary session progress can lose the last autosave window in a hard crash; document measured window. No paid purchases/trading in V1.
- v1 needs no dungeon migration. Future v1→v2 migrations must be deterministic, fixture-tested and backed by recovery/version history before release.

## Cleanup / performance
Release player/profile refs, connections, pending attack tasks, UID visual models and ledger entries on leave/respawn/death generation changes.
One shared coarse enemy lifecycle scheduler is enough. Pets follow locally; do not stream per-frame pet CFrames from server. Cap/coalesce damage numbers and other-player VFX.
StreamingEnabled is currently true. Use logical IDs and resilient instance binding; do not disable it globally to hide nil errors.
Targets: desktop 60fps, low-tier mobile 30fps; these are test goals, not measured results. Capture 8-player/11-enemy/24-pet worst-case baseline, 10-minute memory trend and 10 reopen/respawn cycles.

Official references checked 2026-10-30: [Data stores](https://create.roblox.com/docs/cloud-services/data-stores), [client/server boundary](https://create.roblox.com/docs/scripting/security/client-server-boundary), [Feature Packages](https://create.roblox.com/docs/resources/feature-packages). Exact provider API/version and current engine APIs must be rechecked at implementation.
