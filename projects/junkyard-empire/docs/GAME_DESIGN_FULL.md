# Junkyard Empire — Full Game Design Canon

> Status: Initial canon
> Date: 2026-09-06
> Working title: **Junkyard Empire**

This document is the main design source of truth for the project. It exists so the game can continue coherently across new chats, Codex sessions, Studio sessions and future refactors.

---

# 1. Product goal

Build a **fast-to-produce, easy-to-understand, highly expandable Roblox tycoon/simulator** that can reach a publishable state without relying on original character modeling, difficult combat animation, cinematic map art, or bespoke high-end UI.

The game should create value through:

- immediate interaction;
- visible factory growth;
- frequent upgrades;
- rare-item excitement;
- collection completion;
- zone progression;
- automation;
- prestige/rebirth;
- social comparison;
- optional monetization that fits the loop.

The product goal is not to prove artistic originality. The goal is to create a **competent Roblox commercial game with a short iteration cycle**.

---

# 2. Player fantasy

> “I started with a tiny filthy scrapyard, and now I own an enormous automated junk-processing empire that turns ridiculous rare wreckage into absurd amounts of money.”

The fantasy must be visible in 3D. A veteran player's plot should visibly look more advanced, larger and richer than a new player's plot.

Numbers alone are not enough.

---

# 3. Audience and platform priorities

Primary platform priority:

1. mobile
2. desktop
3. tablet
4. gamepad/console if low-cost to support

Target behavior:

- short first session friction;
- casual players can progress without understanding complex systems;
- engaged players have collection and optimization goals;
- players can understand other players' progress by looking at their factory;
- a returning player immediately sees a next target.

No design may require mouse precision as the only usable interaction method.

---

# 4. Design pillars

## 4.1 Instant readability

A new player should understand the first loop through world layout and feedback rather than a long tutorial.

First visual chain:

```text
junk nearby
→ pickup prompt
→ backpack fills
→ unload/process marker
→ cash appears
→ purchase pad lights up
→ machine visibly appears
```

## 4.2 Visible growth

Every major purchase should change at least one of:

- factory silhouette;
- production flow;
- available path;
- carrying capability;
- item variety;
- processing speed;
- earning potential.

Avoid long sequences of invisible `+5%` upgrades.

## 4.3 Active + automated play

Active scavenging should provide:

- faster short-term progression;
- rare scrap;
- collection discoveries;
- choice of zone;
- occasional high-value moments.

Automation should provide:

- satisfying factory motion;
- baseline income;
- reduced repetitive labor;
- motivation to expand machinery.

Neither side should fully invalidate the other.

## 4.4 Collection aspiration

Rare junk is not just currency. The player should care about discovering it.

Reasons to collect:

- index completion;
- rarity flex;
- bonus first-discovery cash;
- museum/display possibility later;
- achievements/quests;
- zone-specific collections;
- event collections later.

## 4.5 Modular content

New content should usually be addable by data + visual asset rather than new architecture.

Examples:

- new scrap type;
- new zone;
- new machine tier;
- new daily quest;
- new factory cosmetic;
- new prestige reward;
- new limited event junk set.

---

# 5. Genre position

The project sits between old-school purchase-pad tycoon and modern collection simulator.

We intentionally reject two extremes:

### Not a pure old dropper tycoon

The player should have something useful to do besides wait for cash and step on pads.

### Not a complex management simulator

V0.x should not require:

- freeform factory layout editing;
- complex worker AI;
- detailed logistics graphs;
- deep stock accounting;
- difficult build controls.

The game uses authored upgrade positions to keep production and mobile UX simple.

---

# 6. Primary gameplay loop

```text
COLLECT
Player enters a junk zone and grabs scrap.

CARRY
Scrap consumes backpack capacity.

RETURN
Player returns to personal yard.

PROCESS
Scrap enters the factory processing line.

SELL
Processed value becomes Cash.

BUY
Player purchases machinery, capacity, tools or expansion.

UNLOCK
New junk zones and rarities become available.

PRESTIGE
At a major milestone the player sells the company and restarts with permanent bonuses.
```

The loop must remain understandable even when later systems are layered on top.

---

# 7. First-session timeline

These are tuning targets.

## 0–10 seconds

- spawn at/near claimed yard;
- camera faces first junk source and unload area;
- first objective text is one line maximum;
- no shop popup.

## 10–30 seconds

- collect first scrap;
- clear pickup feedback;
- backpack count visible.

## 30–60 seconds

- unload first scrap;
- processing animation or visible machine response;
- first Cash reward.

## 1–3 minutes

- first machine/upgrade purchase;
- purchase creates obvious 3D improvement;
- second upgrade becomes visible.

## 3–5 minutes

- uncommon/rare item or collection index introduced naturally;
- next zone visible or teased.

## 5–8 minutes

- meaningful factory expansion or new junk zone unlock;
- active collection feels faster because of first player upgrade.

## 8–15 minutes

- player sees multiple goals:
  - next machine;
  - next backpack/tool upgrade;
  - collection completion;
  - next zone.

## 25–40 minutes target

- first company sale/prestige becomes attainable for a focused new player.

If playtests show this is too slow or too fast, tune from measured time-to-choice rather than preference alone.

---

# 8. World layout

## 8.1 Server structure

Recommended initial structure:

- 4–6 personal factory plots per server;
- central/shared scavenging zone(s);
- clear sightlines from plots to progression landmarks;
- enough physical separation that factory motion does not become visual noise.

The exact player cap remains implementation-tunable based on performance.

## 8.2 Personal yard

Starter yard should contain:

- player spawn / claim marker;
- unload point;
- processing line;
- purchase pads;
- factory expansion boundaries;
- cosmetic/sign identity point;
- obvious route back to scavenging area.

### Initial footprint target

Rough greybox starting point: around 100–140 studs per side, subject to playtest.

Do not make the starter plot feel empty just because future upgrades need room. Use authored expansion gates or hidden/replaced geometry.

## 8.3 Shared zones

Zones should visually communicate higher value.

Planned progression theme:

1. **Starter Scrap Yard**
2. **Car Graveyard**
3. **Industrial Dump**
4. **Heavy Machinery Yard**
5. **Restricted Salvage Depot**
6. **Space Junk Site**

Only the first 1–3 should be considered early production scope. Later themes are expansion options, not commitments.

---

# 9. Scrap collection

## 9.1 Interaction

Primary collection must work naturally on touch and keyboard/mouse.

Preferred initial approach:

- ProximityPrompt or equivalent low-friction world interaction;
- short/no hold duration for common scrap;
- clear outline/highlight only near interactable scrap;
- authoritative server validation of collection.

Potential later upgrades:

- magnet radius;
- pickup speed;
- multi-pickup;
- vacuum tool;
- rare detector.

## 9.2 Scrap item data

Each scrap definition should be data-driven and include at least:

```text
id
name
displayName
rarity
baseValue
weight/capacityCost
zonePool
spawnWeight
visualAssetKey
collectionIndexGroup
optionalSpecialTag
```

Do not create unique scripts per scrap item.

## 9.3 Starter rarity system

Initial recommendation:

- Common
- Uncommon
- Rare
- Epic
- Legendary

The first slice only needs 3 rarities to prove the hierarchy.

Visual rarity feedback should be readable but not obnoxious:

- nameplate color/icon;
- pickup sound tier;
- subtle highlight;
- stronger reveal only for genuinely rare finds.

## 9.4 Example early scrap catalog

### Common

- Crushed Can
- Rusted Pipe
- Bent Sheet Metal
- Worn Tire
- Broken Gear

### Uncommon

- Car Battery
- Electric Motor
- Car Door
- Copper Coil

### Rare

- Engine Block
- Locked Safe
- Industrial Motor

### Epic/later

- Golden Engine
- Prototype Power Core
- Experimental Machine Part

Names are provisional and may change with the final art library.

---

# 10. Backpack / carrying

The backpack creates an understandable capacity constraint and reason to return to the yard.

Initial player:

- capacity target: around 8–12 normal scrap units;
- capacity is shown clearly;
- full backpack feedback is obvious;
- player can still move normally when full.

Upgrade axes:

- capacity;
- pickup radius;
- pickup speed;
- rare scan capability later.

Avoid weight systems that slow movement heavily in V0.1; they add friction without proving the core loop.

---

# 11. Factory processing

## 11.1 Visual promise

Collected junk should visibly become money through machinery.

The processing line must not feel like a hidden timer.

Starter visual chain example:

```text
Unload Hopper
→ Conveyor
→ Crusher
→ Sorter
→ Sell/Storage Bin
```

Later tiers:

```text
Furnace
→ Separator
→ Compactor
→ Auto Loader
→ Advanced Recycler
```

## 11.2 Simulation level

V0.x does not need physically accurate every-item logistics.

Preferred architecture:

- authoritative server tracks processing jobs/value;
- visuals represent the jobs convincingly;
- moving physical parts/items are bounded and pooled;
- factory cannot generate unlimited loose physics objects.

The player should be able to see what an upgrade changed.

## 11.3 Upgrade categories

Every factory upgrade should map to one clear effect:

- throughput;
- value multiplier;
- buffer/capacity;
- automation;
- access to new material type;
- visual expansion.

Pure income multipliers should not dominate all progression.

---

# 12. Purchase-pad progression

V0.x uses authored purchase pads or clearly located upgrade terminals.

Rules:

- affordable pads become readable at a glance;
- unavailable pads explain the requirement;
- purchased pads disappear or transform;
- purchase result appears immediately;
- dependent upgrades cannot be bought out of sequence;
- costs come from central configuration, not parts/scripts scattered across the map;
- server verifies Cash and prerequisites.

Purchase pads can be grouped into branches:

### Factory

- Conveyor I
- Crusher I
- Sorter I
- Furnace I
- Conveyor II

### Player

- Backpack II
- Magnet I
- Movement convenience if needed

### Expansion

- Yard Extension
- Zone Access
- Automation Node

The exact tree is tuned after slice playtests.

---

# 13. Zones

Zones are both progression gates and content bundles.

Each zone should define:

- unlock cost/requirement;
- visual theme;
- scrap spawn table;
- average value;
- rare chase items;
- density;
- one memorable landmark;
- optional environmental interaction.

Example:

## Starter Scrap Yard

- cheap common metal;
- no dangerous mechanics;
- high density;
- tutorial area.

## Car Graveyard

- batteries, doors, wheels, engines;
- visually recognizable large car wrecks;
- first meaningful rare chase: high-value engine.

## Industrial Dump

- motors, coils, machinery parts;
- higher average item value;
- larger props and deeper factory aesthetic.

---

# 14. Collection index

Collection index is a retention system and content multiplier.

Each discovered scrap records permanently.

Player should see:

- discovered / total;
- rarity;
- zone source;
- best value or discovery count optionally;
- silhouette for undiscovered items where useful.

First discovery can provide a modest bonus.

Do not make collection completion mandatory to progress core zones.

Potential later rewards:

- Cash milestone;
- cosmetic yard sign;
- title;
- magnet skin;
- factory decoration.

---

# 15. Quests and goals

V0.1 does not need a large quest narrative.

Goal system should be lightweight and repeatable.

Example daily/short goals:

- collect 20 scrap;
- discover 1 uncommon item;
- process $X value;
- buy 2 upgrades;
- visit Car Graveyard;
- play with a friend.

Quest rewards should mostly accelerate play, not gate required features.

---

# 16. Prestige / company sale

Working fantasy:

> The player sells the completed company, keeps permanent reputation/experience, and starts a new yard that grows faster.

Working name options:

- Company Sale
- Empire Reset
- Business Level
- Company Stars

Current canonical placeholder: **Company Sale / Company Stars**.

On sale:

Reset candidates:

- Cash;
- temporary factory purchases;
- zone access tied to run if desired.

Permanent candidates:

- Company Stars;
- collection index;
- cosmetics;
- selected permanent perks;
- achievements;
- monetization ownership.

The first sale should feel like a milestone, not punishment.

Later sales should become faster because of permanent power and knowledge.

---

# 17. Social systems

Social is deliberately lightweight at first.

## Initial candidates

- player name/sign on yard;
- visible neighboring factories;
- visit another player's factory;
- friend co-presence bonus;
- server leaderboard for company value/cash/prestige.

Working friend bonus target:

- +10% income per friend in server;
- cap around +30% initially;
- exact number subject to economy test.

This bonus should be server-computed.

## Later candidates

- likes/visits;
- cooperative scrap events;
- gift limited to abuse-safe items;
- global leaderboards;
- shared community milestones.

Trading is explicitly **not early scope** because it introduces duplication, rollback and economy abuse risk.

---

# 18. UI / UX

## 18.1 HUD principle

Keep spawn screen clean.

Always-visible information should initially be limited to:

- Cash;
- backpack capacity;
- current short objective if active;
- minimal access to collection/shop/rewards.

## 18.2 Main navigation

Candidate buttons:

- Index
- Upgrades/Shop
- Rewards
- Prestige when unlocked

Do not show every future system from minute zero.

## 18.3 World-space UI

Prefer world cues where possible:

- purchase pad cost;
- unload marker;
- zone gate cost;
- machine status.

This reduces dependence on sophisticated 2D UI art.

## 18.4 Mobile rules

- large touch targets;
- avoid tiny edge buttons;
- no hover-only information;
- avoid more than a few stacked right-side buttons;
- test on narrow phone aspect ratios;
- important prompts must not overlap Roblox controls.

---

# 19. Feedback design

Even a simple game needs satisfying feedback.

## Scrap pickup

Use a small stack:

- object disappears/moves;
- sound;
- backpack count animates;
- item name/rarity appears briefly.

## Cash gain

- compact number animation;
- machine motion/sound;
- HUD cash tween.

## Upgrade purchase

- pad activation;
- short build/reveal animation;
- machine powers on;
- new upgrade becomes visible.

## Rare discovery

- stronger sound;
- rarity banner/card;
- index first-discovery feedback.

Do not use giant screen flashes for common rewards.

---

# 20. Save data concept

Initial logical schema:

```text
schemaVersion
Cash
CompanyStars
LifetimeCash
UnlockedZones
PurchasedUpgradeIds
PlayerUpgradeLevels
CollectionDiscovered
QuestState
DailyRewardState
Settings
FirstSeenTimestamps / progression flags as needed
```

Server owns canonical progression.

Save implementation details belong to `DEVELOPMENT_RULES.md` and implementation docs.

---

# 21. Analytics plan

Core funnel events should eventually answer where players leave.

Minimum useful progression events:

1. session_start
2. first_scrap_collected
3. first_unload
4. first_cash_earned
5. first_upgrade_bought
6. first_rare_found
7. first_zone_unlocked
8. first_company_sale
9. shop_opened
10. monetization_prompt
11. monetization_success

Useful timing fields:

- seconds since join;
- current Cash;
- current zone;
- company stars;
- session number where possible.

Do not add analytics before the basic route works, but design event points now so the architecture does not fight them later.

---

# 22. Monetization design boundary

Detailed monetization canon lives in `MONETIZATION_AND_ECONOMY.md`.

High-level rules:

- no paywall on the first playable loop;
- no purchase popup immediately on join;
- premium upgrades should feel like convenience/acceleration/status;
- no deceptive sale timers;
- no fake scarcity;
- no unreviewed paid random reward system;
- all purchase fulfillment is server-authoritative;
- IDs/prices live in central config.

Likely categories:

- 2× Cash pass;
- VIP pass;
- larger carry capacity convenience;
- auto-collection/quality-of-life where it does not delete gameplay;
- timed income boosts;
- Cash products;
- cosmetic factory themes later.

---

# 23. Content roadmap

## Launch-oriented content target, not first slice

A reasonable early public version may eventually include approximately:

- 3 zones;
- 25–40 scrap types;
- 15–25 factory purchases/upgrades;
- 5–8 player/tool upgrades;
- collection index;
- daily reward;
- light quests;
- company sale/prestige;
- basic passes/products;
- save/load;
- mobile UI;
- social visibility.

This target is **not permission to build all of it before the vertical slice is fun**.

## Expansion model

Future updates can add:

- zone + scrap collection set;
- new prestige layer;
- factory skins;
- limited seasonal junk;
- event salvage field;
- rare world drop;
- new machine branch;
- collection milestone rewards.

---

# 24. Asset strategy

Use external assets aggressively for visuals, conservatively for logic.

Good import candidates:

- industrial props;
- wrecked vehicles;
- warehouse kit;
- conveyor meshes;
- machines;
- signs;
- pipes;
- junk piles;
- roads/fences;
- forklift/crane decorative models.

Avoid importing a whole free tycoon kit and accepting its logic as architecture.

If a useful kit contains code, treat the code as reference material only until audited and intentionally integrated.

Every accepted external asset must be recorded in `../ASSET_SOURCES.md`.

---

# 25. What must remain cheap to produce

The project succeeds only if content can be added quickly.

Therefore:

- scrap behavior is data-driven;
- zone spawn tables are data-driven;
- purchase pads are data-driven;
- machine upgrade definitions are data-driven;
- monetization products are config-driven;
- quest templates are data-driven;
- rarity presentation is centralized;
- repeated UI uses components/tokens rather than bespoke styling every screen.

Do not make one-off scripts for content objects.

---

# 26. Anti-scope rules

Until the core loop is proven, do not add:

- combat;
- pets;
- trading;
- clans;
- PvP;
- freeform base building;
- complex worker NPCs;
- vehicles that require custom driving systems;
- giant open world;
- multiple prestige currencies;
- crafting tree;
- paid loot boxes;
- 100+ scrap items;
- story quests.

A later feature may be added only because it strengthens measured player behavior or clearly improves the core fantasy.

---

# 27. Vertical slice definition

V0.1 slice route:

```text
spawn
→ claim/receive yard
→ see scrap
→ collect scrap until at least one item is carried
→ return to unload
→ processing visibly occurs
→ Cash increases
→ purchase first factory upgrade
→ factory visibly changes
→ repeat loop faster or for more value
```

Required proof:

- route works after clean Play start;
- no manual developer setup after pressing Play;
- no red Output errors on normal route;
- player cannot award themselves Cash from client;
- no duplicated claim/plot state;
- backpack cannot go negative/overflow incorrectly;
- purchase cannot occur without enough Cash;
- purchased upgrade does not duplicate on repeated interaction;
- reset/respawn does not destroy player progress state unexpectedly;
- basic mobile interaction remains usable.

If this route is boring or unclear, do not hide the problem by adding more systems.

---

# 28. Success test for early human playtest

Ask the player:

- Did you know what to do without reading much?
- How quickly did you get money?
- Was the first machine upgrade noticeable?
- Did collecting junk feel annoying or satisfying?
- Did you understand why you should return to the factory?
- What did you want to unlock next?
- Did you notice rare scrap?
- Did the factory feel like it was growing?
- Would you play another 10 minutes to reach the next zone?

The strongest early signal is not “the systems exist”; it is that the player voluntarily identifies a next goal.

---

# 29. Canonical unresolved decisions

These are intentionally not finalized yet:

- final game title;
- exact visual style / asset pack;
- exact server player cap;
- final first three zone themes;
- exact economy numbers;
- save library choice;
- final monetization prices;
- whether automation generates independent scrap or only processes collected scrap;
- whether offline income exists;
- exact company sale formula;
- whether factory cosmetic themes are launch scope.

Resolve these through prototype/playtest and update this document rather than silently changing assumptions in code.

---

# 30. Current canonical next step

Build the smallest Studio vertical slice around this design. The next implementation batch is defined in `ROADMAP_AND_STATUS.md`.
