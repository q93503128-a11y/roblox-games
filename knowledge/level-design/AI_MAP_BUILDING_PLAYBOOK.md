# AI Map Building Playbook — Roblox

> verified: 2026-09-08
> status: canonical execution guide for AI-assisted world building

이 문서는 AI가 Roblox 맵을 만들 때 반복해 온 좌표 추측, 스케일 오류, 동선 붕괴, 에셋 짜깁기, 검증 없는 대량 배치를 줄이기 위한 실행 정본이다.

핵심 결론은 단순하다.

> **AI에게 더 잘 상상하라고 시키는 것보다, AI가 낮은 수준의 좌표 결정을 덜 하게 하고, 계층·상대배치·검증 루프를 강제하는 편이 훨씬 안정적이다.**

관련 정본:
- `LEVEL_DESIGN_WORLD_TRAVERSAL.md`
- `../regressions/FAILURE_LIBRARY.md`
- `../testing/AUTOMATED_ACCEPTANCE_GATES.md`
- `../workflow/ROBLOX_ASSISTANT_AGENT_WORKFLOW.md`

---

## 1. Map is not a pile of Parts

AI는 맵을 다음 계층으로 생각한다.

```text
Experience
→ Map
→ Zone / District / Floor
→ Room / Arena / Building / Route
→ Reusable Module
→ Individual Part
```

큰 맵을 개별 `Part.Position` 목록으로 직접 설계하지 않는다.

권장 예:

```text
Hub
├─ SpawnPlaza
├─ UpgradeDistrict
├─ PortalDistrict
├─ ShopLane
└─ SocialLandmark
```

각 zone 안에서만 세부 구조를 만든다.

### 실패 신호
- 수십~수백 개 Part의 절대 좌표가 먼저 등장함.
- zone 경계/동선보다 개별 prop 위치가 먼저 정해짐.
- 건물을 만들기 전에 나무·돌·장식부터 뿌림.

---

## 2. Design top-down, place bottom-up

설계 순서:

```text
player fantasy
→ first 30 sec / 3 min / 10 min
→ main loop
→ spatial grammar
→ zones
→ routes
→ landmarks
→ activity nodes
→ reusable structures
→ assets
→ decoration
```

실제 제작은 작은 검증 단위로 진행한다.

```text
zone shell
→ main route
→ one landmark
→ one activity
→ verify
→ next section
```

전체 맵을 한 번에 생성한 뒤 한 번만 검사하지 않는다.

---

## 3. Inspect before coordinates

기존 맵을 수정할 때 AI는 좌표를 쓰기 전에 최소 다음을 읽는다.

```text
playable bounds
floor / terrain contact
spawn transform
avatar reference size
camera distance / FOV
main route centerline
zone bounds
existing landmark pivots
critical doors / portals / interactables
```

새 맵에서도 먼저 reference rig, floor/grid, zone bounds를 만든다.

측정하지 않은 공간에 `Vector3.new(...)`를 감으로 배치하지 않는다.

---

## 4. Prefer anchors and relative placement

절대 world coordinate보다 의미 있는 anchor를 사용한다.

예:

```text
HubCenter
HubNorthGate
UpgradeBay
PortalApproach
ArenaA_Entry
ArenaA_Center
RewardSocket_A
```

그 뒤:

```text
PortalA = HubNorthGate 기준 남쪽 8 studs
UpgradeNPC = UpgradeBay 입구 기준 안쪽 4 studs
Sign = Door top 기준 1.5 studs 위
```

처럼 배치한다.

### 왜 중요한가
- zone 이동 시 모든 child placement를 다시 계산할 필요가 줄어듦.
- 크기 변경 후 좌표 덧칠이 줄어듦.
- 인접 오브젝트 관계가 문서화됨.

---

## 5. Touching geometry must be mathematically related

벽, 문, 간판, 계단, 창문, trim, railing처럼 서로 맞닿아야 하는 것은 독립 좌표로 두지 않는다.

기본 원칙:
- reference face
- local offset
- bounding box
- half-size
- pivot
- raycast contact
을 이용한다.

예:

```text
part center Y = support top Y + part height / 2
```

terrain 위 오브젝트는 가능하면 위에서 아래로 raycast하여 실제 접촉면을 구한다.

외부 모델은 pivot이 바닥에 있다고 가정하지 않는다.

---

## 6. Placement table for bulk work

player-facing object를 5개 이상 배치할 때는 먼저 최소 표를 만든다.

```text
object | role | zone/anchor | footprint | facing | front clearance | neighbor | forbidden overlap
```

예:

```text
UpgradeTerminal | progression | UpgradeBay | 10x6 | faces route | 8 | near NPC | main route
PortalA         | travel      | NorthGate  | 14x4 | faces hub   | 12| visible from spawn | shop queue
```

이 표가 없으면 대량 배치를 시작하지 않는다.

---

## 7. Calibrate scale with an avatar, not with intuition

major asset마다 R15 reference rig 또는 실제 player avatar와 비교한다.

확인:
- doorway width/height
- corridor width
- stairs
- counter height
- interaction reach
- camera clearance
- combat arena diameter
- multiplayer crowd space

실제 에셋 bounding box뿐 아니라 **player가 접근하고 카메라가 돌아갈 공간까지 footprint**로 본다.

기본 숫자는 프로젝트 reference를 우선하고, 표준 치수는 임시 calibration 용도로만 사용한다.

---

## 8. Reference games: copy spatial grammar, not surface art

레퍼런스에서 다음을 측정한다.

```text
spawn → first objective distance/time
main path width
major landmark visibility
activity node spacing
safe vs combat rhythm
hub service walking time
branch count
vertical range
return route
camera obstruction points
```

좋은 맵의 핵심은 건물 모양 복제가 아니라 **공간 관계**다.

예:
- spawn에서 가장 중요한 activity가 바로 읽힘
- 주요 서비스가 지나친 왕복 없이 연결됨
- 다음 목표가 현재 보상 지점에서 보임
- 큰 landmark가 방향 기준 역할을 함

---

## 9. Build one section at a time

큰 맵/건물은 다음처럼 pass를 나눈다.

```text
PASS 1  playable terrain + boundary
PASS 2  spawn / first vista
PASS 3  main route
PASS 4  primary landmark
PASS 5  first activity district
PASS 6  secondary district
PASS 7  route transitions
PASS 8  production assets
PASS 9  props / lighting / atmosphere
PASS 10 gameplay-camera QA
```

각 pass마다 검증한다.

**잘못된 기준으로 300개 배치한 뒤 수정하는 것보다 30개씩 10번 검증하는 것이 낫다.**

---

## 10. Reuse modules instead of sculpting everything from Parts

AI는 production asset을 매번 primitive Parts로 새로 조각하지 않는다.

검토 순서:
1. Roblox Engine/official feature
2. Roblox Package
3. official/approved asset
4. audited Creator Store model
5. ProceduralModel
6. generated mesh
7. reusable internal module
8. custom Parts/CSG

맵 제작 AI의 핵심 역할은 모든 오브젝트를 직접 미술 제작하는 것이 아니라:
- 공간 구성
- 선택
- 조합
- 배치
- 검증
이다.

검증된 `Shop`, `Portal`, `Door`, `ArenaShell`, `Fence`, `CliffEntrance`, `QuestStation` 모듈을 재사용하면 geometry 오류가 줄고 스타일 일관성이 올라간다.

---

## 11. Use constraints for procedural placement

절차적 배치는 무작위 좌표 분사가 아니다.

최소 constraint:

```text
valid region
min separation
path clearance
landmark exclusion
slope limit
ground contact
biome/style set
max density
camera/readability rule
```

예: 나무 배치

```text
sample XZ
→ downward raycast
→ reject if main path buffer
→ reject if building footprint
→ reject if slope too steep
→ reject if too close to another tree
→ place using hit surface
```

---

## 12. Visual QA must include gameplay camera

Studio freecam에서 예쁜 것은 승인 기준이 아니다.

각 중요한 area에서:
- entry
- center
- interaction position
- combat position
- wall-near camera
- high/low elevation
을 본다.

필수 확인:
- landmark가 보이는가
- 길이 읽히는가
- interactable이 가려지지 않는가
- 건물이 카메라를 삼키지 않는가
- foreground prop가 UI/캐릭터를 과도하게 가리지 않는가

가능하면 screenshot/playtest agent를 사용한다.

---

## 13. Geometry QA

맵/건물 배치 후:
- floating
- buried
- clipping
- z-fighting
- accidental overlap
- detached pieces
- wrong pivot/orientation
- route blockage
- invisible collision trap
을 검사한다.

가능하면 spatial query / bounds / raycast / overlap / clipping tools를 사용한다.

눈대중만으로 geometry correctness를 주장하지 않는다.

---

## 14. Art pass cannot break level design

production assets를 넣은 뒤 graybox 동선을 다시 검사한다.

자주 생기는 회귀:
- 나무/돌이 route를 좁힘
- 고퀄 건물이 landmark를 가림
- 장식 collision 때문에 캐릭터가 걸림
- VFX/lighting 때문에 objective visibility가 낮아짐
- 외부 모델 scale이 district scale과 충돌

따라서:

```text
graybox pass
→ art pass
→ same P0 route replay
```

가 필수다.

---

## 15. Roblox Assistant / Agent role

Studio 안의 Agent가 사용할 수 있다면 맵 현장 작업은 Agent가 우선 후보다.

역할 분담:

```text
Strong planning model / Godbase
= game direction, reference analysis, spatial plan, acceptance criteria

Roblox Studio Agent
= current scene inspection, actual placement, asset/model generation, viewport-aware refinement, playtest
```

Agent에게 `make the whole map` 한 번으로 맡기지 않는다.

대신:

```text
plan
→ review
→ one section build
→ screenshot/playtest
→ compare against acceptance
→ repair
→ next section
```

루프를 사용한다.

---

## 16. Map Definition of Done

맵/허브/대형 room은 다음을 모두 만족하기 전 `DONE`이 아니다.

- [ ] zone hierarchy가 명확함
- [ ] spawn에서 첫 목표를 이해 가능
- [ ] main route가 읽힘
- [ ] landmark hierarchy 존재
- [ ] gameplay-camera screenshot 검토
- [ ] avatar scale calibration
- [ ] important interactable clearance
- [ ] ground contact / pivot 정상
- [ ] 주요 overlap/clipping 없음
- [ ] graybox P0 route가 art pass 후에도 유지
- [ ] mobile readability 확인
- [ ] 실제 플레이로 spawn → core activity → reward/progression walk-through

---

## 17. Sources / evidence

S-grade official:
- https://create.roblox.com/docs/assistant/guide
- https://create.roblox.com/docs/studio/mcp
- https://create.roblox.com/docs/parts/procedural-models
- https://create.roblox.com/docs/projects/assets/packages
- https://create.roblox.com/docs/studio/testing-modes
- https://about.roblox.com/newsroom/2026/04/roblox-studio-going-agentic

A/B implementation reference:
- https://github.com/ColinEdw/RobloxStudioMCP
  - `skills/roblox-building/SKILL.md`
  - MIT License

커뮤니티 구현의 tool name이나 수치는 Roblox 공식 기능처럼 취급하지 않는다. 여기서 가져오는 것은 **section-by-section build, relative placement, orthographic/visual verification, clipping-aware iteration** 같은 일반화 가능한 workflow 원칙이다.
