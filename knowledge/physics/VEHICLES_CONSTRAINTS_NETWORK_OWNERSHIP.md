# Vehicles, Constraints, Physics, and Network Ownership

> verified: 2026-09-03

Official:
- Physics: https://create.roblox.com/docs/physics
- Network ownership: https://create.roblox.com/docs/physics/network-ownership
- Mover constraints: https://create.roblox.com/docs/physics/mover-constraints
- Mechanical constraints: https://create.roblox.com/docs/physics/mechanical-constraints

## 1. Build assemblies intentionally

Vehicle/mechanism hierarchy should clearly define:
- chassis/root assembly
- seats
- wheels/suspension
- decorative loose parts
- attachments
- constraints

Loose decoration accidentally forming separate physics ownership is a common source of jitter.

## 2. Prefer current constraints over legacy BodyMovers

Current mover constraints include:
- LinearVelocity
- AngularVelocity
- AlignPosition
- AlignOrientation
- VectorForce
- Torque
- LineForce

Mechanical constraints include:
- Hinge
- Spring
- BallSocket
- Prismatic
- Cylindrical
- Rope and others

Old BodyMover patterns should be treated as legacy migration candidates.

## 3. Driver ownership

Roblox documents a vehicle case where automatic network ownership may go to the first nearby/passenger assembly owner rather than the intended driver. For responsive vehicle control, explicit server-side `SetNetworkOwner(driver)` may be appropriate.

When driver leaves, consider restoring automatic ownership.

## 4. Security

Client network ownership means the client has strong control over simulated physics. Never award valuable state solely because a client-owned vehicle/ball physically touched something.

Server checks:
- race checkpoint order
- plausible position/speed
- lap state
- vehicle ownership
- time/distance sanity

## 5. Vehicle input

Input → desired steering/throttle/brake state.
Do not let client submit authoritative lap time/reward/result.

## 6. Timestep/stability

Physics docs include adaptive timestep concepts. Complex mechanisms may need stability-focused settings/current APIs. Test high load and low FPS instead of assuming desktop local behavior generalizes.

## 7. Suspension

Typical design layers:
- wheel contact
- spring/damper
- steering
- drive torque/force
- friction tuning

Separate visual wheel steering/spin from authoritative chassis behavior when helpful.

## 8. Center of mass

Vehicle feel strongly depends on mass distribution.
Check:
- heavy decoration
- collision parts
- root/chassis density
- rollover tendency

Invisible ballast is acceptable as intentional tuning if documented; random mass from decorative meshes is not.

## 9. Collision groups

Use collision groups to avoid:
- wheels colliding with chassis
- character snagging internal parts
- vehicle parts self-colliding unexpectedly

## 10. Mechanism visualization

Studio can visualize mechanisms/constraints/network ownership. Use it before guessing.

Debug:
- constraint attachments
- ownership color
- chassis assembly boundaries
- contact/collision

## 11. Respawn/reset

Vehicle lifecycle:
- spawn
- assign owner
- seat enter/exit
- destruction/reset
- cleanup loose parts
- owner leave

No abandoned loops/connections after vehicle despawn.

## 12. Projectiles/physics objects

Gameplay-critical moving physics object:
- choose ownership explicitly
- server validates impact
- consider cast-based collision for high speed
- lifetime bounds

## 13. Network simulation

Test:
- latency
- packet loss
- driver/passenger swap
- ownership transfer
- high speed
- multiple vehicles

Responsive local steering with remote jitter may require prediction/ownership tuning.

## 14. Server Authority

Current Server Authority/prediction model may change best practices for physics-heavy competitive games. Re-check current availability/settings before adopting.

## 15. Acceptance

- [ ] assembly boundaries intentional
- [ ] current constraints used where appropriate
- [ ] driver ownership tested
- [ ] passenger does not steal control unexpectedly
- [ ] checkpoint/reward server validated
- [ ] low FPS/network conditions tested
- [ ] collision groups sane
- [ ] cleanup after despawn
- [ ] mechanism/ownership visualization inspected
