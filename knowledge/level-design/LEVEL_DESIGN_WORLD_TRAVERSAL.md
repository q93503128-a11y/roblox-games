# Level Design, World Composition, and Traversal

> verified: 2026-09-08

Roblox 월드는 오브젝트를 많이 배치하는 작업이 아니라 **플레이어의 시선·이동·전투·보상·탐험을 공간으로 설계하는 작업**이다. Procedural/random placement는 이 의도를 확장하는 도구이지 대체재가 아니다.

## 0. Mandatory AI map placement protocol

AI가 맵이나 player-facing object를 배치할 때는 **좌표를 바로 쓰지 않는다.** 먼저 현재 공간을 측정하고 anchor를 만든다.

### Step 0 — inspect before placement

최소 기록:
```text
world/reference origin
playable floor Y or terrain contact method
spawn transform
avatar reference height/width
camera distance/FOV
zone/room bounds
main route centerline
existing landmark pivots
critical doors/portals/interactables
```

기존 맵에서는 현재 DataModel/Studio 상태를 먼저 읽는다. 새 맵에서도 avatar reference rig와 floor/reference grid를 먼저 둔다.

### Step 1 — macro layout before assets

순서:
```text
spawn
→ first objective
→ main route
→ major zones/rooms
→ landmark
→ encounter/reward nodes
→ progression/service nodes
→ side routes
→ production assets
→ micro decoration
```

건물/상점/NPC/포탈/업그레이드 기계부터 개별적으로 찍어 넣지 않는다.

### Step 2 — named anchor + local offset

가능하면 raw world coordinate 대신:
```text
HubCenter
HubNorthGate
UpgradeBay
PortalApproach
ArenaA_Center
ArenaA_Entry
RewardSocket_A
```
같은 의미 있는 anchor를 만들고 그 기준 local offset으로 배치한다.

이렇게 해야 zone 이동/크기 변경 때 배치가 함께 수정 가능하고 좌표 덧칠이 줄어든다.

### Step 3 — placement table for bulk work

player-facing object를 5개 이상 한 번에 추가하면 먼저 최소 표를 만든다.

```text
object | role | anchor/zone | footprint | facing | clearance | required neighbor | forbidden overlap
```

예:
```text
UpgradeTerminal | progression | HubCenter east | 10x6 | faces center | 8 studs front | near spawn | not in main route
PortalA         | travel      | HubNorthGate   | 14x4 | faces south  | 12 studs front| visible from spawn | not behind shop
```

### Step 4 — scale calibration

각 major asset은 Roblox avatar와 같이 비교한다.

확인:
- doorway height/width
- counter/table height
- corridor width
- combat arena diameter
- interactable reach
- camera clearance
- multiplayer crowd space

asset의 visual bounding box만 보지 않고 **실제 플레이에 필요한 clearance까지 footprint**로 취급한다.

### Step 5 — ground contact and pivot

terrain/floor 배치에서는 pivot Y를 ground Y라고 가정하지 않는다.

우선순위:
1. authored socket/anchor
2. known flat floor plane
3. raycast ground contact
4. model bottom offset calculation

경사면 전용이 아닌 건물/기계는 억지로 slope에 붙이지 않는다.

### Step 6 — gameplay-camera validation

Editor freecam approval 금지.

각 major area에서 최소:
- entry
- center
- wall-near/corner
- interaction point
- combat point if applicable

를 실제 gameplay camera로 확인한다.

### Step 7 — walk the route

배치가 끝났다는 기준은 `Instance가 존재함`이 아니다.

실제로:
```text
spawn
→ first objective
→ core activity
→ reward/progression
→ next objective
```
를 걸어서 확인한다.

체크:
- 불필요한 왕복
- 막다른 길
- 너무 긴 빈 이동
- 과밀한 허브
- prompt 접근 방해
- NPC/prop collision
- 시야 차단

### Stop-the-line

다음 중 하나면 decoration/content 확장 금지:
- spawn에서 first objective를 공간적으로 이해하기 어려움
- major object가 겹치거나 뜨거나 파묻힘
- main route가 art asset에 의해 막힘
- gameplay camera에서 landmark/interactable이 가려짐
- 핵심 기능 배치가 긴 불필요 왕복을 만듦
- avatar 기준 scale이 명백히 어색함

## 1. Graybox first

Production asset을 넣기 전에 graybox에서 확인한다.
- spawn에서 첫 목표가 보이는가
- main route / side route가 구분되는가
- landmark가 방향을 잡아주는가
- 전투 공간이 카메라와 이동 속도에 맞는가
- 이동 시간과 encounter 간격이 의도한 pacing인가

Graybox가 재미없으면 나무와 PBR을 추가해도 구조는 그대로 재미없다.

## 2. Critical measurements

프로젝트마다 실제 숫자를 기록한다.
```text
walk speed / sprint speed
jump height/time
avatar reference dimensions
camera distance/FOV
main path width
combat arena typical diameter
interactable approach clearance
landmark visibility distance
spawn → first fun time
encounter → reward interval
hub → activity travel time
```

레퍼런스 게임도 같은 항목으로 측정한다.

## 3. Landmark hierarchy

월드에는 규모 단계가 필요하다.
- macro: 산, 성, 거대 타워, 도시 스카이라인
- meso: 건물, 교량, 큰 나무, 던전 입구
- micro: 표지판, 상자, 장식 prop

모든 것이 landmark면 아무 것도 landmark가 아니다.

## 4. Path readability

길을 화살표 UI로만 해결하지 않는다.
공간 자체로 유도:
- contrast
- light
- opening/frame
- terrain slope
- prop orientation
- landmark
- NPC/activity placement

UI objective marker는 보조 수단.

## 5. Encounter spacing

Combat game에서 enemy placement는 decoration이 아니다.

체크:
- 첫 enemy는 mechanic을 안전하게 학습시키는가
- 여러 enemy의 aggro가 우연히 겹치지 않는가
- retreat space가 있는가
- ranged/melee가 공간을 다르게 쓰는가
- respawn point와 즉시 전투가 겹치지 않는가

## 6. Traversal rhythm

좋은 route는 계속 같은 밀도가 아니다.

예:
`safe hub → short travel → light encounter → vista/reward → stronger encounter → branching choice → landmark`.

긴 빈 복도와 끊임없는 전투 둘 다 fatigue를 만든다.

## 7. Verticality

높낮이는 시야/탐험/전투를 풍부하게 하지만:
- camera occlusion
- fall recovery
- pathfinding
- mobile control
- ranged advantage
를 함께 검토한다.

Jump가 가능한 game이면 railing/edge/fall state를 실제 플레이로 검증.

## 8. Hub design

Hub는 메뉴를 3D로 펼쳐 놓는 곳이 아니다.

좋은 hub:
- spawn orientation clear
- 가장 중요한 activity가 가깝고 눈에 띔
- NPC/shop 사이 이동이 지루하지 않음
- social congregation spot
- future unlock이 visual tease로 보임

기능 NPC를 원형으로 무작정 늘어놓지 않는다.

Hub 배치 시 각 기능의 `role → route → neighbor → clearance`를 먼저 정하고 좌표는 마지막에 정한다.

## 9. Biome transition

Biome 변화는 색 하나만 바꾸지 않는다.
- silhouette
- material
- foliage density
- terrain profile
- ambient audio
- lighting/fog restraint
- enemy composition
- traversal grammar
을 단계적으로 바꾼다.

Transition zone을 두면 abrupt visual cut을 줄일 수 있다.

## 10. Procedural generation

Procedural은 constraints 기반이어야 한다.

좋은 parameter:
- valid placement regions
- density bands
- min separation
- landmark exclusion zones
- path clearance
- biome palette
- slope limits

`Random.new():NextNumber()`로 전월드 좌표를 뿌리는 것은 production level design이 아니다.

Procedural placement도 anchor/path/clearance를 침범하면 실패다.

## 11. Streaming-aware world

큰 월드:
- StreamingEnabled 검토
- spawn/critical path stream availability
- far gameplay object client assumption 금지
- quest/objective state와 streamed Instance 분리
- decorative persistence 최소화

## 12. Navigation and NPCs

Navmesh visualization으로:
- door widths
- stairs/slopes
- obstacles
- agent radius/height
- jump/climb
를 확인한다.

Art pass 후 navmesh가 망가졌는지 regression.

## 13. Collision discipline

Visual detail ≠ collision detail.
- small props player collision off 후보
- simple collision proxies
- invisible wall은 이유/경계 readable
- weapon/projectile collision semantics defined

플레이어가 예쁜 돌멩이마다 걸리면 art가 gameplay를 망친다.

## 14. Camera sweep

각 area를 실제 gameplay camera로:
- entry
- center
- corner
- wall near
- combat
- high/low elevation
에서 screenshot review.

Editor freecam에서 예쁘다는 이유로 승인하지 않는다.

## 15. Reward placement

Reward는 다음 동선을 가르칠 수 있다.
- chest 위치
- drop direction
- quest NPC
- upgrade shrine

보상 직후 다음 landmark가 시야에 들어오도록 구성하면 flow가 자연스럽다.

## 16. Mobile/world scale

모바일은 화면이 작다.
- 너무 작은 interactable
- 얇은 weapon/enemy telegraph
- 멀리 있는 tiny marker
- 과도한 dense props
를 피한다.

## 17. Reference study sheet

레퍼런스 월드에서 area 하나를 골라 기록:
```text
entry composition
main route length
route width
landmark count
encounter count
safe pockets
vertical range
reward locations
side-route return method
camera obstruction points
```

표면을 복사하지 말고 spatial grammar를 배운다.

## 18. Acceptance

- [ ] current map bounds/anchors를 읽고 배치함
- [ ] 5개 이상 bulk placement면 placement table 존재
- [ ] avatar reference와 major asset scale 비교
- [ ] graybox route 자체가 이해됨
- [ ] spawn → first fun 시간 측정
- [ ] landmark hierarchy
- [ ] no random prop soup
- [ ] combat spaces fit camera/movement
- [ ] interactable approach/crowd clearance
- [ ] no floating/buried major asset
- [ ] navmesh/pathfinding smoke
- [ ] no collision clutter
- [ ] streaming behavior if large world
- [ ] mobile readability
- [ ] gameplay-camera sweep
- [ ] main route 직접 walk-through
- [ ] production art 후 route readability 유지

관련 regression:
- `../regressions/FAILURE_LIBRARY.md` RBLX-FAIL-013 ~ RBLX-FAIL-022
