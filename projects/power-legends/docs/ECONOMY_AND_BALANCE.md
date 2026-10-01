# POWER LEGENDS — Economy and Balance Skeleton

> Status: INITIAL TUNING BASELINE
> Date: 2026-10-01
> Important: 아래 숫자는 launch-final 값이 아니라 Studio/Codex simulation을 위한 **첫 기준값**이다.
> Rule: 목표 시간과 체감이 숫자보다 우선한다.

---

# 1. Economy jobs

## Strength

Role:
- current run primary progression
- Body Stage
- training weight/station gate
- combat power input
- Rebirth requirement

Source:
- training only + selected gameplay bonuses

Sink:
- 직접 소비하지 않음
- Rebirth에서 reset

## Gems

Role:
- persistent meta currency
- Pet acquisition
- Moves/meta unlock
- selected cosmetic/meta sinks

Sources:
- first-time milestones
- Brawl
- PvP/Fame milestones
- Rebirth
- achievements/events

Initial rule:
**Robux로 Gems를 직접 판매하지 않는다.**

이유:
Gems가 random Pet egg에 쓰이므로 초기에는 paid-random compliance를 단순화한다.

## Rebirth count

Role:
- prestige progression
- permanent multiplier
- Gym/meta unlock

---

# 2. First-run target curve

목표:

- first heavier weight: ~30 sec
- second meaningful tier: ~1–2 min
- first visibly muscular stage: ~3 min
- first Pet: ~3–5 min
- meaningful heavy-object tier: ~8–12 min
- Rebirth-ready: ~10–15 min real play

실제 training만 연속으로 한 최적 플레이어는 Rebirth target에 약 8–11분 정도 도달하는 것을 초기 baseline으로 한다.
이동/Pet/PvP/Brawl/menu/social 행동을 포함한 실제 세션은 10–15분을 목표.

---

# 3. Initial Strength training tiers

첫 balance simulation용 rough config:

| Tier | Required Strength | Base gain/rep | Base rep time | Intent |
|---|---:|---:|---:|---|
| W0 | 0 | 1 | 1.20s | starter |
| W1 | 25 | 2 | 1.35s | first upgrade |
| W2 | 100 | 5 | 1.50s | early progress |
| W3 | 400 | 12 | 1.65s | first major body change |
| W4 | 1,500 | 30 | 1.80s | heavy training |
| W5 | 6,000 | 75 | 1.95s | absurd/heavy-object transition |

First Rebirth requirement baseline:
**10,000 Strength**

이 표는 station 하나의 linear progression을 의미하지 않는다.
각 threshold는 다른 weight/station family로 표현 가능하다.

## Validation target

No-purchase / first-Pet baseline:

- 25 Strength: ~30 sec continuous training
- 100: ~1.3 min
- 400: ~2.8–3.2 min
- 1,500: ~5–6 min
- 6,000: ~9–10 min
- 10,000: ~10–12 min continuous training before Pet/route optimization

실제 플레이에서는 side content 때문에 더 길어진다.

---

# 4. Body Stage baseline

Initial rough thresholds:

| Stage | Strength threshold | Purpose |
|---|---:|---|
| B0 Skinny | 0 | start |
| B1 Fit | 25 | first visible response |
| B2 Muscular | 400 | clear transformation |
| B3 Huge | 1,500 | server-visible status |
| B4 Titan | 6,000 | first-run late stage |
| Rebirth-ready visual | ~10,000 | peak first-run impression |

Threshold는 training tier와 일부 겹쳐서
**새 중량 + 새 몸**이 동시에 너무 자주 겹치지 않게 presentation spacing을 Studio에서 조정한다.

---

# 5. Training gain formula

Initial conceptual formula:

```text
EffectiveGain =
    BaseWeightGain
    × RebirthMultiplier
    × PermanentPassMultiplier
    × TemporaryBoostMultiplier
    × (1 + SumEquippedPetBonuses)
```

Rules:

- Pet bonuses끼리는 additive
- paid permanent multiplier는 별도 layer
- temporary boosts는 duration/state가 명확
- 모든 multiplier는 server-calculated
- UI는 최종 gain/rep를 명확히 표시

---

# 6. Rebirth curve

## First Rebirth

Requirement:
- 10,000 Strength baseline

Reward:
- persistent Gems
- Rebirth +1
- permanent Training multiplier
- Next Gym access
- next Pet/weight content tease

Initial first-Rebirth multiplier target:
**x1.75 total Rebirth layer**

목표:
첫 run에서 5분 걸린 early section이 두 번째 run에서는 약 2–3분 수준으로 압축되는 체감.

## Subsequent Rebirths

초기 design direction:

Requirement growth:
- geometric 또는 hybrid curve
- content gate와 함께 증가

Multiplier growth:
- first Rebirth가 가장 큰 체감
- 이후 완만하게 증가

예시 후보:

```text
RebirthRequirement(n) = BaseRequirement × 2.3^(n)
```

```text
RebirthMultiplier(n) = 1 + 0.75 × sqrt(n)
```

이 수식은 final이 아니다.
초기 3–5 Rebirth simulation 후 fitting.

금지:
- requirement와 gain multiplier가 동일한 지수로 올라 progress가 매번 완전히 동일해지는 구조
- Rebirth가 새 content 없이 숫자만 reset하는 구조

---

# 7. Pet economy

## First Pet

- 3–5분 내 guaranteed
- free first hatch
- RNG 실패로 onboarding 지연 없음

## Starter Egg

첫 free hatch 이후 repeat egg baseline:
**80 Gems** 후보.

실제 price는 Gems source/sink simulation 후 변경.

## Pet bonus bands

| Rarity | Training bonus rough band |
|---|---:|
| Common | +5% ~ +15% |
| Rare | +15% ~ +30% |
| Epic | +30% ~ +55% |
| Legendary | +55% ~ +90% |

Equip slots:
- base 3

Power stacking:
- additive within Pet layer

Example:

```text
3 pets = +10%, +20%, +45%
Pet layer = 1 + 0.75 = x1.75
```

다른 multiplier와는 layer별 곱연산.

## First slice Pet count

권장:
**8–12 production-quality Pets**

목표:
- rarity distribution 체감
- collection screen 검증
- duplicate/save/equip 검증
- asset quality 검증

30–50개 placeholder Pet 금지.

---

# 8. Gem sources baseline

초기 rough source table:

| Source | Rough reward | Frequency |
|---|---:|---|
| first training milestone | 10–20 | one-time |
| first Body Stage milestones | 10–30 | one-time |
| first PvP interaction/KO milestone | 10–25 | one-time |
| Brawl participation | ~20–30 | recurring |
| Brawl placement | +20–100 | recurring |
| Rebirth 1 | ~120–180 | milestone |
| achievements | variable | controlled |

Goal:
- first free Pet does not require Gems
- first repeat egg should become plausible during first session
- Brawl/Rebirth make Gems feel meaningful
- no mandatory PvP farming to afford Pets

---

# 9. Gem sinks

Initial:

1. Pet eggs
2. Move unlocks
3. later cosmetic/meta options

Do not add:
- Pet fusion fee
- reroll fee
- upgrade fee
- aura spin
- chest keys
all at once.

첫 slice에서는 **Pet egg + Move** 정도만 강한 sink.

---

# 10. PvP power curve

Direct:
`Damage = Strength × constant`
금지.

목표 TTK:

| Relative power | Basic-hit target |
|---|---|
| roughly equal | 5–8 |
| ~2× stronger | 3–5 |
| ~5× stronger | 2–4 |
| ~10×+ stronger | 1–3 |

Toughness/HP가 완충한다.

Codex implementation should use configurable normalized curves.

Possible shape:

```text
AttackScore = f(Strength)
DefenseScore = g(Toughness)
DamageRatio = boundedCurve(AttackScore / DefenseScore)
```

Exact formula must be simulated and playtested.

## PvP reward

KO reward는 opponent power band를 고려.

- much weaker target: small/zero reward
- similar target: normal
- stronger target: bonus

Repeated victim diminishing:

- 1st: 100%
- 2nd: 50%
- 3rd: 20%
- 4th+: 0%

reset window/cooldown은 playtest.

---

# 11. Brawl economy

Initial cadence:
7–10 min.

Initial KO Score match:
90–150 sec.

Rough rewards:

- participation: 25 Gems
- each valid KO: 5 Gems + Fame
- 3rd: +30 Gems
- 2nd: +60 Gems
- 1st: +100 Gems

Numbers are baseline only.

Reward cap/rate limit needed to prevent farming/AFK abuse.

---

# 12. Monetization baseline

Initial paid acceleration should save time without replacing the game.

## Passes

### 2× Training
Permanent Training layer x2.

### Auto Train
Automates repeated reps while valid station/training state conditions are met.
Should not auto-navigate the whole map.

### +1 Pet Equip
Adds one equip slot.
Balance review required because slot scales with Pet quality.

### VIP
Bundle candidate:
- moderate Training bonus
- cosmetic title/aura
- small non-combat convenience
- no exclusive unbeatable PvP move

### Pet Storage
Convenience only.

## Developer Products

### Timed Training Boost
Repeat purchase candidate.

### Starter Pack
One-time-ish offer UX but implemented appropriately:
- guaranteed companion
- boost
- cosmetic
- no random outcome

### Guaranteed Premium Companion
Specific known Pet/result.

## Avoid initially

- Robux → Gems → random egg
- paid Luck affecting randomized Pet acquisition without policy review
- paid random egg
- instant Rebirth spam
- direct overpowered PvP weapon

Roblox official rules require odds disclosure and additional policy handling when random items are purchased directly or indirectly with Robux.

---

# 13. Multipliers and runaway safety

Track layers separately:

```text
Base
Rebirth
Pet
Pass
Temporary
Event
Friend/Premium (if later)
```

Do not silently multiply every system by every other system.

Before adding a new multiplier:
- expected F2P gain
- expected payer gain
- best-case stacked gain
- time-to-Rebirth
- PvP power gap
must be simulated.

---

# 14. Anti-AFK / automation principle

Auto Train is a convenience product, but game health still requires:

- movement to new stations/Gyms
- Pet choices
- Rebirth decisions
- Brawl/PvP/social activity

The optimal entire game must not be:
“enter one machine → leave computer running forever.”

---

# 15. Analytics

Record at minimum:

Progression:
- FirstTrain
- FirstWeightUpgrade
- BodyStageChanged
- FirstPet
- PetEquipped
- FirstPvPContact
- FirstKO
- FirstBrawl
- FirstRebirth
- GymUnlocked

Economy:
- Gems source/sink reason
- Pet hatch cost/result
- Move purchase
- Rebirth reward

Monetization:
- shop view
- product/pass view
- purchase prompt
- receipt success
- benefit usage

Compare:
- F2P vs payer time-to-goal
- first Pet conversion/retention
- PvP-contact retention
- Rebirth completion
- Pet-equipped count distribution

---

# 16. Balance acceptance

Before expanding content:

- first Rebirth real play median target within intended band
- Rebirth 1 produces obvious speed-up
- first Pet is understood and equipped
- Pet does not outweigh training by absurd margin
- F2P can reach Pet/Rebirth without paid boost
- equal-power PvP is not one-shot
- huge power difference remains visually/gameplay meaningful
- Gems have at least one meaningful source and sink in first session
- no infinite/negative/NaN progression path
- all core formulas/configs have automated sanity checks
