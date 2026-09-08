# Failure Library — Roblox Development Regressions

> established: 2026-09-03
> status: mandatory reading for new Roblox AI/development work

이 문서는 실패를 숨기지 않고 **재발 방지 규칙**으로 바꾼다. 새 문제를 발견하면 `증상 → 원인 → 왜 놓쳤나 → 올바른 workflow → regression gate` 형식으로 추가한다.

---

## RBLX-FAIL-001 — Blind `.rbxlx` generation without Studio validation

### 증상
- 파일은 생성됐지만 Studio에서 실제로 보면 맵/모델/UI가 품질 목표와 크게 다름.
- runtime error가 사용자 테스트에서 처음 발견됨.
- 개발자가 코드/XML만 보고 '될 것'이라고 판단.

### 원인
Studio 밖에서 `.rbxlx` XML을 추측 생성하고 실제 Roblox renderer/physics/DataModel/Play mode를 보지 않은 채 handoff.

### 왜 놓쳤나
- code correctness를 game correctness와 혼동.
- user를 첫 playtester로 사용.
- visual comparison loop 없음.

### 올바른 workflow
가능하면 Studio MCP를 통해:
`inspect → edit → Play → console → input → screenshot → fix → repeat`.

### Regression gate
- 사용자 handoff 전 clean Playtest 최소 1회.
- project-attributable unexpected Output error 0.
- viewport screenshot review.
- primary loop 직접 완주.

---

## RBLX-FAIL-002 — Runtime world generator as single point of failure

### 증상
HUD는 뜨는데 map이 없음 / void.

### 실제 사례 유형
Server bootstrap script의 world generation 이전 한 줄에서 error가 발생해 이후 Spawn/Map/NPC 생성 전체가 중단됨.

### 원인
critical world와 bootstrap이 하나의 긴 runtime script에 묶임.

### 올바른 workflow
- 필수 spawn/safety geometry는 authored/static structure로 보존하는 것을 우선.
- procedural 생성은 작은 subsystem으로 분리.
- bootstrap 단계별 health log.
- optional service failure가 world boot를 막지 않게 dependency ordering.

### Regression gate
- server bootstrap dependency 하나를 의도적으로 실패시켜도 diagnosis 가능한 error가 남음.
- spawn/world critical baseline이 언제 생성되는지 명확.

---

## RBLX-FAIL-003 — Coplanar duplicate geometry / z-fighting

### 증상
화면/바닥이 빠르게 번쩍거림.

### 원인
static safety terrain 위에 runtime terrain를 동일/가까운 plane에 중복 생성.

### 올바른 workflow
- 동일 surface를 여러 source가 소유하지 않음.
- procedural + static ownership 분리.
- viewport close/far camera sweep.

### Regression gate
- major floors/walls 중 duplicate transform 검사.
- visual screenshot/video sweep에서 flashing 없음.

---

## RBLX-FAIL-004 — Moving only one BasePart of a Model

### 증상
enemy body만 이동하고 eyes/accessories가 원래 위치에 남음.

### 원인
`Core.CFrame = ...`처럼 model의 일부만 움직임.

### 올바른 workflow
- `Model:PivotTo()`
- WeldConstraint/Motor6D/attachments
- BillboardGui를 target part에 attach
- model pivot ownership 명확화

### Regression gate
모든 moving entity에 대해:
- body
- face
- weapon
- VFX attachments
- health billboard
가 함께 움직이는지 확인.

---

## RBLX-FAIL-005 — Placeholder geometry presented as production art

### 증상
- neon stick weapon
- Part 몇 개짜리 tree/enemy
- cheap-looking scene

### 원인
blockout asset을 visual acceptance build까지 그대로 사용.

### 올바른 workflow
blockout은 `_PLACEHOLDER`로 표시하고 Vertical Slice art gate 전에:
- official assets/templates
- audited Creator Store
- generated mesh/material
- procedural model
- Blender/external DCC
중 적절한 production asset으로 승격.

### Regression gate
player-facing hero asset에 placeholder 0.

---

## RBLX-FAIL-006 — Random procedural layout before art direction

### 증상
맵이 이상하고 목적 없는 object scatter처럼 보임.

### 원인
path/landmark/combat metric 없이 random position으로 trees/rocks/buildings 생성.

### 올바른 workflow
1. authored blockout
2. main path/side path
3. landmark
4. encounter spacing
5. traversal time
6. art kit
7. 그 후 procedural variation

Procedural generation은 randomness 자체가 목적이 아니라 design intent를 scale하는 도구다.

### Regression gate
graybox에서도 첫 objective/path를 설명할 수 있어야 함.

---

## RBLX-FAIL-007 — Surface-copy combat

### 증상
레퍼런스 게임의 '오브를 먹으면 공격' 같은 겉 규칙은 있지만 실제 feel은 전혀 다름.

### 원인
mechanic noun만 복사하고 다음을 측정하지 않음:
- camera
- arena dimensions
- movement speed
- jump arc
- orb spacing/cadence
- anticipation
- enemy pattern cadence
- hitstop
- SFX/VFX
- recovery

### 올바른 workflow
reference combat를 **timing + spatial + audiovisual matrix**로 해부한다.

### Regression gate
전투 한 사이클을 reference matrix와 side-by-side review한 뒤 content 확장.

---

## RBLX-FAIL-008 — Breadth before feel

### 증상
classes/items/zones/systems는 많지만 첫 2분이 재미없음.

### 원인
feature count를 progress로 착각.

### 올바른 workflow
5~10분 Vertical Slice:
- one area
- one enemy family
- one polished combat/tool
- one reward
- one progression decision
부터 quality threshold를 통과.

### Regression gate
core slice가 품질 점수 미달이면 신규 major system 금지.

---

## RBLX-FAIL-009 — Code works = game is good assumption

### 증상
Remote, XP, UI 값은 동작하지만 사용자는 재미없거나 보기 싫다고 느낌.

### 원인
software correctness만 검사하고 input feel / visual hierarchy / pacing / readability / art cohesion을 측정하지 않음.

### 올바른 workflow
기능 QA와 experience QA를 별도 gate로 둔다.

---

## RBLX-FAIL-010 — Error patching without root architecture fix

### 증상
BUILD 002 error → BUILD 003 safety object → 겹침 문제 → BUILD 004 재작업처럼 한 patch가 다음 문제를 만듦.

### 원인
실패한 architecture를 유지한 채 증상마다 덧칠.

### 올바른 workflow
두 번째 structural failure부터는:
- patch 중단
- root-cause tree
- architecture replacement option
- rollback to last sound baseline
을 먼저 검토.

### Regression gate
같은 subsystem에서 구조적 bug가 2회 반복되면 `REASSESS_ARCHITECTURE` 상태.

---

## RBLX-FAIL-011 — Reference research without executable source use

### 증상
많이 조사했지만 실제 구현은 기억/문장 요약에 의존.

### 원인
legal official/open-source/template example을 실제로 실행/해부하지 않음.

### 올바른 workflow
가능하면 `official template/module → run → inspect tree → trace code → extract pattern`.

문서 설명만 보고 비슷하게 만드는 것은 2순위.

---

## RBLX-FAIL-012 — Free asset insertion without audit

### 위험
Creator Store model에 hidden scripts/external requires가 있을 수 있음.

### Rule
Insert 직후 security scan. Visual-only이면 sanitized copy.

---

# Map / Placement failures — mandatory for any world-building task

## RBLX-FAIL-013 — Blind coordinate placement

### 증상
- 건물/문/업그레이드/포탈이 이상한 위치에 놓임.
- 서로 겹치거나 벽을 뚫음.
- 기능은 존재하지만 플레이 공간에서 자연스럽게 접근할 수 없음.

### 원인
현재 맵의 실제 bounds, floor height, player scale, camera scale을 읽지 않고 숫자 좌표를 추측함.

### 올바른 workflow
배치 전에 최소한 다음을 기록한다.
```text
world origin/reference anchor
playable floor Y
spawn transform
player height/width reference
main route centerline
major room/zone bounds
existing landmark pivots
camera/gameplay clearance
```
새 오브젝트는 raw world coordinate가 아니라 **named anchor + local offset**으로 배치하는 것을 우선한다.

### Regression gate
- 신규 major object마다 기준 anchor가 설명 가능.
- top/side/gameplay-camera 관점에서 겹침 없음.
- 플레이어가 실제로 접근 가능.

---

## RBLX-FAIL-014 — No map placement table before bulk building

### 증상
여러 시스템을 한 번에 배치한 뒤 전체 동선이 꼬이고 공간이 비좁거나 비어 보임.

### 원인
기능 목록만 있고 공간 계획표가 없음.

### 올바른 workflow
대량 배치 전에 최소 placement table을 만든다.
```text
object | role | anchor/zone | footprint | facing | clearance | required neighbor | forbidden overlap
```
먼저 macro layout을 확정하고 meso, micro 순서로 내려간다.

### Regression gate
5개 이상의 player-facing object를 한 번에 추가할 때 placement table 없이 bulk placement 금지.

---

## RBLX-FAIL-015 — Wrong scale / footprint estimation

### 증상
- 문이 지나치게 작거나 큼.
- 건물 내부가 플레이어 수에 비해 답답함.
- 상점/NPC/기계가 복도 폭을 잡아먹음.
- 맵은 커 보이는데 실제 플레이 공간은 좁음.

### 원인
asset bounding box와 Roblox avatar/camera 기준을 비교하지 않음.

### 올바른 workflow
- avatar reference rig를 항상 유지.
- `Model:GetBoundingBox()` 또는 실제 bounds 확인.
- 이동/전투/카메라 clearance를 footprint에 포함.
- 최대 동시 플레이어 수를 고려한 통로/허브 폭 검증.

### Regression gate
모든 major prop/building은 avatar와 함께 screenshot 또는 Studio 비교 확인.

---

## RBLX-FAIL-016 — Floating / buried / tilted asset placement

### 증상
모델이 공중에 뜨거나 바닥에 파묻히거나 경사면에서 부자연스럽게 기울어짐.

### 원인
pivot과 실제 visual bottom을 동일하다고 가정하거나 terrain/floor raycast 없이 Y를 고정값으로 사용.

### 올바른 workflow
- pivot sanity check.
- 필요 시 model bottom offset 계산.
- terrain/ground placement는 raycast 또는 authored socket 사용.
- 경사 대응이 필요한 asset과 평탄면 전용 asset 구분.

### Regression gate
entry/center/close camera에서 contact shadow/ground contact가 자연스러움.

---

## RBLX-FAIL-017 — Functional objects placed without flow ownership

### 증상
상점, 강화기, 포탈, 퀘스트 NPC가 각각 존재하지만 위치 관계가 어색하고 플레이어가 계속 왕복함.

### 원인
각 시스템을 개별 feature로 보고 공간 flow를 소유하는 사람이 없음.

### 올바른 workflow
배치 목적을 다음 중 하나로 분류한다.
- onboarding
- core loop
- reward conversion
- progression
- social
- future tease

같은 loop에 속한 기능은 이동 시간과 시야 연결을 같이 설계한다.

### Regression gate
spawn부터 핵심 loop까지 실제로 걸어보고 불필요한 왕복/막다른 동선 기록.

---

## RBLX-FAIL-018 — Editor-view layout that fails gameplay camera

### 증상
Studio freecam에서는 그럴듯하지만 실제 플레이에서는 벽/천장/대형 prop이 시야를 가림.

### 원인
배치를 editor bird's-eye view로만 검토.

### 올바른 workflow
각 주요 공간을 실제 gameplay camera의 entry / center / wall-near / combat / high-low 상태에서 검토.

### Regression gate
major area마다 gameplay-camera screenshot set 최소 3장.

---

## RBLX-FAIL-019 — No clearance budget around interactables

### 증상
구매 버튼/NPC/문/기계 앞에 다른 prop이나 플레이어가 끼어 상호작용이 불편함.

### 원인
visual footprint만 고려하고 interaction footprint를 고려하지 않음.

### 올바른 workflow
player-facing interactable마다:
- approach cone
- standing zone
- camera zone
- prompt radius
- multiplayer crowd clearance
를 확보한다.

### Regression gate
두 명 이상이 동시에 접근해도 주요 interaction이 막히지 않는지 확인.

---

## RBLX-FAIL-020 — Empty huge spaces / cramped content islands

### 증상
전체 맵은 큰데 실제 콘텐츠는 한 구역에 몰려 있고 나머지는 긴 빈 이동, 또는 모든 시스템이 한데 압축되어 답답함.

### 원인
절대 크기만 보고 **활동 밀도와 이동 시간**을 측정하지 않음.

### 올바른 workflow
zone별로 다음을 기록한다.
```text
travel seconds
interactive count
encounter count
reward count
visual landmark count
safe/rest duration
```

### Regression gate
주요 loop의 이동 시간이 재미/의도보다 길면 월드 크기를 줄이거나 활동을 재배치.

---

## RBLX-FAIL-021 — Asset collage without art-direction normalization

### 증상
각 에셋은 괜찮지만 맵 전체가 서로 다른 게임의 무료 모델을 붙여놓은 것처럼 보임.

### 원인
source quality만 보고 silhouette/material/detail density/color language를 통일하지 않음.

### 올바른 workflow
공용 art tokens를 정의하고 외부 asset을 그대로 쓰지 말고 필요하면 material/color/scale/detail을 normalize.

### Regression gate
한 화면에 주요 asset 3개 이상이 보이는 composition screenshot에서 이질감 검토.

---

## RBLX-FAIL-022 — Path blocked after art pass

### 증상
graybox에서는 잘 다녔지만 장식 추가 후 플레이어/NPC가 걸리거나 길이 좁아짐.

### 원인
art pass가 traversal metric을 침범.

### 올바른 workflow
- decoration collision discipline.
- path clearance overlay/guide 유지.
- art pass 후 navmesh + player traversal regression.

### Regression gate
production art 적용 뒤 main route를 처음부터 끝까지 다시 완주.

---

# UI / State / Runtime failures

## RBLX-FAIL-023 — Desktop-only UI approval

### 증상
PC에서는 정상인데 모바일에서 잘림/겹침/터치 불가.

### 원인
fixed pixel/Offset 중심 설계, safe zone/thumb reach 미검증.

### 올바른 workflow
responsive hierarchy + target device matrix를 초기부터 사용.

### Regression gate
최소 desktop 720p/1080p + small/common phone에서 핵심 route 검증.

---

## RBLX-FAIL-024 — UI state desync / stale reopen

### 증상
실제 돈/아이템/진행도와 UI가 다르거나 창을 다시 열면 옛 값이 보임.

### 원인
UI가 local cached state를 source of truth로 사용하거나 update subscription lifecycle이 불명확.

### 올바른 workflow
server-authoritative state snapshot/delta와 UI render state를 분리하고 reopen/resync 경로 정의.

### Regression gate
변경 → UI 닫기 → 재열기 → respawn/rejoin 후 값 일치.

---

## RBLX-FAIL-025 — Duplicate connections / cleanup leak

### 증상
라운드/respawn/UI reopen을 반복할수록 이벤트가 여러 번 실행되고 메모리/효과가 누적.

### 원인
RBXScriptConnection, task, Instance cleanup ownership 부재.

### 올바른 workflow
lifecycle owner를 명시하고 Destroy/disconnect/cancel 경로를 통합.

### Regression gate
동일 route 10회 반복 시 listener/effect/object 수가 계속 증가하지 않음.

---

## RBLX-FAIL-026 — Animation / hit timing mismatch

### 증상
검이 보이기 전에 맞거나, 휘둘렀는데 판정이 늦고, locomotion이 공격 animation을 덮음.

### 원인
animation marker/priority/state와 hitbox timing이 별도 구현.

### 올바른 workflow
animation event/marker를 기준으로 anticipation → active → recovery를 하나의 combat timeline으로 관리.

### Regression gate
slow-motion 또는 frame review에서 visual contact와 damage window가 일치.

---

## RBLX-FAIL-027 — Network ownership / physics assumption

### 증상
NPC/차량/투사체가 멀티플레이에서 떨리거나 플레이어마다 위치가 다르게 보임.

### 원인
physics ownership과 replication strategy를 명시하지 않음.

### 올바른 workflow
중요 physics entity의 authority/ownership 정책을 정하고 latency 상황에서 검증.

### Regression gate
필요한 realtime system은 local server + simulated latency/packet loss 테스트.

---

## RBLX-FAIL-028 — StreamingEnabled instance assumption

### 증상
큰 맵에서 먼 NPC/퀘스트/문이 nil이 되거나 클라이언트 기능이 간헐적으로 깨짐.

### 원인
항상 모든 Instance가 client에 존재한다고 가정.

### 올바른 workflow
persistent gameplay state와 streamed visual Instance를 분리하고 stream-in/out lifecycle 처리.

### Regression gate
critical route에서 stream-out/in을 거쳐도 진행 상태와 interaction 복구.

---

## RBLX-FAIL-029 — Non-idempotent reward / purchase path

### 증상
버튼 연타, Remote 중복, receipt retry로 보상이 두 번 지급됨.

### 원인
한 번만 실행된다는 가정.

### 올바른 workflow
server-side validation + idempotency key/claim state + atomic-ish transition 설계.

### Regression gate
동일 요청 반복/동시 호출에서 보상은 의도된 횟수만 지급.

---

## RBLX-FAIL-030 — Content variants that are only numeric clones

### 증상
적/무기/업그레이드 수는 많지만 실제 플레이 차이는 HP/데미지 숫자뿐.

### 원인
content count를 variety로 착각.

### 올바른 workflow
variant마다 최소 하나 이상의 행동/공간/의사결정 차이를 요구한다.

### Regression gate
새 content batch는 각 항목의 unique gameplay role을 한 문장으로 설명할 수 있어야 함.

---

# Mandatory AI behavior

Roblox를 제작하는 AI는 다음을 금지한다.

1. 실제 Studio 확인 없이 "완성"이라고 말함.
2. runtime error가 있는 상태에서 다음 system 구현.
3. placeholder art에 polish라는 이름을 붙임.
4. user에게 structural QA를 전가.
5. 레퍼런스가 있는데도 맨땅 상상으로 UI/맵/전투를 설계.
6. 같은 실패 패턴을 Godbase 확인 없이 반복.
7. 현재 맵 bounds/anchor/scale을 읽지 않고 major object 좌표를 대량 추측 배치.
8. gameplay camera 검토 없이 editor view만 보고 맵 배치를 승인.
9. placement table 없이 5개 이상의 player-facing object를 한 번에 대량 배치.

# Failure entry template

```markdown
## RBLX-FAIL-XXX — Title
### Date / project
### Symptom
### Impact
### Root cause
### Why we missed it
### Correct workflow
### Automated/static regression
### Studio regression route
### Related Godbase docs
```

실제 프로젝트에서 의미 있는 실패가 발생할 때 이 library를 갱신한다.
