# Luau Engineering Playbook

> verified: 2026-09-03

목표는 코드를 많이 쓰는 것이 아니라 **디버깅 가능하고 교체 가능하며 서버 경계가 명확한 Roblox codebase**를 만드는 것이다.

## 1. Strict typing을 새 코드의 기본 후보로

복잡한 시스템에서는 `--!strict`와 명시적인 타입을 적극 사용한다.

좋은 대상:
- catalog/data schema
- Remote payload
- service public API
- save profile
- combat state
- reusable modules

타입은 runtime validation을 대체하지 않는다. Remote payload는 client가 마음대로 보낼 수 있으므로 server runtime checks가 필요하다.

## 2. Module boundary

ModuleScript는 명확한 한 역할을 가진다.

좋은 예:
- `InventoryService`
- `ItemCatalog`
- `DamageCalculator`
- `EnemySpawner`
- `InputController`

나쁜 예:
- `Utils` 3,000줄
- 한 Module에서 저장/UI/전투/상점 모두 수행

Public API를 작게 유지해 교체 비용을 낮춘다.

## 3. Data-driven content

반복되는 콘텐츠를 코드 분기문으로 복제하지 않는다.

```luau
export type WeaponDef = {
    id: string,
    damage: number,
    cooldown: number,
    animationId: string?,
}

local Weapons: {[string]: WeaponDef} = { ... }
```

Catalog와 behavior를 분리하면:
- 밸런스 변경이 쉬움
- analytics tagging이 쉬움
- content validation 가능
- AI가 새 콘텐츠를 추가할 때 코드 복제 감소

## 4. State ownership

각 state의 owner를 문서화한다.

예:
- Player profile: server
- UI open/close: client
- weapon catalog: shared immutable
- enemy authoritative HP: server
- cosmetic predicted muzzle flash: client

동일 state를 여러 service가 독립적으로 수정하지 않는다.

## 5. Dependency direction

권장 예:

```text
Catalog / Shared Types
       ↓
Domain modules
       ↓
Server services / Client controllers
       ↓
Bootstrap
```

Bootstrap에서 dependencies를 조립하고, module import 순간에 거대한 side effect를 만드는 패턴을 피한다.

## 6. Initialization lifecycle

명시적인 lifecycle을 권장한다.
- `Init()` — dependency wiring / no world mutation if possible
- `Start()` — connections, spawning, runtime work
- `Destroy()` — cleanup

플레이어/캐릭터마다 lifecycle cleanup이 반드시 있어야 한다.

## 7. Cleanup

Connections/tasks/instances는 owner와 lifetime을 가진다.

RbxUtil `Trove` 같은 검증된 cleanup abstraction을 검토하거나 작은 project에서는 명시적으로 disconnect/destroy한다.

특히:
- CharacterAdded 반복
- Tool equip/unequip
- UI open/close
- round restart
- NPC respawn
에서 connection leak를 검사한다.

## 8. Async

`task.spawn`, `task.defer`, `task.delay`, events, Promise를 목적에 맞게 쓴다.

Promise가 좋은 경우:
- 여러 async 단계 조합
- timeout/retry/cancel/error chain
- 여러 작업을 합치기

Promise가 불필요한 경우:
- 단순 한 번 기다리는 함수까지 모두 abstraction

`spawn()`/`wait()` 같은 오래된 패턴보다 `task` 계열을 우선한다.

## 9. Error boundaries

실패 가능한 외부 서비스:
- DataStore
- MemoryStore
- Marketplace receipt path
- HttpService
- MessagingService
- asset loading

은 실패를 정상 상태로 설계한다.

`pcall`만 감싸고 error를 버리지 않는다.
- operation
- user/server correlation id
- retry class
- fallback behavior
를 기록.

## 10. Idempotency

두 번 실행돼도 보상이 두 번 지급되면 안 되는 작업:
- Developer Product receipt
- quest reward
- trade commit
- claim button
- daily reward
- server retry

transaction/receipt/claim identifier를 사용해 duplicate processing을 차단한다.

## 11. Remote schema

Remote 이름과 payload schema를 중앙화한다.

Client request:
```text
PurchaseItem { itemId }
```

금지:
```text
PurchaseItem { itemId, price, newBalance, rewardAmount }
```

서버가 catalog에서 가격/보상/소유권을 계산한다.

## 12. CollectionService / Attributes

world authoring과 runtime code를 decouple할 때 유용하다.

예:
- tagged `DamageZone`
- tagged `QuestNPC`
- attributes `EnemyType`, `SpawnGroup`

하지만 arbitrary attribute를 client trust boundary로 사용하지 않는다.

## 13. Model movement

Model을 구성하는 파트를 따로 CFrame하지 않는다.
- `Model:PivotTo()`
- attachments/constraints/welds
- explicit PrimaryPart/pivot
를 사용.

moving model regression test에 얼굴/장비/effects까지 포함한다.

## 14. Events vs polling

가능하면 state change event를 사용한다. 매 frame 모든 player/NPC를 polling하지 않는다.

매 frame이 필요한 사례:
- camera
- 일부 predicted visuals
- physics-sensitive calculations

그 외는 낮은 tick/event/task scheduling을 먼저 고려한다.

## 15. Server loop budgets

NPC가 많을 때 각 NPC마다 독립 `while true do task.wait()` 수백 개를 무작정 만들지 않는다.
- scheduler/batching
- distance activation
- server LOD
- Parallel Luau candidate
를 profiler와 함께 검토.

## 16. Configuration

magic number를 code 여러 곳에 흩뿌리지 않는다.
- config/catalog
- named constants
- Roblox Configs (live feature/tuning, 필요 시)

현재 Roblox cloud Configs는 server에서 read-only feature/config 값을 실시간 조정하는 용도에 적합하다.

## 17. Tests

pure function은 Studio 없이도 test하기 쉽게 만든다.
좋은 test 대상:
- damage formula
- XP curve
- loot weights
- migration
- purchase validation
- inventory capacity
- cooldown calculation

integration behavior는 Studio playtest/MCP로 검증한다.

## 18. Code review 질문

- client가 이 값을 거짓말하면?
- 함수가 두 번 호출되면?
- player가 중간에 나가면?
- character가 respawn하면?
- DataStore가 실패하면?
- instance가 stream out되면?
- mobile input에서도 호출되나?
- module을 교체하려면 몇 파일을 수정해야 하나?
- cleanup은 누가 하나?

## Useful candidates

- ProfileStore: https://github.com/MadStudioRoblox/ProfileStore
- RbxUtil: https://github.com/Sleitnick/RbxUtil
- Promise: https://github.com/evaera/roblox-lua-promise
- Luau: https://luau.org/

각 library는 SOURCE_POLICY에 따라 도입 시점에 라이선스/maintenance를 다시 확인한다.
