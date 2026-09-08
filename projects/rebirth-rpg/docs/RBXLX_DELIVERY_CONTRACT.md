# Rebirth RPG — RBXLX Delivery Contract

> established: 2026-09-08
> user-required final handoff format: `.rbxlx`

## Purpose

The user-facing playable handoff for Rebirth RPG must be delivered as a Roblox XML place file (`.rbxlx`).

This does not replace the repository source/docs as development truth. The repository remains the canonical development source; `.rbxlx` is the packaged Studio handoff artifact after a coherent build has passed the required Studio checks.

## Required output

Preferred naming:

```text
REBIRTH_RPG_BUILD_<NNN>_YYYY-MM-DD.rbxlx
```

Example:

```text
REBIRTH_RPG_BUILD_001_2026-09-08.rbxlx
```

## Do not hand off an rbxlx when

- the map is still missing or placeholder-only
- the player cannot spawn and complete the current P0 route
- project-attributable unexpected runtime errors remain
- imported production assets have not been audited/sanitized
- major weapon/enemy rigs are detached or broken
- core combat/reward/progression is nonfunctional
- a build has not been opened/saved through Roblox Studio after the relevant changes

A generated XML file that was never validated in Studio is not considered a verified build.

## Minimum verification before each user-facing rbxlx

```text
1. Open target place in Roblox Studio
2. Confirm intended project/DataModel
3. Save current coherent build as .rbxlx
4. Clean Play boot
5. Spawn succeeds
6. Complete current P0 route
7. Check Output for project-attributable unexpected errors
8. Check key visual states from gameplay camera
9. Verify core desktop controls/UI
10. Verify required mobile path when the slice reaches mobile gate
11. Re-open the saved .rbxlx once if export/sync changes could have affected hierarchy
12. Record known limitations
```

## Source / artifact ownership

Development truth:

```text
GitHub source/docs + inspected Studio DataModel
```

User handoff artifact:

```text
.rbxlx
```

Do not silently edit only the handoff rbxlx while leaving canonical repository state stale. Important gameplay/system changes must remain represented in the project source/docs or an explicitly documented Studio-owned hierarchy.

## Asset rule

Creator Store/source packs are not shipped wholesale by default.

Before final rbxlx handoff:
- retain only approved/sanitized subsets
- remove demo scripts and unrelated scaffolding
- remove quarantined source libraries from production hierarchy unless explicitly needed
- keep source IDs/provenance documented in `ASSET_SOURCES.md`

## Build status terminology

Use these separately:

```text
CODE WRITTEN
FEATURE IMPLEMENTED
STUDIO TESTED
RBXLX EXPORTED
HUMAN TESTED
```

`RBXLX EXPORTED` alone does not mean the game or feature is finished.

## Current project status

As of establishment of this contract, Rebirth RPG is still in asset-first preproduction. No user-facing production rbxlx should be produced yet. The first rbxlx should be exported only after the first coherent playable Vertical Slice exists and passes the Studio gate.
