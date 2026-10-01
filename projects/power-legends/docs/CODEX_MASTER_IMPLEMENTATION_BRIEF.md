# POWER LEGENDS — CODEX MASTER IMPLEMENTATION BRIEF

> Date: 2026-10-01
> Role: autonomous implementation lead for Power Legends
> Branch policy: work directly on latest `main`
> Human role: final fun/taste/direction review
> Codex role: research, architecture, implementation, Studio inspection, playtest, repair, regression, Git commits

---

# GOAL

Build Power Legends as a production-quality Roblox Training / Incremental Simulator with:

- visible body/power growth
- polished physical training
- free open-world PvP
- Pets as collection/growth amplifiers
- Brawl
- Rebirth
- modern UI/UX
- coherent asset-driven world art

The target is not “many systems implemented.”
The target is an actually playable, polished vertical slice that can later scale into a public release.

---

# CURRENT CONTEXT

Canonical repository:

`q93503128-a11y/roblox-games`

Project:

`projects/power-legends/`

This is a new project.

Do not copy architecture blindly from older projects.
Use Godbase guidance and current Studio state.

---

# CANONICAL READ ORDER

Before implementation, pull latest `main`.

Read in this order:

1. `knowledge/GODBASE_MANIFEST.json`
2. `knowledge/AGENT_PROTOCOL.md`
3. `knowledge/QUICK_REFERENCE.md`
4. `knowledge/regressions/FAILURE_LIBRARY.md`
5. `knowledge/checklists/PROJECT_START_CHECKLIST.md`
6. relevant specialist Godbase docs
7. `projects/power-legends/README.md`
8. `projects/power-legends/docs/GAME_DESIGN.md`
9. `projects/power-legends/docs/PRODUCTION_SPEC.md`
10. `projects/power-legends/docs/ECONOMY_AND_BALANCE.md`
11. `projects/power-legends/docs/UI_UX_FLOW.md`
12. `projects/power-legends/docs/RELEASE_SCOPE_AND_ROADMAP.md`

Relevant specialist docs include at least:

- simulator/collection genre recipe
- combat feel/hit detection
- AI map building/world traversal
- UI/UX
- animation
- camera
- audio
- asset selection/audit
- security
- save schema/data integrity
- economy
- automated acceptance gates
- reusable package/QA system

---

# AUTONOMY

You are expected to investigate details yourself.

Do not require the user to manually provide every reference screenshot, Roblox asset, UI example, or animation example.

Before each major implementation domain:

1. research current successful Roblox references
2. inspect official Roblox capabilities
3. inspect Creator Store / usable asset supply when appropriate
4. record evidence and rationale
5. design within the canonical Power Legends product direction
6. implement
7. inspect the actual result in Studio
8. playtest
9. repair
10. regression test

Use current public information rather than assuming old reference games are unchanged.

---

# REFERENCE STUDY

Minimum references:

- Muscle Legends
- Gym League
- Strongman Simulator
- at least two current successful training/muscle/incremental experiences

Study:

- first 3 minutes
- training interaction
- animation timing
- camera
- body progression
- HUD/menu density
- Pets
- PvP
- safe zones
- Brawl/event cadence
- Gym progression
- monetization surfaces
- spatial grammar

Do not clone:
- exact UI
- exact map
- exact icons/art
- exact Pets
- proprietary assets

Extract conventions and successful interaction patterns.

---

# ART / ASSET RULE

Do not manufacture an entire production art direction out of primitive Parts.

Asset priority:

1. Roblox official systems/assets
2. verified Roblox packages
3. audited Creator Store
4. procedural/generated assets when suitable
5. approved external/OSS source
6. custom construction

For every external asset:

- source
- license/permission if relevant
- scripts
- external requires
- dependencies
- pivot
- scale
- collision
- style fit

must be inspected.

Visual-only asset with unsafe scripts:
sanitize scripts rather than adopting unknown logic.

Do not create an asset soup.

Select a coherent vocabulary first.

---

# DESIGN RESPONSIBILITY

You may improve presentation and detailed implementation.

You may NOT silently change these core product decisions:

- Training Simulator is the core genre.
- Visible body/power growth is essential.
- Free PvP remains.
- Spawn and first onboarding pocket may be safe; ordinary/advanced training spaces should not become blanket Safe Zones.
- Weak-player attack freedom is not completely removed.
- Repeated-victim reward farming is mitigated.
- Pets are included.
- Pets primarily amplify training/collection/social flex.
- Pets do not directly replace the player in PvP in the first slice.
- First Pet is guaranteed in roughly 3–5 min target.
- First Rebirth target is roughly 10–15 min real play, with ~8–11 min optimal-training baseline.
- Rebirth must accelerate earlier progression and unlock content.
- UI must remain contextual and low-clutter.
- paid random eggs are not an initial monetization feature.
- Portable Weight training is a core social/training mode; fixed machines are higher-efficiency or specialized alternatives.
- Vertical Slice includes at least one short Strength Power Challenge.
- Initial server population target is 16 players; consider 20 only after performance/readability validation.

If a core decision appears technically harmful:
STOP that subsystem and report evidence + smallest proposed design revision.

---

# MAP WORKFLOW

Never guess mass world coordinates.

Before placement:

- inspect actual Studio/DataModel
- playable bounds
- floor/terrain
- spawn
- avatar sizes
- Body Stage reference sizes
- camera/FOV
- main route
- zone bounds
- anchors

Create named anchors.

Vertical Slice macro:

- SpawnSafe
- StarterTraining
- PetCourt
- PvPPlaza
- BrawlGate
- NextGymVista
- NextGymPortal

For 5+ player-facing objects:
write a placement table first.

Build:

```text
bounds/floor
→ spawn
→ main route
→ first training
→ landmark
→ Pet/PvP/Brawl nodes
→ production assets
→ detail
→ gameplay-camera regression
```

Do not build the whole world one-shot.

---

# IMPLEMENTATION STAGES

## P0 — Research / setup

Deliver:
- reference audit
- Studio state inspection
- asset shortlist
- workflow/toolchain decision
- implementation plan

Do not mass-build yet.

## P1 — World shell

Validate 16-player social density assumptions when sizing routes, training clearances and PvP space.

Create:
- safe spawn
- Starter Training zone
- PvP route/plaza
- Pet node
- Brawl entry
- Next Gym visual tease

Graybox and gameplay-camera test first.

## P2 — One polished training action

Start with a **portable Weight training action** to preserve free movement/social/PvP presence. Build it to near-production quality before making five.

Verify:
- approach
- alignment
- animation
- hands/tool contact
- weight movement
- timing
- sound
- gain feedback
- context UI
- exit
- mobile input

Only then expand to five.

## P3 — Training set

Five distinct actions using a mix of portable Weight training and fixed stations.
Multiple weight tiers.
Balance from config.

## P4 — Body progression

B0–B4.
Test:
- camera
- door/route clearance
- interaction
- PvP hitbox
- multiplayer crowding

## P5 — PvP

- Basic Punch
- Heavy Move
- second Move
- authoritative damage
- KO
- respawn
- shield
- anti-farm
- TTK tuning

## P6 — Pets

- first guaranteed Pet
- hatch presentation
- owned/equip
- 3 slots
- follow
- additive training bonus
- collection
- save

Use only enough production Pet content to prove the system.

## P7 — Rebirth

Implement:
- requirement
- reset/keep
- permanent multiplier
- reward
- Next Gym unlock

Simulate first-run timing.

## P8 — Brawl

- announcement
- join
- arena
- KO score
- reward
- return
- cleanup/disconnect

## P9 — UI/visual pass

Derive a coherent design system from reference research.

Do not replace UX structure defined in `UI_UX_FLOW.md`.

## P10 — persistence/security/monetization hooks

- schema
- migrations
- load failure safety
- server authority
- Remote validation
- purchase receipt idempotency
- initial non-random paid product hooks

## P11 — automated/manual acceptance

Pass all Vertical Slice gates.

Only then expand content.

---

# CODE ARCHITECTURE

Choose architecture after current official/OSS/Godbase review.

General requirements:

- valuable state server-authoritative
- content catalogs/configs data-driven
- economy constants centrally tunable
- UI presentation separated from domain state
- explicit state machines for training/hatch/Brawl/Rebirth
- cleanup lifecycle for events/connections
- stable IDs for Pets/content
- schemaVersion and migrations
- no client damage/reward authority
- Remote type/range/state/ownership/rate validation

Do not introduce frameworks solely because they exist in Godbase.

---

# ECONOMY

Start from:

`docs/ECONOMY_AND_BALANCE.md`

Do not hardcode tuning throughout scripts.

Create a central tuning/config layer.

Build progression simulation or equivalent checks for:

- first upgrade
- first Body Stage
- first Pet
- first Rebirth
- Rebirth 2nd-run speed
- stacked Pet/pass boost
- impossible/unreachable thresholds

Initial values are baselines, not sacred final numbers.

Tune to target time.

---

# UI / UX

Follow:

`docs/UI_UX_FLOW.md`

Before visual pass:

compare 3–5 current high-quality Roblox UI references.

Define design tokens.

Do not create:
- random gradients per screen
- many unrelated button styles
- permanent left/right icon walls
- desktop-only fixed pixel layouts

Verify:
- small phone
- common phone
- tablet
- 720p
- 1080p

---

# ANIMATION

Do not call placeholder motions production animation.

Training:
- body/tool alignment
- contact
- cadence
- loop transition
- camera
- no obvious clipping

Combat:
- startup
- active hit frame
- impact
- recovery
- hit reaction
- SFX
- controlled camera impulse

Use high-quality existing animations/assets when legally/technically suitable.
Custom/procedural only when quality is sufficient.

---

# PETS

First slice target:
8–12 good Pets, not 30 placeholders.

Required:
- cohesive style
- follow readability
- no excessive screen clutter
- stable ownership IDs
- 3 equip slots
- additive Pet bonus
- collection
- save/restore

Do not implement trade yet.

Do not add paid random eggs without explicit policy/compliance work.

---

# MONETIZATION

Initial candidates:

Pass:
- 2× Training
- Auto Train
- +1 Pet Equip
- VIP
- Pet Storage

Developer Products:
- timed Training Boost
- Starter Pack
- guaranteed companion/bundle

Do not make monetization popup spam part of FTUE.

Use current Roblox monetization APIs/docs.
Do not trust old assumptions.

Developer Product rewards must use robust receipt processing and be idempotent.

---

# TEST ROUTES

At minimum:

## Route A — new player

join
→ spawn
→ portable first train
→ first upgrade
→ first Pet
→ equip
→ observe next goal

## Route B — Body

B0
→ B1
→ B2+
→ machine interaction
→ narrow/wide route
→ camera sweep

## Route C — PvP

leave safe
→ hit
→ Move
→ KO
→ die
→ respawn
→ shield
→ repeated victim anti-farm

## Route D — Rebirth

reach requirement
→ inspect
→ confirm
→ validate reset
→ validate persist
→ validate multiplier
→ validate Next Gym unlock

## Route E — Brawl

announce
→ join
→ start
→ score
→ disconnect edge case
→ end
→ reward
→ return

## Route F — Pets

free hatch
→ equip
→ 3 slots
→ rejoin
→ restore
→ bonus calculation

## Route G — UI device

small phone
→ training
→ PvP
→ Pets
→ Rebirth
→ Shop

---

# PERFORMANCE

Establish baseline from the Vertical Slice.

Check:
- player Body Stage variants
- Pet followers
- training animation/equipment
- PvP effects
- Brawl
- UI
- external asset instance count
- mobile

Use:
Performance Summary
→ Scene Analysis
→ MicroProfiler if a problem exists.

Do not wait until 5 Gyms and 40 Pets exist.

---

# STOP CONDITIONS

Stop new content immediately if:

- project-attributable unexpected runtime error
- spawn/world missing
- primary loop broken
- save corruption/blank overwrite risk
- reward/purchase duplication risk
- severe Remote exploit
- Body Stage breaks camera/collision
- major map scale failure
- mobile blocker
- verified area regresses after art pass
- same subsystem has structural failure twice

On repeated structural failure:

```text
patch stacking stop
→ evidence
→ root cause
→ architecture/workflow reassessment
→ smallest coherent fix
→ exact route replay
→ regression
```

---

# GIT

- work from latest `main`
- work directly on `main`
- no unnecessary PR workflow
- coherent commits
- commit messages prefixed `power-legends:`
- do not change other project folders without a justified shared/Godbase reason
- do not commit secrets
- do not delete verified content merely to simplify implementation

---

# REPORT FORMAT AFTER EACH COHERENT MILESTONE

```text
CHANGED
TESTED
FAILED & FIXED
KNOWN LIMITATIONS
NEXT SAFE STEP
```

Do not say:
- game complete
- Studio verified
- production ready

unless the corresponding acceptance work was actually performed.

---

# FIRST TASK

Do NOT begin by implementing the whole game.

Begin with:

1. update latest `main`
2. canonical reads
3. current Roblox/reference research
4. Studio/MCP connection and current DataModel inspection
5. asset/animation/UI reference shortlist
6. spatial plan
7. written P0 implementation plan

Then build **one production-quality training interaction and its immediate surrounding Starter Gym section**.

Inspect it in gameplay camera and Playtest it before expanding to the remaining systems.
