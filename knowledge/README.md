# Roblox Godbase

> 검증 기준일: 2026-09-03

`knowledge/`는 이 monorepo의 모든 Roblox 프로젝트가 공통으로 참조하는 **개발 지식 정본**이다. Roblox Studio·Luau·AI 개발·아키텍처·에셋·UI/UX·레벨 디자인·Terrain·3D 아트·전투·히트박스·VFX·카메라·애니메이션·오디오·NPC AI·물리/차량·아바타·Teleport/Matchmaking·보안·성능·저장·경제·LiveOps·Analytics·정책·배포·오픈소스 도구·실패 회귀 지식을 지속적으로 조사하고 검증한다.

목표는 모든 것을 기억으로 때우는 것이 아니라 **현재 검증된 해결책을 먼저 검색하고, 실제 Studio에서 확인하며, 이미 알려진 실패를 반복하지 않는 것**이다.

## 가장 먼저 읽기

새 Roblox 작업을 시작하는 AI/개발자는:
1. `GODBASE_MANIFEST.json`
2. `AGENT_PROTOCOL.md`
3. `QUICK_REFERENCE.md`
4. `regressions/FAILURE_LIBRARY.md`
5. 작업 domain 전문 문서

새 프로젝트라면 추가로 `PROJECT_START_CHECKLIST`, `TOOLCHAIN_DECISION_MATRIX`, `AI_STUDIO_AUTONOMOUS_PLAYTEST`, `VERTICAL_SLICE_DONE_DEFINITION`, `LEVEL_DESIGN_WORLD_TRAVERSAL`을 확인한다.

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

## 주요 전문 문서 지도

### 공식/도구
- `official/CREATOR_DOCS_MAP.md`
- `official/TEMPLATES_FEATURE_PACKAGES_MODULES.md`
- `official/ENGINE_CAPABILITIES_2026.md`
- `workflow/STUDIO_MCP_AND_SCRIPT_SYNC.md`
- `workflow/AI_STUDIO_AUTONOMOUS_PLAYTEST.md`
- `workflow/TOOLCHAIN_DECISION_MATRIX.md`
- `workflow/PACKAGES_TEAM_CREATE_COLLABORATION.md`
- `workflow/OPEN_CLOUD_CI_RELEASE_AUTOMATION.md`

### 구조/코드/네트워킹
- `architecture/ENGINE_AND_NETWORKING.md`
- `architecture/PROJECT_STRUCTURE_PATTERNS.md`
- `networking/REPLICATION_PHYSICS_INPUT.md`
- `code/LUAU_ENGINEERING_PLAYBOOK.md`
- `code/OPEN_SOURCE_STACK.md`
- `catalogs/LIBRARY_CATALOG.json`

### 월드/아트
- `level-design/LEVEL_DESIGN_WORLD_TRAVERSAL.md`
- `graphics/TERRAIN_ENVIRONMENT_PIPELINE.md`
- `graphics/WORLD_ART_ANIMATION_AUDIO.md`
- `graphics/VISUAL_QUALITY_PIPELINE.md`
- `graphics/VFX_TELEGRAPHS_EFFECT_BUDGETS.md`
- `assets/CREATOR_STORE_AUDIT_AND_CATALOG.md`
- `assets/OFFICIAL_ASSET_CATALOG.json`

### 게임플레이
- `combat/COMBAT_FEEL_PLAYBOOK.md`
- `combat/HIT_DETECTION_HITBOXES_PROJECTILES.md`
- `ai/NPC_AI_AND_PATHFINDING.md`
- `camera/CAMERA_AND_GAME_FEEL.md`
- `animation/ANIMATION_AND_RIGGING_PIPELINE.md`
- `audio/AUDIO_SYSTEMS_AND_MIXING.md`
- `physics/VEHICLES_CONSTRAINTS_NETWORK_OWNERSHIP.md`
- `avatar/AVATAR_CHARACTER_ACCESSORIES.md`
- `multiplayer/TELEPORT_MATCHMAKING_RESERVED_SERVERS.md`

### UI/접근성
- `design/GAME_DESIGN_AND_FTUE.md`
- `design/UI_UX_PLAYBOOK.md`
- `ui/CROSS_PLATFORM_ACCESSIBILITY_LOCALIZATION.md`

### 데이터/경제/운영
- `data/CLOUD_SERVICES_DECISION_MATRIX.md`
- `data/SAVE_SCHEMA_MIGRATION_RECOVERY.md`
- `data/ECONOMY_BALANCING_INFLATION.md`
- `data/DATA_ECONOMY_AND_LIVEOPS.md`
- `analytics/ANALYTICS_EVENT_TAXONOMY_EXPERIMENTS.md`
- `production/DISCOVERY_GROWTH_RETENTION.md`
- `production/MONETIZATION_LIVEOPS_NOTIFICATIONS.md`
- `publishing/POLICY_MARKETPLACE_LOCALIZATION.md`

### 품질/검증
- `debugging/STUDIO_DEBUGGING_VISUALIZATION.md`
- `performance/PERFORMANCE_AND_STREAMING.md`
- `performance/LOADING_MEMORY_STREAMING_BUDGETS.md`
- `security/SECURITY_AND_ANTICHEAT.md`
- `testing/AUTOMATED_ACCEPTANCE_GATES.md`
- `testing/DEVICE_NETWORK_TEST_MATRIX.md`
- `checklists/PROJECT_START_CHECKLIST.md`
- `checklists/VERTICAL_SLICE_DONE_DEFINITION.md`
- `checklists/ASSET_IMPORT_CHECKLIST.md`
- `checklists/SHIP_CHECKLIST.md`

### 학습/회귀
- `research/OFFICIAL_CURRICULUM_ROADMAP.md`
- `research/COURSES_COMMUNITY_AND_CONTINUOUS_LEARNING.md`
- `research/CONTINUOUS_RESEARCH_ROADMAP.md`
- `genre/GENRE_REFERENCE_MATRIX.md`
- `regressions/FAILURE_LIBRARY.md`

## 공식 출발점

- Creator Docs agent index: https://create.roblox.com/docs/llms.txt
- Full docs: https://create.roblox.com/docs/llms-full.txt
- Engine API: https://create.roblox.com/docs/reference/engine/llms.txt
- Open Cloud: https://create.roblox.com/docs/cloud/llms.txt
- Creator Docs source: https://github.com/Roblox/creator-docs
- Studio MCP: https://create.roblox.com/docs/studio/mcp
- Script Sync: https://create.roblox.com/docs/scripting/sync

## 사용자 테스트 전 quality gate

`testing/AUTOMATED_ACCEPTANCE_GATES.md`를 적용한다. 최소 Studio clean boot, unexpected Output error 0, 정상 spawn, primary loop 실제 완주, screenshot visual review, moving model integrity, desktop/mobile UI, valuable state server authority를 확인한다.

이를 통과하지 않은 artifact는 `INTERNAL_PROTOTYPE`이다.

## 실패 정본

`regressions/FAILURE_LIBRARY.md`는 mandatory read다. Blind rbxlx generation, bootstrap single-point failure, z-fighting, Model 일부만 이동, placeholder art, random map soup, surface-copy combat, breadth-before-feel, patch stacking 등 이미 겪은 문제를 반복하지 않는다.

## 지속 연구

`research/CONTINUOUS_RESEARCH_ROADMAP.md`가 장기 queue다. Creator Store 실물 S/A tier catalog, 공식 Module/Feature Package 실제 Studio integration, 장르별 현행 상위 게임 역설계, DevForum/강의/creator talks 정제, MCP 자동 regression harness, 기존 `projects/` failure mining을 계속한다.

Godbase는 완결된 백과사전이 아니라 **Roblox가 바뀔수록 함께 갱신되는 개발 운영체계**다.
