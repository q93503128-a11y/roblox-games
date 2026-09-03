# Data, Economy & LiveOps

> 검증 기준일: 2026-09-03

공식 참고:

- Data Stores: https://create.roblox.com/docs/cloud-services/data-stores
- Memory Stores: https://create.roblox.com/docs/cloud-services/memory-stores
- DataStore vs MemoryStore: https://create.roblox.com/docs/cloud-services/data-stores-vs-memory-stores
- Cross-server messaging: https://create.roblox.com/docs/cloud-services/cross-server-messaging
- Secrets: https://create.roblox.com/docs/cloud-services/secrets
- Virtual economy balance: https://create.roblox.com/docs/production/game-design/balance-virtual-economies
- Monetization foundations: https://create.roblox.com/docs/production/game-design/monetization-foundations
- Economy events: https://create.roblox.com/docs/production/analytics/economy-events
- Experience configs: https://create.roblox.com/docs/production/configs
- Experiments: https://create.roblox.com/docs/production/experiments

## 1. 데이터 분류

데이터를 저장 방식보다 먼저 분류한다.

### Persistent player data

- progression
- inventory
- currency
- settings
- quests
- unlocks

→ DataStore/ProfileStore 계열.

### Temporary cross-server data

- matchmaking queue
- temporary reservation
- server browser metadata
- fast ephemeral leaderboard/cache

→ MemoryStore 계열.

### Cross-server notification

- global announcement
- live config change notification
- server coordination

→ MessagingService/cross-server messaging.

### Static content

- item catalog
- enemy definitions
- level tables

→ source-controlled ModuleScript/data, runtime DataStore에 넣지 않는 것을 기본으로.

## 2. Profile schema

profile은 versioned schema로 관리한다.

예:

```lua
{
    SchemaVersion = 4,
    Currency = { Gold = 0, Gems = 0 },
    Inventory = {},
    Equipment = {},
    Progression = { Level = 1, XP = 0 },
    Unlocks = {},
    Settings = {},
}
```

원칙:

- nil 의미를 명확히
- default를 중앙 정의
- migration path
- unique item ID가 필요하면 명시
- 값 하나씩 흩어진 DataStore key로 저장하지 않음

## 3. Session locking

같은 player profile이 두 서버에서 동시에 쓰이면 duplication/data loss 위험이 있다.

일반 player progression에는 ProfileStore 같은 session-locking persistence layer를 우선 검토.

## 4. Save 전략

- 서버 memory가 현재 session state의 working copy
- autosave
- PlayerRemoving
- BindToClose
- 중요 transaction은 crash/retry를 고려

값 하나 변할 때마다 DataStore 호출하지 않는다.

## 5. Migration

schema 변경은 피할 수 없다.

```text
v1 → v2
v2 → v3
```

각 migration은:

- deterministic
- idempotent에 가깝게
- missing field 대응
- legacy 이상값 정리
- 실패 시 데이터 손실 최소화

live data를 코드에서 임의 reset하지 않는다.

## 6. 경제의 Source와 Sink

### Source

재화를 생성한다.

- enemy drops
- quests
- daily reward
- paid grant
- trading이 아닌 system reward

### Sink

재화를 제거한다.

- upgrades
- crafting
- reroll
- shop purchase
- entry fee

경제가 source만 있고 sink가 없으면 inflation. sink가 과도하면 progression이 막힌다.

## 7. 경제 표

각 currency에 기록:

```text
purpose
sources
sinks
average per minute/session
hard/soft currency
tradeable?
paid relationship
cap?
inflation risk
```

currency를 이유 없이 여러 종류 만들지 않는다.

## 8. Progression curve

레벨/업그레이드 cost는 공식만 예쁘게 만드는 것이 목적이 아니다.

측정:

- 첫 upgrade 시간
- session당 upgrades
- 다음 zone unlock 시간
- power increase 체감
- returning player catch-up

초반은 빠른 feedback, 이후 목표 길이를 점진적으로 늘리는 것이 일반적이지만 실제 analytics/playtest로 튜닝.

## 9. Reward table

드랍은 data-driven.

```text
id
weight/chance
quantity range
requirements
pity/protection
unique rule
```

서버에서 roll. client가 rarity/result를 결정하지 않는다.

## 10. RNG와 pity

랜덤 보상은 frustration을 관리해야 한다.

- pity/guarantee 필요 여부
- duplicate protection
- expected attempts
- reward가 paid random item 정책에 해당하는지

유료 랜덤 아이템은 Roblox 정책을 최신 문서로 반드시 재확인.

## 11. Developer Products

소모성 구매.

핵심:

- ProcessReceipt authoritative
- idempotent reward
- receipt 재처리 대응
- UI에서 가격/상품 ID를 흩어 하드코딩하지 않음
- 실제 구매 성공과 UI success presentation 분리

## 12. Passes

영구 entitlement에 적합.

- server에서 ownership 확인
- 구매 직후와 재접속 모두 반영
- 기능이 명확해야 함

## 13. Subscriptions / pricing

Roblox 수익화 기능은 빠르게 변한다. subscriptions, regional/managed pricing 등은 구현 시점 최신 공식 문서를 읽는다.

## 14. Monetization 원칙

좋은 수익화:

- 핵심 재미를 강화
- 구매 가치가 명확
- 반복 사용 가치 또는 convenience/cosmetic
- non-payer도 게임을 이해하고 즐길 수 있음

피해야 할 것:

- 첫 30초 강제 purchase spam
- progress를 일부러 파괴해 구매 강요
- 허위 할인/허위 stock
- confusing confirmation
- paywall 때문에 FTUE가 멈춤

## 15. Economy analytics

AnalyticsService economy events로:

- source
- sink
- balance
- item/category

를 관찰한다.

질문:

- 어떤 source가 inflation을 만드는가
- upgrade가 어디서 막히는가
- 특정 sink가 무시되는가
- paid/non-paid progression 격차가 어떻게 되는가

## 16. LiveOps

LiveOps는 매주 이벤트 하나 던지는 것이 아니다.

구성:

- content calendar
- event configuration
- rewards
- analytics goal
- rollback
- communication

코드 배포 없이 바꿔야 하는 값은 Experience Config/remote config 패턴을 검토.

## 17. Config-driven content

예:

```text
DoubleXP.enabled
DoubleXP.multiplier
EventShop.catalog
BossEvent.spawnRate
DailyReward.tableVersion
```

모든 balance 값을 remote config로 만들지는 않는다. 잘못 바뀌면 경제를 파괴하는 값에는 guardrail과 validation 필요.

## 18. Experiment

A/B 테스트는 하나의 명확한 가설을 검증.

예:

```text
가설: 첫 upgrade를 20% 싸게 하면 FTUE completion이 오른다.
```

동시에 UI, reward, enemy HP, map을 모두 바꾸면 원인을 알기 어렵다.

## 19. Daily/weekly reward

- time source 서버 기준
- timezone/calendar 정의
- duplicate claim 방지
- streak semantics 명확
- missed day punishment가 과도하지 않음
- reward inflation 관리

## 20. Leaderboard

persistent ordered leaderboard와 temporary session leaderboard를 구분.

- global rank update 빈도 제한
- display cache
- exploit-created score validation
- season reset/archive 정책

## 21. Tradeable economy

거래를 넣는 순간 게임 경제 난도가 크게 증가한다.

필요:

- item identity
- rarity/value control
- dupe prevention
- transaction audit
- trade lock
- scam UX 방지
- account restriction 정책

"거래는 인기 기능"이라는 이유만으로 초기에 넣지 않는다.

## 22. 데이터 복구 사고

출시 전 답해야 함:

```text
profile load 실패 시?
save 실패 시?
두 서버 session 충돌 시?
schema migration 실패 시?
paid receipt 처리 중 crash 시?
아이템 지급 후 저장 전 crash 시?
```

복구 전략 없는 경제는 아직 production-ready가 아니다.

## 23. 운영 체크

- [ ] schema version
- [ ] session locking
- [ ] autosave/close
- [ ] migration tests
- [ ] receipt idempotency
- [ ] currency sources/sinks 표
- [ ] reward tables server-side
- [ ] analytics economy events
- [ ] live config validation
- [ ] rollback 계획
- [ ] exploit/dupe test
