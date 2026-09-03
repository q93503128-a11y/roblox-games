# Roblox Godbase

> 검증 기준일: 2026-09-03

`knowledge/`는 이 monorepo의 모든 Roblox 프로젝트가 공통으로 참조하는 **개발 지식 정본**이다. Roblox Studio·Luau·AI 개발·아키텍처·에셋·UI/UX·레벨 디자인·3D 아트·전투·카메라·애니메이션·오디오·NPC AI·보안·성능·저장·경제·LiveOps·Analytics·배포·오픈소스 도구·실패 회귀 지식을 지속적으로 조사하고 검증한다.

목표는 모든 것을 기억으로 때우는 것이 아니라 **현재 검증된 해결책을 먼저 검색하고, 실제 Studio에서 확인하며, 이미 알려진 실패를 반복하지 않는 것**이다.

## 가장 먼저 읽기

새 Roblox 작업을 시작하는 AI/개발자는:
1. `GODBASE_MANIFEST.json`
2. `AGENT_PROTOCOL.md`
3. `QUICK_REFERENCE.md`
4. `regressions/FAILURE_LIBRARY.md`
5. 작업 domain 전문 문서

새 프로젝트라면 추가로:
- `checklists/PROJECT_START_CHECKLIST.md`
- `workflow/TOOLCHAIN_DECISION_MATRIX.md`
- `workflow/AI_STUDIO_AUTONOMOUS_PLAYTEST.md`
- `checklists/VERTICAL_SLICE_DONE_DEFINITION.md`
- `level-design/LEVEL_DESIGN_WORLD_TRAVERSAL.md`

을 확인한다.

## 핵심 원칙

1. **공식 문서 우선** — Creator Docs/Engine API/Open Cloud를 사실 정본으로 사용.
2. **실제 Studio 검증 우선** — 코드가 그럴듯한 것보다 실행·플레이테스트 결과가 우선.
3. **재사용보다 출처 확인이 먼저** — 라이선스/제작자/유지보수/포함 스크립트 검사.
4. **클라이언트를 믿지 않는다** — 경제·저장·보상·중요 전투 결과는 서버 최종 판정.
5. **레퍼런스를 먼저 본다** — UI/맵/전투/성장을 맨땅 상상부터 하지 않는다.
6. **공식 부품을 먼저 찾는다** — Engine → Template → Feature Package → Developer Module → approved OSS/asset → custom.
7. **Vertical Slice 우선** — 시스템 20개보다 실제 좋은 5~10분.
8. **Playtest before scale** — Studio MCP가 가능하면 AI가 먼저 직접 테스트.
9. **실패를 지식으로 환류** — patch stacking보다 regression library.
10. **지식은 유통기한이 있다** — current engine/policy/tool을 다시 확인.

## 현재 권장 workflow 후보

Studio-first:
```text
Roblox Studio
+ Studio MCP
+ Script Sync
+ Git
+ Luau LSP
+ StyLua
+ selene
```

Filesystem-first:
```text
Rojo
+ Rokit
+ Wally
+ Git/CI
+ Studio MCP for QA
```

기존 프로젝트는 Godbase 때문에 workflow를 강제 migration하지 않는다.

## 디렉터리 지도

```text
knowledge/
├─ README.md
├─ GODBASE_MANIFEST.json
├─ AGENT_PROTOCOL.md
├─ QUICK_REFERENCE.md
├─ SOURCE_POLICY.md
├─ official/
│  ├─ CREATOR_DOCS_MAP.md
│  ├─ TEMPLATES_FEATURE_PACKAGES_MODULES.md
│  └─ ENGINE_CAPABILITIES_2026.md
├─ workflow/
│  ├─ STUDIO_MCP_AND_SCRIPT_SYNC.md
│  ├─ AI_STUDIO_AUTONOMOUS_PLAYTEST.md
│  ├─ TOOLCHAIN_DECISION_MATRIX.md
│  ├─ PACKAGES_TEAM_CREATE_COLLABORATION.md
│  └─ OPEN_CLOUD_CI_RELEASE_AUTOMATION.md
├─ architecture/
│  ├─ ENGINE_AND_NETWORKING.md
│  └─ PROJECT_STRUCTURE_PATTERNS.md
├─ networking/
│  └─ REPLICATION_PHYSICS_INPUT.md
├─ code/
│  ├─ OPEN_SOURCE_STACK.md
│  └─ LUAU_ENGINEERING_PLAYBOOK.md
├─ catalogs/
│  └─ LIBRARY_CATALOG.json
├─ assets/
│  ├─ ASSETS_KITS_AND_PLUGINS.md
│  ├─ CREATOR_STORE_AUDIT_AND_CATALOG.md
│  └─ OFFICIAL_ASSET_CATALOG.json
├─ level-design/
│  └─ LEVEL_DESIGN_WORLD_TRAVERSAL.md
├─ design/
│  ├─ GAME_DESIGN_AND_FTUE.md
│  └─ UI_UX_PLAYBOOK.md
├─ ui/
│  └─ CROSS_PLATFORM_ACCESSIBILITY_LOCALIZATION.md
├─ graphics/
│  ├─ WORLD_ART_ANIMATION_AUDIO.md
│  └─ VISUAL_QUALITY_PIPELINE.md
├─ camera/
│  └─ CAMERA_AND_GAME_FEEL.md
├─ animation/
│  └─ ANIMATION_AND_RIGGING_PIPELINE.md
├─ audio/
│  └─ AUDIO_SYSTEMS_AND_MIXING.md
├─ ai/
│  └─ NPC_AI_AND_PATHFINDING.md
├─ combat/
│  └─ COMBAT_FEEL_PLAYBOOK.md
├─ performance/
│  ├─ PERFORMANCE_AND_STREAMING.md
│  └─ LOADING_MEMORY_STREAMING_BUDGETS.md
├─ security/
│  └─ SECURITY_AND_ANTICHEAT.md
├─ data/
│  ├─ DATA_ECONOMY_AND_LIVEOPS.md
│  └─ CLOUD_SERVICES_DECISION_MATRIX.md
├─ analytics/
│  └─ ANALYTICS_EVENT_TAXONOMY_EXPERIMENTS.md
├─ production/
│  ├─ DISCOVERY_GROWTH_RETENTION.md
│  └─ MONETIZATION_LIVEOPS_NOTIFICATIONS.md
├─ testing/
│  ├─ TESTING_RELEASE_ANALYTICS.md
│  ├─ AUTOMATED_ACCEPTANCE_GATES.md
│  └─ DEVICE_NETWORK_TEST_MATRIX.md
├─ genre/
│  └─ GENRE_REFERENCE_MATRIX.md
├─ research/
│  ├─ COURSES_COMMUNITY_AND_CONTINUOUS_LEARNING.md
│  ├─ OFFICIAL_CURRICULUM_ROADMAP.md
│  └─ CONTINUOUS_RESEARCH_ROADMAP.md
├─ regressions/
│  └─ FAILURE_LIBRARY.md
└─ checklists/
   ├─ PROJECT_START_CHECKLIST.md
   ├─ VERTICAL_SLICE_DONE_DEFINITION.md
   ├─ ASSET_IMPORT_CHECKLIST.md
   └─ SHIP_CHECKLIST.md
```

## 공식 출발점

- Creator Docs agent index: https://create.roblox.com/docs/llms.txt
- Full docs: https://create.roblox.com/docs/llms-full.txt
- Engine API: https://create.roblox.com/docs/reference/engine/llms.txt
- Open Cloud: https://create.roblox.com/docs/cloud/llms.txt
- Creator Docs source: https://github.com/Roblox/creator-docs
- Studio MCP: https://create.roblox.com/docs/studio/mcp
- Script Sync: https://create.roblox.com/docs/scripting/sync

## 공용 부품 정책

새 기능을 직접 구현하기 전에:
1. official engine feature
2. official Template
3. official Feature Package
4. official Developer Module
5. `catalogs/LIBRARY_CATALOG.json`
6. audited Creator Store
7. licensed community code
8. custom implementation

순으로 검토한다.

## 사용자 테스트 전 quality gate

`testing/AUTOMATED_ACCEPTANCE_GATES.md`를 적용한다.
최소:
- Studio clean boot
- unexpected Output error 0
- 정상 spawn
- primary loop 실제 완주
- screenshot visual review
- moving model integrity
- desktop/mobile UI
- valuable state server authority

이를 통과하지 않은 artifact는 `INTERNAL_PROTOTYPE`이다.

## 실패 정본

`regressions/FAILURE_LIBRARY.md`는 mandatory read다. Blind rbxlx generation, bootstrap single-point failure, z-fighting, Model 일부만 이동, placeholder art, random map soup, surface-copy combat, breadth-before-feel, patch stacking 등 이미 겪은 문제를 반복하지 않는다.

## 지속 연구

`research/CONTINUOUS_RESEARCH_ROADMAP.md`가 장기 queue다. 큰 남은 축은 Creator Store 실물 S/A tier catalog, 공식 Module/Feature Package 실제 Studio integration, 장르별 현행 상위 게임 역설계, DevForum/강의/creator talks 정제, MCP 자동 regression harness, 기존 `projects/` failure mining이다.

Godbase는 완결된 백과사전이 아니라 **Roblox가 바뀔수록 함께 갱신되는 개발 운영체계**다.
