# Slay & Loot — Asset Sources

Every external production asset used in Slay & Loot must be recorded here after audit.

## Required fields

| Asset | Asset ID / Source | Creator | Category | Intended Use | Scripts Removed | Modified | Security | Scale/Pivot/Collision | Visual Fit | Status | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Synty Dungeon / Polygon Dungeon environment kit (`SyntyDungeon_Q`) | `6934021345` | Synty / Creator Store metadata to reverify before approval | Environment / props | Dungeon production-art candidate | N/A in inspected copy | No production promotion yet | Inspected quarantined copy: 271 MeshParts, 0 scripts observed | Full pack still requires module-by-module pivot/scale/collision/avatar/camera audit | Same stylized family as intended project direction, but not yet evaluated as a live room set | `QUARANTINED` | Stored under `ServerStorage.Quarantine.SyntyDungeon_Q`; current Git source does not reference it. Do not ship the whole library wholesale. |
| Goblin King visual (`Goblin_Q`) | `13557888509` | Creator Store metadata to reverify before approval | Boss visual rig/model | First-dungeon boss visual | No scripts observed in inspected copy; runtime builder removes Humanoid/Animator/animation-sequence objects from the clone | Runtime clone is anchored, non-colliding/non-querying, scaled to 1.75 | Inspected quarantined copy contained 0 scripts; project-owned `EnemyService` controls combat/authority | Current boss builder sanitizes the clone and uses project-owned movement/combat; final pivot/avatar/camera/performance approval still required | Currently visible in the boss path and preferable to the primitive fallback, but full production approval is not yet recorded | `CANDIDATE` | **IN USE BUT NOT APPROVED.** `EnemyService.buildBossRig()` depends on `ServerStorage.Quarantine.Goblin_Q`; if missing, the code falls back to the project block rig. |

## Status meanings

- `CANDIDATE` — discovered, not yet approved
- `QUARANTINED` — inserted only for inspection; must not ship as an unreviewed library
- `APPROVED` — source/security/visual/technical checks passed for the stated use
- `REJECTED` — do not use; explain why in Notes
- `REPLACED` — historical source retained for traceability, but no longer active

An asset being referenced by current prototype/runtime code does **not** automatically make it `APPROVED`.

## Minimum audit before APPROVED

- source and creator known
- usage basis acceptable
- scripts/dependencies inspected
- suspicious runtime loading/obfuscation absent or removed
- pivot/rig usable
- avatar-relative scale checked
- collision suitable or replaced with proxy
- gameplay camera appearance checked
- performance cost reasonable for intended repetition count
- visually coherent with the accepted project direction

If only a visual model is needed, prefer a sanitized script-free copy.
