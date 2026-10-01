# POWER LEGENDS — Release Scope and Production Roadmap

> Status: PREPRODUCTION
> Date: 2026-10-01
> Principle: release scope is defined, future updates are intentionally not overdesigned.

---

# 1. Why this document exists

게임 전체 업데이트 2년치를 미리 기획하지 않는다.

대신 다음은 제작 전에 확정한다.

- Vertical Slice에서 무엇을 증명할지
- Alpha에서 무엇을 확장할지
- 첫 공개 버전이 얼마나 완성되어야 할지
- 어떤 시스템은 launch 이후로 미룰지

---

# 2. Vertical Slice 001

목표:
**첫 20–30분을 production quality로 증명.**

Content target:

- Starter Gym / world district 1
- Next Gym unlock/tease 1
- training actions 5
- weight progression enough for first Rebirth
- Body Stages B0–B4
- Basic Punch + 2 Moves
- free PvP
- Brawl 1 mode
- Pets 8–12
- Pet Egg 1 normal + first guaranteed hatch path
- Rebirth 1 complete route
- Gems
- save/load
- HUD/Pets/Rebirth/Moves/Shop skeleton
- core monetization test hooks, not aggressive sales
- mobile + desktop QA

Do NOT scale before acceptance gates pass.

---

# 3. Production Alpha

Vertical Slice quality preserved while content variety expands.

Target range:

## World

- 3 coherent Gym/world districts total
- each has distinct landmark/asset vocabulary
- one connected progression route or clear portal structure
- safe/social/PvP spaces remain readable

Final theme names are asset-first and reference-research dependent.

## Training

- 6–8 polished training families
- enough weight/object tiers that each Gym feels stronger, not just recolored
- absurd/heavy-object progression introduced

## Body

- 6–7 readable Body Stages
- higher stage animation/stance variation where feasible

## Combat

- Basic Punch
- 3–4 total Moves
- no giant skill tree

## Pets

- 20–28 production Pets
- 3–4 acquisition pools/eggs
- collection
- equip
- duplicates
- simple duplicate sink may be prototyped only after core stability

## Meta

- multiple Rebirths supported
- meaningful unlock milestones
- global/server leaderboards
- Brawl stable
- analytics event pipeline

---

# 4. First Public Release Target

Public release should feel like a real game, not a demo with many placeholders.

Recommended target range, adjustable downward if asset quality would suffer:

## World

**4–5 production-quality Gym/world districts**

Requirements:
- visual progression
- next district aspiration
- no asset soup
- routes replayed after art pass
- mobile readable

## Training

**7–9 polished training families**

Examples may include:
- dumbbell
- bench
- squat
- deadlift
- punching/defense
- treadmill/speed
- industrial/strongman lift
- absurd object lift

Final set follows available animation/assets.

## Weight/object progression

Enough unique visible tiers that:
- first 30 min has frequent upgrades
- later Gyms introduce new silhouettes, not only larger numbers

Do not target a fixed huge count if quality drops.

## Body progression

**7+ readable stages** if camera/collision supports them.

Final physical size must stop before gameplay readability breaks.
Later stages can increase fantasy through stance/aura/held-object scale rather than raw body scale.

## Pets

**30–40 production-quality Pets** as a preferred range.

Only if:
- coherent asset family exists
- following/animation/readability stable
- Pet UI works at this inventory size

Better 24 good Pets than 60 AI-looking placeholders.

Suggested launch structure:
- 4–5 egg/pool families
- Common/Rare/Epic/Legendary
- guaranteed onboarding Pet
- guaranteed premium direct companion candidate
- no paid random egg at launch

## PvP

- free PvP in designated world areas
- safe training footprints
- repeated victim anti-farm
- Basic Punch + 3–4 Moves
- readable power disparity
- Brawl KO Score mode

A second Brawl mode is optional, not launch requirement.

## Meta/retention

Launch minimum:
- Rebirth
- Pet Collection
- Gym progression
- server/global leaderboard
- simple achievement/milestone rewards
- Brawl
- analytics

Candidate only if polished:
- daily reward streak
- lightweight quests

Do not add solely because other simulators have them.

---

# 5. Launch monetization target

Initial catalog can include:

Passes:
- 2× Training
- Auto Train
- +1 Pet Equip
- VIP
- Pet Storage

Developer Products:
- timed Training Boost
- Starter Pack
- guaranteed direct companion/bundle
- selected cosmetic/event bundles

Possible later:
- subscription
- additional convenience
- managed pricing / optimization experiments

Not launch-default:
- paid random eggs
- purchasable currency used in random eggs
- paid luck affecting randomized Pet outcome without explicit policy review
- direct PvP dominance products

Roblox's current monetization supports passes, repeatable Developer Products and subscriptions; product benefit and receipt handling must follow current platform docs.

---

# 6. Explicitly deferred systems

Do NOT implement in first public release unless core game proves a need.

## Trading

Reason:
- dupe/security/economy complexity
- scam UX
- major architecture decision

## Clans/Guilds

Not needed for core fantasy.

## Complex Pet fusion/evolution

Simple duplicate sink first, if needed.

## Paid random eggs

Separate compliance gate.

## Deep quests/story

Not core fantasy.

## Battlegrounds-depth combat

Would replace rather than support the simulator loop.

## Massive open world

More map is not automatically more fun.

## 10+ currencies

Keep economy understandable.

---

# 7. Production stages

## Stage P0 — Research and Studio setup

Codex:
- latest main
- Godbase reads
- reference audit
- Creator Store/asset supply audit
- Studio/DataModel inspection
- workflow selection
- first spatial plan

Output:
- research findings
- asset shortlist
- implementation plan
- no mass content

## Stage P1 — Core movement/world shell

- safe spawn
- Starter Training area
- PvP area
- Pet node
- Brawl access
- Next Gym vista

Graybox first.
Gameplay camera verify.

## Stage P2 — Training feel

One training action production-quality first.
Then five.

Gate:
animation/tool/contact/sound/UI/gain all aligned.

## Stage P3 — Body progression

- B0–B4
- camera/collision QA
- multiplayer giant-body QA

## Stage P4 — PvP

- Punch
- damage curve
- death/respawn
- spawn shield
- anti-farm
- 2 Moves

## Stage P5 — Pets

- first hatch
- collection
- equip
- follow
- multiplier
- save

## Stage P6 — Rebirth / economy

- first-run timing
- reset/persist
- permanent multiplier
- next Gym

## Stage P7 — Brawl

- announcement
- opt-in
- scoring
- rewards
- cleanup

## Stage P8 — UI/visual production pass

- reference-derived design system
- all states
- mobile
- visual consistency

## Stage P9 — Monetization hooks

Only after gameplay loop is good.

## Stage P10 — Vertical Slice acceptance

No new content until passed.

## Stage P11 — Alpha scale

Add content section-by-section with regression after each.

## Stage P12 — Release QA

- clean boot
- multiplayer
- device
- persistence
- purchases
- exploit routes
- performance
- analytics
- policy
- final visual QA

---

# 8. Human review points

User should not be first structural QA.

User review is most valuable at:

1. first polished training action
2. first complete Starter Gym gameplay-camera pass
3. Body growth feel
4. PvP feel
5. first 20–30 min Vertical Slice
6. launch candidate

User judges:
- fun
- feel
- taste
- visual direction
- whether growth feels satisfying

Codex/Studio must catch:
- missing map
- runtime errors
- dead buttons
- broken saves
- obvious clipping
- spawn failure
first.

---

# 9. Release definition

First public build is not approved because content count is reached.

Approved when:

- first 30 minutes are strong
- Rebirth loop works and accelerates
- Pet collection adds aspiration
- free PvP creates social stories without breaking onboarding
- world/assets look coherent
- training animation/feedback is production-quality
- mobile works
- persistence is safe
- monetization is understandable and policy-compliant
- runtime errors attributable to project are zero on acceptance route
- Studio/Codex playtests are completed
- human test says the game is actually enjoyable

---

# 10. Future update philosophy

Updates should extend proven axes:

- new Gym
- new training family
- new heavy-object fantasy
- new Body tier/presentation
- new Pet family
- new Move
- new Brawl/event
- seasonal visual/collection content

Do not add a new subsystem merely because retention drops.

Use analytics to identify the actual bottleneck first.
