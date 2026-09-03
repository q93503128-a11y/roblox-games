# Procedural Generation, Seeds, Constraints, and Determinism

> verified: 2026-09-03

Procedural generation is a content-production technique, not a substitute for design. Randomness must operate inside authored constraints.

## 1. Define what is procedural

Good candidates:
- room sequence
- prop variation
- loot positions
- dungeon branches
- biome dressing
- wave composition

Keep authored when critical:
- spawn safety
- tutorial route
- key landmark
- boss arena metrics
- monetization/quest critical object placement unless robust constraints exist

## 2. Seed strategy

Use a controlled `Random.new(seed)` stream when reproducibility matters.

Record:
- world/run seed
- generator version
- selected content IDs

A seed alone cannot reproduce an old run if generator algorithm/catalog changes; include version.

## 3. Separate RNG streams

Avoid one global RNG where cosmetic decoration changes alter gameplay loot/room outcomes.

Possible streams:
```text
layout RNG
encounter RNG
loot RNG
cosmetic RNG
```

Derived from master seed + stable salt/hash strategy.

## 4. Constraint-first generation

Instead of `random x/z`, define:
- valid regions
- minimum separation
- path clearance
- occupancy grid
- slope
- biome/tag rules
- landmark exclusion
- connectivity

Generate candidate → validate → accept/retry/fallback.

## 5. Guaranteed solvability

Dungeon/obby/puzzle generation needs validators:
- spawn connected to exit
- required keys before locked door
- no unreachable reward/quest
- navmesh/path exists
- platform jump distances within movement capability

If generation fails after bounded retries, load known-safe authored fallback.

## 6. Room graph before geometry

Roguelite example:
```text
Start
→ Combat A
→ Choice
  → Elite → Reward
  → Combat B → Shop
→ Boss
```

Generate semantic graph first, then instantiate compatible room modules.

## 7. Modular room contract

Each module defines:
- entry/exit sockets
- bounds
- tags/category
- difficulty
- allowed neighbors
- spawn anchors
- nav data assumptions

Do not align rooms using arbitrary model centers; use attachments/socket transforms.

## 8. Overlap detection

Use bounding boxes/spatial occupancy to reject intersections.
Keep gameplay clearance, not just geometry non-overlap.

## 9. Decoration after gameplay

Order:
1. topology/layout
2. traversal validation
3. encounter anchors
4. reward/objective
5. decoration

Decoration RNG must not block path/telegraph/camera.

## 10. Difficulty budget

Wave/room generation uses a budget rather than random enemy count.

Example:
```text
room budget = 10
slime cost 1
archer cost 2
elite cost 5
```

Constraints avoid impossible combinations and monotony.

## 11. Repetition control

Use:
- no-repeat window
- weighted rarity
- biome pools
- adjacency rules
- guaranteed variety slots

Pure uniform random often produces streaks that feel non-random/bad.

## 12. Deterministic testing

Keep regression seed set:
```text
seed_small
seed_branching
seed_dense
seed_edgecase_01
```

CI/pure generator tests can ensure:
- finite generation
- valid graph
- no duplicate IDs
- reachable exit
- bounds

Studio integration checks instantiated geometry.

## 13. Runtime vs editor generation

Editor/prebaked:
- easier art polish
- lower boot risk
- inspectable

Runtime:
- replayability
- unique runs

Do not runtime-generate static world just because it is technically possible.

## 14. Performance

Generation has two costs:
- generation CPU/boot time
- resulting scene complexity

Batch/yield expensive generation where appropriate; don't expose player to a half-built unsafe world.

## 15. Multiplayer synchronization

Server owns gameplay seed/layout.
Clients receive instantiated authoritative world/state, not independently roll gameplay layout unless deterministic replication design is proven.

## 16. Save/rejoin

Long procedural run may need:
- seed + generatorVersion
- semantic room index/state
- player run build

If old generator no longer exists, save enough semantic state or intentionally invalidate old runs with clear product policy.

## 17. Debug visualization

Show:
- seed/version
- room graph
- sockets
- occupancy bounds
- rejected candidate reason
- path/connectivity

## 18. Acceptance

- [ ] authored constraints before randomness
- [ ] seed + generator version
- [ ] gameplay RNG separated from cosmetics where needed
- [ ] solvability/connectivity validator
- [ ] bounded retries + safe fallback
- [ ] deterministic regression seeds
- [ ] decoration cannot block gameplay
- [ ] multiplayer server authority
