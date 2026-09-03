# Continuous Research Roadmap

> started: 2026-09-03

Godbase는 한 번 작성하고 끝나는 문서가 아니다. Roblox engine, policies, Creator Store, popular genres, tooling이 계속 변하므로 아래 queue를 반복 연구한다.

## Research rule

한 항목이 `DONE`이 되려면 링크를 찾는 것만으로 부족하다.

필수:
1. source grade
2. verified date
3. 핵심 주장 요약
4. current/deprecated 여부
5. Studio reproduction 또는 executable example inspection where relevant
6. security/performance note
7. Godbase의 실제 decision/checklist에 반영

## Phase A — Official platform sweep

### A1 Creator Docs map — ACTIVE
Coverage:
- Studio
- scripting/Luau
- engine APIs
- client-server/security
- input
- UI
- art
- animation/audio
- physics
- streaming
- performance
- cloud
- monetization
- analytics/discovery
- publishing/localization
- Open Cloud
- AI/MCP

Method:
`llms.txt` tree diff를 주기적으로 보고 신규/변경 문서 확인.

### A2 Templates — ACTIVE
각 template별:
- gameplay features
- architecture
- server/client split
- reusable patterns
- visual reference
- current limitations

### A3 Feature Packages — ACTIVE
Core/Bundles/Missions/Season Passes/Engagement Rewards.
실제 test place integration을 별도 future task로 수행.

### A4 Developer Modules — ACTIVE
모든 official module을 isolated place에서 실행하여:
- dependencies
- data use
- UI
- extension points
- security
을 기록.

## Phase B — Creator Store supply map

Category sweeps:
- environment packs
- modular buildings
- vegetation
- rocks/terrain props
- weapons
- fantasy/SF/modern props
- enemies/NPC rigs
- animation packs
- VFX
- audio
- icons/UI
- procedural generators
- plugins
- complete kits/templates

목표는 수량 수집이 아니다. category당:
- S tier 5~20
- A tier 10~50
- reject patterns
를 만드는 것.

모든 scripted asset은 quarantine audit.

## Phase C — Open-source ecosystem

Categories:
- data/persistence
- networking/remotes
- async/events
- cleanup/lifecycle
- UI frameworks
- component/storybook UI
- ECS/components
- state management
- command/admin
- testing
- serialization
- math/springs/camera
- pathfinding/AI
- animation helpers
- toolchain/build/CI

각 후보:
- repo/license
- archived
- recent maintenance
- docs/tests
- Wally package
- alternatives
- migration cost

## Phase D — Genre reverse engineering

장르별 상위/신흥 Roblox games를 실제 플레이 기준으로 분석한다.

### RPG / action RPG
metrics:
- first fun time
- camera/FOV
- combat timings
- enemy density
- progression curve
- loot feedback
- zone pacing
- HUD density

### Simulator
- collect/conversion loop
- upgrade cadence
- rebirth timing
- pets/collection
- automation
- monetization placement

### Battleground
- input responsiveness
- combo grammar
- hit feedback
- mobility
- stun/recovery
- matchmaking/round flow

### Tycoon
- income visibility
- purchase placement
- unlock pacing
- spatial expansion

### Tower Defense
- placement UX
- wave info
- target priority
- upgrade UX
- speed controls

### Horror
- audio
- darkness/readability
- pacing
- chase/AI
- co-op communication

### Roguelite / dungeon
- room duration
- reward choice
- run build variety
- death/meta progression

### Social / roleplay
- avatar expression
- social proximity
- interaction affordances
- creator tools/content loops

관찰 facts와 interpretation을 분리한다. proprietary content를 복제하지 않는다.

## Phase E — Community knowledge

Sources:
- Roblox DevForum
- reputable creator engineering blogs
- GDC/creator talks when available
- long-lived open-source docs
- high-quality technical YouTube/course

Priority topics:
- production war stories
- large-world optimization
- anti-cheat
- networking
- UI architecture
- liveops/economy
- animation/combat feel

Community advice는 current official API와 Studio reproduction으로 검증 후 B→A 수준으로 승격 가능.

## Phase F — Internal regression mining

모든 `projects/`에서:
- bugs
- test reports
- UI failures
- data failures
- performance failures
을 정기적으로 읽고 공용 lesson을 `regressions/FAILURE_LIBRARY.md`에 환류.

특정 프로젝트 구현을 다른 프로젝트에 그대로 복사하지 않고 principle만 공용화한다.

## Phase G — Starter arsenal

지식이 충분히 검증된 뒤에만 `shared/`로 실제 reusable modules/starter components를 승격한다.

후보:
- secure remote validation primitives
- profile bootstrap/migrations
- receipt idempotency
- UI design tokens
- input action bootstrap
- common analytics taxonomy
- Studio acceptance test helpers

Godbase 문서에 적혔다는 이유만으로 shared production code가 되지 않는다. 최소 2개 project에서 검증 후 공용화를 고려한다.

## Freshness cadence suggestion

- Roblox official docs/engine: monthly or before major project
- security/policy/monetization/discovery: before each release/decision
- libraries/toolchain: quarterly + before upgrade
- Creator Store catalog: when new art direction/project begins
- genre references: each new project + major market shift
- internal regressions: after every meaningful failure

## Never-finish principle

Roblox "전체"를 완전히 고정된 지식으로 만들 수는 없다. 목표는 **모르는 것이 생겼을 때 가장 빠르고 정확하게 현재 정본을 찾고 검증해서 다시 쌓는 시스템**이다.
