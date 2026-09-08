# Rebirth RPG — Reference Structure Matrix 001

> date: 2026-09-08
> purpose: extract reusable structural patterns from a broad Roblox RPG / action RPG / progression sample
> rule: copy structure, not surface identity or IP/theme

## 1. Why this exists

The project should not depend on a tiny set of famous RPGs. We should sample across:
- mainstream action RPGs
- smaller/less-famous RPGs
- dungeon RPGs
- open-world RPGs
- simulator/incremental games with useful prestige loops

The question is not "which game should we clone?" but:
- which control conventions reduce confusion?
- which inventory/equipment structures make drops readable?
- which progression structures create fast early reward cadence?
- which Rebirth/Prestige structures compress old content without making combat complicated?

## 2. Current sampled references

### Levelbound
Official Roblox page observed 2026-09-08.
Public controls:
- LMB attack
- F block
- Q dash
- E class skill
- 1/2/3 skills
- 4/5 potions

Useful:
- basic attack stays on LMB
- mobility gets a dedicated key
- combat skills live in explicit slots
- bottom combat UI should communicate the same structure

Do not copy:
- class roster
- exact economy/content

### Vesteria
Community-documented keybind system.
Observed structure:
- configurable keybinds
- separate inventory, interaction, pickup, quest log, skill menu
- 1–0 hotbar slots

Useful:
- interaction and combat responsibilities should be visually/functionally distinct
- eventual remappable controls are valuable
- hotbar and inventory are separate concepts

### Elemental Odyssey
Community-documented controls.
Observed:
- Q dash
- E interact
- F block
- dedicated move keys
- keybind customization

Useful:
- E as interaction is a strong convention in Roblox action games
- movement/combat/interaction should not compete for one key

### Arcane Odyssey
Community-documented UI/inventory structure.
Observed:
- inventory has equipment slots and item grid
- rarity-coded items
- sort/filter/search
- equipped stat summary
- draggable/saved hotbar ordering
- vanity/stat equipment separation

Useful now:
- inventory must visibly show ownership and equipped state
- item grid + detail/compare panel is clearer than a hidden server state
- equipped weapon should exist both as data and visible character equipment

Defer:
- large vanity/relic depth until core proves itself

### Sword Blox Online: Rebirth
Official Roblox page observed 2026-09-08.
Public structure:
- interconnected floors
- bosses and zone progression
- large item catalog
- long-term progression

Useful:
- region/floor milestones can make long growth easy to understand
- content breadth can grow later without changing the basic kill/loot/equip loop

### Dungeon Quest / Dungeon Quest Reborn family
Public structure:
- compact repeated dungeon loop
- boss climax
- rare gear reward

Useful:
- boss/reward climax after a short combat loop
- rare loot should be visually obvious

### RPG Simulator
Official Roblox page observed.
Public structure:
- zone progression
- raids
- loot
- long level ceiling

Useful:
- simple zone ladder can support long-term growth
- raids are later breadth, not first-slice complexity

### Weapon Fighting Simulator
Official Roblox page observed 2026-09-08.
Public structure:
- monsters -> coins/skills
- stronger weapons
- new worlds
- world bosses

Useful:
- world unlocks and visible power gain can be understood with almost no tutorial
- simulator cadence is relevant to our brain-off RPG goal even if combat presentation stays RPG-like

### Rebirth / prestige simulator patterns
Multiple public Roblox pages show recurring patterns:
- Rebirth is a visible UI action, not a hidden combat key
- permanent multipliers or special currency often survive the reset
- new islands/worlds/features unlock at Rebirth milestones

Useful:
- Rebirth should be a menu/progression action with clear requirements and confirmation
- repeated cycles must visibly shorten old progression
- milestone unlocks are more motivating than a number-only reset

Do not import by default:
- pet systems
- excessive currencies
- giant boost shops
- auto-play layers

## 3. Control contract for this project

Current target, subject to Studio Agent conflict inspection:

```text
M1 = basic attack chain
Q = dash / combat mobility
E = interact / talk / chest / portal / world action
1 = current first active weapon skill
2–4 = reserved future skill slots, not required at Slice start
F = possible later block/secondary defensive action only if actual combat needs it
Rebirth = UI/menu only, no R hotkey in production
Inventory = visible bag button + one conflict-safe keyboard shortcut selected after Studio inspection
```

Rules:
- every input must have visible UI affordance where reasonable
- an input that looks identical to basic attack is not a valid "skill" presentation
- mobile gets equivalent action buttons
- avoid stealing default Roblox/UI keys without checking conflicts first

## 4. First-slice HUD contract

Persistent gameplay HUD should eventually include:
- HP state
- Level + XP bar
- Gold
- bottom/low-center skill/action slots
- cooldown visualization
- inventory/bag button
- current objective/next progression cue

Contextual states:
- enemy health/name presentation
- boss HP presentation
- loot/reward toast
- interaction prompt
- level-up feedback
- meaningful equipment-upgrade feedback

Do not expose every long-term system on the first 30 seconds.

## 5. Inventory/equipment contract

Use Godbase separation:

```text
server persistent inventory
-> server authoritative equipment state
-> safe replicated view model
-> UI
-> derived character visual
```

First slice UI minimum:
- item grid
- rarity/readability
- equipped highlight
- mainhand equipment slot
- item detail panel
- damage/stat comparison for Weapon A vs B
- Equip action
- close/back behavior
- keyboard/touch/gamepad reachability

When Weapon B is equipped:
- server mainhand changes
- UI changes
- character hand visual changes
- respawn rebuilds the same visual from authoritative state

A hidden `weapon_start_b` string is not sufficient equipment presentation.

## 6. Combat presentation contract

Before asking the user to judge combat feel, basic attack needs:
- visible equipped weapon
- actual swing animation
- hit timing aligned with server hit window
- hit impact feedback
- readable enemy health change
- combo cadence

The current active skill must have a presentation difference from M1:
- distinct animation and/or motion
- stronger hit feedback
- clear cooldown slot

No need for deep combo tech.

## 7. Rebirth UX contract

Rebirth is progression UI, not a combat input.

Menu must show:
- requirement
- what resets
- what stays
- permanent multiplier/benefit
- next milestone unlock
- confirmation

Studio test builds must provide a Studio-only fast eligibility path so the tester never has to grind naturally just to validate the state transition.

Production players do not see the developer test action.

## 8. Structures worth reusing rather than reinventing

From Godbase/package roadmap, prioritize project implementations that can later become reusable:
- Inventory cell
- Item tooltip/detail panel
- Equipment slot
- Toast
- Confirm modal
- Currency display
- Mobile action button shell
- Health bar
- Interaction shell
- Loot pickup/reward feedback

Maturity starts EXPERIMENTAL. No immediate Godbase promotion.

## 9. First-session cadence target

```text
0–30 sec: movement + first visible target understood
<= 3 min: first meaningful loot/equipment change
5–10 min: stronger encounter + boss/reward climax
later: Rebirth path clearly visible/teased
```

Do not make the first Rebirth test depend on natural grinding during development.

## 10. Explicit rejects from the previous smoke-build presentation

Do not repeat:
- text-only internal HUD as user-facing RPG UI
- invisible weapons
- server inventory with no real inventory screen
- skill bound to a key but visually indistinguishable from basic attack
- Rebirth on R as a production control
- asking the user to judge feel from animationless graybox combat

The smoke build remains evidence for core runtime only, not a presentation baseline.
