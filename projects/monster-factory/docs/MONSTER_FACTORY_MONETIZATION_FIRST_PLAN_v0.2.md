# Monster Factory Simulator — Monetization-First Plan v0.2

Status: IMPLEMENTATION BASELINE  
Owner: 문승준  
Build target: MVP-001  
Principle: monetization-first, policy-compliant, mobile-first.

## 1. Core business goal

The product is optimized for:
1. low first-session bounce,
2. clear progress within 30 seconds,
3. repeated spend opportunities that give guaranteed value,
4. permanent convenience passes,
5. repeatable non-random developer products,
6. daily return loops,
7. data-driven content expansion.

The game must never depend on deceptive urgency, fake countdowns, hidden prices, or paid random-item behavior.

## 2. Monetization priority

### Tier A — permanent passes
These get the most prominent store placement.

- Starter Pack
  - one-time Game Pass
  - exclusive guaranteed starter monster
  - permanent +1 equip slot
  - starter Gems
  - cosmetic badge/nameplate
- Auto Collect
- +3 Equip Slots
- VIP
- Fast Hatch
- Bigger Storage
- Extra Factory Worker

### Tier B — repeatable Developer Products
- Gem Pack S / M / L
- Rebirth Token Pack S / M
- Factory Overdrive 15 min
- Factory Overdrive 60 min
- Guaranteed Upgrade Token Bundle

No paid currency may be used for randomized hatching in MVP.

### Tier C — contextual upsell surfaces
Show an offer when the related need is visible:
- full inventory -> Bigger Storage
- equip limit reached -> +3 Equip
- repeated manual collection -> Auto Collect
- early first-session milestone -> Starter Pack
- rebirth screen -> Rebirth Token bundle
- factory production screen -> Overdrive

The player must always be able to dismiss the offer.

## 3. Store ordering

1. Starter Pack
2. Auto Collect
3. +3 Equip
4. VIP
5. Factory Overdrive
6. Gem packs
7. Rebirth Token packs
8. remaining convenience passes

## 4. Early session

0:00–0:20
- immediate factory income
- first upgrade highlighted

0:20–1:00
- guaranteed first monster
- visible multiplier increase

1:00–3:00
- second machine
- first quest reward
- first contextual Starter Pack entry point

3:00–8:00
- equipment pressure begins naturally
- shop becomes useful, not mandatory

8:00–15:00
- Zone 2 target
- first rebirth goal preview
- optional Overdrive offer

## 5. Purchase rules

- Server owns all grants.
- Developer Products use MarketplaceService.ProcessReceipt.
- Every receipt is idempotent.
- Pass benefits are validated server-side.
- Product/pass prices are not hard-coded into visible UI.
- All IDs live in MonetizationConfig.
- Paid purchases always deliver deterministic value.
- No fake discount countdown.
- No fake "only X left".
- No forced purchase prompt on join.
- No purchase prompt loops after decline.

## 6. MVP-001 engineering scope

Implemented in the starter package:
- project structure
- player data schema
- DataStore save/load
- cash production loop
- machine upgrade endpoint
- monetization configuration
- Developer Product receipt processing
- Game Pass ownership checks
- server-side entitlement cache
- safe RemoteEvent validation
- basic programmatic HUD/store shell
- Starter Pack / Auto Collect / Equip / VIP buttons
- placeholder product IDs
- development Studio fallback when IDs are 0

Next:
- monster inventory
- free-play hatching
- machine/plot visuals
- first zone art
- real product/pass IDs after experience publication
- analytics event schema
- full onboarding funnel
