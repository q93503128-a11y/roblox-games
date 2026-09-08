# Rebirth RPG — Supervisor Post-Asset Input 001

> purpose: convert Studio asset evidence into the first production-zone spatial plan
> do not use until TASK 01–04 evidence exists

When Studio Agent finishes the staged asset audit, summarize only evidence-backed results here.

## REQUIRED INPUT

```text
ENVIRONMENT
approved packs/subsets:
major structure modules:
terrain/ground vocabulary:
scale/pivot/collision notes:

WEAPONS
approved visual A:
approved visual B:
weapon scale/grip notes:

ENEMIES
approved family:
normal A visual:
normal B visual:
boss-capable visual:
rig/animation notes:

ARMOR
approved/deferred:
approved looks if any:

VFX
swing/trail:
impact:
loot/reward:
boss telegraph:

MISSING / HOLD
...
```

## SUPERVISOR DECISIONS AFTER INPUT

Only after the above evidence is complete:

1. Name the first region based on the approved environment vocabulary.
2. Map enemy visuals to gameplay roles; do not force old labels.
3. Map weapon visuals to two early combat roles.
4. Decide whether visible armor progression ships in slice or is deferred.
5. Define the minimal VFX normalization target.
6. Create named spatial anchors.
7. Create a placement table before 5+ player-facing objects are placed.
8. Produce one Agent build task for **one coherent section only**.

## FIRST-ZONE SPATIAL PLAN OUTPUT

```text
ZONE NAME
PLAYER FANTASY
PLAYABLE BOUNDS
FLOOR/TERRAIN CONTACT
SPAWN TRANSFORM
AVATAR/CAMERA REFERENCE

NAMED ANCHORS
- Spawn
- FirstObjective
- SafeService
- MainRouteEntry
- CombatPocketA
- LandmarkA
- RewardNodeA
- NextRouteTease

P0 ROUTE
spawn → first objective → combat A → loot/equip feedback → landmark → boss/elite tease → return/next goal

PLACEMENT TABLE
object | role | anchor/zone | footprint | facing | clearance | required neighbor | forbidden overlap
```

## DESIGN LIMITS

- no giant hub
- no second region
- no random decoration scatter before main route works
- no absolute-coordinate bulk placement before measuring Studio space
- no new enemy/weapon art invented to fill gaps
- no complex boss mechanics
- no production claim before gameplay-camera and P0 route checks

## BUILD ORDER

```text
terrain/bounds
→ spawn/safe pocket
→ main route
→ first combat pocket
→ one landmark
→ reward/progression node
→ gameplay-camera check
→ P0 walk
→ visual repair
```

Only after this section passes should the next section be authored.
