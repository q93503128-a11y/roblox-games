# Creator Store Automation and Scoring

> verified: 2026-09-03

Creator Store contains millions of assets. Manual browsing alone does not scale, and raw popularity alone produces bad recommendations.

## Current platform capability

Roblox current Open Cloud/Toolbox documentation exposes Creator Store asset search/details endpoints (beta at verification), including:
- Search Creator Store Assets
- Get Creator Store Asset Details

Reference:
https://create.roblox.com/docs/cloud/reference/features/creator-store

Studio MCP can also search/insert Creator Store assets in supported workflows. Prefer official search surfaces over scraping HTML when building automation.

## Three-stage catalog

### Stage 1 — Web/API discovery
Cheap filtering. Record:
- asset ID
- title
- creator
- type/category
- price
- rating/vote count
- created/updated
- script count where exposed
- triangle/vertex/mesh count
- animation/audio/tool count
- description/license-like usage notes

Status remains `WEB_*`; no asset is S-tier yet.

### Stage 2 — Quarantine Studio inspection
Insert into isolated test place.

Automate/inspect:
- descendant class histogram
- Script/LocalScript/ModuleScript source scan
- numeric require
- HTTP/runtime insert patterns
- obfuscation
- asset dependency IDs
- pivots
- collisions
- unexpected parts at origin
- rig integrity
- instance count

Visual screenshot:
- default camera
- avatar scale reference
- close/far shot

### Stage 3 — Production-fit test
Only promising sanitized assets reach this stage.

Test:
- actual game lighting/materials
- target mobile device
- repeated asset count
- collision/pathfinding
- Streaming
- combat camera readability
- VFX worst-case

Then grade S/A/B/Reject.

## Scoring model

Never let one score override security/source rejection.

Hard reject flags:
- unexplained obfuscated script
- malicious/external loader behavior
- stolen/repackaged provenance concern not resolved
- usage terms incompatible with project
- broken asset dependencies that cannot legally/safely be repaired

After hard gates, score 0–5:

| Axis | Meaning |
|---|---|
| Source | creator/provenance/usage clarity |
| Security | script/dependency audit |
| Visual | silhouette/material/detail quality |
| StyleFit | matches current art bible |
| Technical | pivot/rig/collision correctness |
| Performance | cost at expected repetition |
| Mobile | readability + device cost |
| Editability | easy to recolor/resize/package |
| Documentation | clear usage/setup |
| Maintenance | recent/working if tool/scripted kit |

Suggested interpretation:
- `S`: no critical weakness; production-ready after small normalization
- `A`: strong; defined modifications required
- `B`: useful prototype/secondary asset
- `C`: reference only
- `Reject`: do not use

## Rating/popularity policy

Creator Store votes are useful discovery signals, not quality proof.

Examples from seed sweep show why:
- some very highly-rated packs are enormous and should be subset-extracted
- some scripted packs have many scripts and user-reported runtime bugs
- a huge paid VFX pack can have extremely poor reviews/provenance complaints

Always combine marketplace signals with Studio audit.

## Script-risk weighting

Approximate review effort, not a security verdict:
- 0 scripts: still inspect dependencies, but lower code risk
- 1–3 scripts: normal targeted review
- 4–20: medium kit audit
- 20+: quarantine/high review cost

One malicious script is worse than fifty clean scripts, so count alone never proves safety.

## Geometry role weighting

Do not compare all triangle counts equally.

Examples:
- hero boss can justify more geometry than repeated grass
- 500k triangles in a 1000-mesh library can be acceptable **as a source library** if only a few chosen assets ship
- a 40k-triangle tree repeated 400 times may be worse than a large one-off landmark

Catalog role:
- `SOURCE_LIBRARY`
- `HERO`
- `SECONDARY`
- `REPEATED_PROP`
- `VFX`
- `TOOL`

Performance grade depends on intended role.

## Asset extraction policy

Large pack workflow:
1. quarantine original
2. select only approved models
3. remove demo scene/scripts
4. normalize names/pivots/materials
5. package chosen subset
6. record original asset ID/creator
7. test repeated use

Never drag a 1000-mesh pack into production ReplicatedStorage merely because only 10 meshes are visible.

## Plugin policy

Plugins can modify Studio/project state. Before using a third-party plugin:
- verify creator/page/reputation
- inspect source if available
- understand required permissions/capabilities
- test on expendable place/source-controlled project
- keep project backups/Git history

A plugin's runtime output must still pass normal asset/code audit.

## Future automation target

Build a Godbase harvester that:
1. queries official Creator Store search API by category/query
2. stores raw metadata snapshots
3. deduplicates asset IDs
4. flags scripts/large geometry/poor rating/old updates
5. emits `PENDING_STUDIO` queue
6. Studio MCP inserts candidates into quarantine
7. audit script emits descendant/security/geometry report
8. screenshots captured
9. human/AI grades visual/style fit
10. approved records promoted to canonical catalog

Do not attempt to automatically insert thousands of scripted models into a trusted development place.

## Search queues

Priority categories:
1. stylized environment/nature
2. buildings/modular kits
3. weapons/tools
4. enemy/NPC rigs
5. animation packs
6. VFX
7. UI icons/components
8. audio/SFX
9. procedural generators
10. plugins
11. complete genre kits

For every new project, run a project-specific query pass even if the generic catalog is large. Style fit matters more than owning the biggest asset library.
