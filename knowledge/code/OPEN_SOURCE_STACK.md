# Open Source Stack

> 검증 기준일: 2026-09-03

이 문서는 "무조건 이 라이브러리를 써라"가 아니라 **새 프로젝트에서 먼저 검토할 검증 후보군**을 정리한다. 실제 도입 전 `SOURCE_POLICY.md`에 따라 최신 release/maintenance/license/API를 다시 확인한다.

## 현재 기본 언어 선택

### Luau — 기본 권장

Roblox Engine의 원어이며 Studio/MCP/Script Sync와 가장 직접적으로 맞는다.

- 공식 Luau 문서: https://create.roblox.com/docs/luau
- Luau 구현: https://github.com/luau-lang/luau 또는 Roblox 공식 연결 자료 확인

새 게임은 특별한 이유가 없으면 Luau를 기본으로 한다.

### roblox-ts — 조건부

- https://github.com/roblox-ts/roblox-ts
- MIT
- TypeScript → Luau compiler
- 2026년에도 활발히 유지되는 생태계 확인

적합:

- TypeScript 경험이 매우 강함
- 대규모 타입/프론트엔드 생태계 활용
- npm/Jest/React 스타일 개발을 선호

비적합:

- 작은 Roblox 프로젝트
- Luau 디버깅과 TS compile layer가 오히려 복잡도를 늘림
- 기존 Luau 코드와 빠르게 섞어야 함

## 데이터 저장

### ProfileStore — A / 우선 후보

- https://github.com/MadStudioRoblox/ProfileStore
- Apache-2.0
- session locking, autosave, player-profile workflow
- ProfileService의 후속 권장 모듈

적합:

- 일반적인 플레이어 진행도
- trading/duping 위험 때문에 session lock 필요

주의:

- global leaderboard/global state 전용 아님
- 스키마 migration/데이터 API는 게임 레이어에서 명확히 설계

### ProfileService — LEGACY

- https://github.com/MadStudioRoblox/ProfileService
- 저장소 자체가 새 프로젝트에는 ProfileStore 사용을 안내

신규 도입 금지에 가깝게 취급하고, 기존 프로젝트 migration 참고용.

### Lapis — USE WITH CAUTION

- https://github.com/nezuo/lapis
- MIT
- session locking, validation, migration, retries, throttling, immutable document
- 작성자 스스로 대규모 production에서 충분히 battle-tested되지 않았다고 경고

좋은 설계 참고 자료지만 critical live economy의 기본 선택으로 바로 승격하지 않는다.

## 비동기

### Roblox Lua Promise — A

- https://github.com/evaera/roblox-lua-promise
- MIT
- Promise/A+ 스타일

복잡한 비동기 조합, cancellation, 여러 작업 동시 처리에 유용.

모든 함수에 Promise를 강제하지는 않는다. Roblox API 자체의 async/yield semantics와 팀 가독성을 함께 고려.

## 유틸리티

### RbxUtil — A

- https://github.com/Sleitnick/RbxUtil
- MIT

필요한 모듈만 선택한다.

주요 후보:

- Trove — connection/instance/task cleanup
- Signal — custom signal
- Component — tagged component pattern
- Comm / TypedRemote — networking helpers
- Timer
- Spring
- Input
- TableUtil

**전체 라이브러리를 통째로 아키텍처로 삼기보다 작은 검증 모듈을 골라 쓰는 방식**을 선호한다.

### Cmdr — A / 개발도구

- https://github.com/evaera/Cmdr
- MIT
- type-safe extensible command framework

적합:

- 내부 admin/debug console
- QA 명령
- 테스트 상태 전환

production player 권한과 admin permission을 명확히 분리한다.

## UI

### Fusion — A 후보

- https://github.com/dphfox/Fusion
- MIT
- reactive/declarative Luau

커스텀 Roblox UI를 Luau에서 선언적으로 구축할 때 강력.

### Vide — A/B 후보

- https://github.com/centau/vide
- MIT
- Solid-inspired reactive Luau UI

간결하고 reactive한 API. 프로젝트 팀이 패턴을 이해하는지 확인 후 선택.

### React Lua — A 후보 / 큰 UI

- https://github.com/jsdotlua/react-lua
- MIT
- Roblox React 계보의 current community-facing 선택지 중 하나

큰 UI 시스템이나 React mental model이 필요한 경우.

### Roact — DEPRECATED

- https://github.com/Roblox/roact
- 공식 저장소 archived / deprecated
- 새 프로젝트에 채택하지 않음

기존 코드 migration 참고용.

### Charm — A/B / 상태 관리

- https://github.com/littensy/charm
- MIT
- fine-grained reactive state
- Fusion/Vide/React 계열과 조합 가능

작은 게임에서 상태 관리 라이브러리 자체가 과설계가 되지 않는지 먼저 판단.

## ECS

### Matter — A/B

- https://github.com/matter-ecs/matter
- MIT
- modern Roblox ECS

적합:

- 대량 entity
- 시스템 기반 simulation
- combat/projectile/status 등 data-oriented architecture가 명확한 게임

비적합:

- NPC 몇 마리와 UI 중심의 작은 게임
- ECS 경험 없이 "프로처럼 보이기 위해" 도입

## 도구 체인

### Studio Script Sync — S / Roblox 공식

Rojo가 필요 없을 때 가장 먼저 검토.

https://create.roblox.com/docs/scripting/sync

### Rojo — A / 전체 파일시스템 workflow

- https://github.com/rojo-rbx/rojo
- MPL-2.0
- filesystem ↔ Roblox data model

전체 project를 Git/CLI에서 재현해야 할 때 사용. Studio-first 솔로 개발에 강제하지 않는다.

### Rokit — A

- https://github.com/rojo-rbx/rokit
- MIT
- Roblox toolchain manager
- Foreman/Aftman 호환 migration을 지향

새 CLI toolchain manager 기본 후보.

### Wally — A

- https://github.com/UpliftGames/wally
- MPL-2.0
- Roblox package manager

주의: dependency를 넣기 전에 해당 package 자체의 source/license/status를 따로 검증한다.

### StyLua — A

- https://github.com/JohnnyMorganz/StyLua
- deterministic Lua/Luau formatter
- 2026-03 v2.4.0 release 확인

### selene — A

- https://github.com/Kampfkarren/selene
- Luau/Lua linter
- 2026년 PR activity 확인

### Luau Language Server — A

- https://github.com/JohnnyMorganz/luau-lsp
- MIT
- VS Code/OpenVSX
- 2026년 release activity 확인

Roblox 공식 Script Sync 문서도 LSP + companion 사용을 추천한다.

### Lune — A / 외부 Luau 자동화

- https://github.com/lune-org/lune
- MPL-2.0
- standalone Luau runtime
- filesystem/network/Roblox place/model manipulation API

적합:

- build scripts
- static transforms
- data generation
- place/model tooling

Roblox game runtime 대체가 목적은 아니다.

### darklua — A/B

- https://github.com/seaofvoices/darklua
- MIT
- configurable Luau transform

build-time transform이 실제 필요할 때만 도입.

### rbx-dom — A / 고급 tooling

- https://github.com/rojo-rbx/rbx-dom
- MIT
- `.rbxl/.rbxlx/.rbxm/.rbxmx` serialization/deserialization

place file tooling을 직접 만들 때 유용. **게임 맵을 맹목적으로 XML 문자열로 조립하는 용도보다 reflection/serializer를 사용**한다.

## 테스트

### TestEZ — A/B / 기존 Lua 테스트

- https://github.com/Roblox/testez
- Apache-2.0
- BDD-style testing

새 프로젝트에서는 현재 유지보수 상황과 더 현대적인 테스트 스택도 비교한다. Studio integration 테스트를 완전히 대체하지 못한다.

## 추천 스택 프리셋

### Studio-first Solo

```text
Roblox Studio
Studio MCP
Script Sync
Luau LSP
StyLua
selene
Git
ProfileStore (저장 필요 시)
RbxUtil에서 필요한 작은 모듈
```

### File-system heavy / CI

```text
Studio MCP
Rojo
Rokit
Wally
Luau LSP
StyLua
selene
Lune
GitHub Actions
```

### Large reactive UI

```text
Fusion 또는 Vide 또는 React Lua 중 하나
+ 필요 시 Charm
```

세 UI 프레임워크를 동시에 섞지 않는다.

## 의존성 원칙

- 기능 하나 때문에 거대한 framework 전체를 가져오지 않는다.
- dependency 깊이를 제한한다.
- 버전을 pin/lock한다.
- 라이브러리가 없어져도 핵심 게임 데이터가 복구 가능한 구조를 유지한다.
- Remote/security/data ownership을 외부 framework에 이해 없이 위임하지 않는다.
- deprecated 상태를 분기별로 재검토한다.
