# Rebirth RPG — Working Title

> status: DEVELOPMENT / CORE CODE WRITTEN / WAITING FOR STUDIO ASSET + RUNTIME VALIDATION
> established: 2026-09-08
> canonical repo: `q93503128-a11y/roblox-games`
> user handoff format: `.rbxlx`

정석 Roblox 액션 RPG + Rebirth/Prestige 장기 성장 게임.

목표는 복잡한 전술 RPG가 아니라 **뇌 빼고 반복하기 좋은 성장형 RPG**다.

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

- 전투는 단순하지만 입력 반응, animation timing, hit feedback은 싸구려처럼 보이지 않게 한다.
- 보스는 환생마다 복잡한 새 패턴을 추가하지 않는다.
- 환생의 역할은 `성장 가속 + 이전 구간 압축 + 신규 시스템/지역 해금`이다.
- 장비/적/건물의 구체적인 외형을 AI가 먼저 상상해서 요구하지 않는다.
- **실제로 확보되고 Studio에서 검증된 asset vocabulary에 맞춰 적 종류, 장비군, 지역 테마를 정한다.**
- primitive Part placeholder를 production art라고 부르지 않는다.
- 한 visual family를 우선하며 무관한 고품질 에셋을 섞어 asset soup를 만들지 않는다.
- 첫 5–10분 Vertical Slice가 재미있고 보기 좋기 전에는 두 번째 지역으로 확장하지 않는다.
- 사용자에게 넘기는 플레이 가능한 빌드는 `.rbxlx`로 제공한다.
- Studio에서 열고 검증하지 않은 임의 생성 `.rbxlx`를 검증 빌드라고 부르지 않는다.

## Reference axis

Primary gameplay reference:
- Blox Fruits — 단순한 장기 성장, 지역 진행, 무기/능력 수집, 보스, 높은 level ceiling

Secondary references:
- Dungeon Quest — 반복 던전 → 보스 → 희귀 장비
- World // Zero — 퀘스트/던전/보스/클래스/대량 loot
- Swordburst 3 — 지역/층 진행, 장비 loot, 던전/raid, 이동 가속
- SHADOVIS RPG — 여러 realm, 특수 무기, 영구 XP 강화
- Voxlblade — 단순 무기의 성장/진화

Detailed observations: `docs/DESIGN_BASELINE_001.md`.

## Current actual implementation

Repository code now exists under:

```text
projects/rebirth-rpg/scripts/
├─ Shared/
├─ Server/
└─ Client/
```

### CODE WRITTEN

Server-owned core:
- in-memory first-slice PlayerProfile
- Level / XP / Gold
- inventory ownership / mainhand equipment
- Rebirth count / milestone flags / boss clear flag
- Rebirth reset + automatic acceleration multipliers
- server-authoritative basic combat
- three-hit basic combo
- one simple weapon skill
- server spatial-query hit detection
- attack/skill cooldown validation
- enemy chase / windup / attack / death / respawn runtime
- server XP/Gold/loot award
- duplicate kill-reward guard
- rate limiting for client intents/state requests
- Studio-only Rebirth test hooks

Client shell:
- internal Level / XP / Gold / Rebirth HUD
- internal Weapon B equip button
- attack input for desktop/gamepad/touch
- skill input for desktop/gamepad/touch
- Rebirth test input
- reward/hit feedback text shell

Integration:
- Studio Script Sync layout documented
- enemy tag/attribute runtime contract documented
- final user handoff remains `.rbxlx`

Exact status and limitations: `docs/DEVELOPMENT_SLICE_001_STATUS.md`.

## Important implementation boundary

Current stable gameplay IDs are deliberately visual-neutral:

```text
weapon_start_a
weapon_start_b

enemy_field_a_01
enemy_field_b_01
boss_region_01
```

These IDs are not final fantasy names or designs.
After Studio approves actual weapon/enemy assets, visuals map to these stable IDs instead of rewriting combat/progression around imported model names.

## Asset status

### WEB-PREFERRED ENVIRONMENT
- Synty Nature Pack `6933438443`
- Synty Dungeon Pack `6934021345`

Both have web/Creator Store provenance checks but are **not Studio production-approved yet**.

### WEB PROTOTYPE WEAPON
- Sword Pack `10226464132` — small free visual candidate; Studio scale/grip/style verification pending.

### REJECT / DEFER examples
- DemonSword 10Set `82026628729754` — excessive bundled combat/script surface for this architecture.
- legacy goblin `462605` — legacy + high executable/audio audit cost.
- giant random weapon libraries — defer until two combat styles prove fun.

See:
- `ASSET_SOURCES.md`
- `docs/ASSET_WEB_PREFILTER_002.md`
- `docs/ASSET_APPROVAL_GATE_001.md`

## What is NOT yet implemented/verified

Do not call the current source a playable finished feature yet.

Not Studio-verified:
- Script Sync into actual target place
- clean boot / Output
- approved environment insertion
- approved weapon visuals/grips
- approved enemy rigs/animations
- animation hit timing
- hit VFX/audio/camera feedback
- enemy telegraph presentation
- boss AoE
- dash/movement polish
- production inventory UI
- quests / secrets / chests
- first production zone/map
- persistence across server sessions
- mobile device simulation
- P0 route
- `.rbxlx` export/re-open validation

Current enemy movement uses direct `Humanoid:MoveTo`; obstacle-aware pathfinding will be adopted only if the actual combat pocket proves it necessary.

## Studio code layout

Canonical integration document:

`docs/SCRIPT_SYNC_RUNTIME_LAYOUT_001.md`

Intended mapping:

```text
scripts/Shared  → ReplicatedStorage/RebirthRPG/Shared
scripts/Server  → ServerScriptService/RebirthRPG
scripts/Client  → StarterPlayer/StarterPlayerScripts/RebirthRPG
```

Studio remains owner of map/terrain/models/assets/final `.rbxlx`.

## Godbase route

Mandatory references include:
- `knowledge/GODBASE_MANIFEST.json`
- `knowledge/AGENT_PROTOCOL.md`
- `knowledge/QUICK_REFERENCE.md`
- `knowledge/regressions/FAILURE_LIBRARY.md`
- `knowledge/genres/ACTION_RPG_OPEN_WORLD.md`
- `knowledge/combat/COMBAT_FEEL_PLAYBOOK.md`
- `knowledge/combat/HIT_DETECTION_HITBOXES_PROJECTILES.md`
- `knowledge/gameplay/INVENTORY_EQUIPMENT_ARCHITECTURE.md`
- `knowledge/data/ECONOMY_BALANCING_INFLATION.md`
- `knowledge/level-design/AI_MAP_BUILDING_PLAYBOOK.md`
- `knowledge/level-design/LEVEL_DESIGN_WORLD_TRAVERSAL.md`
- `knowledge/assets/ASSET_SELECTION_BY_GENRE.md`
- `knowledge/assets/CREATOR_STORE_RED_FLAGS_AND_QUARANTINE.md`

## Canonical project docs

- `docs/DESIGN_BASELINE_001.md`
- `docs/PROGRESSION_REBIRTH_001.md`
- `docs/SYSTEM_ARCHITECTURE_001.md`
- `docs/VERTICAL_SLICE_001.md`
- `docs/DEVELOPMENT_SLICE_001_STATUS.md`
- `docs/SCRIPT_SYNC_RUNTIME_LAYOUT_001.md`
- `docs/ASSET_WEB_PREFILTER_002.md`
- `docs/STUDIO_AGENT_START_HERE.md`
- `docs/STUDIO_AGENT_TASK_01_ENVIRONMENT.md`
- `docs/STUDIO_AGENT_TASK_01_RESULT_TEMPLATE.md`
- `docs/STUDIO_AGENT_TASK_02_WEAPONS.md`
- `docs/STUDIO_AGENT_TASK_03_ENEMIES.md`
- `docs/STUDIO_AGENT_TASK_04_ARMOR_VFX.md`
- `docs/ASSET_APPROVAL_GATE_001.md`
- `docs/SUPERVISOR_POST_ASSET_INPUT_001.md`
- `docs/RBXLX_DELIVERY_CONTRACT.md`

## Immediate execution gate

The next quality gate is actual Studio evidence, not more code breadth.

```text
TASK 01 environment Studio audit
→ review
→ TASK 02 weapon visuals
→ review
→ TASK 03 enemy family
→ review
→ TASK 04 armor/minimal VFX
→ asset approval
→ Script Sync current gameplay code into inspected place
→ bind ONE approved Enemy A rig
→ clean boot
→ attack → death → reward smoke test
→ fix smallest coherent failures
→ first-zone spatial plan
→ one coherent world section
```

Open `docs/STUDIO_AGENT_START_HERE.md` for the Studio execution entrypoint.

## User-facing build format

When a coherent playable slice passes the required Studio gates, hand it off as:

```text
REBIRTH_RPG_BUILD_<NNN>_YYYY-MM-DD.rbxlx
```

See `docs/RBXLX_DELIVERY_CONTRACT.md`.
