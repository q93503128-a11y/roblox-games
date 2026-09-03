# Genre Reference Matrix

> 검증 기준일: 2026-09-03

이 문서는 장르를 고를 때 "무슨 시스템을 넣어야 하지?"를 맨땅에서 추측하지 않도록 하는 분석 프레임이다. 실제 게임 이름/수치 카탈로그는 지속 조사로 확장한다.

## 공통 조사법

각 장르에서 최소:

- 성공작 5개
- 최근 성장작 3개
- 오래 살아남은 evergreen 2개

를 직접 플레이/영상/공식 페이지로 조사한다.

기록:

```text
first 30 sec
first 3 min
first 10 min
core loop
camera
movement
combat/action cadence
HUD/menu
reward cadence
progression
social
monetization
map density
mobile controls
retention hooks
```

IP/에셋을 복제하지 않고 **장르 문법과 관찰 가능한 관계**를 추출한다.

## 1. Simulator / Incremental

핵심 loop:

```text
action → currency/resource → multiplier/upgrade → new zone/system → faster/bigger action
```

필수 검토:

- 첫 reward가 매우 빠름
- 숫자 성장 가시성
- 다음 unlock이 항상 보임
- collection/pet/gear가 core multiplier와 연결
- rebirth/prestige가 반복 이유를 만듦
- idle/active balance

실패 패턴:

- click만 반복
- upgrade가 숫자 외 플레이 변화를 못 만듦
- pets/eggs를 장르 convention이라서 의미 없이 추가

## 2. Tycoon

loop:

```text
income → build/expand → new production → visual transformation → income
```

중요:

- 기지가 실제로 변하는 만족감
- 다음 purchase 위치 명확
- production chain 읽힘
- 다른 player와 비교/방문

Factory tycoon은 conveyor/worker/machine 관계가 시각적으로 이해되어야 한다.

## 3. Action RPG

loop:

```text
explore → combat → loot/build → power/option change → harder zone/boss
```

필수:

- 이동/카메라
- 기본 공격 하나의 완성도
- enemy role
- build differentiation
- loot가 playstyle을 바꿈
- 지역 landmark/진행 방향

실패:

- 레벨/아이템 수만 많음
- 적은 HP 색깔놀이
- 공격은 Tool touched damage 수준

## 4. Battlegrounds

loop:

```text
spawn → opponent engagement → combo/neutral → KO → immediate re-engagement
```

중요:

- low friction respawn
- 읽히는 move kit
- cancel/stun/i-frame 규칙
- mobile aim/input
- anti-cheat
- training/test 공간

콘텐츠보다 combat feel이 절대 우선.

## 5. Roguelite / Dungeon

loop:

```text
room choice → combat/event → temporary build → risk/reward → boss → meta progression
```

중요:

- run마다 choice가 다름
- build synergy
- room pacing
- recovery/elite/event 배치
- death가 학습/다음 목표로 연결

실패:

- 방 모양만 랜덤이고 경험은 동일
- 임시 강화가 단순 +5%만 반복

## 6. Tower Defense

loop:

```text
wave read → placement → economy → upgrade/coverage → harder wave
```

중요:

- lane/path readability
- range UI
- target priority
- wave composition
- economy decision
- speed controls
- co-op ownership/coordination

UI가 전투를 덮지 않게 한다.

## 7. Horror

loop는 게임마다 다르지만 tension 관리가 핵심.

- information scarcity
- anticipation
- audio
- safe/unsafe rhythm
- chase readability
- social fear/co-op

jumpscare 수보다 pacing과 atmosphere가 중요.

실패:

- 항상 어두워서 아무것도 안 보임
- 큰 소리만 반복
- 죽음 이유 불명확

## 8. Survival / Wave Defense

```text
prepare → threat wave → resource loss/gain → repair/upgrade → escalating threat
```

중요:

- 낮/준비 시간 의미
- resource scarcity
- threat role variety
- base damage readability
- co-op role

웨이브 HP만 늘리는 구조 금지.

## 9. Social / Roleplay

핵심은 시스템보다 player expression/interactions.

- avatar identity
- spaces to gather
- emote/action
- house/vehicle/customization
- low-friction friends join
- safety/moderation

과도한 강제 objective가 social flow를 방해할 수 있다.

## 10. Collection / Creature

```text
find/hatch/catch → collection → upgrade/team → access → rarer collection
```

중요:

- silhouette/rarity desirability
- duplicate usefulness
- collection UI
- team/build choice
- pity/duplicate protection

희귀도 색만 바꾼 duplicate model 남발 금지.

## 11. Obby / Platformer

- movement consistency
- checkpoint cadence
- death/reset friction
- obstacle readability
- difficulty ramp
- camera

장식보다 collision과 movement가 먼저.

## 12. Racing / Vehicle

- vehicle handling
- camera
- track readability
- checkpoint authority
- rubber-banding 필요 여부
- mobile/gamepad
- physics/network ownership

차량 모델이 예뻐도 handling이 나쁘면 실패.

## 13. Shooter

- aim/input
- weapon feedback
- hit registration
- map sightline
- TTK
- spawn
- network/security

client/server 권한과 latency handling을 먼저 설계.

## 14. Party / Minigame

```text
lobby → instantly understandable rules → short round → result/reward → next round
```

- 설명 짧게
- spectator/late join
- round transition
- variety
- social replay

## 15. 장르 혼합 규칙

"RPG + simulator + roguelite + pet + tycoon"처럼 기능 이름을 붙인다고 좋은 hybrid가 되지 않는다.

혼합 전 질문:

```text
primary loop는 무엇인가?
secondary system이 primary loop를 강화하는가?
각 system의 reward currency가 연결되는가?
UI/menu complexity가 감당 가능한가?
```

## 16. 레퍼런스 점수표

게임별 1~5 평가:

| 축 | 질문 |
|---|---|
| FTUE | 첫 3분이 얼마나 빠르고 명확한가 |
| Core feel | 반복 행동 자체가 좋은가 |
| Visual | Roblox 내에서 스타일이 일관적인가 |
| UI | 정보 구조/모바일이 좋은가 |
| Progression | 다음 목표가 보이는가 |
| Variety | 실제 플레이 변화가 있는가 |
| Social | 다른 플레이어가 가치 있는가 |
| Tech | 로딩/성능/버그가 안정적인가 |

평균점 하나보다 **우리 프로젝트가 가져갈 특정 강점**을 적는다.

## 향후 확장

실제 조사 결과는 다음으로 분리한다.

```text
genre/references/
├─ rpg.md
├─ simulator.md
├─ battlegrounds.md
├─ tycoon.md
├─ roguelite.md
├─ tower-defense.md
└─ ...
```

각 문서는 현재 Roblox 시장 변화 때문에 날짜를 반드시 기록한다.
