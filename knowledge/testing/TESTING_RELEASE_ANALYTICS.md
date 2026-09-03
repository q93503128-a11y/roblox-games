# Testing, Release & Analytics

> 검증 기준일: 2026-09-03

공식 참고:

- Studio testing modes: https://create.roblox.com/docs/studio/testing-modes
- Output: https://create.roblox.com/docs/studio/output
- Developer Console: https://create.roblox.com/docs/studio/developer-console
- Testing via Studio MCP: https://create.roblox.com/docs/studio/mcp
- Analytics: https://create.roblox.com/docs/production/analytics
- Retention: https://create.roblox.com/docs/production/analytics/retention
- Engagement: https://create.roblox.com/docs/production/analytics/engagement
- Acquisition: https://create.roblox.com/docs/production/analytics/acquisition
- Funnel events: https://create.roblox.com/docs/production/analytics/funnel-events
- Error Report: https://create.roblox.com/docs/production/analytics/error-report
- Crashes: https://create.roblox.com/docs/production/analytics/crashes
- Publishing: https://create.roblox.com/docs/production/publishing/publish-games-and-places

## 1. "코드가 저장됨"은 테스트가 아니다

최소 품질 루프:

```text
변경
→ Studio 실행
→ Output 확인
→ Play
→ 실제 입력
→ 기능 확인
→ edge case
→ Stop
→ Output/metrics 다시 확인
```

AI-assisted 개발에서는 Studio MCP로 이 루프를 가능한 한 자동화한다.

## 2. 테스트 층

### Static

- syntax/type/lint
- formatting
- config/schema
- forbidden pattern scan

### Unit

순수 함수/데이터 변환/경제 공식/loot logic.

### Integration

- service 간 호출
- profile + inventory + economy
- Remote validation
- receipt handling

### Studio Playtest

- DataModel
- physics
- UI
- animation
- character
- client/server

### Multiplayer

- 2+ clients
- race conditions
- trade
- party
- PvP/co-op

### Device

- mobile
- desktop
- gamepad/console 대상
- 낮은 사양

어떤 한 층도 나머지를 완전히 대체하지 못한다.

## 3. Studio testing modes

공식 Studio testing modes를 상황에 맞게 사용한다.

- client simulation
- server/client multi-session
- device emulation
- team/party flow

중요한 multiplayer 기능을 single-player Play 버튼만으로 완료 판정하지 않는다.

## 4. Smoke test

모든 build에서 빠르게 확인:

```text
place opens
server boot completes
player spawns safely
HUD appears
core input works
first interaction works
no red Output errors
reset/respawn works
```

이 단계 실패 시 콘텐츠 테스트로 넘어가지 않는다.

## 5. Vertical slice acceptance

새 프로젝트의 첫 빌드는 기능 수가 아니라 다음으로 판정.

- 맵이 edit mode와 play mode에서 안정적
- spawn void/낙하 없음
- 핵심 루프 5~10분 완주
- 한 전투/행동이 만족스러움
- HUD/메뉴가 장르와 일치
- reward가 명확
- mobile 기본 사용 가능
- Output clean

## 6. Regression checklist

버그를 고쳤다면 같은 종류가 다시 생기지 않게 테스트 항목으로 승격.

예:

```text
BUG: runtime terrain + static terrain 겹쳐 flicker
REGRESSION: edit-time/runtime duplicate geometry scan
```

```text
BUG: enemy body만 이동하고 eyes 분리
REGRESSION: rig/model 이동 시 child visual attachment 확인
```

실패를 문서화하면 개발 품질 자산이 된다.

## 7. Race condition 테스트

Roblox는 event/async가 많다.

검사:

- player joins while world loading
- player leaves during save/trade/purchase
- character respawns during UI action
- two requests arrive nearly simultaneously
- server shutdown while saves pending

`task.wait(1)`로 startup order 문제를 숨기지 않는다. readiness/state dependency를 명시한다.

## 8. Output discipline

red error를 "게임은 돌아가니까" 무시하지 않는다.

분류:

- boot blocker
- repeated runtime error
- warning/deprecation
- asset permission
- network/data store

반복 warning도 log flood와 실제 버그 은폐 원인이 된다.

## 9. Test data

production data에 QA가 의존하지 않게 한다.

- developer/test grants
- deterministic seed
- debug commands
- isolated test profile/place

단, debug/admin 기능은 production 권한 검증.

## 10. CI

파일시스템 프로젝트라면:

```text
lint
format check
unit tests
Rojo/build validation
schema/content validators
forbidden secret scan
```

통과 후 TEST place 배포. LIVE는 별도 승인 단계를 둔다.

Studio-first/Script Sync 프로젝트도 source scripts와 validators를 Git에서 관리할 수 있다.

## 11. TEST vs LIVE

최소:

- local/dev place
- TEST/staging place
- LIVE production

대규모 데이터 migration/monetization/config 변경을 live에서 처음 시험하지 않는다.

## 12. Release checklist

### 기능

- core loop
- onboarding
- save/load
- respawn
- reconnect

### 플랫폼

- mobile
- desktop
- gamepad if supported
- localization layout

### 보안

- Remote audit
- receipt
- admin
- third-party scripts

### 성능

- low-end target
- memory
- high-density combat

### 운영

- analytics
- errors/crashes
- rollback
- version notes

## 13. Analytics는 출시 후 디버거

주요 영역:

### Retention

- D1/D7 등 return behavior
- onboarding과 long-term value의 결과

### Engagement

- session time
- active days
- core loop participation

### Acquisition

- 유입 경로
- conversion

### Monetization

- payer conversion
- revenue behavior

숫자 하나만 목표로 최적화하지 않는다. 예를 들어 session time을 늘리기 위해 불필요한 grind를 넣으면 retention/quality가 나빠질 수 있다.

## 14. Funnel

핵심 flow를 funnel event로 기록.

예:

```text
join
spawn
first_action
first_enemy
first_win
first_reward
first_upgrade
zone_2
session_10m
```

step 간 conversion을 보면 onboarding 막힘을 찾기 쉽다.

## 15. Custom events

기본 dashboard로 답할 수 없는 제품 질문에 사용.

좋은 event:

- 명확한 제품 질문과 연결
- 이름/parameter schema 일관
- 과도한 고빈도 spam 아님

나쁜 event:

- 클릭 하나마다 무작위 name
- 개인정보/불필요 문자열
- 분석 계획 없이 수천 종류

## 16. Error / crash monitoring

출시 후:

- top error
- affected sessions/users
- 새 release와 상관
- crash rate

을 추적한다.

QA에서 못 잡은 device/scale issue가 production에서 나타날 수 있다.

## 17. 업데이트

작은 safe patch와 큰 feature를 구분.

큰 update:

- staging test
- migration plan
- compatibility
- rollback
- analytics hypothesis
- communication

## 18. Experiment

실험은 사용자에게 의미 있는 하나의 변수를 검증한다.

예:

```text
첫 reward 시간
shop entry placement
quest guidance
upgrade cost
```

statistical confidence뿐 아니라 guardrail metric도 본다.

## 19. Human playtest

자동 테스트가 찾기 어려운 것:

- 재미
- 혼란
- 감정
- 장르 감각
- 시각 품질
- 타격감

관찰자가 설명해주지 말고 플레이어가 스스로 하는 것을 본다.

## 20. AI Studio playtest

Studio MCP를 활용하면 반복 가능한 QA를 만들 수 있다.

예:

```text
spawn
→ MoveTo NPC
→ E
→ menu open 확인
→ mouse click purchase
→ server state 확인
→ reset
```

이것은 인간 감각 테스트를 대체하지 않지만 **"아예 작동하지 않는 빌드"가 사용자에게 전달되는 것**을 크게 줄인다.

## 21. 버그 리포트 형식

```text
build/commit:
place:
device:
steps:
expected:
actual:
output/log:
screenshot/video:
repro rate:
severity:
```

## 22. Definition of Done

기능은 다음이 끝나야 Done.

```text
implemented
+ tested
+ error-free in expected path
+ mobile/platform considered
+ security boundary reviewed
+ cleanup/legacy removed
+ docs/data updated
```

"코드를 작성했다"는 Done이 아니다.
