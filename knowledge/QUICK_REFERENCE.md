# Roblox Godbase Quick Reference

> 검증 기준일: 2026-09-04

이 문서는 새 작업을 시작할 때 2~3분 안에 의사결정을 내리기 위한 Godbase 요약표다. 세부 근거는 각 전문 문서에서 확인한다.

## 0. 무조건 먼저

1. `GODBASE_MANIFEST.json` 확인.
2. 새 게임이면 `genres/STARTER_RECIPE_MATRIX.json`에서 primary genre recipe 선택.
3. 목표 게임과 가장 가까운 **실제 Roblox 레퍼런스**를 정한다.
4. Roblox 공식 Template / Feature Package / Developer Module에 해결책이 있는지 찾는다.
5. 외부 에셋·코드는 출처/라이선스/스크립트부터 검사한다.
6. 게임 전체가 아니라 **5~10분 Vertical Slice** 하나를 먼저 완성한다.
7. Studio MCP가 가능하면 AI가 user보다 먼저 실제 Playtest한다.

## 개발 방식 선택

| 상황 | 기본 선택 |
|---|---|
| Studio가 맵/모델/UI의 정본이고 코드만 Git 관리 | Studio + Script Sync |
| AI가 Studio 안을 읽고 수정하고 플레이테스트 | Studio MCP |
| 전체 DataModel을 파일시스템 정본으로 관리 | Rojo |
| CLI 버전을 재현 가능하게 관리 | Rokit |
| Luau 패키지 설치 | Wally |
| 코드 포맷 | StyLua |
| 정적 린트 | selene |
| 외부 편집기 타입/자동완성 | Luau LSP |

기존 프로젝트는 관성적으로 workflow migration하지 않는다.

## 신규 게임 장르 route

현재 starter recipe:

- Action RPG / Open World
- Battlegrounds / Fighting
- Simulator / Collection
- Tycoon / Management
- Tower Defense
- Horror / Run-based
- Survival / Extraction / Co-op
- Round / Minigame
- Social / Roleplay
- Shooter / Arena

각 recipe는 first slice와 **content breadth 전에 반드시 통과할 quality gate**를 정의한다.

## 구현하기 전에 공식 부품 확인

### Templates

Platformer, Laser Tag, FPS, Racing, Combat 등 현행 공식 starting experience가 목적에 맞는지 먼저 확인한다.

### Feature Packages

Core / Bundles / Missions / Season Passes / Engagement Rewards 등은 백엔드·UI·analytics 관행까지 포함할 수 있으므로 custom 구현 전에 검토한다.

### Developer Modules

Friends Locator, Spawn With Friends, Emote Bar, Profile Card, Scavenger Hunt, Event Sequencer 등 목적이 맞는 공식 모듈을 먼저 검토한다.

## Studio MCP 한 줄 원칙

**AI가 만들었으면 AI가 먼저 Studio에서 실제 사용자 경로로 깨본다.**

표준:

```text
inspect
→ edit
→ Play
→ navigate/input
→ Output
→ screenshot
→ compare
→ fix
→ replay
```

필수 후보:

- explicit Studio target
- clean boot
- P0 route
- zero unexpected runtime errors
- key visual states
- required device profiles
- 필요한 multiplayer scenarios
- known limitations

정본: `workflow/STUDIO_MCP_AUTONOMOUS_BUILD_HARNESS.md`, `testing/MCP_PLAYTEST_CONTRACT_SCHEMA.json`.

## 서버 / 클라이언트 원칙

**클라이언트는 intent를 보내고 서버가 결과 state를 결정한다.**

서버 최종 판정:

- 돈/재화/아이템
- 구매 보상/영수증
- 드랍/가챠 결과
- XP/레벨/퀘스트
- 거래 소유권
- 중요한 전투 판정
- 영구 저장 상태

Remote 입력은 타입, 값 범위, 문자열/테이블 크기, 인스턴스 소유권, 거리, 진행상태, 호출 빈도를 검증한다.

## 데이터 서비스 선택

| 필요 | 서비스 |
|---|---|
| 영구 플레이어 진행/인벤토리 | DataStore / 검증된 profile wrapper |
| 영구 숫자 순위 | OrderedDataStore |
| 빠른 크로스서버 임시 상태/매치메이킹 | MemoryStore |
| 런타임 읽기 전용 tuning/flag | Configs |
| 외부 API key/token | Secrets Store |
| 한 서버 즉시 상태 | Luau memory |

ProfileStore는 player profile/session locking 후보이지 global state/leaderboard 만능 도구가 아니다.

## 성능 원칙

- 먼저 측정하고 최적화.
- 큰 월드는 Instance Streaming 우선 검토.
- 매 프레임 RunService 최소화.
- `PreloadAsync`는 시작에 정말 필요한 자산만.
- Parallel Luau는 독립적이고 계산량 큰 작업에만.
- 저사양 모바일을 target matrix에 포함.
- MicroProfiler/Scene Analysis/Performance Summary로 원인 확인.

## UI / 입력 원칙

- PC만 보고 완료 판정 금지.
- touch / keyboard+mouse / gamepad의 핵심 행동 확인.
- Input Action System 우선 검토.
- safe zone, thumb reach, text legibility, focus navigation, dynamic sizing 확인.
- 실제 reference UI의 정보 구조/시각 언어를 먼저 분석.

## 전투 원칙

좋은 전투는 `damage code`가 아니라:

```text
input latency
+ anticipation
+ animation
+ hit timing
+ hitstop
+ sound/VFX
+ camera
+ knockback
+ enemy telegraph
+ arena/readability
+ recovery
```

한 무기/한 적부터 전체 사이클을 완성한 뒤 콘텐츠를 늘린다.

## Creator Store 원칙

무료 모델/에셋은 바로 production에 넣지 않는다.

```text
search
→ metadata triage
→ quarantine Studio audit
→ visual review
→ production-fit test
→ S/A/B/C/REJECT
```

검사:

- Script / LocalScript / ModuleScript
- numeric `require(assetId)`
- loadstring / HTTP / InsertService 계열
- dependency / referenced asset IDs
- pivot / scale / collision / rig
- style fit / mobile / repeated placement cost
- creator/source/license/attribution

구체적인 security report는 높은 평균 평점보다 우선한다.

## 현재 legacy 함정

- Knit → archived
- TestEZ → archived
- ProfileService → 신규는 ProfileStore 우선
- BridgeNet2 → 신규 기본값 금지
- 옛 BodyMover/task/input 고정패턴 → current API 확인
- old tutorial의 fixed-pixel/mobile-무시 UI → 금지
- Free Model scripts 무검사 실행 → 금지

정본: `catalogs/DEPRECATED_LEGACY_WATCHLIST.md`, `catalogs/LIBRARY_CATALOG.json`.

## 사용자 테스트 전 최소 gate

- clean boot
- unexpected Output error 0
- spawn 정상
- P0 primary route 완주
- viewport screenshot 검토
- detached parts / z-fighting 없음
- desktop + mobile 핵심 UI
- 필요한 multiplayer route
- valuable state server authority
- known limitations 기록

통과 전에는 `INTERNAL_PROTOTYPE`.

## 출시 전 우선순위

1. crash/error/performance
2. first-play bounce / FTUE friction
3. D1 retention + first-session retention
4. core loop engagement
5. D7/D30 progression
6. monetization value alignment
7. acquisition/discovery scaling

## 공식 출발점

- https://create.roblox.com/docs/llms.txt
- https://create.roblox.com/docs/studio/mcp
- https://create.roblox.com/docs/scripting/sync
- https://create.roblox.com/docs/resources/templates
- https://create.roblox.com/docs/resources/feature-packages
- https://create.roblox.com/docs/resources/modules
- https://create.roblox.com/docs/scripting/security/security-tactics
- https://create.roblox.com/docs/performance-optimization
- https://create.roblox.com/docs/discovery
