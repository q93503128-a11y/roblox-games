# Analytics Event Taxonomy and Experiments

> verified: 2026-09-03

Official:
- Event types: https://create.roblox.com/docs/production/analytics/event-types
- Funnel events: https://create.roblox.com/docs/production/analytics/funnel-events
- Custom events: https://create.roblox.com/docs/production/analytics/custom-events

## 1. Analytics 목적

데이터를 많이 보내는 것이 아니라 **결정을 바꾸는 질문**을 계측한다.

질문 예:
- FTUE 어디서 이탈?
- 어떤 upgrade에서 진행 정지?
- 어떤 weapon이 거의 안 쓰임?
- gold source/sink 균형?
- shop purchase funnel 어디서 중단?

## 2. Roblox current event categories

Official AnalyticsService/dashboard는 economy, funnel, custom event categories를 제공한다.

Custom events는 current docs 기준 game-specific adoption/behavior/core-loop metric에 사용 가능하고 server/published experience constraints가 있다. 최신 limits를 구현 시 다시 확인한다.

## 3. Naming convention

일관된 lower snake_case 또는 project standard.

Bad:
- `Test1`
- `ButtonClick`
- `NewEventFinal2`

Good:
- `ftue_first_enemy_defeated`
- `inventory_equip_success`
- `boss_attempt_started`
- `ability_used`

## 4. Event vs property

Event name을 동적 ID마다 만들지 않는다.

Bad:
```text
used_fireball
used_iceball
used_dash
```

Better conceptual:
```text
ability_used {abilityId="fireball"}
```

실제 Roblox current custom field API와 cardinality/limits에 맞게 구현.

## 5. FTUE funnel

Suggested project funnel:
1. spawn ready
2. first movement
3. first interaction
4. first core action
5. first reward
6. first upgrade/equip
7. tutorial complete

각 step은 실제 user achievement여야 한다. UI가 화면에 보인 것만으로 completion으로 치지 않는다.

## 6. Progression funnel

Examples:
- zone 1 enter
- first boss
- first class unlock
- first rebirth
- dungeon tier

너무 촘촘하게 모든 level을 funnel step으로 만들지 않는다. 중요한 gates를 고른다.

## 7. Economy

Track sources/sinks 의미를 일관되게.

Examples sources:
- enemy_drop
- quest_reward
- daily_reward
- purchase

Sinks:
- upgrade
- craft
- reroll
- shop

Transaction reason string를 서버 catalog/enum처럼 관리.

## 8. Session/core loop custom metrics

내부 meaningful session 정의 예:
- rounds_completed
- bosses_defeated
- items_crafted
- deliveries_complete

Roblox official Qualified Play signal을 직접 동일한 내부 event로 재현한다고 가정하지 않는다. 내부 KPI는 game design용.

## 9. Error analytics

모든 Lua error를 custom event로 폭탄처럼 전송하지 않는다.

필요한 structured product errors:
- profile_load_failed class
- purchase_reward_failed
- matchmaking_failed

개인/민감 정보를 event parameter에 넣지 않는다.

## 10. Sampling

고빈도:
- every bullet
- every movement step
- every frame
를 analytics event로 보내지 않는다.

Aggregate/sample/server summary를 사용.

## 11. Experiments

A/B test는 "색깔 두 개"보다 중요한 product hypothesis에 우선.

Examples:
- tutorial dialog vs guided arrow
- first reward timing
- default camera distance
- shop timing

Experiment 전:
- hypothesis
- primary metric
- guardrail metric
- duration/sample criteria
를 기록.

## 12. Guardrail metrics

한 metric만 좋아지는 것을 성공으로 보지 않는다.

Example:
- purchase conversion ↑
- but D1 ↓ / bounce ↑
→ monetization prompt가 experience를 해쳤을 수 있음.

## 13. Release annotation

각 주요 update:
```text
release id/date
features
expected metric
risk
```

Analytics chart change를 코드/디자인 update와 연결하기 쉬워진다.

## 14. Dashboard delay

Current Roblox analytics event charts may not be immediate; docs note events can take time (for example daily aggregation/roughly up to 24h for some charts). Real-time debugging channel과 product analytics를 혼동하지 않는다.

## 15. Event versioning

Semantics를 바꿀 때 same event name을 몰래 재사용하지 않는다.
- new field
- schema version
- old event deprecation

## 16. Privacy/minimization

필요한 game behavior만 계측한다.
- secret/token 금지
- arbitrary chat/text 금지
- sensitive personal info 금지

## 17. Analytics acceptance

Vertical Slice:
- [ ] FTUE/core funnel plan
- [ ] core economy source/sink tags if relevant
- [ ] analytics event server ownership
- [ ] no spam/high cardinality design

Release:
- [ ] dashboard event validation
- [ ] update annotation
- [ ] primary + guardrail metrics
