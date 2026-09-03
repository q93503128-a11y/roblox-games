# Cloud Services Decision Matrix

> verified: 2026-09-03

Official source:
https://create.roblox.com/docs/cloud-services/data-stores-vs-memory-stores

## 현재 Roblox storage/service 선택

| Need | Default candidate | Persistence | Scope |
|---|---|---|---|
| player progress/inventory | DataStore | permanent | cross-server |
| permanent numeric ranking | OrderedDataStore | permanent | cross-server |
| matchmaking queue | MemoryStore Queue/Map | temporary | cross-server |
| high-frequency ephemeral global state | MemoryStore | max TTL subject to current limits | cross-server |
| feature flag/tuning | Configs | permanent | cross-server read-only in game |
| API keys/tokens | Secrets Store | permanent | cross-server read-only |
| session-only state | Luau memory | server lifetime | one server |
| external admin/data tooling | Open Cloud | service dependent | external |
| cross-server messages | MessagingService | transient messages | cross-server |

Current official comparison lists MemoryStore expiry up to 45 days; always re-check current limits.

## DataStore

Use:
- inventory
- progression
- settings
- permanent unlocks

Official:
https://create.roblox.com/docs/cloud-services/data-stores

Critical warning:
Studio access can touch the same production stores. **Do not enable Studio API services on a live place and casually test writes.**

Preferred strategy:
- separate test experience/place/namespace
- explicit environment key prefix
- production writes require deliberate configuration

## Standard vs Ordered

Standard DataStore:
- tables/booleans/strings/numbers
- player data
- current official docs provide version history backup for standard data

OrderedDataStore:
- numeric values
- persistent ranking

Do not use player profile wrapper for every global leaderboard problem.

## ProfileStore

Repository:
https://github.com/MadStudioRoblox/ProfileStore

Current documented strengths:
- player-oriented profile wrapper
- autosave
- session locking

Current docs explicitly state it is not designed for global state/leaderboards.

Use when:
- one canonical progress profile per player
- duplicate session ownership must be controlled

Still required:
- schema/version design
- migration
- data validation
- game-specific idempotency

## MemoryStore

Official:
https://create.roblox.com/docs/cloud-services/memory-stores

Current primitives:
- Queue
- Sorted Map
- Hash Map

Good:
- matchmaking
- ephemeral leaderboard
- auctions/temporary listings
- cross-server cache
- short-lived coordination

Bad:
- permanent inventory as only storage
- state that must survive expiry/outage without reconstruction

Every entry needs intentional TTL/cleanup policy.

## Configs

Current official purpose:
- feature flags
- live-tunable values
- read-only from experience

Examples:
- enable event
- weapon multiplier
- item prices
- message

Benefits:
- no server restart required for many tuning changes
- safer than hand-editing constants in many scripts

But:
- config content is not a replacement for secure server logic
- validate types/defaults
- rollout/fallback value

## Secrets Store

Official:
https://create.roblox.com/docs/cloud-services/secrets

Use for external service:
- API key
- password
- access token

Never:
- source code literal
- ReplicatedStorage
- client script
- DataStore as fake secrets vault

## MessagingService

Use for low-volume cross-server notifications/state invalidation.

Examples:
- global announcement
- cache invalidation
- live config/event coordination

Need:
- retry/failure tolerance
- message duplication assumptions
- not a durable queue

## Open Cloud

Use when external CI/admin/service needs Roblox resource access.

Principles:
- minimum scope
- secret storage
- environment separation
- audit key rotation
- never commit credentials

Open Cloud index:
https://create.roblox.com/docs/cloud

## Save schema

Recommended shape:
```luau
{
    schemaVersion = 3,
    currencies = {...},
    inventory = {...},
    progression = {...},
    settings = {...},
    receipts = {...}, -- if project needs idempotency markers
}
```

Do not save Instances/CFrames/userdata directly without serialization strategy.

## Migration

Schema change must define:
- old versions accepted
- ordered migration functions
- defaults for missing fields
- validation after migrate
- rollback/recovery plan

Never overwrite unknown old data blindly with a fresh template because a new field is missing.

## Data validation on load

Assume historical/corrupt/out-of-range data exists.
- type check
- range check
- unknown item IDs
- impossible currencies
- duplicate unique items
- exploit-era data cleanup policy

## Save frequency

Avoid writing every small stat mutation.
- in-memory authoritative session state
- periodic/autosave
- critical transaction markers
- leave/shutdown handling

Respect current DataStore request limits and wrapper behavior.

## Trade/economy transaction

Trade is not just two inventory edits.
Need:
- session ownership
- both offers versioned
- items locked while trade active
- final validation immediately before commit
- atomic-like transfer in server session state
- save/recovery plan

Cross-server global trading becomes 훨씬 복잡하며 MemoryStore/DataStore consistency model을 명시해야 한다.

## Service failure design

Outage behavior를 product decision으로 만든다.

예:
- profile load 실패 → retry/loading, not fresh-profile overwrite
- global event config unavailable → safe default
- MemoryStore matchmaking fail → local retry/fallback

## Environment matrix

```text
LOCAL/Studio → fake/test data
TEST place → test datastore/config
STAGING → staging
PRODUCTION → live
```

API key, DataStore namespace, product IDs를 environment-aware하게 관리한다.

## Done checklist

- [ ] service choice documented
- [ ] test/prod separated
- [ ] migration version
- [ ] validation
- [ ] retries/fallback
- [ ] idempotency where value can duplicate
- [ ] shutdown/leave
- [ ] no secrets client-side
- [ ] no production Studio writes
