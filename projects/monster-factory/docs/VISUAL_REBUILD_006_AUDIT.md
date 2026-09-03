# Monster Factory Simulator — Visual Rebuild 006 Audit

## Scope

Visual Rebuild 006 removes the runtime orb-to-character worker handoff and adds a dedicated hatch reveal presentation while keeping gameplay authority unchanged.

## Worker renderer refactor

### Before

The legacy client flow was:

1. `WorkerVisualService` built a dedicated worker visual state.
2. `ClientBootstrap.client.lua` received it.
3. `ClientBootstrap` created colored spherical worker placeholder Parts.
4. `WorkerCharacters.client.lua` detected those Parts.
5. The placeholder orb was parsed and replaced with a procedural character.

This created an unnecessary visual/state translation layer and left two client scripts sharing worker-render responsibility.

### Visual Rebuild 006

The active worker path is now:

1. `MonsterService` publishes canonical `MonsterStateUpdated` state.
2. `ZoneService` publishes canonical `ZoneStateUpdated` state.
3. `WorkerCharacters.client.lua` reads equipped inventory entries and current zone directly.
4. `WorkerVisualFactory.lua` creates the final procedural worker model at the correct `WorkerStation`.

No orb placeholder is required in the active runtime path.

## Legacy compatibility bridge

`WorkerVisualService.lua` remains because existing gameplay services still call `WorkerVisualService.PushState(player)`.

In Visual Rebuild 006:

- `PushState()` is intentionally a no-op.
- legacy `RequestWorkerVisualState` returns `nil`.
- `WorkerVisualStateUpdated` is no longer published by the service.

This prevents the old ClientBootstrap worker renderer from creating orb handoff objects while avoiding a risky cross-service dependency rewrite in the same visual pass.

### Remaining dead compatibility code

`ClientBootstrap.client.lua` still contains the old `applyWorkers` compatibility function and waits for the legacy worker remotes.

Because the bridge now returns no state and fires no worker visual events, that function is inert at runtime.

It should be physically removed when ClientBootstrap is split into smaller UI/controller modules. Do not add new behavior to that dead path.

## Shared worker visual factory

Added:

`src/ReplicatedStorage/Shared/WorkerVisualFactory.lua`

Responsibilities:

- maps Monster IDs to procedural visual families,
- creates the final Model/Root structure,
- owns rarity colors,
- owns Shiny highlight/halo treatment,
- optionally builds the in-world worker nameplate,
- is reusable by both world workers and UI previews.

This removes duplicated monster-shape definitions between different presentation features.

## Hatch reveal

Added:

`src/StarterPlayer/StarterPlayerScripts/HatchReveal.client.lua`

The reveal contains:

- centered reveal card,
- rarity-colored border and burst,
- ViewportFrame preview using the same `WorkerVisualFactory`,
- monster name,
- rarity,
- production bonus,
- stronger Epic / Legendary headline treatment,
- click/tap dismissal,
- queued reveal handling,
- responsive scaling down to narrow mobile viewports.

## Hatch correctness contract

The reveal does not assume that every newly granted monster is a hatch.

Current server flow publishes Monster state once from `GrantMonster`, then increments `HatchCount`, then publishes Monster state again.

`HatchReveal.client.lua` therefore:

1. seeds current inventory UIDs and HatchCount at startup,
2. records newly observed non-Shiny inventory items as pending candidates,
3. waits for an actual server-published `HatchCount` increase,
4. reveals the newest pending candidate only when that increase occurs.

This prevents Shiny fusion from being misidentified as a hatch reveal.

The reveal is presentation-only. It cannot create monsters, spend Cash, alter hatch odds, or change inventory state.

## Mobile behavior

The reveal card has a canonical desktop size of 430×520 and computes a viewport-based scale using available width/height.

The scale clamps down for narrow screens so the whole reveal remains visible around the 360×640 test class.

## Security / authority

No new state-changing RemoteEvent was introduced.

Visual Rebuild 006 only consumes the existing canonical Monster/Zone state already used by gameplay UI.

Server authority remains unchanged for:

- hatch validation,
- Cash spending,
- capsule odds,
- inventory grants,
- equip state,
- Shiny fusion,
- zone state,
- production bonuses.

## Files changed in this pass

Core code:

- `src/ReplicatedStorage/Shared/WorkerVisualFactory.lua` — added
- `src/StarterPlayer/StarterPlayerScripts/WorkerCharacters.client.lua` — rewritten as direct state renderer
- `src/StarterPlayer/StarterPlayerScripts/HatchReveal.client.lua` — added
- `src/ServerScriptService/Services/WorkerVisualService.lua` — retired into compatibility no-op

Documentation:

- `docs/VISUAL_REBUILD_006_AUDIT.md`
- README / CHANGELOG baseline updates

## Runtime validation still required

Visual Rebuild 006 has been statically reviewed but has not yet been executed in Roblox Studio.

When the grouped visual batch is next pulled, verify:

- no visible worker orb flashes during equip/state refresh,
- equipped workers appear on the six factory stations,
- zone travel rebuilds workers in the destination zone,
- Equip / Unequip / Equip Best refresh worker presentation,
- first free Meadow hatch shows one reveal,
- paid later hatches show one reveal each,
- Shiny fusion does not show a normal Hatch reveal,
- Common/Rare/Epic/Legendary preview models frame correctly,
- 360×640 reveal remains fully on-screen,
- no new red Output errors occur.
