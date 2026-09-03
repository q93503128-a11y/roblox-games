# Monster Factory Simulator — Visual Rebuild 005 Audit

Date: 2026-09-03

## Goal

Move the HUD from a visually restyled prototype toward a simulator-style card system that can later accept sanitized external GUI art without rewriting gameplay logic.

Visual Rebuild 005 focuses on:

- hierarchy,
- card readability,
- semantic icon slots,
- shop/reward/world/monster presentation,
- action feedback,
- keeping all economy/progression authority on the server.

## 1. Semantic icon contract

Added:

`src/ReplicatedStorage/Shared/UIVisualContract.lua`

The contract defines semantic slots for:

- Cash
- Collector
- Gems
- Production
- Friends
- Rebirth
- Equip Best
- Monsters
- Worlds
- Quests
- Achievements
- Shop
- Rewards
- Index
- Collect
- Hatch
- Upgrade
- Monster cards
- World cards
- Quest cards
- Achievement cards
- Product cards
- Reward cards
- Index entries

Every slot currently has:

- a fallback glyph,
- a canonical accent color,
- an empty optional image field.

### External UI rule

The contract explicitly keeps Creator Store runtime loading disabled.

A future sanitized GUI-art intake may assign project-owned image IDs to the semantic slots after manual Studio review.

The interface does **not** call `require(assetId)`, `InsertService`, HTTP, or Creator Store assets at runtime.

## 2. VisualRefresh 005

`VisualRefresh.client.lua` was replaced in-place.

No `VisualRefresh005.client.lua` stacking file was created.

### Top resource bar

The six live resource labels are wrapped in individual stat cards with:

- semantic icon slots,
- compact dark panels,
- accent borders,
- automatic value pulse when the underlying text changes.

### Side navigation

Collection/progression navigation now uses compact icon+label buttons instead of plain text rectangles.

Left group:

- Equip Best
- Monsters
- Zones
- Quests
- Achievements

Right group:

- Shop
- Rewards
- Index
- Rebirth

### Primary actions

Collect / Hatch / Upgrade remain the dominant bottom actions.

They now have:

- larger semantic icon slots,
- stronger accent treatment,
- press scale feedback,
- click rings,
- server-result feedback text when a corresponding state change is observed.

## 3. Modal/card treatment

The following existing gameplay windows keep their original functional controller but receive one consistent presentation contract:

- Shop
- Monsters
- Zones
- Quests
- Rewards
- Achievements
- Index

Each modal receives:

- header icon,
- contextual subtitle,
- accent strip,
- one-modal-at-a-time behavior,
- dimmed world layer,
- BlurEffect while open,
- common dark panel/card language.

### Dynamic scrolling entries

Direct scrolling entries are automatically decorated with:

- semantic icon slot,
- gradient card body,
- left-aligned information hierarchy,
- status badge where appropriate.

Examples:

- Shop: `DEV` / `BUY`
- Worlds: `HERE` / `GO` / `LOCK`
- Rewards / Quests / Achievements: `CLAIM` / `DONE`
- Index: `FOUND` / `?`

Monster inventory frames use the same card vocabulary while retaining their original Equip/Fuse controls and remote behavior.

## 4. Feedback layer

Visual Rebuild 005 adds client-only presentation feedback.

### State-driven feedback

`StateUpdated` is observed for presentation only.

When the authoritative state reports a real change:

- generator level increase -> `PRODUCTION UPGRADED`
- successful collect pattern -> floating Cash gain
- production increase -> production delta feedback

### Monster feedback

`MonsterStateUpdated` is observed for `HatchCount` changes.

A real hatch-count increase produces:

- `NEW WORKER!`
- `MONSTER HATCHED`

### Toast-derived feedback

Existing server toast messages can produce larger presentation feedback for:

- new world unlock,
- insufficient Cash,
- Shiny creation.

The legacy toast still exists; this layer does not own gameplay state.

## 5. Security / authority audit

Visual Rebuild 005 does not add a new state-changing remote.

It does not calculate or grant:

- Cash,
- Gems,
- monsters,
- upgrades,
- zone unlocks,
- rewards,
- rebirths,
- purchases.

The existing ClientBootstrap still sends requests through the existing RemoteEvents, and existing server services remain authoritative.

VisualRefresh 005 only:

- rearranges existing GUI objects,
- decorates dynamic GUI entries,
- listens to state events,
- plays client-side Tween/UI feedback.

## 6. Responsive behavior

The existing three presentation ranges remain:

- desktop,
- <=900 px,
- <=560 px.

At smaller widths:

- stat bar scales down,
- side docks scale down,
- bottom actions scale down,
- modal width expands toward the available viewport,
- brand lockup hides before it competes with stat cards.

Short-height screens also reduce side/action scale.

## 7. External GUI intake readiness

The approved design-intake candidate remains:

Creator Store asset `130347426228193` — `GUI Asset Pack!`

It is not loaded by runtime code.

When manually sanitized in Studio, useful visual pieces can be translated into the semantic slots defined by `UIVisualContract.lua` rather than copied ad hoc into gameplay code.

This is important because a later art replacement should change presentation without changing:

- button callbacks,
- remote names,
- server validation,
- economy logic,
- save data.

## 8. Known transitional debt

`ClientBootstrap.client.lua` is still the functional constructor/controller for the legacy HUD.

`VisualRefresh.client.lua` owns the presentation adapter on top of those functional objects.

This is intentional for the current milestone because it avoids rewriting all working gameplay callbacks during the visual pass.

Future cleanup should eventually split the client into:

- UI construction/presentation,
- state binding,
- gameplay actions,
- worker/world presentation.

That cleanup should happen as a deliberate refactor rather than by stacking more visual scripts.

## 9. Validation status

Static integration complete.

Studio runtime validation is intentionally deferred until the current grouped visual/content batch reaches the next useful test point.

Do not claim Visual Rebuild 005 as visually approved until it has been observed in Roblox Studio at desktop and mobile/narrow viewport sizes.
