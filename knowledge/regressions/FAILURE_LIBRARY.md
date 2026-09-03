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
- Output unexpected error 0.
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

예:
```text
camera FOV/distance
enemy telegraph ms
player jump height/time
attack opportunity spacing
hit impact duration
recovery duration
```

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
software correctness만 검사하고:
- input feel
- visual hierarchy
- pacing
- readability
- art cohesion
을 측정하지 않음.

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
가능하면:
`official template/module → run → inspect tree → trace code → extract pattern`.

문서 설명만 보고 비슷하게 만드는 것은 2순위.

---

## RBLX-FAIL-012 — Free asset insertion without audit

### 위험
Creator Store model에 hidden scripts/external requires가 있을 수 있음.

### Rule
Insert 직후 security scan. Visual-only이면 sanitized copy.

---

# Mandatory AI behavior

Roblox를 제작하는 AI는 다음을 금지한다.

1. 실제 Studio 확인 없이 "완성"이라고 말함.
2. runtime error가 있는 상태에서 다음 system 구현.
3. placeholder art에 polish라는 이름을 붙임.
4. user에게 structural QA를 전가.
5. 레퍼런스가 있는데도 맨땅 상상으로 UI/맵/전투를 설계.
6. 같은 실패 패턴을 Godbase 확인 없이 반복.

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
