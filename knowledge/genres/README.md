# Roblox Genre Starter Recipes

> 검증 기준일: 2026-09-04

이 디렉터리는 새 Roblox 프로젝트를 `빈 Baseplate + 기억`에서 시작하지 않게 하는 **장르별 실전 시작 정본**이다.

## 사용 순서

1. `GODBASE_MANIFEST.json`의 공통 mandatory read를 먼저 읽는다.
2. 이 README에서 가장 가까운 장르 1개를 primary recipe로 고른다.
3. hybrid game이면 secondary recipe는 최대 2개까지만 추가한다.
4. 실제 reference game 1개를 primary, 2~4개를 secondary로 선정한다.
5. `STARTER_RECIPE_MATRIX.json`에서 필요한 Godbase domain 문서/공식 template/asset/테스트 계약을 뽑는다.
6. 5~10분 vertical slice만 먼저 완성한다.
7. Studio MCP가 가능하면 AI가 사용자보다 먼저 Play → 조작 → Output → screenshot → 수정 루프를 반복한다.

## 공통 Discovery/Retention 원칙

Roblox 공식 Discovery는 2026-09-04 기준 다음 신호를 특히 중요하게 본다.

- play-through rate
- first-play bounce rate (<60s, 61~180s)
- play days per user
- playtime per user
- intentional co-play days
- qualified play sessions

따라서 모든 recipe는 **첫 60초 이해 가능성, 첫 3분의 보상/표현, 첫 세션의 완결된 루프, 다시 올 이유**를 포함해야 한다.

공식 근거:
- https://create.roblox.com/docs/discovery
- https://create.roblox.com/docs/production/analytics
- https://create.roblox.com/docs/production/analytics/retention

## 장르별 정본

- `ACTION_RPG_OPEN_WORLD.md` — 액션 RPG / 성장 / 탐험 / 보스
- `BATTLEGROUNDS_FIGHTING.md` — arena/battlegrounds PvP
- `SIMULATOR_COLLECTION.md` — 수집/업그레이드/반복 루프 simulator
- `TYCOON_MANAGEMENT.md` — 건설/경영/자동화 tycoon
- `TOWER_DEFENSE.md` — wave/tower/upgrade/co-op 전략
- `HORROR_RUN_BASED.md` — room/run 기반 공포
- `SURVIVAL_EXTRACTION_COOP.md` — 생존/원정/loot/귀환 co-op
- `ROUND_MINIGAME.md` — 역할/라운드/짧은 재시작 게임
- `SOCIAL_ROLEPLAY.md` — 목적 없는 social/RP sandbox
- `SHOOTER_ARENA.md` — arena/duel/arcade shooter

## Reference를 쓰는 법

Reference에서 복제하지 말고 아래 축을 측정한다.

- 첫 입력까지 걸리는 시간
- 첫 보상까지 걸리는 시간
- 카메라 거리/FOV/속도
- 이동/전투 cadence
- UI 점유율과 정보 계층
- 맵 landmark/동선/밀도
- 반복 루프 길이
- failure → retry 시간
- social contact가 일어나는 지점
- 어떤 progression이 세션을 끝내지 못하게 하는지

## 금지

- 장르명만 보고 generic template 생성
- reference 없이 UI를 취향대로 그림
- 시스템 10개를 넣고 핵심 루프를 나중에 테스트
- 첫 세션이 재미없는데 장기 retention 시스템부터 제작
- IP 캐릭터/맵/코드/에셋 직접 복제
- 인기 게임의 숫자/경제를 근거 없이 그대로 복사

## 완료 기준

장르 recipe 적용 결과가 `READY_FOR_USER_TEST`가 되려면 최소:

- clean boot
- P0 route 직접 완주
- 예상치 못한 Output error 0
- 첫 60초 내 목적 이해 가능
- primary loop 최소 3회 반복 가능
- reference와 나란히 볼 visual evidence 존재
- desktop + mobile 핵심 UI 확인
- server-authoritative valuable state
- regression route 기록

그 전에는 `INTERNAL_PROTOTYPE`이다.
