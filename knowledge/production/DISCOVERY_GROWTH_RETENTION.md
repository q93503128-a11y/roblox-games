# Discovery, Growth, Retention, and FTUE

> verified: 2026-09-03
> metrics and algorithms are time-sensitive; re-check official Discovery docs before major acquisition decisions.

Official:
- Discovery: https://create.roblox.com/docs/discovery
- Analytics: https://create.roblox.com/docs/production/analytics
- Onboarding: https://create.roblox.com/docs/production/game-design/onboarding
- Retention: https://create.roblox.com/docs/production/analytics/retention

## 1. 순서가 중요하다

Roblox Analytics의 현재 권장 흐름을 Godbase 기본값으로 사용한다.

1. retention / engagement / monetization 개선
2. 그 다음 acquisition 확대
3. update 후 metrics 지속 모니터링

광고로 나쁜 첫 경험에 사람을 더 붓는 것은 성장 전략이 아니다.

## 2. 현재 Home recommendation 핵심 신호

공식 Discovery 문서의 current signals에는 다음이 포함된다.

Most important:
- Play-through rate
- First-play bounce rate (negative)
  - <60 seconds
  - 61–180 seconds
- Play days per user
  - Day 1
  - Days 2–7
  - Days 8–28
- Playtime per user
  - official current calculation has a 60 min/user/game/day cap

Important:
- intentional co-play days per user
- qualified play sessions per user
- spend days per user
- Robux spent per user

이 signal set은 고정 불변이 아니다. Roblox가 추가/제거/가중치 변경할 수 있으므로 verified date를 유지한다.

## 3. Organic recommendation 해석

현재 공식 설명에서 Recommended for You의 ranking stage는 **Recommended for You를 통해 유입된 사용자 행동**을 중요하게 본다. Ads/search/friends/social 등은 retrieval/exploration 기회를 늘릴 수 있지만, 좋은 organic distribution을 지속시키려면 실제 recommended cohort가 만족해야 한다.

따라서:
- clickbait icon으로 PTR만 올리고 bounce가 폭증하면 실패
- 광고 cohort와 organic cohort를 analytics에서 분리
- update 후 explore spike를 success로 착각하지 말고 subsequent engagement 확인

## 4. FTUE

FTUE는 첫 몇 분의 게임 경험이다.

현재 공식 onboarding 목표:
- teach essentials
- get to fun quickly
- leave players wanting more

### 첫 30초
가능하면 player가 다음 중 하나를 경험해야 한다.
- 움직임/핵심 interaction
- core fantasy
- 첫 명확한 목표

긴 lore text, 여러 menu 선택, 설정 화면으로 시작하지 않는다.

### 첫 3분
- core loop 최소 1회
- 첫 reward
- 다음 goal preview
- 실패해도 회복 가능

### 첫 10분
- progression 의미 확인
- 새로운 choice/feature teaser
- session continuation reason

장르에 따라 시간을 조정하되 실제 funnel로 검증한다.

## 5. Tutorial principles

Teach by doing.

나쁜 예:
`WASD 이동 / E 상호작용 / 클릭 공격`을 8개 textbox로 먼저 읽게 함.

좋은 예:
- move target 5m
- contextual interact
- weak first enemy
- reward pops where needed

Tutorial step마다 funnel event를 만들 수 있다.

```text
ftue_spawn
ftue_first_move
ftue_first_interact
ftue_first_combat
ftue_first_reward
ftue_first_upgrade
ftue_complete
```

## 6. First-play bounce 대응

60초 이전 이탈이 높으면 먼저 확인:
- join/load time
- spawn bug
- controls unclear
- camera uncomfortable
- immediate visual quality
- obvious purpose 없음
- forced dialog/login-style friction

61~180초 이탈이 높으면:
- core loop 재미 부족
- reward delayed
- first failure too punishing
- repetition without new information
- menu/tutorial friction

## 7. D1 retention

D1이 낮을 때 priority:
1. core loop quality
2. FTUE completion
3. performance/stability
4. clear progression promise
5. social entry point where natural

Daily reward만 추가해서 core problem을 덮지 않는다.

## 8. D7/D30

장기 retention에서:
- meaningful progression
- content variety
- collection/mastery
- social relationships
- events/updates
- long-term goals
를 장르에 맞게 조합한다.

Time gate만 늘려 플레이 시간을 강제하는 것은 progression quality가 아니다.

## 9. Social / intentional co-play

Roblox Discovery가 intentional co-play를 current signal로 본다는 사실과 별개로, social feature는 game fantasy와 맞아야 한다.

후보:
- friend spawn
- party
- co-op bonus
- team challenge
- gifting/trading (security high)
- shared boss
- social hub

공식 Developer Modules에서 Friends Locator / Spawn With Friends 등 먼저 검토.

## 10. Qualified play

짧은 accidental session을 늘리는 것보다 실제 core loop를 수행하는 session을 늘린다.

Game-specific qualified action 예:
- complete 1 round
- kill 1 boss
- finish 1 delivery
- craft 1 item
- survive 5 minutes

Roblox official definition과 내부 analytics event를 혼동하지 않되, 내부 meaningful-session KPI를 만든다.

## 11. Metadata / icon / thumbnail

Discovery surface는 게임의 promise다.

- 실제 gameplay fantasy와 일치
- readable at small size
- one focal subject
- no misleading content
- title/description은 core fantasy 설명

PTR을 높이기 위한 A/B는 downstream bounce/retention과 함께 본다.

## 12. Update measurement

업데이트 전 baseline을 저장한다.

```text
D1/D7
first session retention
avg session time
FTUE funnel
play-through rate
first-play bounce
payer conversion (if relevant)
performance errors
```

업데이트 후 cohort를 비교한다.

## 13. Growth anti-patterns

- 광고 먼저, retention 나중
- fake engagement / AFK 유도
- tutorial을 completion reward 때문에 강제로 늘림
- pop-up 연속 노출
- every-session purchase modal
- social invite spam
- recommendation signal을 직접 게임 디자인 목표로 과적합

Roblox 자체도 모든 signal을 기계적으로 optimize하기보다 높은 품질/engagement/accurate metadata를 우선하라고 안내한다.

## 14. Godbase growth gate

Acquisition spend / 큰 promotion 전에:
- [ ] first 3 min structural bugs 없음
- [ ] core loop player feedback positive
- [ ] first session funnel 계측
- [ ] D1 baseline 확보
- [ ] severe device/performance issue 없음
- [ ] monetization blocks tutorial fun 없음

게임이 아직 재미있는지 모르는데 traffic부터 사지 않는다.
