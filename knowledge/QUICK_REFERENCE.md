# Roblox Godbase Quick Reference

> 검증 기준일: 2026-09-08

이 문서는 새 작업을 시작할 때 2~3분 안에 의사결정을 내리기 위한 Godbase 요약표다. 세부 근거는 각 전문 문서에서 확인한다.

## 0. 무조건 먼저

1. `GODBASE_MANIFEST.json` 확인.
2. 새 게임이면 `genres/STARTER_RECIPE_MATRIX.json`에서 primary genre recipe 선택.
3. 목표 게임과 가장 가까운 **실제 Roblox 레퍼런스**를 정한다.
4. Roblox 공식 Template / Feature Package / Developer Module에 해결책이 있는지 찾는다.
5. 외부 에셋·코드는 출처/라이선스/스크립트부터 검사한다.
6. 게임 전체가 아니라 **5~10분 Vertical Slice** 하나를 먼저 완성한다.
7. Studio Assistant/Agent가 가능하면 현장 inspect/build/visual QA/playtest에 활용한다.
8. Studio MCP가 필요한 경우에만 추가 toolchain으로 사용한다.
9. 맵/배치 작업이면 `level-design/AI_MAP_BUILDING_PLAYBOOK.md`, `level-design/LEVEL_DESIGN_WORLD_TRAVERSAL.md`, Failure `013~022`를 먼저 확인한다.
10. 반복 기능은 처음부터 다시 만들기 전에 `production/REUSABLE_PACKAGE_AND_QA_SYSTEM.md`의 공용 package 후보인지 판단한다.

프로젝트 상시 AI 지침 압축본: `PROJECT_AI_INSTRUCTIONS.md`.

## 개발 방식 선택

| 상황 | 기본 선택 |
|---|---|
| Studio 안에서 AI가 current scene을 보고 직접 제작/수정 | Roblox Studio Assistant / Agent |
| Studio가 맵/모델/UI의 정본이고 코드만 Git 관리 | Studio + Script Sync |
| 외부 AI가 Studio를 직접 inspect/edit/playtest해야 함 | Studio MCP |
| 전체 DataModel을 파일시스템 정본으로 관리 | Rojo |
| CLI 버전을 재현 가능하게 관리 | Rokit |
| Luau 패키지 설치 | Wally |
| 코드 포맷 | StyLua |
| 정적 린트 | selene |
| 외부 편집기 타입/자동완성 | Luau LSP |

기존 프로젝트는 관성적으로 workflow migration하지 않는다. Studio Agent로 충분한 작업에 MCP/Codex/local model을 무조건 추가하지 않는다.

## Roblox Agent 한 줄 원칙

**총감독은 방향과 기준을 만들고, Roblox Agent는 Studio 현장에서 한 구역씩 만들고 직접 확인한다.**

```text
inspect
→ plan
→ review
→ one coherent section
→ visual/runtime test
→ repair
→ next section
```

금지:
- `게임 전체 완성해` one-shot
- 이미 검증된 영역까지 불필요하게 재작성
- plan/acceptance/test route 없이 대규모 변경

정본: `workflow/ROBLOX_ASSISTANT_AGENT_WORKFLOW.md`.

## 맵 / 배치 한 줄 원칙

**좌표부터 찍지 말고, 공간을 먼저 읽는다. Part가 아니라 Map → Zone → Structure → Module 순으로 생각한다.**

필수 순서:
```text
inspect current map
→ floor/spawn/avatar/camera/zone bounds
→ named anchors
→ macro layout
→ placement table if 5+ objects
→ one section placement
→ scale/pivot/ground/clearance
→ gameplay-camera sweep
→ P0 route walk
→ detail/art pass
→ same route replay
```

금지:
- 맵 bounds를 안 보고 world coordinate 추측
- 5개 이상의 player-facing object 즉흥 대량 배치
- freecam만 보고 승인
- avatar 기준 없이 건물/문/상호작용 물체 scale 판단
- 기능은 존재하지만 실제 동선/접근성이 깨진 배치
- production asset을 primitive Parts로 매번 처음부터 조각

정본: `level-design/AI_MAP_BUILDING_PLAYBOOK.md`.

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

### Roblox Packages / Procedural Models

검증된 반복 구조는 Package로 공용화하고, 조정 가능한 반복 구조는 ProceduralModel 후보를 검토한다. 같은 portal/shop/UI/world module을 매 프로젝트 새로 만들지 않는다.

공용 승격:
```text
EXPERIMENTAL
→ PROJECT_PROVEN
→ CROSS_PROJECT_PROVEN
→ GODBASE_PACKAGE
```

정본: `production/REUSABLE_PACKAGE_AND_QA_SYSTEM.md`.

## Studio MCP 한 줄 원칙

**외부 AI가 Studio를 직접 다뤄야 할 때도 AI가 만들었으면 AI가 먼저 실제 사용자 경로로 깨본다.**

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
- zero project-attributable unexpected runtime errors
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

## 테스트 자동화 원칙

반복 가치가 높은 P0 route는 Studio scripted QA 후보로 본다.

공식 Studio-only 도구 후보:
- `StudioTestService`
- `StudioDeviceSimulatorService`
- `VirtualInput`

자동화 후보:
```text
clean boot
spawn
respawn
join/leave
UI open/close
button spam
mobile orientation
multiplayer interaction
primary route
```

완전 자동화를 목표로 하기보다 **사용자가 반복해서 발견하는 구조 버그부터 자동화**한다.

## 성능 원칙

- 먼저 측정하고 최적화.
- Vertical Slice부터 baseline 기록.
- 큰 월드는 Instance Streaming 우선 검토.
- 매 프레임 RunService 최소화.
- `PreloadAsync`는 시작에 정말 필요한 자산만.
- Parallel Luau는 독립적이고 계산량 큰 작업에만.
- 저사양 모바일을 target matrix에 포함.
- Performance Summary → Scene Analysis → 필요 시 MicroProfiler.

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
- project-attributable unexpected Output error 0
- spawn 정상
- P0 primary route 완주
- viewport/gameplay-camera visual 검토
- detached parts / z-fighting 없음
- major map object overlap/floating/burial 없음
- avatar/world scale 자연스러움
- desktop + mobile 핵심 UI
- 필요한 multiplayer route
- valuable state server authority
- known limitations 기록

통과 전에는 `INTERNAL_PROTOTYPE`.

## 출시 후 개선

느낌만으로 수정하지 않는다. 가능한 경우 AnalyticsService의:
- Funnel
- Economy
- Custom events
를 이용해 onboarding, core loop, progression, shop, ability usage 같은 실제 행동을 측정한다.

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
- https://create.roblox.com/docs/assistant/guide
- https://create.roblox.com/docs/studio/mcp
- https://create.roblox.com/docs/studio/testing-modes
- https://create.roblox.com/docs/projects/assets/packages
- https://create.roblox.com/docs/parts/procedural-models
- https://create.roblox.com/docs/performance-optimization/scene-analysis
- https://create.roblox.com/docs/production/analytics/event-types
- https://create.roblox.com/docs/scripting/sync
- https://create.roblox.com/docs/resources/templates
- https://create.roblox.com/docs/resources/feature-packages
- https://create.roblox.com/docs/resources/modules
- https://create.roblox.com/docs/scripting/security/security-tactics
- https://create.roblox.com/docs/discovery

AI 개발 근거 인덱스: `research/AI_ROBLOX_SOURCES_2026-09-08.md`.
