# Junkyard Empire — Economy & Monetization Canon

> Status: Initial planning canon
> Date: 2026-09-06
> All numbers are provisional until playtested.

This document defines progression pacing, currency ownership, prestige structure and monetization boundaries. It intentionally separates **commercial design** from implementation so the game can be tuned without rewriting systems.

---

# 1. Economy goals

The economy should make the player repeatedly ask:

> “What should I buy next?”

rather than:

> “How long do I have to wait until the next number gets bigger?”

The early game should provide frequent choices and visible upgrades. Long-term progression may become exponential, but the first session should remain readable.

Primary goals:

- first purchase in roughly 1–3 minutes;
- new meaningful choice every few minutes early on;
- clear zone aspirations;
- rare scrap creates exciting burst value;
- automation improves baseline output;
- active scavenging remains valuable;
- prestige creates a strong restart loop;
- monetization accelerates/conveniences without deleting the free game.

---

# 2. Currency model

## 2.1 Cash

Primary run currency.

Earned from:

- processed scrap;
- quests;
- daily rewards;
- optional developer products.

Spent on:

- factory machinery;
- yard expansions;
- player tools/capacity;
- zone unlocks;
- selected convenience upgrades.

Cash should be the only currency visible to a brand-new player.

## 2.2 Company Stars

Permanent prestige currency/progression marker.

Earned from Company Sale / prestige.

Used for:

- permanent income multiplier;
- permanent carrying improvements;
- prestige-only upgrade tree later;
- cosmetic status unlocks;
- access to higher-tier progression later.

Do not expose Company Stars until the player has a credible path to first prestige.

## 2.3 No early currency bloat

Do not add Gems, Tickets, Shards, Tokens, Bolts, Keys and Event Coins simply because simulator games often have them.

Any additional currency needs a distinct reason and should usually wait until the base game is proven.

---

# 3. Scrap value model

Each scrap item has a server-owned `baseValue`.

Working final reward concept:

```text
processedValue
= baseValue
× machineValueMultiplier
× permanentCompanyMultiplier
× temporaryBoostMultiplier
× optionalFriendMultiplier
```

The implementation should clamp/validate multipliers and never accept any multiplier supplied by the client.

Initial rarity value bands can roughly follow increasing orders rather than strict ratios:

| Rarity | Example early base-value band | Purpose |
|---|---:|---|
| Common | 5–20 | frequent baseline |
| Uncommon | 20–75 | noticeable pickup |
| Rare | 75–300 | short excitement spike |
| Epic | 300–1,500 | aspirational |
| Legendary | 1,500+ | chase / later content |

These are placeholders for tuning, not final launch values.

---

# 4. Starter progression target

The first slice should initially tune around a simple ladder such as:

| Milestone | Provisional target |
|---|---:|
| First Cash reward | < 60 sec |
| Backpack upgrade | 1–3 min |
| First machine purchase | 1–3 min |
| Second visible machine upgrade | 3–5 min |
| First uncommon/rare aspiration | 3–5 min |
| Starter yard expansion | 5–8 min |
| First new zone | 5–10 min |
| First prestige eligibility | 25–40 min focused play |

If testing shows the player waits with no interesting decision, lower the gap or add an active route; do not merely add a countdown.

---

# 5. Example V0.1 price skeleton

Initial balance scaffold only:

| Upgrade | Example cost | Effect |
|---|---:|---|
| Conveyor I | 50 | establishes visible factory flow |
| Crusher I | 120 | unlocks/value-processes first line |
| Backpack II | 200 | 10 → 15 capacity example |
| Sorter I | 350 | increases value/throughput |
| Conveyor Speed I | 700 | visible speed increase |
| Yard Extension I | 1,200 | physical factory expansion |
| Magnet I | 2,000 | easier active collection |
| Furnace I | 3,500 | new processing tier |
| Car Graveyard access | 5,000–8,000 | new content pool |

Do not implement these exact values blindly. Use them only to establish relative order and then tune in playtest.

---

# 6. Upgrade design

Avoid an upgrade tree made entirely of multiplicative income nodes.

Use at least these categories:

## Capacity

- backpack size;
- unload buffer;
- factory queue/buffer.

## Throughput

- conveyor speed;
- processing speed;
- parallel machine capacity.

## Value

- material sorting bonus;
- furnace refinement;
- higher-value processing stage.

## Active collection

- pickup radius;
- pickup speed;
- rare-item scanner;
- auto-vacuum convenience later.

## Expansion

- new yard section;
- new zone;
- new machine branch.

Each major purchase should create an observable difference.

---

# 7. Automation philosophy

Automation is important because it turns the plot into a satisfying machine and supports idle/casual play.

However:

- it should not instantly make scavenging obsolete;
- rare scrap should remain primarily active-content driven;
- automated income should be predictable and capped enough to tune;
- offline income should not be added until the online progression loop is stable.

Potential model:

### Early game

Player manually gathers almost all scrap.

### Mid game

Factory includes an automatic low-tier scrap source or contracted delivery that generates baseline materials.

### Later game

Automation handles common value while the player actively hunts rare items/zones.

This produces a natural shift from labor → optimization → collection.

---

# 8. Prestige / Company Sale

Working system:

When Company Value reaches a threshold, player may **Sell Company**.

On sale:

- current Cash resets;
- run-based factory upgrades reset;
- zone progression may reset according to final tuning;
- collection index remains;
- Game Pass ownership remains;
- Company Stars increase;
- permanent multipliers/perks remain.

## 8.1 First prestige target

The first prestige should be achievable in approximately 25–40 minutes of focused first-session play as a starting hypothesis.

It should be visibly teased before the player is eligible.

## 8.2 Working multiplier formula

Simple initial version:

```text
PermanentIncomeMultiplier = 1 + (CompanyStars × 0.25)
```

Example:

- 0 stars = ×1.00
- 1 star = ×1.25
- 5 stars = ×2.25
- 10 stars = ×3.50

This is intentionally simple for the first implementation.

If long-term growth needs stronger scaling later, change the formula centrally and migrate carefully.

## 8.3 Multi-star sales later

Later versions may grant multiple Stars based on Company Value above threshold. Do not add this until the one-star prestige loop is tested.

---

# 9. Company Value

Company Value can be a derived display metric used for prestige and social comparison.

Possible components:

```text
cashEquivalentOfPurchasedUpgrades
+ current Cash fraction
+ lifetime factory tier value
```

Do not make it easy to exploit by buying/refunding loops.

For V0.1 it may simply equal the sum of canonical purchased upgrade costs plus current eligible value.

---

# 10. Friend/social multiplier

Working optional system:

```text
+10% income per friend in current server
cap at +30%
```

Server computes valid friend presence.

Reasons:

- gives players an uncomplicated reason to join friends;
- visible but not mandatory;
- scales without custom co-op systems.

The exact bonus must be tested for economy distortion.

---

# 11. Daily reward

Daily reward is **post-slice** scope.

Goals:

- give returning players an immediate action;
- avoid gigantic reward spikes that invalidate early progression;
- use escalating but understandable rewards.

Possible reward types:

- Cash scaled by progression;
- temporary income boost;
- cosmetic token/reward later;
- one rare scrap discovery item only if it does not damage collection integrity.

Do not build a manipulative 30-day claim maze before retention is measured.

---

# 12. Quests

Quest rewards should create variety, not replace the core loop.

Example short quests:

- collect 15 Common scrap;
- collect 5 Uncommon scrap;
- process $1,000 value;
- buy one factory upgrade;
- unlock/visit zone;
- collect with a friend in server.

Rewards:

- Cash;
- short temporary boost;
- collection milestone cosmetics later.

Avoid rewarding premium currency if no premium currency otherwise exists.

---

# 13. Monetization philosophy

The project is commercially oriented, but conversion must not destroy retention.

Principles:

- player experiences the core loop before being asked to spend;
- product value is understandable;
- purchases accelerate or add convenience/status;
- no false scarcity;
- no fake “90% OFF” pricing;
- no repeated prompt spam;
- no paid-only essential gameplay path;
- paid randomness is excluded from initial scope;
- verify current Roblox policy before public release because platform requirements can change.

---

# 14. Game Pass candidates

Prices are **provisional test points**, not promises.

## 14.1 2× Cash

Working price: **199 Robux**

- clear evergreen value;
- easy to understand;
- central multiplier implementation.

Risk:

- can compress progression too much if base economy is already fast.

## 14.2 VIP

Working price: **299 Robux**

Possible bundle:

- VIP yard sign/name color;
- small permanent income bonus;
- cosmetic machine skin/theme later;
- daily VIP bonus;
- chat/title cosmetic if appropriate.

Avoid stacking VIP with too many exclusive power gates.

## 14.3 Bigger Backpack / Capacity

Working price: **99–149 Robux**

Possible implementation:

- +50% base carrying capacity;
- or fixed extra slots.

Must not make free capacity upgrades feel pointless.

## 14.4 Auto Collect / Magnet Convenience

Working price: **149–249 Robux** depending on strength.

This needs careful design.

Preferred behavior:

- improves pickup convenience/range;
- does not automatically farm rare zones while the player is AFK;
- active player still moves/explores.

## 14.5 Cosmetic factory theme later

Possible price: variable.

Examples:

- Gold Factory
- Neon Recycler
- Rust Lord Yard

Cosmetic products are attractive because they do not distort balance, but require enough visual assets to justify them.

---

# 15. Developer Product candidates

Repeatable purchases may include:

## Cash packs

Examples only:

- Small Cash Pack
- Medium Cash Pack
- Large Cash Pack

Do not hardcode a fixed amount forever if economy spans huge progression ranges. Consider scaling packs by current prestige/zone using a transparent formula, but make the displayed reward exact before purchase.

## Timed boost

Examples:

- 2× Income — 15 minutes
- 3× Income — 10 minutes

Boost timers should use server-tracked state and persist appropriately if design says paid time should survive disconnect.

## Instant convenience

Potential later products:

- immediate delivery crate;
- temporary rare-scan boost;
- temporary factory overdrive.

Avoid products that repeatedly interrupt normal play with prompts.

---

# 16. Monetization surface timing

Recommended first-session behavior:

### Spawn

No forced monetization popup.

### After first upgrade

Shop button may become noticeable, but no prompt required.

### When a relevant limitation is experienced

Example:

- backpack fills → show free upgrade path first; optional capacity pass can be discoverable.

### Later

At meaningful milestones, optional offers may appear in a non-deceptive, dismissible way.

The purchase path should be contextual rather than constant.

---

# 17. Shop UI hierarchy

Preferred categories:

1. Passes
2. Boosts
3. Cash
4. Cosmetics later

Show:

- exact benefit;
- exact current Robux price obtained from Marketplace data where appropriate;
- owned state;
- active boost time;
- no fake crossed-out price unless a real platform-supported discount applies.

---

# 18. Receipt and ownership rules

Implementation requirements:

- server verifies Game Pass ownership;
- Developer Products are fulfilled through canonical receipt processing;
- receipt fulfillment is idempotent;
- do not grant valuable product reward solely from client purchase-finished events;
- central `MonetizationConfig` maps semantic product keys to IDs;
- TEST and LIVE IDs must not be casually mixed;
- unknown/missing product ID should fail safely, not silently reward free goods;
- purchase errors are logged without spamming the player.

---

# 19. Economy exploit checklist

Before public release test:

- spam purchase remote;
- send negative/huge amount;
- request nonexistent upgrade ID;
- request locked zone;
- double-trigger same purchase pad;
- collect same scrap twice simultaneously;
- leave during processing;
- respawn during unload;
- disconnect during prestige;
- duplicate receipt replay;
- save failure around purchase;
- friend multiplier updates when friend leaves;
- boost timer reconnect behavior.

---

# 20. Balance telemetry

Once analytics is available, track at least:

- median time to first scrap;
- median time to first Cash;
- median time to first upgrade;
- median time to first zone;
- median time to first prestige;
- Cash earned per minute by progression stage;
- upgrade purchase distribution;
- backpack-full frequency;
- active vs automated income share;
- shop open rate;
- purchase prompt rate;
- purchase conversion by product;
- post-purchase retention, not only revenue.

A monetization feature that raises short-term revenue but causes players to leave is not automatically good.

---

# 21. Initial launch monetization scope

Do not implement all monetization during the first vertical slice.

Suggested sequence:

```text
core loop
→ stable economy
→ persistence
→ prestige
→ retention systems
→ basic shop
→ 2–4 clear passes/products
→ analytics review
→ add/adjust offers
```

Potential first public set:

- 2× Cash Pass
- VIP Pass
- Bigger Backpack or convenience Pass
- one timed income boost Product
- 2–3 Cash pack Products

Anything beyond this should have a reason.

---

# 22. Unresolved economy decisions

Still to be proven through playtest:

- exact scrap values;
- exact machine costs;
- first prestige threshold;
- whether zones reset on prestige;
- whether offline income is added;
- exact automation income share;
- final friend bonus;
- pass/product prices;
- whether paid capacity is fixed or percentage-based;
- whether Cash packs scale with prestige.

Do not treat placeholder numbers in this document as immutable canon.

---

# 23. Economy quality gate

Before adding more than roughly three zones or a large catalog, the game should demonstrate:

- first purchase feels quick but earned;
- at least two meaningful early upgrade choices;
- no obvious wait wall;
- active scavenging is worth doing;
- automation feels useful but not dominant;
- rare scrap matters;
- first prestige feels desirable;
- no trivial duplication/exploit path;
- free player can complete the progression loop without payment.
