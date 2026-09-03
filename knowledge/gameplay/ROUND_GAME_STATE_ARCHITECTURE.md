# Round, Match, Run, and Game-State Architecture

> verified: 2026-09-03

Official executable curriculum:
- Gameplay scripting / rounds: https://create.roblox.com/docs/tutorials/curriculums/gameplay-scripting
- Spawn/respawn: https://create.roblox.com/docs/tutorials/curriculums/gameplay-scripting/spawn-respawn

Roblox's official Laser Tag curriculum demonstrates explicit player/round states rather than scattered booleans. Use it as an executable reference before inventing a round framework.

## 1. Explicit state machine

Example:
```text
BOOT
LOBBY
COUNTDOWN
STARTING
ACTIVE
ENDING
RESULTS
RESETTING
```

Run/dungeon may use:
```text
PREPARING → ROOM_ACTIVE → REWARD → NEXT_ROOM → BOSS → COMPLETE/FAILED
```

Every state has entry/exit responsibilities.

## 2. One authoritative owner

Server `RoundService`/coordinator owns round phase.
Other systems read/subscribe; they do not independently set `roundActive = true`.

## 3. State transition table

Document legal transitions:
```text
LOBBY -> COUNTDOWN
COUNTDOWN -> STARTING | LOBBY(cancel)
STARTING -> ACTIVE
ACTIVE -> ENDING
ENDING -> RESULTS
RESULTS -> RESETTING
RESETTING -> LOBBY
```

Illegal transitions are rejected/logged.

## 4. Entry/exit actions

Example `ACTIVE` entry:
- lock team roster
- spawn/loadout
- enable combat interaction
- start timer
- analytics round_started

Exit:
- disable combat
- freeze scoring
- finalize results once

This avoids side effects scattered across heartbeat loops.

## 5. Player state separate from round state

Player states:
- InLobby
- Loading
- Alive
- Eliminated
- Spectating
- Results

Late joiner behavior depends on both round and player state.

## 6. Late join / leave

Define:
- can join active round?
- spectator until next round?
- backfill?
- minimum players?
- cancel countdown if population drops?

No undefined behavior.

## 7. Spawn/respawn

Official curriculum uses team/neutral spawn behavior and Player attributes to distinguish lobby/round state.

Project rules:
- spawn point selection server-owned
- spawn protection duration/state
- reset inventory/loadout
- character lifecycle cleanup

Do not assume CharacterAdded means player is active in round.

## 8. Timer

Server owns canonical end time, not decrementing client value as truth.

Prefer:
`endTimestamp - serverNow`
for replicated display where appropriate.

Client can animate local countdown; server decides transition.

## 9. Score

Server validates scoring event.
Freeze score once ending begins.

Result calculation happens once with match/round ID to prevent duplicate reward.

## 10. Round ID

Every run/round instance gets unique ID.
Used for:
- dedupe rewards
- analytics
- debugging
- stale Remote rejection

Client request can include observed round ID; server compares current.

## 11. Cleanup ownership

Every round-created object belongs to round lifecycle container/Trove/folder:
- NPCs
- drops
- effects
- connections
- tasks

Reset destroys/cleans owner container. Avoid trying to individually remember 80 things.

## 12. Map rotation

Separate map catalog/selection from round state.
Selection policy:
- random weighted
- vote
- no-repeat window
- server rotation

Server chooses final map. Voting input validated/rate-limited.

## 13. Results/rewards

Results state is not reward authority from UI.
Server finalizes:
- winners
- score
- XP/currency
- progression
- analytics

Use round ID idempotency.

## 14. Disconnect/reconnect

For long valuable runs decide:
- grace rejoin
- reservation
- run state persistence
- forfeit

Short casual rounds may simply join next round.

## 15. Spectating

Spectator camera/input is client presentation based on server player state.
Handle target death/leave and no valid targets.

## 16. Interactions by phase

ProximityPromptService or interaction router can disable/reject categories based on round state.
Even if UI hidden, server validation checks phase.

## 17. Testing

- 0/1/min/max players
- player joins every phase
- leaves every phase
- countdown cancel
- all players die same moment
- timer/score tie
- server reset repeated 20 rounds
- map failure
- character fails load/respawn

## 18. Acceptance

- [ ] explicit state enum/table
- [ ] one authoritative transition owner
- [ ] player state separate
- [ ] late join/leave defined
- [ ] round ID
- [ ] server timer/score/result
- [ ] one cleanup owner
- [ ] rewards idempotent
- [ ] repeated-round soak no leaks
