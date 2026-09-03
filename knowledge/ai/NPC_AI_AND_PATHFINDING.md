# NPC AI and Pathfinding

> verified: 2026-09-03

Official pathfinding:
https://create.roblox.com/docs/characters/pathfinding

## 1. AI layers

NPC를 한 거대한 loop로 만들지 않는다.

```text
Perception
→ Decision/state
→ Navigation
→ Action/combat
→ Animation/VFX
```

각 layer를 교체/테스트 가능하게 한다.

## 2. State machine baseline

일반 enemy:
- Idle
- Patrol
- Alert
- Chase
- AttackWindup
- Attack
- Recover
- Stunned
- Return
- Dead

게임에 필요하지 않은 state를 억지로 늘리지 않는다.

## 3. Perception

Server가 중요한 target eligibility를 결정.

Check:
- distance
- alive/team
- line of sight if relevant
- aggro/leash region
- stealth/status

모든 NPC가 every frame 모든 player를 scan하지 않는다. spatial partition/distance scheduling을 규모에 따라 검토.

## 4. PathfindingService

`PathfindingService:CreatePath()`에서 agent parameters를 NPC 실제 크기/능력에 맞춘다.

Important current parameters include:
- AgentRadius
- AgentHeight
- AgentCanJump
- AgentCanClimb
- WaypointSpacing
- Costs/labels where used

Navigation mesh visualization을 켜서 "코드가 왜 길을 못 찾지"를 추측하지 않는다.

## 5. Blocked path

Dynamic world에서 path가 막힐 수 있다.
`Path.Blocked`가 발생했다고 무조건 즉시 전체 recompute하지 말고 **현재 진행 방향 앞쪽 waypoint가 막혔는지** 확인하는 패턴을 사용한다.

Repath 조건:
- target moved meaningful distance
- blocked ahead
- stuck timer
- navigation state changed

매 frame `ComputeAsync()` 금지.

## 6. Direct movement vs pathfinding

항상 pathfinding이 정답은 아니다.

Direct steering:
- open arena
- short LOS chase
- flying/simple enemy

Pathfinding:
- maze/building
- obstacles/corners
- navigation constraints

Hybrid가 흔히 좋다:
LOS에서는 direct chase, blocked면 path.

## 7. Stuck recovery

Detect:
- expected movement but displacement low for N seconds
- waypoint timeout

Recovery:
1. local repath
2. short reposition if game design permits
3. return to spawn
4. respawn last resort

무한 repath spam을 막는다.

## 8. Leash

Enemy가 world 전체를 player 따라가지 않게:
- spawn anchor
- max aggro distance
- max combat region
- return behavior
- reset HP policy
를 명시.

## 9. Combat telegraph

AI sophistication보다 attack readability가 중요할 수 있다.

Attack cycle:
- choose
- face/aim
- anticipation
- active
- recover

Player가 counterplay할 시간이 있어야 한다.

## 10. Server performance

많은 NPC:
- distance activation
- AI tick frequency tiers
- sleeping state
- pooled sensing
- path recompute cooldown
- raycast budget
- Parallel Luau candidate

Profiler로 확인.

## 11. Physics ownership

Enemy/root parts의 network ownership과 security/consistency를 검토한다. 중요한 boss/combat physics가 client-controlled authority에 의존하지 않게 한다.

## 12. Animation

Navigation velocity와 animation speed를 연결하되:
- hit window는 animation visual만 믿지 않고 authoritative state timing과 연결
- stun/death에서 locomotion cleanup

## 13. Boss design

Boss AI는 random attack list보다 phase grammar를 갖는다.

```text
Phase 1: teach A/B
Phase 2: combine A+B + C
Phase 3: space pressure + shorter recovery
```

항상 dodge 불가능한 visual noise로 난이도를 만들지 않는다.

## 14. Debug tools

Studio debug visualization 후보:
- aggro radius
- leash
- current target
- path waypoints
- current state
- attack hitbox
- path compute count

Release에서 disable.

## 15. Acceptance

- [ ] navmesh inspected
- [ ] obstacle path
- [ ] blocked/repath
- [ ] target leave/death
- [ ] player respawn
- [ ] leash
- [ ] multi-NPC performance
- [ ] no path spam
- [ ] attack telegraphs readable
- [ ] body/accessories move as one Model
