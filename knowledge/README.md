# Roblox Godbase

> 검증 기준일: 2026-09-03

`knowledge/`는 이 monorepo의 모든 Roblox 프로젝트가 공통으로 참조하는 **개발 지식 정본**이다. 목표는 Roblox를 기억으로 때우는 것이 아니라, 현재 검증된 해결책·도구·에셋·실패 패턴을 먼저 찾고 실제 Studio에서 검증한 뒤 구현하는 것이다.

## 가장 먼저 읽기

모든 새 Roblox 작업:

`GODBASE_MANIFEST.json → AGENT_PROTOCOL.md → QUICK_REFERENCE.md → regressions/FAILURE_LIBRARY.md → 작업 domain 문서`

새 프로젝트는 추가로:
- `checklists/PROJECT_START_CHECKLIST.md`
- `workflow/TOOLCHAIN_DECISION_MATRIX.md`
- `workflow/AI_STUDIO_AUTONOMOUS_PLAYTEST.md`
- `checklists/VERTICAL_SLICE_DONE_DEFINITION.md`
- `level-design/LEVEL_DESIGN_WORLD_TRAVERSAL.md`

## 핵심 원칙

1. 공식 문서 우선.
2. 실제 Studio 검증 우선.
3. 출처/라이선스/포함 스크립트 검사 후 재사용.
4. 가치 있는 state는 서버 최종 판정.
5. 레퍼런스 분석 후 설계.
6. Engine → Template → Feature Package → Developer Module → approved OSS/asset → custom 순으로 검토.
7. 5~10분 Vertical Slice를 breadth보다 먼저 완성.
8. Studio MCP가 가능하면 AI가 사용자보다 먼저 Playtest.
9. 실패는 regression knowledge로 환류.
10. Roblox 지식은 유통기한이 있으므로 current source 재검증.

## 권장 workflow 후보

Studio-first:
```text
Roblox Studio + Studio MCP + Script Sync + Git + Luau LSP + StyLua + selene
```

Filesystem-first:
```text
Rojo + Rokit + Wally + Git/CI + Studio MCP for QA
```

기존 프로젝트는 Godbase 때문에 강제 migration하지 않는다.

## 2026-09-03 오픈소스/에셋 선별 핵심

- `catalogs/OPEN_SOURCE_ECOSYSTEM_AUDIT.md` — 현재 Roblox OSS를 추천/조건부/전환/레거시로 분류.
- `catalogs/LIBRARY_CATALOG.json` — AI가 읽는 canonical dependency catalog.
- `networking/NETWORK_LIBRARY_DECISION_MATRIX.md` — native remotes vs ByteNet vs Zap vs legacy BridgeNet2.
- `ui/UI_STORYBOOK_COMPONENT_WORKFLOW.md` — UI Labs/Flipbook을 이용한 component state 검증.
- `assets/CREATOR_STORE_SEED_CATALOG.json` — 실제 Creator Store 후보의 첫 metadata catalog.
- `assets/CREATOR_STORE_AUTOMATION_AND_SCORING.md` — API discovery → quarantine Studio audit → production-fit test 자동화 규칙.

중요 상태:
- **Knit**: archived, 신규 기본값 금지.
- **BridgeNet2**: 작성자 README가 ByteNet을 권장하므로 신규 기본값 금지.
- **Zap**: 0.6.x 유지 + rewrite 병행, exact version/branch 확인 필수.
- **Matter**: ECS가 실제로 필요한 게임에서만 조건부.
- **Cmdr/Charm/Nevermore 개별 packages/UI storybook tools**: 문제에 맞으면 강한 후보.
- Creator Store의 rating/vote는 discovery signal일 뿐 S-tier 증명이 아니다.

## 전문 문서 지도

### 공식/워크플로
- `official/CREATOR_DOCS_MAP.md`
- `official/TEMPLATES_FEATURE_PACKAGES_MODULES.md`
- `official/ENGINE_CAPABILITIES_2026.md`
- `workflow/STUDIO_MCP_AND_SCRIPT_SYNC.md`
- `workflow/AI_STUDIO_AUTONOMOUS_PLAYTEST.md`
- `workflow/TOOLCHAIN_DECISION_MATRIX.md`
- `workflow/PACKAGES_TEAM_CREATE_COLLABORATION.md`
- `workflow/OPEN_CLOUD_CI_RELEASE_AUTOMATION.md`

### 구조/코드/OSS
- `architecture/ENGINE_AND_NETWORKING.md`
- `architecture/PROJECT_STRUCTURE_PATTERNS.md`
- `code/LUAU_ENGINEERING_PLAYBOOK.md`
- `code/OPEN_SOURCE_STACK.md`
- `catalogs/OPEN_SOURCE_ECOSYSTEM_AUDIT.md`
- `catalogs/LIBRARY_CATALOG.json`

### 네트워킹/보안
- `networking/REPLICATION_PHYSICS_INPUT.md`
- `networking/NETWORK_LIBRARY_DECISION_MATRIX.md`
- `security/SECURITY_AND_ANTICHEAT.md`

### 공통 게임플레이
- `gameplay/INTERACTION_SYSTEMS.md`
- `gameplay/INVENTORY_EQUIPMENT_ARCHITECTURE.md`
- `gameplay/LOOT_DROP_CRAFTING.md`
- `gameplay/QUEST_OBJECTIVE_MISSIONS.md`
- `gameplay/TRADING_GIFTING_SECURITY_UX.md`
- `gameplay/ROUND_GAME_STATE_ARCHITECTURE.md`
- `gameplay/PROCEDURAL_GENERATION_DETERMINISM.md`
- `social/SOCIAL_PARTY_INVITES.md`
- `operations/ADMIN_MODERATION_COMMANDS.md`

### 월드/에셋/아트
- `level-design/LEVEL_DESIGN_WORLD_TRAVERSAL.md`
- `graphics/TERRAIN_ENVIRONMENT_PIPELINE.md`
- `graphics/VISUAL_QUALITY_PIPELINE.md`
- `graphics/VFX_TELEGRAPHS_EFFECT_BUDGETS.md`
- `assets/CREATOR_STORE_AUDIT_AND_CATALOG.md`
- `assets/CREATOR_STORE_AUTOMATION_AND_SCORING.md`
- `assets/CREATOR_STORE_SEED_CATALOG.json`
- `assets/OFFICIAL_ASSET_CATALOG.json`

### 전투/캐릭터/멀티플레이
- `combat/COMBAT_FEEL_PLAYBOOK.md`
- `combat/HIT_DETECTION_HITBOXES_PROJECTILES.md`
- `ai/NPC_AI_AND_PATHFINDING.md`
- `camera/CAMERA_AND_GAME_FEEL.md`
- `animation/ANIMATION_AND_RIGGING_PIPELINE.md`
- `audio/AUDIO_SYSTEMS_AND_MIXING.md`
- `physics/VEHICLES_CONSTRAINTS_NETWORK_OWNERSHIP.md`
- `avatar/AVATAR_CHARACTER_ACCESSORIES.md`
- `multiplayer/TELEPORT_MATCHMAKING_RESERVED_SERVERS.md`

### UI
- `design/UI_UX_PLAYBOOK.md`
- `ui/CROSS_PLATFORM_ACCESSIBILITY_LOCALIZATION.md`
- `ui/UI_STORYBOOK_COMPONENT_WORKFLOW.md`

### 데이터/경제/운영
- `data/CLOUD_SERVICES_DECISION_MATRIX.md`
- `data/SAVE_SCHEMA_MIGRATION_RECOVERY.md`
- `data/ECONOMY_BALANCING_INFLATION.md`
- `production/DISCOVERY_GROWTH_RETENTION.md`
- `production/MONETIZATION_LIVEOPS_NOTIFICATIONS.md`
- `analytics/ANALYTICS_EVENT_TAXONOMY_EXPERIMENTS.md`
- `publishing/POLICY_MARKETPLACE_LOCALIZATION.md`

### 품질/테스트
- `debugging/STUDIO_DEBUGGING_VISUALIZATION.md`
- `performance/PERFORMANCE_AND_STREAMING.md`
- `performance/LOADING_MEMORY_STREAMING_BUDGETS.md`
- `testing/AUTOMATED_ACCEPTANCE_GATES.md`
- `testing/DEVICE_NETWORK_TEST_MATRIX.md`
- `checklists/ASSET_IMPORT_CHECKLIST.md`
- `checklists/SHIP_CHECKLIST.md`

## 공식 출발점

- Creator Docs agent index: https://create.roblox.com/docs/llms.txt
- Full docs: https://create.roblox.com/docs/llms-full.txt
- Engine API: https://create.roblox.com/docs/reference/engine/llms.txt
- Open Cloud: https://create.roblox.com/docs/cloud/llms.txt
- Creator Store Cloud/API surface: https://create.roblox.com/docs/cloud/reference/features/creator-store
- Creator Docs source: https://github.com/Roblox/creator-docs
- Studio MCP: https://create.roblox.com/docs/studio/mcp
- Script Sync: https://create.roblox.com/docs/scripting/sync

## Godbase 자체 품질관리

`tools/godbase/validate.py` + `.github/workflows/godbase-check.yml`가 manifest 경로, JSON 파싱, 비정상적으로 빈 문서 등을 검사한다.

## 사용자 테스트 전

`testing/AUTOMATED_ACCEPTANCE_GATES.md`를 적용한다. 최소 clean boot, unexpected Output error 0, 정상 spawn, primary loop 직접 완주, screenshot visual review, model integrity, desktop/mobile UI, server authority를 확인한다. 통과 전 상태는 `INTERNAL_PROTOTYPE`이다.

Godbase는 완결된 백과사전이 아니라 **Roblox가 바뀔수록 같이 갱신되는 개발 운영체계**다.
