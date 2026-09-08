# AI Roblox Development Sources — 2026-09-08

> purpose: curated evidence for AI-assisted Roblox development decisions
> source policy: `../SOURCE_POLICY.md`

이 문서는 Roblox AI 개발의 최신 근거를 한 곳에 모은다. 링크 수보다 **어떤 결정을 뒷받침하는 source인지**를 기록한다.

---

## S-grade — Roblox official

### Roblox Studio is Going Agentic
- URL: https://about.roblox.com/newsroom/2026/04/roblox-studio-going-agentic
- verified: 2026-09-08
- supports:
  - Roblox의 공식 `Plan → Build → Test` agentic 방향
  - one-shot generation보다 reviewable planning을 강조
  - Playtesting Agent Beta
  - Studio built-in MCP를 통한 third-party agent integration
  - reusable procedural model 방향
- use for: AI workflow architecture / Agent role design

### Assistant for Studio
- URL: https://create.roblox.com/docs/assistant/guide
- verified: 2026-09-08
- supports:
  - Studio Assistant capabilities
  - generated mesh / procedural model workflow
  - current generation limits and UI behavior
- freshness note: generation limits and supported commands are time-sensitive; recheck before relying on exact numbers.

### Roblox Studio MCP
- URL: https://create.roblox.com/docs/studio/mcp
- verified: 2026-09-08
- supports:
  - Studio built-in MCP server
  - DataModel/script interaction
  - play mode testing
  - mesh/material/procedural generation
  - Creator Store search/asset insertion
  - explore/playtest subagents where documented
- use for: deciding when external AI client should directly control Studio

### Procedural Models
- URL: https://create.roblox.com/docs/parts/procedural-models
- verified: 2026-09-08
- supports:
  - configurable reusable procedural structures
  - Assistant/MCP generation
  - edit-time integration
- use for: replacing repeated primitive-Part hand building with adjustable modules

### Packages
- URL: https://create.roblox.com/docs/projects/assets/packages
- verified: 2026-09-08
- supports:
  - reusable asset hierarchies across projects
  - versioning
  - selected/all/automatic updates
  - placeholder package → later production version workflow
- use for: Godbase shared production modules

### Studio testing modes
- URL: https://create.roblox.com/docs/studio/testing-modes
- verified: 2026-09-08
- supports:
  - StudioTestService
  - StudioDeviceSimulatorService
  - VirtualInput
  - scripted multi-client/device/input testing
- use for: deterministic P0 route automation and cross-device regression

### Scene Analysis
- URL: https://create.roblox.com/docs/performance-optimization/scene-analysis
- verified: 2026-09-08
- supports:
  - client/server scene comparison
  - resource/instance contribution analysis
- use for: map/package performance regression

### MicroProfiler
- URL: https://create.roblox.com/docs/performance-optimization/microprofiler
- verified: 2026-09-08
- supports:
  - detailed frame timing for engine/script/physics/render work
- use for: root-cause performance investigation after a baseline indicates a problem

### Analytics event types
- URL: https://create.roblox.com/docs/production/analytics/event-types
- verified: 2026-09-08
- supports:
  - Economy/Funnel/Custom events
  - free Creator Dashboard analysis
  - onboarding/progression/shop/core-loop measurement
- use for: replacing subjective live-game guesses with behavior evidence

### Third-party security vulnerabilities
- URL: https://create.roblox.com/docs/scripting/security/third-party-vulnerabilities
- use for: Creator Store / third-party script quarantine policy

### Roblox Creator Docs LLM indexes
- https://create.roblox.com/docs/llms.txt
- https://create.roblox.com/docs/llms-full.txt
- https://create.roblox.com/docs/reference/engine/llms.txt
- use for: broad current official documentation routing

---

## A/B-grade implementation reference

### ColinEdw/RobloxStudioMCP
- repo: https://github.com/ColinEdw/RobloxStudioMCP
- relevant file: `skills/roblox-building/SKILL.md`
- license: MIT
- license verified: 2026-09-08
- useful ideas:
  - large builds decomposed into sections
  - build → view → clipping check → fix loop
  - relative placement instead of repeated hand-computed absolute coordinates
  - orthographic/scene inspection for geometry alignment
  - raycast/ground-aware placement
  - reusable modules instead of repeated low-level Parts
- policy:
  - treat tool names and exact APIs as implementation-specific, not Roblox platform facts
  - generalize workflow lessons into Godbase
  - code reuse only under MIT terms and after project-fit review

---

## Key conclusions supported by the sources

### 1. One-shot AI building is not the target workflow
Official Roblox direction explicitly favors a reviewable multi-step plan/build/test loop for complex work.

### 2. The AI that edits a 3D scene should receive visual/runtime feedback
Studio Agent/MCP/playtest capabilities reduce blind generation. For map work, this is a major quality improvement over chat-only coordinate generation.

### 3. Better geometry comes from reducing raw coordinate decisions
Hierarchical structures, relative relationships, packages, procedural models, bounds/raycast checks, and section verification reduce floating/clipping/scale errors.

### 4. Reuse should include both components and tests
Packages provide component versioning; Studio scripted testing can provide repeatable QA. Godbase should accumulate both.

### 5. Human testing should move upward
Humans should spend more time on fun, feel, taste, readability and direction; structural failures should increasingly be caught by AI/Studio/scripted QA first.

### 6. Performance and analytics belong in the development loop
Scene Analysis/MicroProfiler should inform performance before the world becomes huge, and AnalyticsService should inform live design after release.

---

## Files produced from this research

- `../level-design/AI_MAP_BUILDING_PLAYBOOK.md`
- `../workflow/ROBLOX_ASSISTANT_AGENT_WORKFLOW.md`
- `../production/REUSABLE_PACKAGE_AND_QA_SYSTEM.md`
- `../PROJECT_AI_INSTRUCTIONS.md`

Future research should update these canonical docs rather than spawning parallel duplicate notes unless the subject is genuinely new.
