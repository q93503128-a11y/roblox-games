# Economy Balancing, Progression Curves, Sources, Sinks, and Inflation

> verified: 2026-09-03

경제는 숫자를 크게 만드는 시스템이 아니라 **행동 → 보상 → 선택 → 성장 → 다음 목표**를 유지하는 구조다.

## 1. Every currency needs a job

Currency definition:
```text
name/id
player fantasy
sources
sinks
expected earn rate
expected spend rate
caps/soft caps
premium relation
analytics tags
```

용도가 겹치는 currency를 이유 없이 늘리지 않는다.

## 2. Sources and sinks ledger

Example:
```text
Gold sources:
- enemy 45%
- quests 35%
- sell 20%

Gold sinks:
- upgrades 60%
- craft 25%
- reroll 15%
```

실제 analytics로 비율을 확인하고 예상과 비교한다.

## 3. First-session economy

첫 세션에서 player가:
- reward를 받음
- 무엇에 쓰는지 이해
- 실제로 한 번 spend
- spend 후 power/option 변화 체감
해야 한다.

첫 10분 동안 돈을 모으기만 하고 쓸 곳이 없는 것은 poor onboarding.

## 4. Progression curve

Level/cost/reward formula를 선택할 때 목표 시간을 먼저 정한다.

```text
T1 first upgrade: ~project target
T2 unlock: target session
midgame milestone: target day/session
```

그 후 수식을 fitting한다. 수식이 예뻐서 progression을 정하지 않는다.

## 5. Additive vs multiplicative power

Additive growth:
- 예측 가능
- balancing 쉬움

Multiplicative systems:
- build depth
- 큰 power fantasy
- runaway scaling 위험

Critical multipliers는 source별 caps/stacking rule을 정의한다.

## 6. Diminishing returns

Movement speed, cooldown reduction, dodge, crit 등은 무한 선형 성장 시 game rules를 깨기 쉽다.

Use:
- hard cap
- soft cap
- diminishing formula

UI에 실제 effect를 이해 가능하게 표시.

## 7. Inflation

Live game currency supply는 누적된다.

Inflation warning:
- average balance 계속 상승
- core upgrade가 trivial
- trading price runaway
- new player와 veteran 격차 급증

Responses:
- meaningful repeat sinks
- prestige/rebirth
- crafting/reroll
- cosmetic sinks
- late-game upgrades

기존 재화를 갑자기 삭제/너프해 해결하지 않는다.

## 8. Rebirth/prestige

좋은 prestige:
- 의미 있는 reset
- 명확한 permanent gain
- 다음 run이 다르게/빠르게 느껴짐
- 반복마다 선택/새 콘텐츠

나쁜 prestige:
- 같은 행동을 숫자만 2배로 반복
- 처음 몇 분을 다시 지루하게 함

## 9. Loot rarity

Rarity should communicate:
- expected frequency
- power/utility
- visual feedback

Rarity color만 바꾸고 stat 차이가 무의미하면 collection fantasy가 약함.

## 10. Randomness

Free gameplay randomness도 pity/bad-luck protection이 player experience에 도움될 수 있다.
Paid randomized items는 현재 Roblox 정책을 반드시 별도 확인한다.

## 11. Upgrade choice

최적 답 하나가 항상 명백하면 choice가 아님.
Build tradeoff examples:
- damage vs speed
- single target vs AoE
- safety vs risk/reward
- farming vs boss

## 12. Cost curve validation

자동 validator:
- cost finite/nonnegative
- unreachable requirement 없음
- dependency graph cycle/dead-end
- reward < max safe numeric domain
- progression time simulation

## 13. Simulation

Spreadsheet/script simulation으로 player archetype을 돌린다.

```text
casual 15m/day
engaged 60m/day
power 180m/day
```

Assumption과 실제 analytics를 비교.

## 14. Trading economy

Trading이 있으면 훨씬 더 복잡하다.
Need:
- item uniqueness
- dupe prevention
- transaction lock
- scam-resistant confirmation UX
- price discovery strategy
- supply/sink

거래는 retention feature가 아니라 경제 전체를 바꾸는 architecture decision.

## 15. Monetization interaction

Paid acceleration이 free economy를 무가치하게 만들지 않는지 본다.

Metrics:
- time-to-goal payer/nonpayer
- retention payer/nonpayer
- currency balance distribution
- source/sink by cohort

## 16. Live tuning

Current Roblox Configs 같은 live config를 활용할 수 있지만:
- bounds/defaults
- rollback
- experiment cohort
를 갖는다.

한 번의 hot config로 경제를 10배 바꾸는 것보다 작은 controlled change.

## 17. Analytics taxonomy

Every transaction:
```text
currency
amount
source_or_sink
reasonId
itemId(optional)
progressionContext
```

High-cardinality arbitrary strings 금지.

## 18. Acceptance

- [ ] currency jobs documented
- [ ] source/sink ledger
- [ ] first-session spend
- [ ] progression target times
- [ ] multipliers/caps
- [ ] inflation sinks
- [ ] simulation
- [ ] validators
- [ ] monetization interaction reviewed
- [ ] analytics transaction reasons consistent
