# Level Design, World Composition, and Traversal

> verified: 2026-09-03

Roblox 월드는 오브젝트를 많이 배치하는 작업이 아니라 **플레이어의 시선·이동·전투·보상·탐험을 공간으로 설계하는 작업**이다. Procedural/random placement는 이 의도를 확장하는 도구이지 대체재가 아니다.

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
camera distance/FOV
main path width
combat arena typical diameter
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

- [ ] graybox route 자체가 이해됨
- [ ] spawn → first fun 시간 측정
- [ ] landmark hierarchy
- [ ] no random prop soup
- [ ] combat spaces fit camera/movement
- [ ] navmesh/pathfinding smoke
- [ ] no collision clutter
- [ ] streaming behavior if large world
- [ ] mobile readability
- [ ] production art 후 route readability 유지
