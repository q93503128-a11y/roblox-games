# Rebirth RPG — Working Title

> status: DEVELOPMENT / CORE CODE WRITTEN / WAITING FOR STUDIO SCRIPT SYNC + CORE SMOKE TEST
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
- 환생은 `성장 가속 + 이전 구간 압축 + 신규 콘텐츠 해금`에 집중한다.
- 장비/적/건물 외형은 AI가 먼저 발명하지 않는다.
- **실제로 확보되고 Studio에서 검증된 asset vocabulary에 맞춰 적/장비/지역 정체성을 정한다.**
- primitive Part placeholder를 production art라고 부르지 않는다.
- 한 visual family를 우선하고 asset soup를 만들지 않는다.
- 첫 5–10분 Vertical Slice가 재미있고 보기 좋기 전에는 두 번째 지역을 만들지 않는다.
- 사용자에게 전달하는 플레이 가능한 빌드는 `.rbxlx`다.
- Studio에서 열고 검증하지 않은 임의 생성 `.rbxlx`를 검증 빌드라고 부르지 않는다.

## Reference axis

Primary gameplay reference:
- Blox Fruits — 단순한 장기 성장, 지역 진행, 무기/능력 수집, 보스, 높은 level ceiling

Secondary:
- Dungeon Quest — 반복 전투/던전 → 보스 → 희귀 장비
- World // Zero — 월드/던전/보스/loot progression
- Swordburst 3 — 지역 진행, 장비 loot, raid/dungeon
- SHADOVIS RPG — 여러 realm, 특수 무기, 영구 성장
- Voxlblade — 기본 무기의 성장/진화

Detailed observations: `docs/DESIGN_BASELINE_001.md`.

## Current actual implementation

Repository code:

```text
projects/rebirth-rpg/scripts/
├─ Shared/
├─ Server/
└─ Client/
```

### CODE WRITTEN

Server-owned core:
- in-memory Slice 001 PlayerProfile
- Level / XP / Gold
- inventory ownership / mainhand equipment
- Rebirth count / milestone flags / boss clear flag
- Rebirth reset + automatic acceleration multipliers
- server-authoritative M1 combat
- 3-hit basic combo
- one simple skill per current abstract weapon
- server spatial-query melee hit detection
- cooldown / busy-state validation
- enemy chase / windup / attack / death / respawn
- server XP / Gold / loot award
- deterministic first meaningful Weapon B upgrade
- unique-drop dedupe
- rate limiting for client intents/state request
- Studio-only Rebirth test hooks
- runtime Config/Protocol validation before services start
- staged boot logs
- refusal to bind enemy rigs that still contain Script/LocalScript/ModuleScript descendants

Client test shell:
- internal Level / XP / Gold / Rebirth HUD
- Weapon B equip action
- desktop/gamepad/touch Attack
- desktop/gamepad/touch Skill
- Rebirth test input
- server-driven hit/reward feedback text

Studio-only validation support:
- opt-in smoke harness
- explicit named `RebirthRPG_SmokeOrigin` anchor
- temporary sanitized R15 Enemy A / Enemy B / Boss debug rigs
- anchor-relative placement only
- debug harness failure isolated from core server boot

Exact status: `docs/DEVELOPMENT_SLICE_001_STATUS.md`.

## Stable gameplay IDs

Current IDs deliberately do not encode final visual design:

```text
weapon_start_a
weapon_start_b

enemy_field_a_01
enemy_field_b_01
boss_region_01
```

After Studio asset approval, approved visuals map onto these IDs instead of imported model names becoming gameplay architecture.

## Asset status

### WEB-PREFERRED ENVIRONMENT
- Synty Nature Pack `6933438443`
- Synty Dungeon Pack `6934021345`

Web provenance is checked; Studio production approval is still pending.

### WEB PROTOTYPE WEAPON
- Sword Pack `10226464132` — small free candidate; Studio grip/scale/style inspection pending.

### REJECT / DEFER examples
- DemonSword 10Set `82026628729754` — excessive bundled script/combat surface
- legacy goblin `462605` — high legacy executable/audio audit cost
- giant random weapon libraries — deferred before combat style proof

Canonical:
- `ASSET_SOURCES.md`
- `docs/ASSET_WEB_PREFILTER_002.md`
- `docs/ASSET_APPROVAL_GATE_001.md`

## What is NOT yet implemented/verified

Current source is **not yet a Studio-implemented playable feature**.

Not yet Studio-verified:
- Script Sync into exact target place
- clean boot / Output error count
- smoke harness runtime
- attack/hit timing in Studio
- enemy debug rig behavior
- death/respawn route
- Rebirth runtime transition
- approved environment
- approved weapon visuals/grips
- approved enemy rigs/animations
- production attack animations/VFX/audio/camera feedback
- boss AoE presentation/logic
- dash/movement polish
- production inventory UI
- quests / secrets / chests
- first production zone/map
- DataStore persistence across sessions
- mobile device simulation
- production P0 route
- `.rbxlx` export/re-open validation

Current enemy pursuit uses direct `Humanoid:MoveTo`; Pathfinding is deferred until actual combat-space evidence requires it.

## Studio code integration

Canonical:

`docs/SCRIPT_SYNC_RUNTIME_LAYOUT_001.md`

Mapping:

```text
scripts/Shared → ReplicatedStorage/RebirthRPG/Shared
scripts/Server → ServerScriptService/RebirthRPG
scripts/Client → StarterPlayer/StarterPlayerScripts/RebirthRPG
```

Studio owns map/terrain/models/assets/final `.rbxlx`.

## Immediate execution gate

Open:

`docs/STUDIO_AGENT_START_HERE.md`

Current order:

```text
inspect clean Rebirth RPG Studio place
→ Script Sync current code
→ create explicit smoke anchor after reading floor/spawn
→ Studio-only core smoke test
→ clean boot
→ Enemy A reward
→ Enemy B → Weapon B → equip
→ boss clear
→ death/respawn
→ Rebirth test
→ report / fix exact failed route
→ then asset TASK 01 environment
→ TASK 02 weapons
→ TASK 03 enemy family
→ TASK 04 armor/minimal VFX
→ asset approval
→ first-zone spatial plan
→ one coherent production section
```

Do not add a second region or broad system layer before the Studio core route and first Vertical Slice pass.

## Canonical project docs

- `docs/DESIGN_BASELINE_001.md`
- `docs/PROGRESSION_REBIRTH_001.md`
- `docs/SYSTEM_ARCHITECTURE_001.md`
- `docs/VERTICAL_SLICE_001.md`
- `docs/DEVELOPMENT_SLICE_001_STATUS.md`
- `docs/SCRIPT_SYNC_RUNTIME_LAYOUT_001.md`
- `docs/STUDIO_CORE_SMOKE_TEST_001.md`
- `docs/ASSET_WEB_PREFILTER_002.md`
- `docs/STUDIO_AGENT_START_HERE.md`
- `docs/STUDIO_AGENT_RUN_SEQUENCE_001.md`
- `docs/STUDIO_AGENT_TASK_01_ENVIRONMENT.md`
- `docs/STUDIO_AGENT_TASK_01_RESULT_TEMPLATE.md`
- `docs/STUDIO_AGENT_TASK_02_WEAPONS.md`
- `docs/STUDIO_AGENT_TASK_03_ENEMIES.md`
- `docs/STUDIO_AGENT_TASK_04_ARMOR_VFX.md`
- `docs/ASSET_APPROVAL_GATE_001.md`
- `docs/SUPERVISOR_POST_ASSET_INPUT_001.md`
- `docs/RBXLX_DELIVERY_CONTRACT.md`

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
- `knowledge/level-design/AI_MAP_BUILDING_PLAYBOOK.md`
- `knowledge/level-design/LEVEL_DESIGN_WORLD_TRAVERSAL.md`
- `knowledge/assets/ASSET_SELECTION_BY_GENRE.md`
- `knowledge/assets/CREATOR_STORE_RED_FLAGS_AND_QUARANTINE.md`

## User-facing build format

When a coherent playable slice passes Studio gates, hand it off as:

```text
REBIRTH_RPG_BUILD_<NNN>_YYYY-MM-DD.rbxlx
```

See `docs/RBXLX_DELIVERY_CONTRACT.md`.
