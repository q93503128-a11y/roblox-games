# Monetization, LiveOps, Events, and Notifications

> verified: 2026-09-03
> monetization/policy details are time-sensitive. Always re-check official Creator Hub before shipping.

## 원칙

수익화는 core loop를 방해하는 popup layer가 아니라 게임의 가치 교환이다.

좋은 방향:
- convenience
- expression/cosmetics
- meaningful optional content
- fair progression acceleration
- transparent bundle/value

나쁜 방향:
- fake discount
- forced purchase repetition
- unclear randomized paid outcome
- misleading currency
- purchase prompt during every failure

Official monetization hub:
https://create.roblox.com/docs/production/monetization

## 1. Passes

일회성 entitlement.
Use:
- permanent feature/perk
- access/cosmetic privilege

Server verifies ownership when gameplay value is granted.

## 2. Developer Products

repeatable purchases.

Critical rule:
**reward is granted through server `ProcessReceipt` flow and must be idempotent.**

Never trust:
- button click as proof of purchase
- client saying purchase succeeded

Receipt may be retried. Duplicate reward 방지 ledger/state 필요.

## 3. Subscriptions

Recurring benefit가 실제로 recurring value를 제공할 때 사용. 최신 regional/platform eligibility와 policy를 공식 docs에서 다시 확인한다.

## 4. Paid access / private servers / avatar commerce / ads

Roblox가 제공하는 monetization surface는 계속 변한다. 프로젝트 기획 시 official monetization index에서 현재 지원 상태와 eligibility를 확인한다.

## 5. Economy design

Currency마다 source/sink를 정의한다.

```text
Currency: Gold
Sources: combat, quests, sell
Sinks: upgrades, crafting, reroll
Inflation control: scaling costs, consumable sinks
```

Premium currency와 earnable currency가 섞일 때 UI에서 명확히 구분한다.

## 6. Pricing source of truth

price를 UI 여러 script에 하드코딩하지 않는다.
- catalog/server config
- Marketplace current info where appropriate
- Configs for game-side tunable values if suitable

Client price display가 server purchase calculation의 authority가 아니다.

## 7. Bundles

공식 Feature Package `Bundles`를 custom implementation 전에 검토한다.

Bundle design:
- 구성 item 명확
- discount/value calculation transparent
- owned items handling 정의
- limited/availability messaging accurate

## 8. Missions / Season Pass

공식 Feature Packages:
- Missions
- Season Passes
- Engagement Rewards

LiveOps foundation으로 먼저 분석한다. 자체 system을 만들면:
- objective schema
- progress source
- claim idempotency
- season reset
- timezone/server consistency
- old season migration
을 설계.

## 9. LiveOps architecture

LiveOps는 매번 code deploy를 요구하지 않는 것이 이상적이다.

Current Roblox cloud Configs는:
- read-only in-game
- cross-server
- feature flags/tuning
에 적합하다.

후보:
- event enabled
- enemy multiplier
- limited shop rotation id
- welcome message

Critical reward logic 자체를 untrusted text config처럼 설계하지 않는다.

## 10. Experience events

Current official event system은 experience update/event promotion과 notification flow에 활용할 수 있다.

Official:
https://create.roblox.com/docs/production/promotion/experience-events

Use for:
- scheduled update
- limited event
- seasonal content

Player join context가 필요한 경우 current `GetJoinData()` docs와 event integration을 확인한다.

## 11. Experience notifications

Official:
https://create.roblox.com/docs/production/promotion/experience-notifications

현재 eligibility/frequency는 정책 변화 가능성이 높다. verified date 없는 숫자를 permanent Godbase rule로 만들지 않는다.

좋은 notification:
- personalized
- actionable
- player가 opt-in reason을 이해
- 실제 content/event와 연결

나쁜 notification:
- generic 광고 문구
- 의미 없는 "come back now"
- 과도한 frequency

## 12. Creator Rewards

Current reward program 세부 기준은 time-sensitive. 공식 current page를 release/planning 시 다시 확인:
https://create.roblox.com/docs/creator-rewards

Godbase 원칙:
Reward program의 특정 threshold를 게임 디자인의 영구 목표로 hard-code하지 않는다. 프로그램이 바뀌어도 좋은 게임이 남아야 한다.

## 13. Shop UX

Shop open 시:
- category
- owned/equipped state
- exact cost
- purchase consequence
- confirm only when needed

Purchase success:
- server confirmation 후 UI 반영
- duplicate click lock
- failure message

## 14. Ethical progression

좋은 monetization은 free loop를 의도적으로 고장내고 해결책을 파는 구조가 아니다.

평가 질문:
- 결제 안 해도 core fantasy가 성립하는가?
- 구매 value가 명확한가?
- 청소년 user에게 오해를 유발하지 않는가?
- randomized paid item policy를 지키는가?

## 15. Analytics

Monetization을 볼 때 revenue만 보지 않는다.
- conversion
- ARPPU
- retention by payer/nonpayer
- purchase funnel
- refund/complaint context
- first purchase timing

첫 3분에 purchase prompt를 넣어 conversion이 조금 올라도 bounce/D1이 나빠지면 전체적으로 실패일 수 있다.

## 16. LiveOps release checklist

- [ ] start/end time server-consistent
- [ ] config rollback
- [ ] old servers behavior
- [ ] reward idempotency
- [ ] event assets preloaded only when needed
- [ ] analytics events
- [ ] localized copy
- [ ] mobile UI
- [ ] shop after event end
- [ ] save migration
- [ ] exploit/rate limit

## 공식 부품 우선
Feature Packages:
https://create.roblox.com/docs/resources/feature-packages

Event Sequencer:
https://create.roblox.com/docs/resources/modules/event-sequencer
