# Roblox Assistant / Agent Workflow

> verified: 2026-09-08
> status: canonical operating guide when Roblox Studio Assistant/Agent is available

Roblox Studio Agent는 전체 게임의 총감독이 아니라 **Studio 현장 작업자 + QA 보조자**로 사용한다.

현재 Roblox는 Assistant와 Studio를 `Plan → Build → Test` agentic loop 방향으로 확장하고 있으며, Playtesting Agent Beta는 code/data model/log를 분석하고 player character를 QA tester로 활용할 수 있다.

공식 근거:
- https://about.roblox.com/newsroom/2026/04/roblox-studio-going-agentic
- https://create.roblox.com/docs/assistant/guide
- https://create.roblox.com/docs/studio/mcp

---

## 1. Role split

### Planning / supervision model
담당:
- game fantasy
- core loop
- reference selection and analysis
- progression/content architecture
- spatial grammar
- acceptance criteria
- failure/root-cause analysis
- Godbase routing

### Roblox Studio Assistant / Agent
담당:
- current Studio/DataModel inspection
- actual instance placement and editing
- scripts tied to the inspected scene
- Creator Store search/asset insertion where appropriate
- mesh / material / procedural model generation where appropriate
- viewport-aware refinement
- playtest and log inspection when supported

### Human tester
담당:
- fun
- taste
- feel
- direction
- final visual judgment

사용자는 spawn failure, dead button, missing map 같은 structural QA의 첫 발견자가 되어서는 안 된다.

---

## 2. Never one-shot a large game

금지:

```text
"완성도 높은 RPG 맵 전체와 모든 시스템을 만들어"
```

대신:

```text
1. inspect current state
2. plan one coherent slice
3. human/supervisor review
4. build one section
5. inspect visual/runtime result
6. fix
7. mark verified
8. next section
```

복잡한 작업은 계획을 먼저 리뷰 가능한 형태로 만든 뒤 실행한다.

---

## 3. Required prompt anatomy

Agent에게 작업을 줄 때 최소 포함:

```text
GOAL
CURRENT CONTEXT
DO NOT CHANGE
REFERENCE / STYLE
SPATIAL OR SYSTEM CONSTRAINTS
ACCEPTANCE CRITERIA
TEST ROUTE
STOP CONDITIONS
```

예:

```text
GOAL: Hub의 Portal District 제작.
CURRENT: SpawnPlaza와 UpgradeBay는 검증 완료.
DO NOT CHANGE: SpawnPlaza, progression scripts, existing package instances.
REFERENCE: clean readable simulator hub, not fantasy medieval.
CONSTRAINTS: portal visible from spawn; main route >= project standard; no raw random scatter.
ACCEPTANCE: avatar scale natural, portal front clearance, no route blockage, gameplay-camera visibility.
TEST: spawn → portal approach → interact → return.
STOP: existing verified zone가 깨지면 신규 작업 중단 후 원인 보고.
```

---

## 4. Plan review gate

Build 전에 plan에서 검사:
- 사용자가 원하지 않은 rewrite/migration
- 이미 검증된 영역의 불필요한 변경
- 너무 큰 작업 단위
- placeholder를 production으로 오해
- reference 부재
- spatial measurement 부재
- test route 부재

위 항목이 있으면 plan을 먼저 고친다.

---

## 5. Map/visual work rule

맵은 `../level-design/AI_MAP_BUILDING_PLAYBOOK.md`가 정본이다.

Agent는:
- scene inspect
- bounds/anchor/scale 확인
- one section build
- screenshot/viewport 검토
- geometry correction
- gameplay camera review
순으로 진행한다.

에셋을 많이 넣는 것이 progress가 아니다.

---

## 6. Generated asset policy

Roblox Assistant/MCP는 mesh, material, ProceduralModel 등 생성 기능을 제공할 수 있다.

사용 원칙:
- hero asset은 생성 결과를 반드시 visual review
- generated model scale/pivot/collision 확인
- 스타일 일관성 확인
- 반복 가능한 구조는 ProceduralModel 또는 Package 후보 검토
- 생성량 제한/현재 기능 상태는 사용 직전 공식 문서 재확인

생성형 asset을 썼다는 사실만으로 production-ready가 아니다.

---

## 7. Creator Store policy

Agent가 Creator Store asset을 찾더라도 바로 production promotion하지 않는다.

`discovery → source/security audit → quarantine → visual fit → production test`

관련:
- `../assets/CREATOR_STORE_RED_FLAGS_AND_QUARANTINE.md`
- `../assets/CREATOR_STORE_SUPPLY_CATALOG.json`
- `../SOURCE_POLICY.md`

---

## 8. Playtesting rule

가능한 경우 Agent의 playtesting 기능을 이용해 사용자보다 먼저 P0 route를 실행한다.

확인:
- clean boot
- spawn
- navigation/input
- primary interaction
- reward/state transition
- respawn/reset where relevant
- Output/log
- visual state

현재 Agent가 특정 테스트를 안정적으로 자동화하지 못하면 `StudioTestService`, `StudioDeviceSimulatorService`, `VirtualInput` 기반 scripted QA를 검토한다.

공식:
https://create.roblox.com/docs/studio/testing-modes

---

## 9. Stop-the-line

다음이면 다음 section/content 생성 중단:
- project-attributable runtime error
- spawn/world missing
- primary route broken
- verified area regression
- major scale/layout failure
- severe mobile blocker
- reward/save/purchase duplication risk

두 번 이상 같은 구조 실패가 나면 좌표/조건 덧칠을 멈추고 architecture/workflow를 재평가한다.

---

## 10. What to send back to supervisor

각 coherent section 종료 시:

```text
CHANGED
OBSERVED
TESTED
FAILED/FIXED
KNOWN LIMITATIONS
NEXT SAFE STEP
```

"완료" 한 단어로 끝내지 않는다.

---

## 11. Recommended Roblox project workflow

```text
Godbase + strong planning model
        ↓
reference / design / acceptance
        ↓
Roblox Assistant Agent plan
        ↓
review/edit plan
        ↓
Agent builds one section
        ↓
Agent/Studio QA
        ↓
scripted P0 tests where valuable
        ↓
human feel review
        ↓
generalizable failure → Godbase
```

MCP/Codex 같은 외부 agent는 필요할 때 추가한다. Studio Assistant가 작업을 충분히 수행한다면 불필요하게 tool stack을 복잡하게 만들지 않는다.
