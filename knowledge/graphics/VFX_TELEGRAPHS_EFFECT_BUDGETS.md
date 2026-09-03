# VFX, Telegraphs, Trails, Beams, and Effect Budgets

> verified: 2026-09-03

Official:
- Effects overview: https://create.roblox.com/docs/effects
- ParticleEmitter: https://create.roblox.com/docs/effects/particle-emitters
- Beams: https://create.roblox.com/docs/effects/beams
- Trails: https://create.roblox.com/docs/effects/trails

## 1. VFX has jobs

Classify every effect:
- anticipation / telegraph
- direction/motion
- active hit volume hint
- impact confirmation
- status state
- reward
- ambience

If an effect has no job, remove or simplify it.

## 2. Telegraph vs impact

Enemy danger telegraph must not look like player success impact.
Separate with:
- color family
- shape
- timing
- spatial language

Example:
- enemy danger: expanding ground shape / clear directional line
- player impact: short burst at contact

## 3. Timing grammar

For combat effects:
```text
windup cue starts
→ active danger/attack
→ contact flash
→ short debris/sparks
→ cleanup
```

Effect appearing after damage by 300ms makes hit feel disconnected.

## 4. ParticleEmitter budget

Roblox documents that overlapping transparent particles create overdraw and can hurt performance. Current per-emitter Rate limits differ by platform; therefore use **the lowest emission rate that creates the intended look** rather than designing around maximums.

Prefer burst `:Emit()` for one-shot impacts over always-enabled high Rate when suitable.

## 5. Particle size matters as much as count

Ten giant transparent sprites covering the screen can cost more/read worse than many tiny particles.
Check:
- screen coverage
- transparency layers
- lifetime
- texture alpha
- camera proximity

## 6. Trails

Good for:
- weapon swing direction
- projectile movement
- fast dash/ball

Trail should clarify trajectory, not become a permanent ribbon wall.
Control:
- attachment spacing
- lifetime
- width
- texture
- transparency curve

## 7. Beams

Good for:
- laser/target line
- lightning/energy connection
- forcefield edge
- telegraph between two points

Beam endpoints should be Attachment-based and follow moving models correctly.

## 8. Ground telegraphs

Ground warning effect needs:
- clear boundary
- readable duration
- active moment
- world slope handling

Avoid large opaque decal/part that hides terrain and players.

## 9. Hit flash

Use short duration.
Possible layers:
- target highlight/color flash
- small particles
- sound transient
- damage number
- camera/hitstop

Do not make all of them extreme at once.

## 10. Pooling

Object pooling can help frequent effects, but only after profiling. Pool complexity is not free.

Always cleanup:
- emitters
- attachments
- beams/trails
- temporary parts
- connections

## 11. LOD

Effect scale by distance/device:
- nearby hero: full
- mid: reduced particles/lights
- far: minimal or none

Gameplay-critical telegraph cannot disappear solely for performance; simplify while preserving information.

## 12. Lighting effects

PointLight/SurfaceLight can add impact but many moving lights are expensive/noisy. Use as accent, and test simultaneous multiplayer worst case.

## 13. Color discipline

Project semantic palette example:
```text
danger = warm red/orange
healing = green/teal
player magic = class accent
interactable = neutral cyan
legendary reward = gold
```

Do not let every skill choose arbitrary rainbow colors.

## 14. VFX and accessibility

Do not rely on color alone for lethal telegraph.
Add shape/timing/outline.

Avoid:
- repeated full-screen flashes
- extreme shake + flash combination
- opaque particles at camera

## 15. Reference analysis

Record:
```text
telegraph duration
impact duration
screen coverage
particle direction
trail lifetime
camera response
sound synchronization
```

Copy timing/communication lessons, not proprietary textures/assets.

## 16. Worst-case test

- 1 player attack
- max nearby players same attack
- boss + players
- camera inside effect
- low quality/mobile
- 30s spam/cleanup soak

## 17. Acceptance

- [ ] danger and impact visually distinct
- [ ] timing matches gameplay
- [ ] no opaque screen filling
- [ ] mobile overdraw tested
- [ ] attachment movement correct
- [ ] all temporary effects cleanup
- [ ] color not sole danger signal
- [ ] multiplayer worst-case readable
