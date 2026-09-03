# Engine Capabilities 2026

> verified: 2026-09-03
> rule: engine features change quickly. Re-check official API before production adoption.

이 문서는 오래된 Roblox 튜토리얼만 따라가면 놓치기 쉬운 현재 엔진 기능을 정리한다.

## Studio MCP
Official: https://create.roblox.com/docs/studio/mcp

AI client가 열린 Studio 세션과 직접 상호작용한다.
- DataModel inspect/search
- script read/edit/search
- Luau execute
- Creator Store search/insert
- Play mode start/stop
- console output
- screen capture
- character navigation
- keyboard/mouse input

의미: AI 개발은 blind `.rbxlx` generation보다 **Studio-in-the-loop**가 우선이다.

## Script Sync
Official: https://create.roblox.com/docs/scripting/sync

Studio scripts와 disk `.luau`를 양방향 동기화한다.
- top-level sync root당 최대 10,000 scripts
- 최대 128 top-level roots (verified date 기준)
- Folder/Script/LocalScript/ModuleScript 중심
- Team Create 지원

전체 DataModel을 파일시스템 정본으로 만들려면 Rojo가 더 적합하다.

## Input Action System
Official: https://create.roblox.com/docs/input/input-action-system

`InputAction`과 bindings로 gameplay action을 hardware input과 분리한다.
Use:
- touch / gamepad / keyboard mapping
- combat/spectator context switching
- ability hotkeys
- driving controls

새 프로젝트에서 `UserInputService.InputBegan`를 곳곳에 직접 하드코딩하기 전에 IAS를 검토한다.

## Server Authority
Official:
- https://create.roblox.com/docs/projects/server-authority
- https://create.roblox.com/docs/reference/engine/enums/AuthorityMode

`Workspace.AuthorityMode = Server`는 server authoritative simulation + client prediction/rollback 방향의 현재 엔진 모델이다.

공식 문서가 요구하는 관련 engine settings와 beta/availability를 실제 Studio에서 다시 확인한다.

설계 영향:
- prediction/re-simulation에 side effect가 중복되지 않게 함
- audio/VFX/network write를 simulation logic과 분리
- `RunService:IsResimulating()` 등 current API 검토
- 기존 distributed network ownership와 behavior 차이를 test

`Automatic`은 전통적 distributed authority model이며 `SetNetworkOwner()` 영향을 받는다.

## Network Ownership
Security reference:
https://create.roblox.com/docs/scripting/security/network-ownership

클라이언트가 physics ownership을 가지면 해당 물리 상태를 조작할 수 있다는 threat model을 가진다.
- competitive projectile
- physics-based reward trigger
- vehicle
- touched-based damage
에서 server validation을 별도로 설계한다.

## Instance Streaming
Large world에서 memory/load time의 핵심 lever.

Principles:
- `StreamingEnabled` 검토
- 필요 이상으로 Persistent model 사용 금지
- gameplay-critical object availability를 streaming-aware하게 설계
- client에서 멀리 있는 Instance가 존재한다고 가정하지 않음
- stream-in/out 이후 connections/state 복구

Performance docs:
https://create.roblox.com/docs/performance-optimization/improve

## Parallel Luau
Official: https://create.roblox.com/docs/scripting/multithreading

Core concepts:
- Actor
- `task.desynchronize()` / `task.synchronize()`
- `ConnectParallel`
- SharedTable / messaging patterns

Good candidates:
- many independent NPC calculations
- large raycast/query workloads
- procedural calculations
- CPU-heavy pure computation

Bad default:
- 모든 code parallelization
- DataModel mutation이 많은 간단한 gameplay
- 작은 작업을 Actor 수백 개로 쪼개 overhead 증가

먼저 profiler로 CPU bottleneck을 확인한다.

## Native code generation
일부 CPU-heavy Luau는 native compilation flag로 이득을 볼 수 있다. 지원 범위/제약은 현재 docs/API를 확인하고 profiler 기반으로 도입한다.

## ProceduralModel
Official: https://create.roblox.com/docs/parts/procedural-models

parameter/attribute 기반으로 edit/runtime model을 생성하는 current Roblox workflow.
Use:
- modular buildings
- tracks
- fences
- configurable environment assets
- repetitive art production

Creator Store procedural generator ModuleScript는 sandbox/capability 경계를 확인한다.

## AI asset generation
Official: https://create.roblox.com/docs/ai/accelerated-workflows

현재 Studio AI workflow에서 지원되는 범주를 공식 문서에서 확인:
- material generation
- mesh/model generation
- scripted/model editing
- Assistant-driven creation

Rule:
AI asset는 **초안 가속 도구**다. 최종 채택 전:
- silhouette
- scale
- topology/performance
- collision
- pivot
- material consistency
- mobile render cost
검수.

## Material Generator / PBR
- https://create.roblox.com/docs/studio/material-generator
- https://create.roblox.com/docs/art/overview-studio

MaterialVariant / PBR material pipeline을 art direction에 맞춰 사용한다. 모든 표면에 고해상도 PBR을 쓰는 것은 품질이 아니라 비용 증가일 수 있다.

## glTF export
Current beta/reference:
https://create.roblox.com/docs/art/modeling/gltf-export

Studio assets/place를 external DCC(Blender/Maya 등) workflow로 넘길 때 검토한다. beta status와 export support는 매번 확인.

## EditableImage / editable assets
Runtime/editable graphics는 powerful하지만 permissions, ownership, memory/frame update constraints가 있다. 최신 API page를 확인하고 일반 UI image replacement처럼 가볍게 취급하지 않는다.

## UnreliableRemoteEvent
고빈도이며 일부 packet loss가 허용되는 cosmetic/transient data에 검토한다.
예:
- aim visuals
- continuously updated cosmetic positions
- non-critical effect hints

절대 사용하지 않을 것:
- 구매
- inventory mutation
- authoritative damage result
- critical progression

## Network simulation
Studio testing modes에서 latency/packet loss/jitter simulation을 사용해 remotes와 prediction이 현실적인 network에서 버티는지 확인한다.

Docs: https://create.roblox.com/docs/studio/testing-modes

## ContentProvider preload
Rule:
- loading UI/start area의 critical assets만 preload
- Workspace 전체 preload 금지
- timeout/skip path 고려
- `RequestQueueSize`를 정확한 percentage bar의 source-of-truth로 취급하지 않음

API: https://create.roblox.com/docs/reference/engine/classes/ContentProvider

## Capability adoption policy

새 엔진 기능을 발견했을 때:
1. official status/beta 확인
2. minimum isolated prototype
3. desktop/mobile/network test
4. rollback path 작성
5. performance profile
6. security implications 검토
7. 실제 프로젝트에 gradual adoption

Godbase는 최신 기능을 적극 활용하되 **새롭다는 이유만으로 production default로 승격하지 않는다.**
