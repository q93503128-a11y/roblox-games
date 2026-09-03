# Terrain and Environment Production Pipeline

> verified: 2026-09-03

Official:
- Terrain Editor: https://create.roblox.com/docs/studio/terrain-editor
- Environmental terrain: https://create.roblox.com/docs/parts/terrain
- Terrain API: https://create.roblox.com/docs/reference/engine/classes/Terrain

Roblox smooth terrain is voxel-based; current terrain resolution for relevant API operations is 4 studs. Use Terrain where it improves natural forms and scale, not automatically for every environment.

## 1. Choose terrain vs parts/meshes

Terrain excels at:
- hills/mountains
- caves/ground masses
- water/shorelines
- natural transitions

Parts/meshes excel at:
- architecture
- precise gameplay edges
- modular platforms
- stylized authored silhouettes

Hybrid is often strongest.

## 2. Heightmap workflow

For large geography:
1. define playable route/landmarks first
2. generate/import heightmap
3. carve playable areas
4. paint materials
5. add modular hero geometry

Never let a random generated heightmap dictate game design after the fact.

## 3. Terrain Editor tools

Current toolset includes:
- Generate/import
- Draw/Sculpt
- Smooth
- Flatten
- Paint
- region transformations
- sea level/fill/replace operations

Sculpt strength and brush size should change by macro/meso/micro pass.

## 4. Three-pass terrain authoring

### Macro
- mountains/valleys/islands
- horizon silhouette
- biome boundaries

### Meso
- playable slopes
- cliffs
- paths
- combat clearings

### Micro
- small erosion/variation
- material breakup

Do not micro-detail before traversal is validated.

## 5. Gameplay surfaces

Every terrain slope is gameplay.
Check:
- walkability
- jump edge
- vehicle traction if relevant
- NPC navmesh
- camera clipping
- fall recovery

Beautiful steep terrain that blocks pathing unintentionally is a defect.

## 6. Material language

Limit material family per biome.
Example:
```text
forest: grass + leafy/ground + rock + mud accent
snow: snow + rock + ice accent
```

Too many materials in one small area create visual noise.

## 7. Water

Define:
- swimmable?
- lethal?
- traversal vehicle?
- boundary?

Visual water and gameplay rule must match. Invisible kill plane immediately under shallow-looking water is confusing unless clearly signaled.

## 8. Custom terrain colors/materials

Use custom color/material behavior to support art direction, but validate under project lighting. Material palette should match meshes/parts nearby.

## 9. Procedural terrain API

Terrain APIs such as fill/read/write voxel operations can generate runtime/editor terrain.
Good use:
- controlled procedural maps
- editor tooling
- destructible/rebuildable regions if design requires

Bad use:
- regenerate entire authored world every server boot without reason
- critical spawn dependent on one huge generator script

## 10. Streaming/performance

Large terrain worlds still need:
- streaming design
- first-spawn content availability
- distant object density control
- mobile performance testing

Terrain size alone is not the only cost; foliage, effects, meshes, scripts, and physics often dominate.

## 11. Foliage placement

Use density zones and clearance rules.
- keep main route readable
- preserve combat sightlines
- avoid tiny collision blockers
- vary clusters, not uniform random noise

## 12. Rock/cliff seam strategy

Terrain + mesh cliff combinations should avoid:
- z-fighting
- obvious floating mesh edges
- repeated identical rocks
- collision mismatch

Use transition props/material blending sparingly.

## 13. Lighting/fog

Terrain depth can be strengthened with atmosphere/fog, but readability first. Do not compensate weak composition with extreme fog/post-processing.

## 14. Navmesh regression

After terrain/art pass:
- show navigation mesh
- run NPC route
- test slope/bridge/cave entrances
- check AgentRadius/Height

## 15. Terrain source/versioning

Studio-authored terrain may not diff nicely in Git. Project workflow must state whether terrain source is:
- Studio place
- package/template
- generated from data/heightmap

Keep source heightmaps/scripts if reproducibility matters.

## 16. Acceptance

- [ ] macro silhouette supports navigation
- [ ] main route validated before micro detail
- [ ] terrain slopes playable
- [ ] material family consistent
- [ ] water rule obvious
- [ ] no terrain/mesh z-fighting
- [ ] navmesh tested after art pass
- [ ] mobile/streaming test for large world
