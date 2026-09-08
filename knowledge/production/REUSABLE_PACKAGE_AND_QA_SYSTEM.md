# Reusable Package and QA System

> verified: 2026-09-08
> status: production-system roadmap

Godbase의 다음 단계는 지식 문서를 계속 늘리는 것이 아니라 **검증된 시스템과 검증 절차를 재사용 가능한 생산 자산으로 바꾸는 것**이다.

핵심:

```text
Knowledge reuse
+ Component reuse
+ Test reuse
+ Failure reuse
= project-to-project quality compounding
```

---

## 1. Why this matters

프로젝트마다 다음을 다시 만들면 같은 실패가 반복된다.
- 상호작용
- 문/포탈
- 상점
- 퀘스트 NPC
- health bar
- loot pickup
- mobile HUD
- save status
- basic arena shell
- common UI modal

한 번 검증한 것을 다시 처음부터 생성하는 것은 AI 개발의 장점을 버리는 일이다.

---

## 2. Roblox Packages as reusable production assets

Roblox Packages는 여러 place/game에서 같은 asset hierarchy를 재사용하고 버전 업데이트할 수 있다.

공식:
https://create.roblox.com/docs/projects/assets/packages

Package 후보:

### World modules
- Door
- Portal
- Shop booth
- Upgrade terminal
- Quest station
- Arena shell
- Fence/railing kit
- modular cliff/entrance
- common sign/wayfinding

### Gameplay modules
- Interaction prompt shell
- Loot pickup
- Damage number
- Health bar
- Objective marker
- Respawn feedback

### UI modules
- Modal shell
- Confirm dialog
- Toast
- Currency display
- Inventory cell
- Settings row
- Mobile action button shell

모든 것을 Package로 만들지는 않는다. **여러 프로젝트에서 반복되고, visual/system contract가 안정된 것**만 승격한다.

---

## 3. Package maturity states

```text
EXPERIMENTAL
→ PROJECT_PROVEN
→ CROSS_PROJECT_PROVEN
→ GODBASE_PACKAGE
```

### EXPERIMENTAL
한 프로젝트의 새 구현. 자동 업데이트 금지 후보.

### PROJECT_PROVEN
한 프로젝트에서 P0 route + regression을 통과.

### CROSS_PROJECT_PROVEN
두 개 이상 서로 다른 프로젝트에서 문제 없이 재사용.

### GODBASE_PACKAGE
공용 정본. 문서화/버전/rollback/test contract 존재.

---

## 4. Every reusable package needs a contract

최소 기록:

```text
name
version
purpose
inputs / attributes
server-client ownership
required dependencies
visual size assumptions
interaction clearance
supported input modes
known limitations
security notes
P0 test route
rollback/version notes
```

맵 모듈은 추가:

```text
pivot convention
footprint
front direction
required approach clearance
ground-contact rule
recommended anchor type
```

---

## 5. Placeholder-to-production workflow

Packages는 graybox placeholder부터 사용할 수 있다.

권장:

```text
Package v0: correct footprint / pivot / interaction socket
→ level design uses it
→ Package v1: production visual
→ same spatial contract preserved
→ copies update after review
```

이렇게 하면 art가 늦어져도 level design을 다시 하지 않아도 된다.

단, production visual이 footprint/collision을 바꾸면 반드시 map regression을 돌린다.

---

## 6. Shared test contracts

공용 시스템은 코드만 공유하지 말고 테스트도 공유한다.

예 Portal:

```text
spawn near portal
→ approach
→ prompt visible
→ interact
→ one transition only
→ destination correct
→ cooldown/debounce
→ return/respawn behavior
```

예 Shop:

```text
open
→ insufficient currency
→ valid purchase
→ currency decrement once
→ item grant once
→ reopen state
→ spam input
```

---

## 7. Scripted Studio QA

Roblox Studio는 Studio-only scripted testing 기능을 제공한다.

공식:
https://create.roblox.com/docs/studio/testing-modes

주요 후보:
- `StudioTestService`: 서버 + 다중 클라이언트 시나리오
- `StudioDeviceSimulatorService`: device/resolution/orientation regression
- `VirtualInput`: 실제 입력 흐름에 가까운 UI/input 자동화

이를 활용해 다음을 자동화 후보로 삼는다.

```text
clean boot
spawn
join/leave
respawn
UI open/close
button spam
mobile orientation
multiplayer interaction
primary route
```

모든 게임을 처음부터 완전 자동화하려 하지 않는다. 반복 가치가 높은 P0 route부터 시작한다.

---

## 8. QA layers

```text
Layer 0 static
Layer 1 boot
Layer 2 scripted deterministic route
Layer 3 Studio Agent/playtest agent
Layer 4 human feel test
Layer 5 live analytics
```

### Layer 0
lint/schema/source/security

### Layer 1
spawn/runtime errors/critical bootstrap

### Layer 2
정해진 state transition을 재현

### Layer 3
실제 게임 상황을 Agent가 탐색/검증

### Layer 4
재미, 감각, 가독성, 디자인 방향

### Layer 5
실제 유저 행동 데이터

한 레이어가 다른 레이어를 완전히 대체하지 않는다.

---

## 9. Performance gate earlier, not at the end

Vertical Slice부터 성능 baseline을 기록한다.

공식:
- https://create.roblox.com/docs/performance-optimization/scene-analysis
- https://create.roblox.com/docs/performance-optimization/microprofiler

권장:

```text
slice complete
→ Performance Summary
→ Scene Analysis
→ problem exists? MicroProfiler
→ record baseline
```

맵이 커진 뒤 최적화를 시작하지 않는다.

특히 reusable Package는 인스턴스 수/메모리/반복 배치 비용을 검토한다.

---

## 10. Analytics as the final QA layer

실제 플레이어 행동은 `AnalyticsService`로 관측한다.

공식:
https://create.roblox.com/docs/production/analytics/event-types

초기 공통 Funnel 후보:

```text
SessionStart
→ FirstControl
→ FirstCoreAction
→ FirstReward
→ FirstUpgrade
→ FirstProgressionUnlock
```

장르별로 수정한다.

목표는 analytics를 많이 찍는 것이 아니라 **개발자가 실제로 결정할 수 있는 질문**을 측정하는 것이다.

예:
- 첫 재미 전에 어디서 이탈하는가?
- 첫 업그레이드를 이해하는가?
- 어떤 능력이 거의 쓰이지 않는가?
- 어느 progression 구간에서 멈추는가?

---

## 11. Promotion rule

공용 자산/테스트로 승격하기 전:

- [ ] project-specific hack 제거
- [ ] server/client ownership 명확
- [ ] no hidden asset dependency
- [ ] package pivot/footprint contract
- [ ] desktop/mobile where applicable
- [ ] deterministic P0 test
- [ ] known limitation
- [ ] rollback/version path
- [ ] at least one real project evidence

---

## 12. Priority roadmap

### P0 — immediately useful
1. Portal / Door / Interaction package contract
2. common UI modal/toast/action button
3. scripted clean-boot + spawn regression
4. mobile UI smoke test
5. map module pivot/footprint convention

### P1
6. Shop / upgrade terminal package
7. loot/reward package
8. combat dummy / health bar
9. generic objective route test
10. package catalog/version manifest

### P2
11. genre-specific arena/hub modules
12. cross-project performance budget data
13. analytics funnel templates
14. automated package regression matrix

---

## 13. Principle

**공용 시스템은 편의를 위한 복붙 묶음이 아니다.**

Godbase Package의 가치는:

```text
이미 실패를 겪었고
→ 원인을 고쳤고
→ 테스트를 만들었고
→ 다른 프로젝트에서도 검증된 것
```

이라는 신뢰에 있다.
