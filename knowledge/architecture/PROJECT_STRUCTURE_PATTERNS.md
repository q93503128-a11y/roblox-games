# Project Structure Patterns

> verified: 2026-09-03

폴더 이름 자체보다 **ownership과 dependency direction**이 중요하다. 아래는 default patterns이며 existing project를 무조건 rewrite하지 않는다.

## Pattern A — Studio-first small/medium game

```text
Studio DataModel
├─ ReplicatedStorage
│  ├─ Shared
│  │  ├─ Types
│  │  ├─ Catalogs
│  │  └─ Util
│  └─ Remotes
├─ ServerScriptService
│  ├─ Services
│  └─ ServerBootstrap
├─ StarterPlayer
│  └─ StarterPlayerScripts
│     ├─ Controllers
│     └─ ClientBootstrap
└─ StarterGui / authored UI
```

Disk Script Sync:
```text
scripts/
├─ Shared/
├─ Server/
└─ Client/
```

Use when Studio owns map/UI/assets.

## Pattern B — Rojo filesystem project

```text
src/
├─ ReplicatedStorage/
│  └─ Shared/
├─ ServerScriptService/
│  ├─ Services/
│  └─ ServerBootstrap.server.luau
├─ StarterPlayer/
│  └─ StarterPlayerScripts/
│     └─ ClientBootstrap.client.luau
└─ ...
docs/
tests/
default.project.json
```

Use when full project reproducibility/CI matters.

## Shared vs server vs client

### Shared
Only things safe to replicate:
- immutable catalogs needed client-side
- types
- math/pure utility
- remote schema
- cosmetic definitions

Do not put:
- secret keys
- anti-cheat heuristics you want hidden
- server-only reward tables if client need not know

Remember exploit clients can inspect replicated scripts/data.

### Server
- profile/data
- economy
- inventory ownership
- purchases
- authoritative combat
- matchmaking logic
- rewards

### Client
- input
- UI
- camera
- local VFX/audio
- predicted visual response

## Service vs controller

Use names based on responsibility, not framework religion.

Server service:
long-lived domain coordinator.

Client controller:
input/UI/camera local orchestrator.

Small game에서는 function modules + bootstrap로 충분할 수 있다.

## Domain-first alternative

큰 codebase에서 domain folder도 가능:

```text
Domains/
├─ Combat/
│  ├─ Shared
│  ├─ Server
│  └─ Client
├─ Inventory/
└─ Quests/
```

장점: feature ownership.
주의: Roblox execution locations와 build mapping이 복잡해질 수 있어 clear tooling 필요.

## Catalog pattern

```text
Catalogs/
├─ Items.luau
├─ Enemies.luau
├─ Areas.luau
├─ Abilities.luau
└─ Products.luau
```

Definitions는 stable IDs를 사용.
Display name을 key로 사용하지 않는다.

## Remotes

Central names/schema:
```text
Net/
├─ Remotes
├─ Schemas
├─ RateLimits
└─ Validation
```

하지만 overengineer하지 않는다. Remote 수가 적은 prototype은 단순하게 유지.

## Bootstrap

Server boot stages example:
1. config/catalog validation
2. shared service init
3. data layer init
4. domain init
5. player binding
6. world runtime start

Critical principle:
optional system failure가 base world/spawn 전체를 파괴하지 않게 dependency를 분리.

## World authored vs runtime

Authored world:
- Studio models/terrain
- packages
- spawn/critical geometry

Runtime:
- enemies
- temporary loot
- round objects
- procedural variation

필수 world 전체를 한 server script로 runtime 생성하는 것은 특별한 이유가 있을 때만.

## Configuration

Three classes:
- build-time/project constants
- gameplay catalogs
- live configs/flags

서로 섞지 않는다.

## Tests

```text
tests/
├─ unit/
├─ validators/
└─ integration-routes/
```

Pure functions는 automated tests.
DataModel behavior는 Studio MCP/integration tests.

## Docs

프로젝트 최소 docs:
- README
- DESIGN / GAME_LOOP
- ARCHITECTURE
- ASSET_SOURCES
- TEST_ROUTE
- DATA_SCHEMA if persistent
- RELEASE notes for live

## Naming

Stable naming examples:
- `item_iron_sword`
- `enemy_meadow_slime`
- `area_forest_01`

Display localization과 내부 ID 분리.

## Deletion policy

새 implementation으로 교체할 때 old code를 disabled/unused 상태로 영원히 남기지 않는다.
- migrate
- test
- remove legacy

필요한 history는 Git에 있다.

## Architecture smell

- service 30개 before first playtest
- circular require
- `Utils` huge
- every module knows player profile internal table
- client direct writes money
- map generation inside inventory service
- UI script performs DataStore
- random duplicate bootstrap scripts

## Decision rule

구조는 미래의 모든 기능을 예상해서 설계하지 않는다. **현재 vertical slice + 다음 1~2 확장에 충분한 가장 단순한 구조**를 사용하고 실제 pressure가 생길 때 확장한다.
