# Ship Checklist

> verified: 2026-09-03

릴리스는 "Publish 버튼 누르기"가 아니라 데이터, device, economy, analytics, rollback을 포함한 운영 변경이다.

## Build identity
- [ ] release version/tag
- [ ] commit/source state recorded
- [ ] TEST vs LIVE target explicit
- [ ] release notes

## Critical gameplay
- [ ] primary loop regression pass
- [ ] death/respawn
- [ ] multiplayer critical flow
- [ ] tutorial/FTUE
- [ ] no progression blocker

## Studio QA
- [ ] clean boot
- [ ] unexpected Output error 0
- [ ] viewport screenshot review
- [ ] no z-fighting/detached models
- [ ] no hero placeholders

## Security
- [ ] server authority for economy/reward
- [ ] Remote validation/rate limits
- [ ] external assets audited
- [ ] no secret/client sensitive code
- [ ] network ownership risk reviewed

## Data
- [ ] schema version/migration
- [ ] staging save/rejoin
- [ ] no Studio production write risk
- [ ] failed load safe behavior
- [ ] receipt/claim idempotency
- [ ] backup/recovery path understood

## Monetization
- [ ] correct product/pass IDs by environment
- [ ] ProcessReceipt tested where applicable
- [ ] double click/retry safe
- [ ] shop prices/display correct
- [ ] current policy checked

## Device/input
- [ ] small/common phone
- [ ] desktop
- [ ] tablet if target
- [ ] gamepad/console if target
- [ ] core action available on all supported inputs

## Performance
- [ ] join-to-control baseline
- [ ] no new major profiler regression
- [ ] target low device checked
- [ ] streaming behavior correct
- [ ] VFX worst case
- [ ] memory/connection leak smoke

## Network
- [ ] multi-client
- [ ] latency
- [ ] packet loss/jitter for realtime critical systems
- [ ] reconnect/lifecycle scenarios

## UI/localization
- [ ] no clipping
- [ ] translated long strings smoke
- [ ] purchase state/loading/errors
- [ ] gamepad focus if supported
- [ ] safe area/topbar

## Analytics
- [ ] FTUE/core funnel events
- [ ] release annotation/date recorded
- [ ] error/performance monitoring ready
- [ ] metrics to watch defined

Suggested post-release watch:
- join/boot errors
- first session retention
- D1
- avg session
- monetization funnel
- home recommendation PTR/bounce if scale exists

## LiveOps
- [ ] event start/end
- [ ] Config fallback
- [ ] old server behavior
- [ ] event reward duplicate prevention
- [ ] notification copy/eligibility checked

## Rollback
- [ ] prior stable build identifiable
- [ ] data migration backward impact understood
- [ ] feature flag/disable path for risky system
- [ ] on-call decision: what metric/error triggers rollback

## Store/metadata
- [ ] title/description accurate
- [ ] icon/thumbnail reflect actual game
- [ ] age/policy/permissions settings current
- [ ] supported devices settings correct

## Release severity rule
No ship with:
- S0 blocker
- unresolved data corruption/dupe
- broken purchase
- unplayable target platform
- exploitable economy path
- boot/spawn failure

## After release
Within first observation window:
1. technical health first
2. first-play bounce/FTUE
3. D1/session
4. progression/funnel
5. monetization
6. discovery/acquisition

변경 후 metric이 나빠졌다면 "더 많은 콘텐츠"를 즉시 넣기보다 원인 cohort를 찾는다.
