# Rebirth RPG — Studio Agent TASK 01: Environment Intake

> status: READY TO RUN IN ROBLOX STUDIO ASSISTANT / AGENT
> scope: environment only
> rule: STOP after report

## GOAL

현재 Roblox Studio place를 먼저 검사하고, Rebirth RPG의 첫 5~10분 Vertical Slice에 사용할 수 있는 **환경 에셋 family만** 격리 검수한다.

이번 작업에서 최종 맵을 만들지 않는다.
무기/적/방어구/VFX도 건드리지 않는다.

검수 우선순위:
1. Synty Nature Pack `6933438443`
2. Synty Dungeon Pack `6934021345`

## CURRENT CONTEXT

게임 방향:
- 정석 Roblox 판타지 액션 RPG
- 뇌 빼고 반복하기 좋은 사냥/장비/성장/환생
- 디자인은 AI가 먼저 발명하지 않고 실제 확보된 에셋 vocabulary를 따라간다
- 환경은 stylized low-poly fantasy 계열을 목표로 하되 실제 Studio 결과가 기준이다

정본 문서:
- `projects/rebirth-rpg/README.md`
- `projects/rebirth-rpg/ASSET_SOURCES.md`
- `projects/rebirth-rpg/docs/ASSET_WEB_PREFILTER_002.md`
- `projects/rebirth-rpg/docs/STUDIO_AGENT_RUN_SEQUENCE_001.md`

## DO NOT CHANGE

- 다른 프로젝트의 verified content
- progression/combat architecture
- 최종 world hierarchy
- final lighting
- 무기/적/방어구/VFX
- paid assets

외부 pack의 Script/LocalScript/ModuleScript/demo scaffolding을 production content로 승격하지 않는다.

## PHASE A — INSPECT CURRENT STUDIO FIRST

아무것도 import하기 전에 아래를 먼저 보고한다.

```text
PLACE / EXPERIENCE IDENTITY
CLEAN OR EXISTING PLACE
WORKSPACE TOP-LEVEL CHILDREN
SPAWN STATE
LIGHTING BASICS
EXISTING SCRIPT / PACKAGE SURFACE
UNRELATED VERIFIED PROJECT CONTENT: YES / NO
```

`UNRELATED VERIFIED PROJECT CONTENT = YES`이면 즉시 STOP.

## PHASE B — CREATE QUARANTINE ONLY

안전한 경우에만 다음 격리 구조를 만든다.

```text
Workspace
└─ _AssetQuarantine
   ├─ Environment
   │  ├─ NatureSource
   │  └─ DungeonSource
   └─ ReferenceRig
```

`ReferenceRig`에는 R15 기준 rig를 둔다.

이 구조는 검수용이며 최종 맵 hierarchy가 아니다.

## PHASE C — IMPORT AND AUDIT NATURE

Synty Nature Pack `6933438443`를 격리 공간에서 확인한다.

필수 확인:
- Studio가 표시하는 creator/source
- Script / LocalScript / ModuleScript descendant 수
- numeric/remote require 또는 외부 dependency 여부
- 대표 tree / rock / bush / foliage
- R15 대비 실제 scale
- pivot 상태
- collision 상태
- texture/material missing 여부
- gameplay camera 거리에서 silhouette/readability
- 반복 배치 시 눈에 띄는 문제

그 후 첫 필드에 쓸 수 있는 **작은 curated subset**만 제안한다.

예:
```text
3 tree variants
3 rock variants
2 bush/foliage clusters
1 dead/log prop family
```

실제 asset 구성에 맞춰 정하며 억지로 수량을 채우지 않는다.

## PHASE D — IMPORT AND AUDIT DUNGEON

Synty Dungeon Pack `6934021345`를 같은 방식으로 확인한다.

대표 확인 대상:
- cave wall/floor pieces
- bridge/tunnel pieces
- castle/interior modules
- rocks/structural trim

확인:
- source
- scripts/dependencies
- R15 scale
- modular seam quality
- pivot
- collision
- texture/material
- gameplay camera
- 첫 compact dungeon section을 만들 정도의 curated subset 가능 여부

## PHASE E — SIDE-BY-SIDE FIT CHECK

Nature subset과 Dungeon subset을 서로 인접하게 놓고 확인한다.

질문:
- 같은 게임의 환경처럼 보이는가?
- scale language가 맞는가?
- material/palette가 심하게 충돌하지 않는가?
- field → cave/dungeon transition을 자연스럽게 만들 수 있는가?

## REQUIRED EVIDENCE

가능하면 다음 view를 남긴다.

1. R15 + Nature representative lineup
2. R15 + Dungeon representative lineup
3. Nature/Dungeon side-by-side compatibility view
4. gameplay-camera approximate view

## REQUIRED REPORT

다음 형식으로 답한다.

```text
CURRENT STUDIO
- place identity:
- clean/existing:
- unrelated project content:

NATURE PACK
- source verified:
- script counts:
- dependencies:
- curated subset:
- R15 scale:
- pivot:
- collision:
- textures/materials:
- gameplay-camera fit:
- repetition/performance concern:
- decision: APPROVE / HOLD / REJECT
- reason:

DUNGEON PACK
- source verified:
- script counts:
- dependencies:
- curated subset:
- R15 scale:
- modular seams:
- pivot:
- collision:
- textures/materials:
- gameplay-camera fit:
- performance concern:
- decision: APPROVE / HOLD / REJECT
- reason:

COMBINED VISUAL FAMILY
- coherent together: YES / NO / PARTIAL
- usable first field vocabulary:
- usable first dungeon vocabulary:
- missing environment vocabulary:

CHANGED
OBSERVED
TESTED
FAILED / FIXED
KNOWN LIMITATIONS
```

## ACCEPTANCE

TASK 01은 아래를 만족해야 성공이다.

- 실제 Studio를 먼저 검사했다
- 다른 프로젝트 content를 오염시키지 않았다
- Nature와 Dungeon을 실제 Studio에서 봤다
- R15 scale 비교가 있다
- pivot/collision/material 상태를 확인했다
- 작은 curated subset이 제안됐다
- 최종 맵을 만들지 않았다
- 승인/보류/폐기 이유가 증거 기반이다

## STOP CONDITIONS

즉시 중단:
- 다른 프로젝트 place
- suspicious script/require
- 깨진 critical dependency
- 치명적인 scale/collision mismatch
- 두 pack이 실제로는 한 art family로 사용하기 어려움

그리고 정상 완료해도 **REPORT 후 STOP**.
TASK 02 무기로 자동 진행하지 않는다.
