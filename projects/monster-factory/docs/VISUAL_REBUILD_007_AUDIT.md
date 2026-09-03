# Monster Factory Simulator — Visual Rebuild 007 Audit

## Purpose

Visual Rebuild 007 removes the legacy two-stage HUD architecture.

Before this pass the client did this:

1. `ClientBootstrap.client.lua` built a large placeholder HUD and all dynamic UI,
2. `VisualRefresh.client.lua` searched that HUD after creation,
3. the second script reparented, resized and restyled the first script's UI.

That architecture was useful during the visual rescue passes, but it was not acceptable as the long-term canonical client structure.

## Canonical HUD architecture after 007

### Bootstrap

`src/StarterPlayer/StarterPlayerScripts/ClientBootstrap.client.lua`

The bootstrap now only resolves the client module folder and starts the HUD controller.

It no longer owns:

- UI construction,
- marketplace cards,
- monster cards,
- zone cards,
- quest/reward/achievement rendering,
- index rendering,
- worker-orb rendering,
- responsive layout,
- visual restyling.

### HUD view

`src/StarterPlayer/StarterPlayerScripts/Client/HUDView.lua`

Owns the canonical GUI tree and presentation primitives from first creation:

- `MonsterFactoryHUD`,
- top stat chips,
- collection/progression docks,
- Collect / Hatch / Upgrade primary actions,
- Shop / Monsters / Zones / Quests / Rewards / Achievements / Index windows,
- modal dim/blur,
- context offer card,
- toast and state-result feedback,
- responsive layout,
- semantic icon slots through `UIVisualContract.lua`.

No separate visual adapter is required afterward.

### HUD controller

`src/StarterPlayer/StarterPlayerScripts/Client/HUDController.lua`

Owns client state binding and player actions:

- existing RemoteEvents/RemoteFunctions,
- economy label binding,
- current capsule/Hatch text,
- monster inventory rendering data,
- zone unlock/travel actions,
- quest/reward/achievement claim actions,
- Monster Index population,
- marketplace prompts,
- contextual offer state,
- onboarding state.

The controller sends requests through the same existing server-authoritative Remotes. It does not grant Cash, monsters, rewards, zones, upgrades or purchases locally.

## Removed legacy architecture

`VisualRefresh.client.lua` was deleted.

The previous 28k+ `ClientBootstrap.client.lua` UI/controller monolith was replaced with a minimal bootstrap.

Therefore these old runtime stages no longer exist:

- create placeholder left/right UI,
- create placeholder top bar,
- create generic unstyled windows,
- spawn worker orb placeholders,
- search controls by their displayed text,
- reparent those controls into a visual shell,
- restyle every newly created descendant after the fact.

## Worker rendering relationship

Visual Rebuild 006 remains authoritative for worker presentation:

- `WorkerCharacters.client.lua` consumes Monster/Zone state directly,
- `WorkerVisualFactory.lua` creates final procedural workers,
- no Worker orb handoff is created by the canonical HUD.

The old `applyWorkers` function disappeared when the monolithic Bootstrap was physically replaced in this pass.

## Hatch reveal relationship

`HatchReveal.client.lua` remains independent of the HUD controller and continues to:

- confirm a real server-side HatchCount increase,
- identify the newly added inventory UID,
- render the matching `WorkerVisualFactory` model in a ViewportFrame,
- keep Shiny Fusion separate from normal Hatch reveal.

## External GUI art contract

`UIVisualContract.lua` was promoted to contract version 2.

It still prohibits Creator Store runtime loading and now normalizes legacy lowercase stat slot names to canonical semantic keys.

Approved sanitized art can later replace slot `Image` values without moving gameplay callbacks or changing HUD controller logic.

## Preserved external GUI contract

The ScreenGui and major window names remain stable:

- `MonsterFactoryHUD`
- `Shop`
- `Monsters`
- `Zones`
- `Quests`
- `Rewards`
- `Achievements`
- `Index`

This preserves the current in-world guide's ability to locate the Zones window without coupling it to internal module implementation.

## Static review

Confirmed by repository structure after this pass:

- `VisualRefresh.client.lua` is absent,
- `ClientBootstrap.client.lua` is minimal,
- canonical HUD implementation lives under `StarterPlayerScripts/Client/`,
- no economy/progression server service was modified in 007,
- no new external runtime asset load was introduced,
- no replacement client-side authority was introduced.

## Runtime status

This is a static architecture pass and has not yet been certified by the next Studio runtime validation.

The next grouped Studio validation must specifically verify:

1. HUD boots with no client error,
2. all seven windows open/close,
3. in-world Worlds prompt still opens `Zones`,
4. Collect/Hatch/Upgrade still reach the server,
5. shop DEV states still render with IDs set to zero,
6. monster Equip/Fuse actions still work,
7. Hatch reveal still appears after a real hatch,
8. 360x640 / 390x844 / desktop layouts remain usable.
