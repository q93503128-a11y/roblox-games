# Asset Selection by Genre

> verified: 2026-09-04

This is a procurement decision guide, not a style bible. Every project must still choose reference games and define its own art direction before importing assets.

## Universal sequence

1. Define the game's visual target from real Roblox references.
2. Search official Roblox packs/modules first.
3. Search coherent community packs second.
4. Prefer one visual family over ten unrelated packs.
5. Build a 5–10 minute vertical slice with the selected art stack.
6. Only after the slice works, expand the asset vocabulary.

## Stylized RPG / adventure

Good starting supply:
- Synty Nature Pack (`6933438443`) for trees/rocks/outdoor props.
- compact weapon model packs such as `10226464132` for silhouette prototyping.
- VFX PACK (`112672322113504`) as a reference source, not as a one-click style replacement.

Look for:
- readable silhouettes at combat-camera distance
- strong biome color grouping
- modular rocks/cliffs/trees with controlled repetition
- weapons that read from third-person zoom
- effects with clear telegraphs rather than particle spam

Avoid:
- realistic PBR props mixed randomly into low-poly worlds
- giant asset libraries loaded wholesale
- combat kits that dictate the architecture before core feel is proven

## Simulator / tycoon

Good starting supply:
- Synty Nature Pack for coherent low-poly exterior vocabulary.
- Simulator Assets (`13418164648`) if its explicit credit requirement is acceptable and recorded.
- selected low-poly packs after Studio audit.

Priorities:
- low repeated cost
- strong color coding
- large readable props
- simple collision
- scalable production pipeline for many zones/upgrades

The repeated prop is more important than the hero prop. A cheap tree used 400 times matters more than a beautiful one-off statue.

## Horror / narrative exploration

Strong source:
- Duvall Drive House Props (`10840642581`)
- Duvall Furniture (`10847897579`)
- Duvall Landscaping (`10840661513`)
- Duvall Material Variants (`10841357434`)

Use these as source libraries for:
- environmental storytelling
- clutter density
- PBR material language
- believable interior scale
- visual cues and diegetic guidance

Do not import every prop. Curate a room vocabulary and keep scene hierarchy clean.

## City / roleplay / driving

Potential stack:
- City Road Pack (`6432233485`) for roads/intersections.
- Synty City Pack only after texture dependency re-verification.
- Duvall exterior props for detail layers when style-compatible.

Critical checks:
- vehicle collision and road seam quality
- Streaming behavior
- distant silhouette readability
- repeated-window/material memory cost
- sidewalk scale for avatars

Avoid making an entire city from unique heavy meshes with unique PBR texture sets.

## Fantasy medieval

Potential sources:
- compact Medieval Asset Pack (`74849899553864`) as a secondary candidate.
- Sword Pack (`10226464132`) for simple static weapon prototypes.
- Layered R15 Medieval Armor (`125797252502681`) only if the paid terms/style/R15 fit justify purchase.

Priorities:
- consistent scale between weapon/armor/buildings
- readable item rarity silhouettes
- clear collision around stairs/doors/walls
- animation-compatible weapon grips

Do not let one high-detail armor pack force the rest of the game into an incompatible realism level.

## Shooter / combat

Asset procurement must be separated into:
- weapon visual
- first/third-person animation
- firing VFX/audio
- hit feedback
- combat code/netcode

Never treat a scripted gun/sword model as all four layers by default.

A combat kit can be studied in quarantine, but Godbase architecture remains server-authoritative and project-owned.

For weapons:
- prefer clean static models first
- verify Tool handles/pivots
- replace/retarget animations intentionally
- validate muzzle/attachment positions
- test mobile aim readability

## NPC / creature-heavy game

Official RO-01 (`3924232032`) is useful as an NPC Kit/animation organization reference.

For production enemies, evaluate separately:
- rig quality
- animation set completeness
- collision/hitbox geometry
- LOD/repetition cost
- AI architecture
- network ownership

A good mesh does not imply good AI, and a good AI kit does not imply a suitable mesh.

## Realistic outdoors

Potential stack:
- Roblox Forest Pack (`6432306802`)
- PBR Nature Pack (`10088225842`)
- selected Duvall landscaping/material assets

Priorities:
- foliage overdraw
- texture-memory reuse
- shadow cost
- terrain/material blending
- wind/particle density
- low-end device scene complexity

Use PBR where it materially improves the target visual; do not use unique 1K/2K texture sets on every repeated prop.

## UI-heavy games

Do not search for an entire generic UI kit and accept its visual identity blindly.

Preferred process:
1. reference-game UI analysis
2. project design tokens
3. icon/source asset search
4. component stories via UI Labs/Flipbook if useful
5. responsive desktop/mobile states
6. motion pass

UI packs are source material. The final interface should look like one authored system, not a Toolbox collage.

## VFX-heavy action/anime

Use large VFX packs as a **reference library**.

Choose effects by gameplay role:
- anticipation/telegraph
- cast/startup
- projectile/travel
- hit/impact
- lingering area
- buff/debuff state
- ultimate/hero moment

Then normalize:
- palette
- particle lifetime
- beam width
- brightness
- timing
- scale
- mobile budget

Never ship 100 unrelated effect styles simply because the pack contains them.

## Audio

Roblox documentation states Creator Store contains more than 100,000 professionally produced sound effects/music tracks from audio partners.

Search by functional layer:
- UI click/confirm/error
- footstep/material
- weapon swing/fire/reload
- hit/body/armor
- ambience/weather
- enemy vocal
- reward/progression
- music states

Record asset IDs and usage role in the project manifest. Mix and loudness consistency matter more than owning many sounds.

## Decision score for a project

Before adopting a pack, score 0–5:
- Source/provenance
- Security
- Style fit
- Visual quality
- Technical correctness
- Performance at expected repetition
- Mobile suitability
- Editability
- Documentation
- Maintenance/dependency health

Reject incompatible usage terms/security issues before scoring.

The best asset is not the highest-rated asset. It is the safest, most coherent, technically suitable asset that helps the current vertical slice look and play closer to the chosen reference quality bar.
