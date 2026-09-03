# Networking Library Decision Matrix

> verified: 2026-09-03

Networking abstraction is optional. Native Roblox networking is the baseline, not a failure state.

## Decision order

1. Define authoritative state and request schemas.
2. Implement/measure with native `RemoteEvent`, `RemoteFunction` only if truly needed, and `UnreliableRemoteEvent` for allowed transient data.
3. Measure bandwidth/CPU/message frequency under realistic multiplayer load.
4. Adopt a buffer/codegen networking library only if it materially improves the measured bottleneck or gives a valuable schema/code-generation workflow.

## Native Remotes — DEFAULT

Best for:
- normal inventory/shop/quest requests
- low/moderate combat message rate
- small/medium projects
- simple Studio-first architecture

Advantages:
- no dependency
- direct Roblox docs/debugging
- easy hand inspection
- smallest migration surface

Still build:
- central remote names/schema
- runtime type/range/state validation
- rate limiting
- idempotency where value can duplicate

## ByteNet — STRONG CONDITIONAL

Repo: https://github.com/ffrostfall/ByteNet

Best for:
- high traffic
- typed packet schemas
- buffer serialization
- teams willing to own a packet layer

Risks:
- additional abstraction/debugging layer
- performance benefit depends on real payloads
- security logic still belongs to game server

Godbase status: `CURRENT_CONDITIONAL_A`.

## Zap — TRANSITION

Repo: https://github.com/red-blox/zap

Observed current repository state:
- default branch `0.6.x`
- 0.6.x maintained
- rewrite also underway

Adoption rule:
- pin exact branch/version
- use docs matching installed branch
- do not mix rewrite examples with 0.6.x

Godbase status: `TRANSITION_B` until rewrite/stable state is clearer.

## BridgeNet2 — LEGACY

Repo: https://github.com/ffrostfall/BridgeNet2

Its own README strongly recommends ByteNet instead.

New projects: do not choose by default.
Existing projects: keep if stable until migration has measured value.

Godbase status: `LEGACY_REPLACED`.

## RbxUtil Comm / TypedRemote — SIMPLE ABSTRACTION CANDIDATE

When the goal is API organization rather than extreme bandwidth optimization, RbxUtil networking utilities may be a smaller fit than introducing a serializer/codegen stack.

## Reliable vs unreliable

Critical/value messages remain reliable:
- purchases
- rewards
- inventory changes
- quest completion
- trade commits
- authoritative hit result

Unreliable candidates:
- aim direction cosmetics
- high-frequency orientation hints
- transient VFX positions
- state replaced by newer state immediately

Loss-tolerant does not mean client-authoritative.

## Performance benchmark rules

Benchmark realistic traffic:
- 1 / 8 / target players
- expected packet schema
- expected send rate
- server encode/decode time
- client encode/decode time
- bandwidth
- GC/memory
- latency/packet loss

Do not select a library from a benchmark of 200 empty calls/frame if the game sends structured tables at 5 Hz.

## Security checklist independent of library

- server recomputes value
- finite numeric checks
- max string/table/buffer lengths
- enum/id whitelist
- instance ancestry/ownership
- distance/LOS where relevant
- state machine validation
- action rate limit
- duplicate request identity where needed
- malformed packet handling does not crash central receive loop

## Migration strategy

If changing networking layer:
1. central schema first
2. adapter interface
3. migrate one domain
4. dual-path only temporarily and explicitly
5. multiplayer/latency regression
6. delete old path after success

Never run two overlapping authoritative remote stacks forever.
