# Rebirth RPG — Working Title

> status: PREPRODUCTION / ASSET-FIRST / WAITING_FOR_STUDIO_TASK_01_EXECUTION
> established: 2026-09-08
> canonical repo: `q93503128-a11y/roblox-games`

정석 Roblox 액션 RPG + Rebirth/Prestige 장기 성장 게임.

이 프로젝트의 목표는 복잡한 전술 RPG가 아니라 **뇌 빼고 반복하기 좋은 성장형 RPG**다.

## Core loop

```text
사냥
→ XP / Gold / Loot
→ 더 강한 장비
→ 다음 지역
→ 지역 보스
→ 더 높은 지역
→ Rebirth
→ 초반 성장 가속 + 새 콘텐츠 해금
→ 반복
```

## Non-negotiable direction

- 전투는 단순하지만 입력 반응, 애니메이션, hit feedback은 싸구려처럼 보이지 않게 한다.
- 보스는 환생마다 복잡한 새 패턴을 추가하지 않는다.
- 환생의 역할은 `성장 가속 + 이전 구간 압축 + 신규 시스템/지역 해금`이다.
- 장비/적/건물의 구체적인 외형을 AI가 먼저 상상해서 요구하지 않는다.
- **실제로 확보되고 Studio에서 검증된 에셋 vocabulary에 맞춰 적 종류, 장비군, 지역 테마를 정한다.**
- primitive Part placeholder를 production art라고 부르지 않는다.
- 한 visual family를 우선하며 무관한 고품질 에셋을 섞어 asset soup를 만들지 않는다.
- 첫 5~10분 Vertical Slice가 재미있고 보기 좋기 전에는 두 번째 지역으로 확장하지 않는다.

## Reference axis

Primary gameplay reference:
- Blox Fruits — 매우 단순한 장기 성장, 지역 진행, 무기/능력 수집, 보스, 높은 level ceiling

Secondary references:
- Dungeon Quest — 반복 던전 → 보스 → 희귀 장비
- World // Zero — 퀘스트/던전/보스/클래스/대량 loot
- Swordburst 3 — 지역/층 진행, 장비 loot, 던전/raid, 이동 가속 수단
- SHADOVIS RPG — 여러 realm, 특수 무기, 영구 XP 강화 수집
- Voxlblade — 단순 무기의 성장/진화가 외형과 행동 변화로 이어지는 구조

Reference URLs and extracted lessons are maintained in `docs/DESIGN_BASELINE_001.md`.

## Godbase route

Mandatory:
- `knowledge/GODBASE_MANIFEST.json`
- `knowledge/AGENT_PROTOCOL.md`
- `knowledge/QUICK_REFERENCE.md`
- `knowledge/checklists/PROJECT_START_CHECKLIST.md`
- `knowledge/regressions/FAILURE_LIBRARY.md`
- `knowledge/genres/ACTION_RPG_OPEN_WORLD.md`
- `knowledge/combat/COMBAT_FEEL_PLAYBOOK.md`
- `knowledge/gameplay/INVENTORY_EQUIPMENT_ARCHITECTURE.md`
- `knowledge/data/ECONOMY_BALANCING_INFLATION.md`
- `knowledge/level-design/AI_MAP_BUILDING_PLAYBOOK.md`
- `knowledge/level-design/LEVEL_DESIGN_WORLD_TRAVERSAL.md`
- `knowledge/assets/ASSET_SELECTION_BY_GENRE.md`
- `knowledge/assets/CREATOR_STORE_RED_FLAGS_AND_QUARANTINE.md`

## Current production status

### CHANGED
- 프로젝트 방향 고정.
- Reference set 고정.
- asset-first art policy 고정.
- Creator Store 웹 사전검수 002 완료.
- Studio Agent Asset Intake Pass 001 작성.
- Studio 작업을 환경 → 무기 → 적 → 방어구/VFX의 4개 짧은 현장 task로 분해.
- TASK 01 환경 검수만 수행하는 standalone Agent prompt 작성.
- TASK 01 결과 템플릿 작성.
- 실제 Studio evidence 없이는 첫 production zone을 설계하지 못하게 `ASSET_APPROVAL_GATE_001.md` 추가.
- 환생 progression과 server-authoritative system boundary 정본화.

### WEB-PREFERRED ENVIRONMENT
- Synty Nature Pack `6933438443`
- Synty Dungeon Pack `6934021345`

둘 다 Creator Store에서 Roblox 배포 및 동일 Synty art family 설명을 재확인했지만, 아직 Studio production approval은 아니다.

### WEB PROTOTYPE WEAPON
- Sword Pack `10226464132` — 작은 무료 시각 후보. Studio scale/grip/style 검증 전.

### WEB REJECT / DEFER EXAMPLES
- DemonSword 10Set `82026628729754` — 111 scripts의 bundled combat surface 때문에 현재 architecture에는 부적합.
- legacy goblin `462605` — legacy + 높은 executable/audio audit cost.
- giant random weapon libraries — 첫 두 combat style이 검증되기 전 defer.

### TESTED
- GitHub current source/docs 확인.
- Creator Store/web metadata 수준의 provenance, creator, asset size/script-surface 사전검수.

### NOT YET TESTED
- 실제 Studio 삽입
- scale/pivot/collision
- rig/animation
- asset dependencies
- gameplay camera visual fit
- mobile performance
- P0 combat

따라서 현재는 **게임 구현 완료/Studio 검증 완료 상태가 아니다.**

## Canonical preproduction docs

- `docs/DESIGN_BASELINE_001.md`
- `docs/PROGRESSION_REBIRTH_001.md`
- `docs/SYSTEM_ARCHITECTURE_001.md`
- `docs/VERTICAL_SLICE_001.md`
- `docs/ASSET_WEB_PREFILTER_002.md`
- `docs/STUDIO_AGENT_ASSET_PASS_001.md`
- `docs/STUDIO_AGENT_RUN_SEQUENCE_001.md`
- `docs/STUDIO_AGENT_TASK_01_ENVIRONMENT.md`
- `docs/STUDIO_AGENT_TASK_01_RESULT_TEMPLATE.md`
- `docs/ASSET_APPROVAL_GATE_001.md`

## Immediate execution gate

Run only:

`docs/STUDIO_AGENT_TASK_01_ENVIRONMENT.md`

TASK 01 must produce actual Studio evidence for:
- current place/DataModel safety
- Synty Nature Pack
- Synty Dungeon Pack
- curated environment subsets
- R15-relative scale
- pivot/collision/material health
- field/dungeon visual compatibility

Record the evidence using:

`docs/STUDIO_AGENT_TASK_01_RESULT_TEMPLATE.md`

Then STOP.

Do **not** proceed to final map construction yet.

After TASK 01 evidence is reviewed:

```text
TASK 02 weapon visual intake
→ TASK 03 coherent enemy family discovery
→ TASK 04 armor + minimal VFX
→ ASSET_APPROVAL_001
→ first-zone spatial plan
→ one-section Studio build
```

The first production-zone build remains blocked by `docs/ASSET_APPROVAL_GATE_001.md` until the required Studio evidence exists.
