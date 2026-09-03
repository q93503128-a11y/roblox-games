# Game Design, Core Loop & FTUE

> 검증 기준일: 2026-09-03

공식 참고:

- Design games on Roblox: https://create.roblox.com/docs/production/game-design
- Design for Roblox: https://create.roblox.com/docs/production/game-design/design-for-roblox
- Prototyping: https://create.roblox.com/docs/production/game-design/prototyping
- Onboarding: https://create.roblox.com/docs/production/game-design/onboarding
- Onboarding techniques: https://create.roblox.com/docs/production/game-design/onboarding-techniques
- Recommended strategies: https://create.roblox.com/docs/get-started/strategies

## 1. Roblox에서 가장 먼저 이해할 것

Roblox 플레이어는 다른 게임으로 이동하기 매우 쉽다. 그래서 첫 몇 분이 약하면 사용자는 기다려주지 않는다.

Roblox 공식 디자인 자료의 반복 메시지:

- 목표 장르의 인기 게임을 직접 플레이하고 분석
- MVP를 일찍 만들고 피드백 받기
- 플레이테스트를 조기에 자주 수행
- FTUE에서 재미에 빠르게 도달
- 튜토리얼은 필요한 것만, 가능하면 시각적/맥락적으로
- retention/engagement/monetization을 실제 데이터로 반복 개선

## 2. 게임을 시작하기 전 질문

```text
누가 플레이하는가?
첫 30초에 무엇을 하는가?
3분 안에 어떤 재미를 느끼는가?
10분 안에 어떤 성장/발견을 경험하는가?
왜 내일 다시 오는가?
친구와 같이 하면 무엇이 달라지는가?
```

이 질문에 답이 없으면 클래스 수, 아이템 수, 맵 수를 늘리지 않는다.

## 3. Core Loop

Core loop는 반복되는 핵심 행동이다.

예: simulator

```text
행동 → 재화 획득 → 강화 → 더 빠른 행동 → 새 지역/시스템
```

예: action RPG

```text
탐험 → 전투 → 드랍 → build 변화 → 더 어려운 탐험
```

예: roguelite

```text
방 선택 → 전투/위험 → 임시 강화 → 보스 → 영구 성장 → 다음 run
```

좋은 core loop 조건:

- 설명 없이도 행동이 이해 가능
- 각 반복이 너무 길지 않음
- 작은 보상이 자주 존재
- 선택/숙련/랜덤성 중 최소 하나가 반복을 새롭게 만듦
- 다음 목표가 자연스럽게 보임

## 4. Vertical Slice

Vertical slice는 전체 게임의 얕은 복사본이 아니다. **최종 품질 목표를 작은 범위에 압축한 샘플**이다.

RPG라면:

```text
작은 시작 마을
→ 적 2~3종
→ 전투 1개 완성도 높게
→ 드랍/장비
→ 성장 1회
→ 미니 보스
→ 다음 지역을 보여주는 tease
```

이 단계에서 확인할 것:

- 실제로 재미있는가
- 캐릭터 이동이 좋은가
- 카메라가 좋은가
- hit feel이 좋은가
- UI가 장르에 맞는가
- 맵이 Roblox 게임처럼 읽히는가
- 모바일에서도 가능한가

통과 전에는 콘텐츠 50개를 만들지 않는다.

## 5. Reference-first 설계

새 장르를 만들 때 최소 3종 레퍼런스를 둔다.

```text
Primary reference: 전체 core loop / 장르 문법
Combat reference: 입력·카메라·VFX·hit feel
UI/reference: HUD·menu·shop·inventory 문법
```

분석 항목:

- camera distance/FOV
- WalkSpeed/점프 체감
- 첫 적까지 시간
- 전투 한 번 길이
- reward cadence
- UI density
- 버튼 위치
- 몬스터 밀도
- landmark 간 거리
- 첫 upgrade까지 시간
- 첫 "와" 순간

복제할 것은 IP가 아니라 **문법과 수치 관계**다.

## 6. Prototyping과 feature 개발의 차이

공식 문서가 강조하듯 prototype은 빠르게 특정 질문에 답하기 위한 것이다.

예:

"orb combat가 재미있는가?"

필요:

- arena
- 한 적
- orb 1~2종
- 한 클래스
- 타격 피드백

불필요:

- 저장
- 20 클래스
- 거래
- 상점
- 큰 월드

prototype이 재미없는데 시스템을 더 붙여서 살리려고 하지 않는다.

## 7. FTUE — 첫 몇 분

공식 Onboarding 문서는 FTUE의 핵심 목표로:

- D1 retention
- onboarding goals

를 든다.

높은 수준 원칙:

### Teach essentials

필수 조작과 core loop만 가르친다.

### Get to the fun quickly

진행/보상/사회적 요소/스타터 아이템을 너무 늦게 숨기지 않는다.

### Leave players wanting more

짧은/중간/장기 목표를 눈에 보이게 한다.

예:

```text
단기: 첫 검 강화
중기: 다음 지역 해금
장기: 희귀 클래스 / 보스 / 컬렉션
```

## 8. 튜토리얼 방식 우선순위

### 1) 플레이 공간 자체가 가르치기

가장 좋음.

예:

- 첫 적이 한 방향에만 있음
- 첫 상호작용 대상이 자연스럽게 시야 중앙에 있음
- 문/빛/길이 다음 목표를 보여줌

### 2) 시각적 힌트

- Highlight
- bouncing arrow
- world trail
- icon
- animation

### 3) Contextual tutorial

기능을 실제 처음 만났을 때만 설명.

### 4) 짧은 text

정말 필요한 경우.

### 피해야 할 것

게임 시작 즉시 8개 팝업, 2분 dialogue, 메뉴 5개 설명.

## 9. Onboarding funnel

각 중요한 step을 event로 계측한다.

예:

```text
join
spawn_complete
move_first_time
first_enemy_engaged
first_enemy_killed
first_reward_claimed
first_upgrade
first_zone_unlock
session_10min
```

어디서 이탈하는지 모르면 FTUE를 감으로 수정하게 된다.

## 10. Progression pacing

초반은 빠르게.

공식 onboarding 문서도 early level threshold를 낮게 두어 progression을 즉시 체감시키는 예를 든다.

권장 사고:

```text
첫 1분: 무언가 얻음
첫 3분: 눈에 띄는 power increase
첫 5~10분: 새 기능/지역/선택
첫 세션 종료 전: 다음 목표 명확
```

정확한 수치는 장르와 playtest로 조정.

## 11. Moments of joy

보상을 숫자만 올리는 것으로 끝내지 않는다.

- sound cue
- animation
- particle/VFX
- screen motion
- world reaction
- rarity reveal
- progression unlock presentation

단, 모든 행동에 과한 폭죽을 넣으면 중요한 순간의 가치가 사라진다.

## 12. Short / Mid / Long goals

### Short

초 단위~몇 분.

- 적 처치
- 상자
- 작은 upgrade

### Mid

한 세션.

- 지역 unlock
- boss
- quest chain

### Long

여러 세션.

- class evolution
- collection
- prestige/rebirth
- seasonal goal

세 층이 동시에 보여야 장기 retention에 도움이 된다.

## 13. Social 설계

Roblox는 사회적 플랫폼이다.

생각할 것:

- 친구와 같이 들어오면 spawn/party가 자연스러운가
- cooperative reward가 solo를 망치지 않는가
- 다른 플레이어의 멋진 성장 상태가 보이는가
- trade가 있다면 exploit/dupe 방어 가능한가
- PvP가 onboarding을 방해하지 않는가

"멀티플레이 지원"과 "social design"은 다르다.

## 14. 콘텐츠 양보다 변화

RPG 적 50종이 모두:

```text
HP만 다르고 플레이가 같음
```

이면 실질 콘텐츠는 적다.

좋은 확장:

- 다른 telegraph
- 이동 방식
- 공간 압박
- 방어/회피 요구
- build 상성
- 위치/환경 상호작용

## 15. Playtest 질문

사용자에게 "재밌어?"만 묻지 않는다.

관찰:

- 어디로 가야 할지 멈췄는가
- 버튼을 못 찾았는가
- 처음 죽은 이유를 이해했는가
- 보상을 알아차렸는가
- 목표를 스스로 말할 수 있는가
- 어떤 순간에 웃거나 집중했는가
- 어디서 지루해졌는가

## 16. 실패 판단

다음이면 시스템 추가보다 재설계:

- 첫 3분이 재미없음
- 핵심 행동이 불명확
- hit/movement/camera가 불쾌
- UI가 행동을 방해
- 플레이어가 다음 목표를 모름
- 보상이 의미 없음

"컨텐츠가 적어서"라고 자동 결론 내리지 않는다.
