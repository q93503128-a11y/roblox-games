# Studio MCP Autonomous Build Harness

> 검증 기준일: 2026-09-04

이 문서는 Roblox Godbase의 **AI가 Studio 안에서 직접 만들고, 실행하고, 보고, 고치는 표준 루프**다. 목표는 `.rbxlx`를 바깥에서 추측 생성한 뒤 사용자가 첫 테스터가 되는 실패 방식을 폐기하는 것이다.

## 공식 근거

현행 Roblox Studio MCP는 Studio에 내장되어 있으며 다음 계열을 공식 제공한다.

- script: `script_read`, `multi_edit`, `script_search`, `script_grep`
- asset/content: `search_asset`, `insert_asset`, `generate_mesh`, `generate_material`, `generate_procedural_model`
- DataModel: `search_game_tree`, `inspect_instance`, `subagent`
- Luau: `execute_luau`
- playtest: `get_studio_state`, `start_stop_play`, `get_console_output`, `screen_capture`
- input: `character_navigation`, `user_keyboard_input`, `user_mouse_input`
- docs/skills: `http_get`, `skill`
- session: `list_roblox_studios`

공식 source:
- https://create.roblox.com/docs/studio/mcp
- Roblox/creator-docs `content/en-us/studio/mcp.md`

각 MCP call은 `studio_id`를 명시하므로 여러 Studio 창이 열려 있을 때도 대상 place를 명시적으로 고정한다.

## AI 개발의 기본 원칙

```text
inspect before edit
→ small coherent edit
→ static sanity check
→ Play
→ exercise actual user route
→ read Output
→ capture viewport
→ compare against acceptance contract/reference
→ fix
→ replay
```

**Play 없이 완료 판정 금지.**

## Phase 0 — Target lock

1. `list_roblox_studios`
2. 대상 Studio의 name/placeId/studioId 확인
3. 작업 시작 로그에 studioId 기록
4. 다른 Studio 창에는 쓰기 금지

같은 이름의 local place가 여러 개면 이름만 보고 작업하지 않는다.

## Phase 1 — Reconnaissance

쓰기 전에 최소 확인:

- `search_game_tree`: 주요 서비스/폴더/스크립트 구조
- `script_search` / `script_grep`: 현재 구현과 중복 기능
- `inspect_instance`: 수정할 instance의 properties/attributes/children
- project README / Godbase domain docs

금지:
- 기존 architecture를 보지 않고 새 서비스/Remote 중복 생성
- 같은 기능을 새 파일로 덧칠
- `Workspace` 전체를 무작정 재생성

## Phase 2 — Build with evidence

우선순위:

```text
current engine capability
→ official template / feature package / developer module
→ approved Godbase OSS
→ approved Creator Store asset
→ custom implementation
```

Creator Store asset은 `search_asset`으로 발견했다고 production place에 즉시 삽입하지 않는다. scripted/unknown asset은 Godbase quarantine pipeline을 거친다.

`multi_edit`은 관련 변경을 한 operation으로 묶되, 거대한 전면 rewrite는 피한다. 수정 뒤 `script_read` 또는 `script_grep`으로 핵심 invariant가 반영됐는지 확인한다.

## Phase 3 — Clean boot gate

1. `get_studio_state`
2. 필요 시 Play 중지
3. `start_stop_play`로 새 Play Client 시작
4. spawn 완료까지 합리적 대기
5. `get_console_output`

즉시 FAIL:
- runtime error
- infinite yield가 핵심 기능을 막음
- player가 spawn하지 않음
- primary UI가 생성되지 않음
- 핵심 서비스 bootstrap 중단

warning은 무조건 실패가 아니지만 원인/영향을 분류한다.

## Phase 4 — Functional route

실제 플레이어처럼 검증한다.

예:

```text
spawn
→ 이동
→ NPC/버튼/문/적 접근
→ mouse/keyboard interaction
→ primary mechanic 실행
→ reward/state 변화 확인
→ 실패/취소/재시도
```

도구:
- `character_navigation`: 위치/instance까지 이동
- `user_keyboard_input`: 스킬, 이동, 메뉴, 텍스트 입력
- `user_mouse_input`: 버튼/월드 상호작용/스크롤
- `execute_luau` Client/Server: 관찰 가능한 state 검사

테스트를 통과시키려고 production-only 로직을 직접 우회하거나 임의 state를 주입하면 안 된다. `execute_luau`는 **관찰/테스트 fixture**용이지 실제 사용자 경로 대체물이 아니다.

## Phase 5 — Visual gate

`screenshot` 역할은 `screen_capture`가 담당한다.

필수 기본 샷:
- initial spawn
- primary gameplay camera
- 핵심 상호작용/전투
- 주요 UI open state
- 실패/피격 등 중요한 feedback state

평가:
- 화면 번쩍임/z-fighting
- 겹침/클리핑/분리된 model parts
- 카메라 framing
- UI safe area와 hierarchy
- asset scale/style 일관성
- VFX telegraph/readability
- placeholder가 production art로 오인되는지

가능하면 reference screenshot과 동일한 구도/거리의 비교 샷을 만든다.

## Phase 6 — Repair loop

한 번의 loop:

```text
failure evidence
→ root cause hypothesis
→ smallest coherent repair
→ clean boot
→ exact failed route replay
→ broader regression replay
```

상한 없이 무작정 patch하지 않는다. 같은 symptom이 3회 반복되면 architecture/root cause를 재조사한다.

## Phase 7 — Device simulation

`StudioDeviceSimulatorService`는 외부 MCP tool/Plugin에서 Studio Device Simulator를 programmatically 제어할 수 있다.

최소 UI-heavy project matrix:
- 360×640 phone portrait
- 390×844 phone portrait
- 412×915 phone portrait
- 768×1024 tablet
- 1280×720 desktop
- 1920×1080 desktop

검사:
- clipping
- touch target
- scrolling
- text wrapping/localization expansion
- safe insets
- modal stacking
- HUD가 gameplay를 가리는지

Device Simulator의 해상도/DPI override는 session-level일 수 있으므로 테스트 후 상태를 복구한다.

## Phase 8 — Multiplayer automation

단일 MCP `start_stop_play`는 한 Play Client에 적합하다. 멀티클라이언트 race/join/leave/lobby/matchmaking 검증은 `StudioTestService`를 사용한다.

현행 공식 capability:
- server + multiple simulated clients
- staggered player add
- test arguments
- client leave/disconnection
- server-driven EndTest
- 한 test session 최대 8 simulated clients

필수 후보 시나리오:
- 2인 동시 join
- host/owner leave
- mid-round late join
- 거래/공유 state 동시 수정
- reward 중복 수령 경쟁
- Remote spam/중복 action
- matchmaking/lobby transition

## Phase 9 — Performance evidence

visual pass가 곧 performance pass가 아니다.

필요 시:
- SceneAnalysisService via MCP
- MicroProfiler capture/analysis
- repeated asset/VFX/NPC worst case
- StreamingEnabled 이동 테스트
- low-end mobile device profile

측정 없는 `최적화됨` 선언 금지.

## Completion gate

AI가 `READY_FOR_USER_TEST`라 부르려면 최소:

```text
[ ] target Studio locked
[ ] current tree/code inspected
[ ] clean boot
[ ] unexpected runtime error 0
[ ] primary user route completed by simulated input/navigation
[ ] failure/retry path checked when relevant
[ ] screenshot visual review completed
[ ] model attachment/pivot/collision sanity
[ ] required device profiles checked
[ ] multiplayer scenarios checked when relevant
[ ] server-authoritative valuable state verified
[ ] known limitations explicitly listed
```

이보다 낮으면 `INTERNAL_PROTOTYPE`다.

## Never do

- 사용자에게 Studio Output 확인을 첫 QA 단계로 떠넘기기
- Play하지 않은 파일을 `완성`이라고 부르기
- screenshot 없이 visual quality를 추정하기
- free model script를 실행한 뒤 감사하기
- 단일 client test로 multiplayer-safe라고 결론내기
- desktop 한 해상도만 보고 responsive UI라고 결론내기
- 실패 원인을 모르면서 patch를 누적하기

## Godbase integration

관련 정본:
- `knowledge/workflow/AI_STUDIO_AUTONOMOUS_PLAYTEST.md`
- `knowledge/testing/AUTOMATED_ACCEPTANCE_GATES.md`
- `knowledge/testing/DEVICE_NETWORK_TEST_MATRIX.md`
- `knowledge/assets/CREATOR_STORE_HARVESTER_AND_QUARANTINE_PIPELINE.md`
- `knowledge/regressions/FAILURE_LIBRARY.md`
- `knowledge/performance/PERFORMANCE_AND_STREAMING.md`

이 harness의 최종 목적은 **사용자는 첫 디버거가 아니라 최종 감각/기획 reviewer가 되는 것**이다.
