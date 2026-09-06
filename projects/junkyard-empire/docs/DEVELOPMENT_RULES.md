# Junkyard Empire — Development Rules

> Status: Canonical production rules
> Date: 2026-09-06

This file defines **how** Junkyard Empire is built. The purpose is to prevent a fast-production Roblox project from degrading into free-model spaghetti, duplicated scripts, unsafe economy code, or an untestable Studio state.

These rules apply to ChatGPT, Codex CLI, Roblox Studio MCP work, and manual edits.

---

# 1. Start every work session from current truth

Before meaningful work:

1. read current GitHub `main` for this project;
2. read at minimum:
   - `README.md`
   - `docs/GAME_DESIGN_FULL.md`
   - `docs/ROADMAP_AND_STATUS.md`
   - `docs/PROJECT_STATE.json`;
3. if Studio work is needed, query the **actual currently open Studio instance** through MCP;
4. inspect existing DataModel/services/scripts before creating replacements;
5. do not trust an old chat message or old handoff SHA as latest truth.

If GitHub docs and Studio disagree, stop and identify which side contains newer intended work before destructive edits.

---

# 2. Workflow: Studio-first, not Studio-only

Chosen direction:

```text
Studio MCP + Codex CLI
          ↕
      Roblox Studio
          ↕
Git project documentation / synchronized source
```

Studio-first means geometry, asset placement and playtesting may happen directly in Studio.

It does **not** mean important logic is allowed to exist only as an undocumented mystery in one local Place.

Required continuity:

- gameplay source must be synchronized/exported into the project repository once the source workflow is established;
- changes to architecture or DataModel layout must be reflected in docs/status;
- after meaningful batches, update `PROJECT_STATE.json` and `ROADMAP_AND_STATUS.md`;
- imported external art must be recorded in `ASSET_SOURCES.md`.

Do not introduce Rojo solely out of habit. If Script Sync proves insufficient, document the concrete reason before switching workflow.

---

# 3. Codex / MCP operating protocol

## 3.1 Inspect before modify

Codex must first inspect relevant objects/scripts rather than guessing their names.

Bad:

> Create a new EconomyService because there probably isn't one.

Good:

> Inspect ServerScriptService and ReplicatedStorage for current economy ownership. Reuse or cleanly replace the canonical implementation; do not leave two economy owners.

## 3.2 Explicit Studio target

If multiple Studio instances are open, identify the intended one before modifying anything.

Never assume the first returned Studio is correct if there is ambiguity.

## 3.3 Group work into coherent batches

Prefer:

- one small architecture batch;
- one gameplay route batch;
- one visual/asset batch;
- one bugfix batch.

Avoid random changes across unrelated systems in one prompt.

## 3.4 Verify changes in Studio

A response that says “implemented” is not sufficient.

For gameplay changes Codex should, where practical:

1. inspect resulting Instances/scripts;
2. enter Play mode;
3. exercise the relevant route;
4. inspect Output/errors;
5. report what was actually observed;
6. record remaining limitations.

## 3.5 Do not hide failed tests

If MCP cannot perform a required interaction reliably, state it clearly and define the human test that remains.

Never report a human-visible feature as verified merely because the code exists.

---

# 4. Code ownership and architecture

## 4.1 Server owns valuable state

Server must own/validate:

- Cash;
- scrap collection acceptance;
- scrap value;
- backpack capacity state that affects rewards;
- factory purchases;
- machine ownership;
- zone unlocks;
- prestige/company sale;
- daily rewards;
- quest rewards;
- monetization fulfillment;
- save writes.

Client may request actions and render state, but does not decide the reward result.

## 4.2 Central data definitions

Repeated content should use catalogs/configs, not repeated scripts.

Expected data domains:

- ScrapCatalog
- ZoneCatalog
- UpgradeCatalog
- MachineCatalog
- RarityConfig
- MonetizationConfig
- QuestCatalog
- BalanceConfig

Exact filenames may change, but the principle does not.

## 4.3 One owner per system

There should be one canonical owner for each of:

- plot assignment;
- economy;
- scrap spawning/collection;
- inventory/backpack;
- factory progression;
- save/profile;
- monetization receipt handling.

Do not “fix” a system by adding another Script that competes with the old one.

## 4.4 Avoid monoliths

Do not put the whole game in one ServerScript.

Prefer small services/modules with clear responsibility and an obvious bootstrap path.

## 4.5 No patch pile

When replacing a bad implementation:

- identify all call sites;
- migrate deliberately;
- delete or disable the obsolete path;
- verify only one implementation remains.

Do not keep `Old`, `New`, `New2`, `Final`, `FinalFix` scripts in production hierarchy.

---

# 5. Remote security

Every RemoteEvent/RemoteFunction with valuable effects must validate as appropriate:

- argument type;
- finite numeric ranges;
- player ownership;
- distance/proximity where relevant;
- current progression/prerequisite;
- cooldown/rate limit;
- item/upgrade ID membership in server catalog;
- current state transition legality.

Examples:

### Scrap pickup

Client must not send “give me Legendary item worth 1,000,000.”

Server identifies/validates a real collectible or server-generated collection result.

### Purchase

Client sends purchase intent / upgrade ID. Server looks up canonical cost and verifies prerequisites and Cash.

### Prestige

Server calculates eligibility and reward. Client does not provide the resulting multiplier.

---

# 6. Save-data rules

Do not scatter raw DataStore calls across gameplay scripts.

Use one persistence layer/service.

Requirements before public release:

- schema version;
- migration path;
- safe handling of missing/new fields;
- autosave strategy;
- PlayerRemoving/server shutdown handling;
- no saving Instances;
- no trusting client save payloads;
- idempotent purchase fulfillment where required;
- failure/retry behavior documented;
- Studio tests must not accidentally corrupt production data.

Current logical schema is defined in `GAME_DESIGN_FULL.md`.

Persistence library/implementation remains a documented decision, not an accidental dependency.

---

# 7. Economy implementation rules

All economy numbers come from canonical configuration/data.

Do not hardcode the same price/value in:

- 3D purchase pad;
- UI text;
- server logic;
- client logic;

separately.

The UI/world reads canonical replicated display data; server uses canonical authoritative data.

Every source and sink should be identifiable.

Typical sources:

- processed scrap;
- quests;
- daily reward;
- monetization products.

Typical sinks:

- factory upgrades;
- player capacity/tool upgrades;
- zone unlocks;
- later cosmetics if Cash-purchasable.

Before broad content production, test for runaway inflation and progression dead zones.

---

# 8. Asset import policy

External assets are expected and encouraged for this project, but **untrusted code is not**.

Before use:

1. record creator/source/asset ID or source URL;
2. insert into a quarantine area when practical;
3. inspect descendants;
4. search for:
   - Script
   - LocalScript
   - ModuleScript
   - suspicious `require(number)`
   - HTTP calls
   - loadstring-like patterns
   - InsertService use
   - hidden remotes/admin loaders
   - unexpected constraints/welds;
5. remove all unnecessary scripts;
6. normalize collisions/anchors/pivots;
7. check scale;
8. check visual fit;
9. record accepted modifications in `ASSET_SOURCES.md`.

### Rule of thumb

Use external **appearance** freely after review.
Use external **gameplay code** only as audited reference or intentionally adopted dependency.

Never import a free tycoon kit and allow it to silently become the game's economy architecture.

---

# 9. Visual assembly rules

The project does not require custom high-end art, but it must not look broken.

Minimum requirements:

- no floating props caused by bad pivots;
- no obvious z-fighting;
- no unintentional neon/legacy-material mismatch;
- no detached model pieces;
- collision matches visible walkable surfaces;
- decorative parts do not block expected navigation;
- repeating asset packs are recolored/recomposed enough to avoid looking like untouched toolbox dumps;
- scale between trucks, doors, machines and avatar is believable;
- static decoration is anchored;
- unnecessary collisions are disabled;
- lights/VFX are bounded.

Prefer coherent composition over asset quantity.

---

# 10. Physics and performance

Avoid solving factory visuals with unlimited physical parts.

Rules:

- do not spawn endless loose scrap parts;
- pool/reuse repeated visual items where useful;
- cap simultaneous visible conveyor items;
- server state may simulate value/jobs without one physical object per unit;
- avoid per-object Heartbeat/RenderStepped connections when a manager can update many objects;
- disconnect events on cleanup;
- destroy temporary effects;
- static environment should be anchored;
- use collision groups where helpful;
- investigate StreamingEnabled when world size justifies it, not automatically.

Performance tests later must include a busy server state, not only an empty place.

---

# 11. Plot system rules

Plot assignment must be authoritative and robust.

Required behavior:

- one active plot per player;
- no two players own one plot simultaneously;
- plot resets/cleans when player leaves;
- progression restoration applies only to owner;
- neighboring players cannot trigger paid upgrades on someone else's plot;
- plot references do not depend on player display name;
- respawn does not create a duplicate plot;
- joining after another player leaves can reuse a clean plot.

If server is full, handle the condition deliberately.

---

# 12. Scrap spawning rules

Spawn system should be centralized.

Requirements:

- zone-specific pools;
- rarity weighting server-side;
- max active scrap cap;
- cleanup when abandoned/invalid;
- deterministic enough to debug;
- no reward duplication from double-triggering;
- collection lock/claim during interaction;
- fast respawn tuning for crowded servers.

The game may later use per-player or shared pickups, but the chosen ownership model must be documented because it changes fairness and server load.

---

# 13. UI production rules

UI must be functional before decorative.

## Required order

```text
information hierarchy
→ wireframe
→ responsive layout
→ interaction
→ visual polish
```

Rules:

- mobile first;
- no mouse-hover requirement;
- minimum practical touch target size;
- no overlapping Roblox topbar/core controls;
- use scale/constraints thoughtfully, not fixed desktop-only offsets;
- large numbers use consistent abbreviation;
- close/back behavior consistent;
- one canonical token set for typography, corner radius, spacing and button states;
- avoid 8 permanent HUD buttons at launch;
- no popup immediately demanding Robux.

World-space purchase information is preferred where it reduces HUD clutter.

---

# 14. Monetization implementation rules

All Marketplace ownership/receipt logic is server-controlled.

Developer Product fulfillment must be idempotent and follow Roblox receipt handling requirements.

Do not:

- award product based only on client `PromptProductPurchaseFinished`;
- hardcode product IDs across UI scripts;
- automatically open purchase dialogs repeatedly;
- create fake limited stock;
- use false discount claims;
- hide the actual cost behind misleading UI;
- block the first core loop behind payment.

Monetization design canon: `MONETIZATION_AND_ECONOMY.md`.

---

# 15. Mobile-first interaction rules

Every P0 gameplay action must be testable on mobile-equivalent input.

For V0.1:

- scrap pickup should work through standard touch-friendly prompt;
- purchase pads require no precision clicking;
- core HUD remains readable on narrow screens;
- backpack feedback is visible without covering center screen;
- no mandatory keyboard hotkeys;
- movement path around factory has enough space for touch movement.

Desktop convenience may be added, but mobile cannot be a second-class port.

---

# 16. Testing discipline

## 16.1 Test layers

### Edit-mode inspection

- required Instances exist;
- no obvious duplicate services;
- imported assets sanitized;
- scripts enabled/located correctly.

### Solo Play

- clean spawn;
- plot assignment;
- collect;
- unload;
- process;
- purchase;
- respawn/reset;
- UI.

### Multiplayer

Required before public release:

- two+ players claim separate plots;
- one player cannot steal another's upgrades;
- shared scrap behavior is correct;
- friend bonus logic if enabled;
- player leave/rejoin cleanup.

### Persistence

- clean profile;
- save;
- simulated restart/new session;
- restored upgrades/collection;
- schema migration test when schema changes.

### Monetization

- ownership checks;
- product receipt success;
- duplicate receipt safety;
- failure path.

---

# 17. P0 vertical-slice acceptance route

The first slice must pass this route:

```text
Play
→ player spawns safely
→ yard assigned
→ scrap visible
→ scrap collected
→ backpack state changes
→ unload accepted
→ factory shows processing
→ Cash awarded once
→ first upgrade becomes affordable
→ upgrade purchased once
→ new machine/visual appears
→ next loop is measurably improved
```

Failure of any core step blocks the slice.

Do not call the slice finished because the map “looks complete.”

---

# 18. Error policy

Before user playtest:

- no known red Output errors on P0 route;
- no infinite yield warnings caused by normal flow;
- no nil spam;
- no repeated remote spam warnings;
- no obvious datastore error loop;
- no parts falling into void unexpectedly;
- no broken prompt after respawn.

Warnings with understood benign causes may remain only if documented.

---

# 19. Versioning / status updates

After each meaningful batch:

Update:

- `docs/ROADMAP_AND_STATUS.md`
- `docs/PROJECT_STATE.json`
- `README.md` when baseline/next validation point changes
- `ASSET_SOURCES.md` for asset changes
- design docs if the actual design decision changes.

Status must distinguish:

- planned;
- implemented;
- code-inspected;
- MCP-playtested;
- human-tested.

Never collapse these into one vague “done.”

---

# 20. Completion language

Use precise wording.

Good:

> Implemented and MCP solo-playtested through first upgrade; multiplayer and mobile human test remain.

Bad:

> Game finished.

A feature is not production-complete until required test layers pass.

---

# 21. Fast-production rule

If a feature is taking disproportionate effort, first ask:

1. Is it necessary for the core loop?
2. Can a standard Roblox interaction replace custom UX?
3. Can an external visual asset replace custom modeling?
4. Can the system be represented with data instead of custom scripts?
5. Can it be postponed until retention data justifies it?

The project deliberately values **simple systems polished enough to ship** over impressive systems that delay the game indefinitely.

---

# 22. Reusable-framework boundary

Long-term, this project may become the basis for other themed tycoons.

But do not prematurely build a universal framework.

Only generalize code when:

- the Junkyard implementation is stable;
- at least two real use cases need the abstraction;
- abstraction does not slow current iteration.

First make Junkyard Empire work. Then extract proven modules.

---

# 23. Current next implementation contract

The first Codex Studio build must stay small:

1. inspect current Studio DataModel;
2. create a clean project namespace/folder/service skeleton;
3. greybox one personal yard and one starter scrap field;
4. implement server-authoritative Cash;
5. implement a tiny scrap catalog;
6. implement collection + backpack;
7. implement unload/process result;
8. implement one purchase pad and one visible upgrade;
9. add minimal HUD;
10. Play-test the complete route;
11. report exact observed results;
12. update project status docs.

Do not add rebirth, daily rewards, large shops, 30 scrap items, or paid products in this first implementation batch.
