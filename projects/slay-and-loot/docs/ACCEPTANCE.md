# First Build acceptance / test contract
Current game status: DESIGN. **Runtime cases below are NOT RUN.**
Machine-readable specification: [mcp-playtest.contract.json](specs/mcp-playtest.contract.json). It defines future routes; the Godbase structural validator does not execute them.

## Foundation acceptance — this task
- Actual repo and intended Studio target inspected; fetch/prune + ff-only pull.
- Prior project deletions preserved, old runtime not restored, unrelated changes not staged.
- Current product canon has one direction; old run-based direction is explicitly historical.
- Exact 3 weapons / 6 pets / 1 Egg / 4 enemy types / 11 sockets / 1 personal gate defined.
- Relative placement table, authority, protocol, participation and persistence failure modes documented.
- Existing scene/assets availability reported honestly; zero Studio mutations.
- Catalog/profile/contracts parse, weights/IDs/links resolve; contract structural validator passes.
- Project-only commit pushed; remote revision matches.

## B01 scope and readiness
Spawn/safe area + one farming zone + visible functioning gate + safe preview landing. No complete second farm, no World2.
First required primary route uses actual input, not direct profile grants:
spawn → first Slime kill → first duplicate/level → earn30 → Hatch1 → Pet Equip Best → measurable damage increase → Scout/new weapon → 600 net Coins → Unlock → walk to preview → save/rejoin.
Observe first kill5–12s, duplicate<60s and first meaningful gate roughly3–5min. Report measured times even if tuning fails.

## Explicit pass/fail cases
| ID | Pass condition / evidence |
|---|---|
| T01 Boot | Character stable, authored floor exists even if optional bootstrap module fails, HUD loads, zero project-attributable unexpected errors |
| T02 First duplicate | Fresh profile RustyLv1; first eligible Slime reward gives12Coins, RustyLv2, still one weapon entry; effective damage10→12 |
| T03 New weapon/pity | Unowned Goblin Blade created by fourth eligible Scout reward at latest; pity persists across leave; owned copies advance same entry |
| T04 Overflow/MAX | RustyLv9/XP39 +5 → Lv10/XP0 and48Coins; replay does not repeat; no XP+conversion for same copy |
| T05 Equip Best | RustyLv10 beats GoblinLv1 despite lower rarity; tie retains current; respawn rebuilds correct held model |
| T06 Hatch | Cost30, server roll from six outcomes, unique UID; probabilities visible, no charge on insufficient Coins/full100/distance failure |
| T07 Pets | 3 unique equipped UIDs maximum; duplicates as different UIDs allowed; Equip Best maximizes bonus; no independent pet damage; UI/server damage formula agree |
| T08 Pet capacity | Release only owned unequipped UID after clear UI confirmation; replay cannot remove another UID; capacity space becomes usable |
| T09 Personal gate | Cost600 once; repeat unlock costs0; A unlock leaves B blocked; respawn/rejoin preserve each player's permission |
| T10 Attack abuse | Fake damage/owner/price/roll, stale target generation, dead/out-of-range/blocked target, fast spam and locked-zone context cannot grant value |
| T11 Shared rewards | Two eligible contributors each receive one full personal reward; <2%/stale/dead/distant participants fail; overkill never creates extra contribution or a second death |
| T12 Leave/respawn | Queued attack/hatch/close races cannot mutate closed/other profile; no dangling targets or growing effects |
| T13 Protocol | Same nonce/seq is idempotent; changed/old payload/session rejected; revision gap resync and UI reopen show correct owner snapshot |
| T14 Real persistence | Isolated TEST save→leave→server restart→rejoin restores Coins, zones, weapons/XP/equipment, pet UIDs/equipment, discovery, tutorial/pity |
| T15 Persistence failure | Load failure is not new profile; future schema/corrupt fields/unknown IDs don't overwrite; active lock conflict and session loss prevent dual owners |
| T16 Devices/art | Required phones+720p+1080p primary route; safe areas, 48px logical touch start target, no overlapping reward modals; approved hero assets and accessible interactables |
| T17 Density/perf | 8 players/11 enemies/24pets,10-minute farm;10 UI reopen/respawn cycles; record FPS/memory/network/listener trend, no runaway growth |
| T18 Provenance/sync | Asset ledger approvals/dependencies match live use; source hashes and Studio tree match build; test save/publish/revision recorded |

Unit/pure tests should focus on progression overflow, deterministic tie-break, schema validation, transaction replays and eligibility boundaries. Do not substitute them for actual input or real persistence tests.
Deterministic rare-drop/edge fixtures belong in server-only isolated TEST harness, not public remotes/production controls.

## Device / network evidence
667×375,844×390 landscape;1280×720,1920×1080 desktop. Capture required visual states from actual gameplay camera.
Two players for isolation + eight for density. Add declared latency/jitter/loss scenario; record exact simulated values and results.
A local multi-client session with different users does not prove same-key locking between two independent servers.
Device Simulator proves layout, not real low-end hardware FPS; record any missing hardware evidence as a limitation.

## Completion rule
INTERNAL_PROTOTYPE: partial runtime may exist, missing gates explicit.
READY_FOR_USER_TEST: T01–T18 relevant P0 gates pass, real persistence test included, known limitations and test instructions provided.
No game implementation exists in Foundation. Static contract/catalog checks never upgrade status.
Stop expansion on boot/save/authority/route/mobile/hero-art failures.

## Foundation verification record
2026-10-30: PASS — Godbase contract structural validator; catalog counts, unique IDs and references; all weapon/Egg weight totals100; 11 socket/anchor/path checks; starter profile references; XP thresholds and MAX overflow arithmetic; 15 Markdown documents/local links and 11 source-image byte counts. Whitespace is normalized to LF before final Git validation. These are specification checks, not tests of nonexistent game code.
Runtime T01–T18: NOT RUN. No Studio Play/save/publish in this pass. Final commit/push result is recorded in the task response.
