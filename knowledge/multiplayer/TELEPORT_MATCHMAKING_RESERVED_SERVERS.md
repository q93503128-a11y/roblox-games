# Teleport, Matchmaking, Parties, and Reserved Servers

> verified: 2026-09-03

Official:
- Matchmaking: https://create.roblox.com/docs/matchmaking
- Teleport between places: https://create.roblox.com/docs/projects/teleport
- TeleportService: https://create.roblox.com/docs/reference/engine/classes/TeleportService
- TeleportOptions: https://create.roblox.com/docs/reference/engine/classes/TeleportOptions
- MemoryStore: https://create.roblox.com/docs/cloud-services/memory-stores

## 1. Separate concepts

- Roblox default matchmaking: places player into eligible scored public server.
- Custom queue/matchmaker: game decides who should play together.
- Reserved server: private allocation/access code.
- Private server: product/platform concept, distinct from a temporary reserved match server.
- Multi-place teleport: moving players between places within/among experiences as allowed.

Do not use one term for all of them.

## 2. TeleportAsync baseline

Use server-side `TeleportService:TeleportAsync()` for normal gameplay teleports.
`TeleportOptions` can select:
- `ServerInstanceId`
- `ReservedServerAccessCode`
- `ShouldReserveServer`

These targeting properties have incompatible combinations; follow current API docs.

## 3. Teleports fail

Network/API calls fail. Required:
- `pcall`
- bounded retry for retryable failures
- `TeleportInitFailed` handling
- player feedback
- no duplicate queue/match reward when retrying

A successful initial API call does not guarantee the final teleport completed.

## 4. Teleport data is not trusted permanent data

Use teleport data for transient context:
- match id
- expected destination spawn
- party metadata identifier
- run/session token

Do not use client-readable teleport payload as authority for currency/items. Permanent valuable state remains server/data-store authoritative.

## 5. Party flow

Recommended conceptual flow:
```text
party create
→ invite/join
→ ready state
→ server validates composition
→ enqueue party atomically
→ match assignment
→ reserve/select destination
→ teleport group
→ destination validates match/session token
```

A party should not split silently unless game design explicitly supports partial teleport/rejoin.

## 6. MemoryStore matchmaking

MemoryStore is a candidate for:
- queue entries
- short-lived party/match records
- server registry
- temporary skill buckets

Every record needs:
- TTL
- owner/state
- unique match/party id
- retry/claim semantics

MemoryStore is not the permanent source of player inventory/progression.

## 7. Queue race conditions

Avoid two matchmakers claiming same players.
Use atomic/update semantics supported by chosen MemoryStore primitive and a clear state machine:
```text
QUEUED → CLAIMED → TELEPORTING → ACTIVE / EXPIRED
```

Timeout can release abandoned claims.

## 8. Skill/region/language preferences

Roblox matchmaking already uses platform signals for default server selection. Custom matchmaking should only add constraints actually needed by game design.

Too many exact constraints increase queue time.
Use widening search windows where appropriate:
- strict skill initially
- wider skill after wait

Never infer or use sensitive user traits outside supported platform/game needs.

## 9. Reserved server lifecycle

A reserved server access code is a credential-like routing value. Do not expose unnecessarily to clients or logs.

Destination server should know:
- expected match id
- expected party roster or validation source
- game mode/map seed
- expiration

## 10. Multi-place version compatibility

Hub and dungeon/battle places may deploy at different times.
Keep teleport/match payload backwards compatible during rollout.

Example:
```text
schemaVersion
matchId
modeId
seed
```

Unknown/new fields should not crash old destination servers.

## 11. Rejoin/recovery

Decide behavior if:
- one player fails teleport
- client disconnects during match
- destination server closes
- player rejoins experience

Options by genre:
- rejoin active reserved server
- return hub
- forfeit
- grace period

Store recovery context durably enough for value at risk.

## 12. Cross-server reward

Match server computes result and saves it authoritatively.
Do not trust hub return teleport data saying `won=true, gold=1000`.

## 13. Loading screen

Teleport loading UI should:
- explain destination/mode
- not fake exact progress if unknown
- have failure fallback
- minimize unnecessary asset delay

## 14. Testing

Teleport behavior cannot always be fully validated by ordinary single-client Play mode. Use published TEST places and current Studio testing guidance.

Test:
- group teleport
- one failure
- reserved allocation
- retry
- destination crash/rejoin
- old/new server versions
- queue expiry

## 15. Acceptance

- [ ] pcall/retry/failure handling
- [ ] no duplicate queue claim
- [ ] transient vs permanent state separated
- [ ] destination validates match context
- [ ] group partial failure behavior defined
- [ ] multi-place schema versioned
- [ ] TEST environment used
- [ ] match rewards server authoritative
