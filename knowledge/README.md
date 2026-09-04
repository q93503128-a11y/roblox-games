# Roblox Godbase

> 검증 기준일: 2026-09-04
> 초기 구축 상태: `INITIAL_FOUNDATION_COMPLETE`

`knowledge/`는 이 monorepo의 모든 Roblox 프로젝트가 공통으로 참조하는 **개발 지식 정본**이다. 목표는 Roblox를 기억으로 때우는 것이 아니라, 현재 검증된 해결책·도구·에셋·실패 패턴을 먼저 찾고 실제 Studio에서 검증한 뒤 구현하는 것이다.

초기 Foundation 종료 문서:
- `research/INITIAL_FOUNDATION_FINAL_AUDIT_2026-09-04.md`
- `GODBASE_NEXT_CHAT_HANDOFF.md`
- `NEXT_CHAT_PROMPT.md`

`INITIAL_FOUNDATION_COMPLETE`는 백과사전 완결 선언이 아니다. **실제 게임 제작에 적용할 공통 기반이 갖춰졌다는 뜻**이며 Roblox 변화와 프로젝트 경험에 따라 계속 갱신한다.

## 시작 순서

```text
GODBASE_MANIFEST.json
→ AGENT_PROTOCOL.md
→ QUICK_REFERENCE.md
→ regressions/FAILURE_LIBRARY.md
→ genre recipe / domain 문서
→ project README/docs/current source
```

새 프로젝트는 추가로:
- `checklists/PROJECT_START_CHECKLIST.md`
- `workflow/TOOLCHAIN_DECISION_MATRIX.md`
- `workflow/STUDIO_MCP_AUTONOMOUS_BUILD_HARNESS.md`
- `testing/MCP_PLAYTEST_CONTRACT_SCHEMA.json`
- `checklists/VERTICAL_SLICE_DONE_DEFINITION.md`
- `genres/README.md`
- `genres/STARTER_RECIPE_MATRIX.json`

을 확인한다.

## 핵심 원칙

1. 공식 Roblox 문서/엔진 기능 우선.
2. 실제 Studio 검증 우선.
3. 출처/라이선스/포함 스크립트 검사 후 재사용.
4. 가치 있는 state는 서버 최종 판정.
5. 실제 Roblox 레퍼런스 분석 후 설계.
6. Engine → Template → Feature Package → Developer Module → approved OSS/asset → custom 순으로 검토.
7. 5~10분 Vertical Slice를 breadth보다 먼저 완성.
8. Studio MCP가 가능하면 AI가 사용자보다 먼저 Playtest.
9. 실패는 regression knowledge로 환류.
10. Roblox 지식은 유통기한이 있으므로 adoption/release 전 current source 재검증.

## 장르 라우팅

신규 게임은 `genres/README.md`와 `genres/STARTER_RECIPE_MATRIX.json`에서 primary recipe를 먼저 고른다.

현재 recipe:
- Action RPG / Open World
- Battlegrounds / Fighting
- Simulator / Collection
- Tycoon / Management
- Tower Defense
- Horror / Run-based
- Survival / Extraction / Co-op
- Round / Minigame
- Social / Roleplay
- Shooter / Arena

`genre/GENRE_REFERENCE_MATRIX.md`는 범용 분석 background이고, **신규 프로젝트 시작은 `genres/` recipe를 우선**한다.

## 권장 workflow

Studio-first:
```text
Roblox Studio + Studio MCP + Script Sync + Git + Luau LSP + StyLua + selene
```

Filesystem-first:
```text
Rojo + Rokit + Wally + Git/CI + Studio MCP for QA
```

기존 프로젝트를 Godbase 때문에 강제 migration하지 않는다.

## Studio MCP 표준 loop

실행 정본: `workflow/STUDIO_MCP_AUTONOMOUS_BUILD_HARNESS.md`

```text
inspect current DataModel/code
→ smallest coherent change
→ Play
→ actual navigation/input
→ Output
→ screenshot
→ acceptance/reference compare
→ root-cause repair
→ exact route replay
→ regression
```

project별 P0 route는 `testing/MCP_PLAYTEST_CONTRACT_SCHEMA.json`로 계약화한다. `코드 작성 완료`와 `Studio에서 사용자 경로 검증 완료`는 다른 상태다.

## Creator Store 공급망

핵심 정본:
- `assets/CREATOR_STORE_SUPPLY_CATALOG.json`
- `assets/OFFICIAL_ROBLOX_ASSET_PACKS.md`
- `assets/ASSET_SELECTION_BY_GENRE.md`
- `assets/CREATOR_STORE_RED_FLAGS_AND_QUARANTINE.md`
- `assets/CREATOR_STORE_HARVESTER_AND_QUARANTINE_PIPELINE.md`
- `assets/CREATOR_STORE_BATCH_AND_PROMOTION.md`

```text
search/discovery
→ metadata triage
→ quarantine Studio audit
→ visual review
→ production-fit test
→ S/A/B/C/REJECT
→ canonical promotion
```

평점은 discovery signal일 뿐 안전/품질 증명이 아니다. scripted model/plugin은 높은 audit surface로 취급한다.

## OSS / legacy 판단

Machine-readable 정본: `catalogs/LIBRARY_CATALOG.json`.

핵심 예:
- Knit → archived, 신규 기본값 금지.
- TestEZ → archived; Jest Roblox 우선 평가.
- ProfileService → 신규 프로젝트는 ProfileStore 우선.
- BridgeNet2 → 신규 기본값 금지, ByteNet 검토.
- jecs → 현재 ECS 강력 후보.
- Matter → established conditional ECS.
- Chickynoid → 특수 simulation 후보; native Server Authority 먼저 검토.
- Ripple → UI motion 후보; 단순 TweenService로 충분하면 추가하지 않음.

관련: `catalogs/OPEN_SOURCE_ECOSYSTEM_AUDIT.md`, `catalogs/DEPRECATED_LEGACY_WATCHLIST.md`.

## 전문 문서 지도

### 공식/워크플로
- `official/CREATOR_DOCS_MAP.md`
- `official/TEMPLATES_FEATURE_PACKAGES_MODULES.md`
- `official/ENGINE_CAPABILITIES_2026.md`
- `workflow/STUDIO_MCP_AND_SCRIPT_SYNC.md`
- `workflow/STUDIO_MCP_AUTONOMOUS_BUILD_HARNESS.md`
- `workflow/TOOLCHAIN_DECISION_MATRIX.md`
- `workflow/OPEN_CLOUD_CI_RELEASE_AUTOMATION.md`

### 코드/네트워크/보안
- `architecture/ENGINE_AND_NETWORKING.md`
- `architecture/PROJECT_STRUCTURE_PATTERNS.md`
- `code/LUAU_ENGINEERING_PLAYBOOK.md`
- `networking/REPLICATION_PHYSICS_INPUT.md`
- `networking/NETWORK_LIBRARY_DECISION_MATRIX.md`
- `security/SECURITY_AND_ANTICHEAT.md`

### 게임플레이/멀티플레이
- `gameplay/INTERACTION_SYSTEMS.md`
- `gameplay/INVENTORY_EQUIPMENT_ARCHITECTURE.md`
- `gameplay/LOOT_DROP_CRAFTING.md`
- `gameplay/QUEST_OBJECTIVE_MISSIONS.md`
- `gameplay/TRADING_GIFTING_SECURITY_UX.md`
- `gameplay/ROUND_GAME_STATE_ARCHITECTURE.md`
- `gameplay/PROCEDURAL_GENERATION_DETERMINISM.md`
- `multiplayer/TELEPORT_MATCHMAKING_RESERVED_SERVERS.md`
- `social/SOCIAL_PARTY_INVITES.md`

### 아트/게임감
- `level-design/LEVEL_DESIGN_WORLD_TRAVERSAL.md`
- `graphics/TERRAIN_ENVIRONMENT_PIPELINE.md`
- `graphics/VISUAL_QUALITY_PIPELINE.md`
- `graphics/VFX_TELEGRAPHS_EFFECT_BUDGETS.md`
- `animation/ANIMATION_AND_RIGGING_PIPELINE.md`
- `audio/AUDIO_SYSTEMS_AND_MIXING.md`
- `camera/CAMERA_AND_GAME_FEEL.md`
- `combat/COMBAT_FEEL_PLAYBOOK.md`
- `combat/HIT_DETECTION_HITBOXES_PROJECTILES.md`
- `ai/NPC_AI_AND_PATHFINDING.md`

`graphics/WORLD_ART_ANIMATION_AUDIO.md`는 넓은 overview이고 위 세분화 문서를 실행 정본으로 우선한다.

### UI/데이터/운영
- `design/UI_UX_PLAYBOOK.md`
- `ui/CROSS_PLATFORM_ACCESSIBILITY_LOCALIZATION.md`
- `ui/UI_STORYBOOK_COMPONENT_WORKFLOW.md`
- `data/CLOUD_SERVICES_DECISION_MATRIX.md`
- `data/SAVE_SCHEMA_MIGRATION_RECOVERY.md`
- `data/ECONOMY_BALANCING_INFLATION.md`
- `production/DISCOVERY_GROWTH_RETENTION.md`
- `production/MONETIZATION_LIVEOPS_NOTIFICATIONS.md`
- `analytics/ANALYTICS_EVENT_TAXONOMY_EXPERIMENTS.md`
- `publishing/POLICY_MARKETPLACE_LOCALIZATION.md`

`data/DATA_ECONOMY_AND_LIVEOPS.md`는 넓은 overview로 유지한다.

### 테스트/품질
- `testing/LUAU_TESTING_FRAMEWORKS_AND_CI.md`
- `testing/AUTOMATED_ACCEPTANCE_GATES.md`
- `testing/DEVICE_NETWORK_TEST_MATRIX.md`
- `testing/MCP_PLAYTEST_CONTRACT_SCHEMA.json`
- `debugging/STUDIO_DEBUGGING_VISUALIZATION.md`
- `performance/PERFORMANCE_AND_STREAMING.md`
- `performance/LOADING_MEMORY_STREAMING_BUDGETS.md`
- `checklists/ASSET_IMPORT_CHECKLIST.md`
- `checklists/SHIP_CHECKLIST.md`

## Godbase 품질관리

`tools/godbase/validate.py` + `.github/workflows/godbase-check.yml`가 다음을 검사한다.

- Manifest/JSON local routing path
- JSON parsing/schema basics
- 명시적인 Markdown local reference
- suspiciously empty docs
- genre recipe routing integrity
- Godbase unit tests
- Python tool compile

## 사용자 테스트 전 최소 gate

- clean boot
- unexpected Output error 0
- 정상 spawn
- project-specific P0 route 직접 완주
- screenshot visual review
- model integrity
- desktop/mobile UI
- 필요한 multiplayer route
- server-authoritative valuable state
- known limitations 기록

통과 전 상태는 `INTERNAL_PROTOTYPE`이다.

## 공식 출발점

- https://create.roblox.com/docs/llms.txt
- https://create.roblox.com/docs/reference/engine/llms.txt
- https://create.roblox.com/docs/cloud/llms.txt
- https://create.roblox.com/docs/studio/mcp
- https://create.roblox.com/docs/scripting/sync
- https://create.roblox.com/docs/discovery
- https://github.com/Roblox/creator-docs

## 이후 운영

초기 Foundation은 완료했다. 이제 기본 우선순위는:

```text
Godbase를 실제 프로젝트에 사용
→ Studio evidence 수집
→ human feel feedback
→ 일반화 가능한 성공/실패만 Godbase에 환류
```

지식 문서 수 자체를 늘리는 것은 목표가 아니다.
