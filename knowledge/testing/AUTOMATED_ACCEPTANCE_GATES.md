# Automated Acceptance Gates

> verified: 2026-09-08

목적: "코드가 생성됐다"와 "테스트 가능한 빌드다"를 분리한다. Godbase를 사용하는 AI/개발자는 아래 gate를 통과하지 못한 build를 사용자에게 완성/테스트 빌드라고 넘기지 않는다.

## Gate 0 — Static sanity

- [ ] 필요한 scripts/modules가 존재
- [ ] syntax/type/static lint critical errors 없음
- [ ] duplicate system/legacy implementation 없음
- [ ] unresolved placeholder IDs / TODO가 critical path에 없음
- [ ] secret/API key commit 없음
- [ ] asset source 기록 존재
- [ ] 5개 이상의 player-facing world object를 bulk placement했다면 placement table 또는 동등한 spatial plan 존재

## Gate 1 — Boot

Studio Play 시작 후:
- [ ] expected spawn 존재
- [ ] character가 void/falling 상태 아님
- [ ] expected camera mode
- [ ] project-attributable unexpected Output errors = 0
- [ ] known Studio/plugin/external noise는 별도 기록되어 실제 project error와 구분됨
- [ ] boot sequence timeout 없음
- [ ] critical service 하나 실패해도 세계 전체가 사라지는 single point of failure 없음

실패하면 즉시 중단하고 다음 feature를 만들지 않는다.

## Gate 2 — Primary loop

AI 또는 developer가 실제 입력으로 최소 1회 완주한다.

예 RPG:
`spawn → enemy 발견 → attack → kill → reward → inventory/equip → progression acknowledgement`

예 simulator:
`collect → convert → buy upgrade → stronger output`

예 tycoon:
`earn → buy dropper/upgrade → production 증가`

- [ ] 모든 transition 실제로 발생
- [ ] UI 숫자와 server state 일치
- [ ] reward duplicate 없음
- [ ] 주요 기능 사이 이동 동선이 의도와 일치
- [ ] 불필요한 왕복/막다른 배치 때문에 loop가 깨지지 않음

## Gate 3 — Failure paths

- [ ] player death/respawn
- [ ] player leaves mid-action
- [ ] action spam
- [ ] invalid Remote payload
- [ ] insufficient currency
- [ ] inventory full or equivalent limit
- [ ] save/service failure fallback where applicable

## Gate 4 — Visual and spatial integrity

Viewport/screenshots와 실제 플레이에서:
- [ ] no z-fighting
- [ ] moving Model parts stay attached
- [ ] no obvious default/placeholder hero assets
- [ ] no giant accidental part at origin
- [ ] pivot/orientation correct
- [ ] animations/VFX do not block view
- [ ] interactable visual hierarchy clear
- [ ] major asset가 뜨거나 바닥에 파묻히지 않음
- [ ] avatar 기준 문/복도/건물/상호작용 물체 scale이 자연스러움
- [ ] main route를 major props가 막지 않음
- [ ] important interactable 앞 approach/standing/camera clearance 확보
- [ ] gameplay camera에서 주요 landmark/interactable이 가려지지 않음
- [ ] player-facing object 간 명백한 overlap 없음

### Mandatory map placement evidence

맵/허브/방/대형 배치 작업이 포함된 build는 최소 다음을 확인한다.

- [ ] current floor/zone bounds/anchors를 읽고 배치함
- [ ] spawn transform과 first objective 관계 확인
- [ ] avatar reference와 major asset scale 비교
- [ ] gameplay-camera entry/center/interaction 시점 검토
- [ ] spawn → first objective → core activity → reward/progression route 직접 walk-through

Editor freecam screenshot만으로 Gate 4 통과 판정 금지.

## Gate 5 — UI cross-platform

Desktop:
- [ ] common 720p/1080p

Mobile emulator:
- [ ] small/common phone
- [ ] no clipping
- [ ] core touch action available

Gamepad if supported:
- [ ] focus navigation
- [ ] back/cancel
- [ ] core action binding

## Gate 6 — Networking

- [ ] server/client separation correct
- [ ] reward/economy never client-authoritative
- [ ] rate limits
- [ ] multiplayer local server test
- [ ] latency/packet loss test for important realtime systems

## Gate 7 — Persistence

Test environment only:
- [ ] save
- [ ] rejoin/load
- [ ] schema defaults
- [ ] migration path if schema changed
- [ ] duplicate session behavior
- [ ] receipt/claim idempotency

Studio must not casually write into live production DataStore.

## Gate 8 — Performance baseline

- [ ] join-to-control measured
- [ ] no obvious every-frame runaway loop
- [ ] Performance Summary checked
- [ ] MicroProfiler used if frame rate issue
- [ ] effects worst-case tested
- [ ] client memory trend doesn't climb after repeated rounds/respawns
- [ ] dense world area에서 저사양 target을 고려한 instance/effect cost 확인

## Gate 9 — Reference quality

목표 레퍼런스가 있다면 같은 상태를 비교한다.

Score 1~5:
- camera
- map composition
- spatial readability
- animation
- responsiveness
- impact feedback
- UI hierarchy
- art consistency
- pacing

평균 2 이하인데 content expansion으로 넘어가지 않는다.

맵이 핵심인 프로젝트는 다음도 별도 비교한다.
- entry composition
- route width/length
- landmark hierarchy
- activity density
- travel time
- camera obstruction

## Gate 10 — User handoff package

- [ ] build/version clearly named
- [ ] test instructions 3~8 steps
- [ ] known limitations explicitly listed
- [ ] what changed listed
- [ ] regression path listed
- [ ] artifact opens without external hidden setup, or setup documented

## CI 자동화 가능한 것

- StyLua check
- selene
- project build / Rojo build if applicable
- schema/catalog validators
- asset ID/source manifest validator
- duplicate IDs
- loot weights / economy sanity
- forbidden code scan (`loadstring`, external require policy etc.)
- tests for pure Luau modules

Studio visual/play/spatial gates는 Studio MCP automation과 결합한다.

## Stop-the-line rule

다음 중 하나면 새 content 추가 금지:
- boot error
- player spawn failure
- save corruption risk
- purchase duplicate risk
- primary combat/input broken
- reference visual fundamentally wrong
- severe mobile clipping
- structural model breakup
- major map object overlap/floating/burial
- core route가 배치 때문에 막힘
- player/world scale이 명백히 어색함
- spawn에서 first objective spatial readability 실패

품질 문제가 쌓인 상태에서 feature count를 늘리는 것은 progress가 아니다.
