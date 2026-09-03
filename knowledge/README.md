# Roblox Godbase

> 검증 기준일: 2026-09-04

`knowledge/`는 이 monorepo의 모든 Roblox 프로젝트가 공통으로 참조하는 **개발 지식 정본**이다. 목표는 Roblox를 기억으로 때우는 것이 아니라, 현재 검증된 해결책·도구·에셋·실패 패턴을 먼저 찾고 실제 Studio에서 검증한 뒤 구현하는 것이다.

## 가장 먼저 읽기

모든 새 Roblox 작업:

`GODBASE_MANIFEST.json → AGENT_PROTOCOL.md → QUICK_REFERENCE.md → regressions/FAILURE_LIBRARY.md → catalogs/DEPRECATED_LEGACY_WATCHLIST.md → 작업 domain 문서`

새 프로젝트는 추가로 `PROJECT_START_CHECKLIST`, `TOOLCHAIN_DECISION_MATRIX`, `AI_STUDIO_AUTONOMOUS_PLAYTEST`, `VERTICAL_SLICE_DONE_DEFINITION`, `LEVEL_DESIGN_WORLD_TRAVERSAL`을 확인한다.

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

## 최신 OSS / 테스트 / 구조 판단

Canonical machine-readable catalog: `catalogs/LIBRARY_CATALOG.json`.

현재 중요한 판정:
- **Knit** → archived, 신규 기본값 금지.
- **TestEZ** → archived; 신규 테스트는 Roblox가 현재 유지하는 **Jest Roblox** 우선 평가.
- **ProfileService** → upstream README가 신규 프로젝트에 **ProfileStore 사용**을 직접 권고.
- **BridgeNet2** → upstream이 ByteNet을 권고. 신규 기본값 금지.
- **Zap** → 0.6.x 유지 + rewrite 병행, exact branch/version 필요.
- **jecs** → 현재 활발한 ECS 후보. ECS가 필요한 신규 프로젝트에서 Matter와 비교하되 jecs를 먼저 검토할 가치가 큼.
- **Matter** → 여전히 유효한 established ECS지만 무조건 기본값은 아님.
- **Chickynoid** → custom server-authoritative character simulation의 연구/특수용 후보. 먼저 current Roblox native Server Authority를 검토.
- **Flamework** → roblox-ts를 의도적으로 선택한 프로젝트에서만 조건부.
- **Ripple** → UI/motion에 강한 현재 후보. 단순 TweenService로 충분하면 추가하지 않음.
- **TopbarPlus** → 유용할 수 있으나 adoption 전 정확한 license terms 검토.

관련 문서:
- `catalogs/OPEN_SOURCE_ECOSYSTEM_AUDIT.md`
- `catalogs/DEPRECATED_LEGACY_WATCHLIST.md`
- `architecture/ECS_CHARACTER_SIMULATION_DECISION.md`
- `testing/LUAU_TESTING_FRAMEWORKS_AND_CI.md`
- `networking/NETWORK_LIBRARY_DECISION_MATRIX.md`
- `ui/UI_STORYBOOK_COMPONENT_WORKFLOW.md`
- `ui/UI_MOTION_TOPBAR_MICROINTERACTIONS.md`

## 테스트 방향

Roblox 공식 `Jest Roblox`가 현재 유지되고 있으며 upstream README는 Roblox 내부 앱/CoreScripts/Studio plugins 등에 사용한다고 설명하고, **OCALE(Open Cloud API for Luau Execution)** 기반 CI 실행도 지원한다고 명시한다.

Godbase 테스트 계층:
```text
pure/domain unit tests
→ DataModel tests
→ Studio integration
→ Studio MCP end-to-end regression route
```

Unit test가 실제 Playtest를 대체하지 않는다.

## Creator Store 공급망

Canonical procurement files:
- `assets/CREATOR_STORE_SUPPLY_CATALOG.json` — 현재 선별된 실제 공급 후보/보류/거절 목록.
- `assets/OFFICIAL_ROBLOX_ASSET_PACKS.md` — Roblox 공식 팩/Developer Module 우선 공급원.
- `assets/ASSET_SELECTION_BY_GENRE.md` — RPG/시뮬레이터/호러/도시/전투/VFX 등 장르별 선택 순서.
- `assets/CREATOR_STORE_RED_FLAGS_AND_QUARANTINE.md` — backdoor/virus 신고, 검색어 스팸, 과도한 script surface, 깨진 dependency 처리.
- `assets/CREATOR_STORE_SEED_CATALOG.json` — 초기 웹/API metadata seed.
- `assets/CREATOR_STORE_AUTOMATION_AND_SCORING.md` — discovery → quarantine Studio audit → production-fit test.
- `assets/CREATOR_STORE_AUDIT_AND_CATALOG.md` — 보안/출처/품질 정책.

### 2026-09-04 실물 선별 핵심

강한 공식 공급원:
- Roblox `Forest Pack` — realistic/stylized-real foliage source library.
- `Synty Nature Pack` — stylized/low-poly world의 강한 generic seed.
- `City Road Pack` — modular road/PBR/traffic-light reference.
- `Duvall Drive` props/furniture/landscaping/material variants — production environment/detail/PBR reference.
- `RO-01 Robot` — NPC Kit/rig/animation organization reference.
- `Merch Booth [Dev Module]` — intended use가 맞을 때 공식 기능 우선.

중요 HOLD/REJECT:
- `Synty City Pack` — 현재 리뷰에서 removed texture 문제가 반복 보고되어 HOLD.
- `Nature Pack Studs Trees Bush Grass Flower` (`82060619904561`) — 최근 리뷰에 backdoor/virus 의혹이 있어 REJECT.
- generic `free` bulk asset (`17300868459`) — 56 scripts + 거대한 dependency surface + 빈약한 provenance로 REJECT.
- `[FREE] Low Poly Dungeon Kit` (`84153348982194`) — 설명의 대규모 unrelated trending-keyword spam으로 discovery trust 낮아 REJECT.

**평점/투표 수는 discovery signal일 뿐 S-tier 증명이 아니다.** 구체적인 security/dependency report는 aggregate rating보다 우선한다. Scripted kit/plugin은 quarantine에서 먼저 검사한다. 대형 asset pack은 필요한 subset만 추출한다.

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
- `architecture/ECS_CHARACTER_SIMULATION_DECISION.md`
- `code/LUAU_ENGINEERING_PLAYBOOK.md`
- `code/OPEN_SOURCE_STACK.md`
- `catalogs/OPEN_SOURCE_ECOSYSTEM_AUDIT.md`
- `catalogs/DEPRECATED_LEGACY_WATCHLIST.md`
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
- `assets/OFFICIAL_ROBLOX_ASSET_PACKS.md`
- `assets/ASSET_SELECTION_BY_GENRE.md`
- `assets/CREATOR_STORE_RED_FLAGS_AND_QUARANTINE.md`
- `assets/CREATOR_STORE_AUDIT_AND_CATALOG.md`
- `assets/CREATOR_STORE_AUTOMATION_AND_SCORING.md`
- `assets/CREATOR_STORE_SUPPLY_CATALOG.json`
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
- `ui/UI_MOTION_TOPBAR_MICROINTERACTIONS.md`

### 데이터/경제/운영
- `data/CLOUD_SERVICES_DECISION_MATRIX.md`
- `data/SAVE_SCHEMA_MIGRATION_RECOVERY.md`
- `data/ECONOMY_BALANCING_INFLATION.md`
- `production/DISCOVERY_GROWTH_RETENTION.md`
- `production/MONETIZATION_LIVEOPS_NOTIFICATIONS.md`
- `analytics/ANALYTICS_EVENT_TAXONOMY_EXPERIMENTS.md`
- `publishing/POLICY_MARKETPLACE_LOCALIZATION.md`

### 품질/테스트
- `testing/LUAU_TESTING_FRAMEWORKS_AND_CI.md`
- `testing/AUTOMATED_ACCEPTANCE_GATES.md`
- `testing/DEVICE_NETWORK_TEST_MATRIX.md`
- `debugging/STUDIO_DEBUGGING_VISUALIZATION.md`
- `performance/PERFORMANCE_AND_STREAMING.md`
- `performance/LOADING_MEMORY_STREAMING_BUDGETS.md`
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

`testing/AUTOMATED_ACCEPTANCE_GATES.md`를 적용한다. clean boot, unexpected Output error 0, 정상 spawn, primary loop 직접 완주, screenshot visual review, model integrity, desktop/mobile UI, server authority를 확인한다. 통과 전 상태는 `INTERNAL_PROTOTYPE`이다.

Godbase는 완결된 백과사전이 아니라 **Roblox가 바뀔수록 같이 갱신되는 개발 운영체계**다.
