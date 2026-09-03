# Hit Detection, Hitboxes, Projectiles, and Combat Queries

> verified: 2026-09-03

Official API:
- WorldRoot: https://create.roblox.com/docs/reference/engine/classes/WorldRoot
- RaycastParams: https://create.roblox.com/docs/reference/engine/datatypes/RaycastParams
- Network ownership security: https://create.roblox.com/docs/scripting/security/network-ownership

## 1. Do not use `Touched` as universal combat truth

`Touched` can be useful for simple local/environment interactions, but gameplay-critical combat must account for network ownership and exploitability. Roblox documents that clients owning physics can manipulate contact events.

For valuable damage/reward, server validates independently.

## 2. Query toolbox

### Raycast
Best for:
- bullets/hitscan
- line of sight
- narrow directional checks
- ground probes

Returns first hit and surface information.

### Spherecast
Best for:
- projectile with thickness
- forgiving aim
- fast-moving orb where a zero-width ray feels unfair

### Blockcast
Best for:
- sword/hammer sweep approximation
- dash body volume
- rectangular projectile/hazard

### Shapecast
Casts an existing BasePart shape through space. Useful where the actual hit volume shape matters.

### GetPartBoundsInBox / Radius
Best for:
- area melee hit
- explosion/zone query
- nearby target list

### GetPartsInPart
Best for precise overlap against a query part when needed.

Old Region3 query APIs are deprecated; use current WorldRoot query APIs.

## 3. Collision filtering

Use `RaycastParams` / `OverlapParams` intentionally.
- include/exclude relevant descendants
- collision group
- water behavior
- CanCollide semantics

Do not build huge ad-hoc ignore lists every frame if collision groups/tags can express policy.

## 4. Melee attack timeline

Server attack definition:
```text
attackId
windup
activeStart
activeEnd
recovery
shape
range
maxTargets
baseDamage
```

Client:
- immediate animation/VFX prediction
- sends attack intent

Server:
- validates weapon/state/cooldown
- opens authoritative active window
- queries hit volume
- deduplicates target per attack instance
- applies damage

## 5. One hit per attack target

Every attack instance gets unique server token/id.
Maintain hit set:
```text
attackInstanceId -> targetId -> alreadyHit
```

Avoid Heartbeat overlap causing same sword swing to damage 10 times unless attack intentionally multi-ticks.

## 6. Fast projectiles

A projectile moving many studs per frame can tunnel through targets if relying on physical contact only.

Candidates:
- ray/spherecast from previous position → new position each simulation step
- server-authoritative projectile timeline
- client cosmetic projectile matched to server path

Projectile visual and damage authority can be separate.

## 7. Lag tolerance

Competitive combat may need limited temporal/spatial tolerance, but never trust client-declared hit result.

Possible server checks:
- attack existed
- target alive
- distance plausible
- facing/aim plausible
- timestamp within bounded window
- cooldown/state valid

Full lag compensation/rewind is genre-specific and must be designed explicitly rather than improvised.

## 8. Line of sight

AoE does not automatically mean through walls.
For each target if design requires occlusion:
- area query first
- then raycast LOS

Do not raycast every possible object in world when a broad-phase query can reduce candidates.

## 9. Hitbox visualization

Debug build/MCP test should be able to show:
- attack volume
- cast path
- active window color
- targets hit
- rejected targets/reason

Disable in production or gate behind developer permission.

## 10. Client prediction

Immediate feel:
- animation
- trail
- swing sound
- local camera response

Authoritative:
- damage
- stagger state
- reward
- kill ownership

Server rejection should reconcile gracefully; do not wait for round trip before showing every visual.

## 11. Damage pipeline

Keep hit detection and damage formula separate.

```text
query hit
→ validate target
→ DamageCalculator
→ mitigation/status
→ health mutation
→ reaction/analytics
```

This makes balancing/tests easier.

## 12. Friendly fire / teams

Filter before damage:
- self
- team
- invulnerability
- dead
- safe zone
- immune category

Do not scatter these checks in every weapon script.

## 13. Performance

Avoid:
- every weapon creating permanent Heartbeat loop
- huge overlap query every frame
- raycasting all players/NPCs individually without broad phase

Use attack-active windows, batching, distance activation, and profiler.

## 14. Regression matrix

- stationary target
- moving target
- target behind wall
- attacker moving fast
- high latency
- target dies during windup
- simultaneous attackers
- same target in repeated query frames
- edge of hitbox
- multiple targets
- friendly/safe-zone target
- respawn mid-combat

## 15. Acceptance

- [ ] visual hit timing matches authoritative active window
- [ ] no duplicate damage per intended hit
- [ ] server does not trust client damage/result
- [ ] query type matches attack geometry
- [ ] fast projectile tunneling addressed
- [ ] LOS policy explicit
- [ ] debug visualization exists for hard combat bugs
- [ ] network ownership/Touched risk reviewed
