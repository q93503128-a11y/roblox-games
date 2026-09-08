# Studio Agent Asset Pass 001

> purpose: inspect and secure the visual vocabulary before gameplay/world implementation
> do not one-shot build the RPG in this pass

Copy/use this task with Roblox Studio Assistant/Agent.

---

## GOAL

Create an **asset intake / quarantine scene only** for Rebirth RPG.

The goal is to determine which actual environment, weapon, enemy/character, armor and minimal VFX assets are suitable for the first 5–10 minute RPG Vertical Slice.

Do NOT build the final map yet.

## CURRENT CONTEXT

Game direction:
- common Roblox fantasy action RPG
- intentionally brain-off farming/progression
- kill → XP/Gold/loot → equip → stronger area → boss → rebirth
- Rebirth accelerates early progression and unlocks content
- boss patterns remain simple; no rebirth-specific phase redesign
- art/content design must follow secured assets rather than invented requirements

Canonical project docs:
- `projects/rebirth-rpg/README.md`
- `projects/rebirth-rpg/ASSET_SOURCES.md`
- `projects/rebirth-rpg/docs/DESIGN_BASELINE_001.md`
- `projects/rebirth-rpg/docs/VERTICAL_SLICE_001.md`

Godbase:
- `knowledge/PROJECT_AI_INSTRUCTIONS.md`
- `knowledge/assets/CREATOR_STORE_RED_FLAGS_AND_QUARANTINE.md`
- `knowledge/assets/ASSET_SELECTION_BY_GENRE.md`
- `knowledge/level-design/AI_MAP_BUILDING_PLAYBOOK.md`
- `knowledge/workflow/ROBLOX_ASSISTANT_AGENT_WORKFLOW.md`

## DO NOT CHANGE

- Do not create a final world.
- Do not write/replace the RPG progression architecture.
- Do not create 20+ enemies/items just to increase content count.
- Do not use random primitive Parts as final enemy/weapon/building art.
- Do not keep third-party gameplay scripts just because they came with a model.
- Do not import giant packs wholesale into the production hierarchy.
- Do not buy paid assets automatically.

## REFERENCE / STYLE

Desired broad visual family:
- stylized low-poly fantasy
- clean silhouette at third-person combat distance
- not neon/anime-VFX soup
- not realistic PBR medieval mixed with low-poly nature
- not childish toy proportions unless the whole approved family consistently supports it

Preferred starting candidates:

1. Synty Nature Pack — `6933438443`
2. Synty Dungeon Pack: Cave & Castle Interiors — `6934021345`

Secondary preview candidates only if needed:
3. Sword Pack — `10226464132`
4. Castle/Medieval Asset Pack — `12007890134`

Do not purchase these without human approval:
- Polygon Knights Pack — `111508606283106`
- Low Poly Medieval House Pack — `129929120993235`
- Low Poly Mine Asset Pack — `83935977466934`

Reject/avoid:
- `82060619904561`
- giant scripted generic packs when safer alternatives exist

## PASS 0 — INSPECT CURRENT STUDIO

Before importing anything, report:
- current place/DataModel state
- whether this is a clean/new place
- existing Workspace children
- existing Lighting/camera setup
- existing player spawn
- existing scripts/packages

If this place contains unrelated verified project content, STOP instead of contaminating it.

## PASS 1 — QUARANTINE STRUCTURE

Create an isolated inspection structure such as:

```text
Workspace
└─ _AssetQuarantine
   ├─ Environment
   ├─ Weapons
   ├─ Characters
   ├─ Armor
   ├─ VFX
   └─ ReferenceRig
```

Place an R15 reference avatar/rig beside major assets for scale review.

Do not make this the final map hierarchy.

## PASS 2 — ENVIRONMENT INTAKE

Inspect Synty Nature and Synty Dungeon first.

For each pack:
- confirm actual creator/source shown by Studio
- count Script / LocalScript / ModuleScript descendants
- identify external dependencies / requires if any
- inspect representative trees/rocks/foliage
- inspect representative cave/castle/bridge/tunnel modules
- check pivots
- check collision behavior
- compare scale to R15 rig
- inspect textures/materials for missing/broken dependencies
- inspect gameplay-camera readability
- identify a curated subset sufficient for one hub/field/dungeon slice

Do not retain every source asset in the future production world.

## PASS 3 — WEAPON INTAKE

Inspect Sword Pack `10226464132`.

Need at least two candidate silhouettes that can plausibly become two early play styles.

Check:
- grip/pivot
- visual scale on R15
- number of MeshParts
- scripts/dependencies
- whether silhouettes are readable at gameplay camera distance
- whether style clashes with Synty baseline

Do not design weapon stats yet beyond noting plausible roles such as `fast/short` vs `slow/long`.

If the free pack is visually incompatible, mark HOLD/REJECT and search Creator Store for one small coherent alternative family. Do not assemble unrelated individual weapons.

## PASS 4 — ENEMY / CHARACTER DISCOVERY

First inspect whether approved environment/source packs already contain any usable character/creature rigs. Do not assume they do.

If not:
- search Creator Store for a coherent fantasy enemy family
- prefer one creator/style family with at least 2 normal-enemy silhouettes and 1 larger elite/boss-capable silhouette
- prefer rigged assets with no gameplay scripts or minimal removable scripts
- inspect idle/walk/attack/hit/death animation feasibility
- verify R15/custom rig type and Animator/Humanoid arrangement

Do NOT lock names such as goblin/orc/wolf until the actual approved family is known.

For scripted NPC assets:
- quarantine only
- inspect every executable script
- never inherit bundled AI architecture into production by default
- extract visual/rig/animation material only if safe and useful

## PASS 5 — ARMOR / PLAYER VISUALS

Do not invent an armor taxonomy.

Search/inspect only enough to answer:
- can we visually show early equipment progression without style mismatch?
- are there 2–3 coherent player equipment looks or layered R15 pieces available?
- do they fit blocky R15 avatars?
- do they clip during basic locomotion/combat?

If good armor is not available, report that and leave armor visuals for a later pass. Do not fill the gap with low-quality custom Parts.

## PASS 6 — MINIMAL VFX SOURCE

Only find enough visual material for:
- weapon swing/trail
- hit impact
- loot/reward burst
- obvious boss AoE telegraph

Prefer consistent simple effects.

No large effect library should be dumped into runtime hierarchy.

## REQUIRED REPORT FORMAT

Return an intake table:

```text
category
asset id
creator
candidate subset
script counts
dependency notes
pivot/scale
collision
rig/animation status
visual fit
performance concern
APPROVE / HOLD / REJECT
reason
```

Then give:

```text
APPROVED VISUAL VOCABULARY
- environment
- structures
- enemies
- weapons
- player equipment
- VFX

MISSING VOCABULARY
- what the first slice still lacks

PROPOSED CONTENT MAPPING
- only after approval, map secured visuals to Enemy A/B, Boss A, Weapon Style A/B, SafeHub/Field/Dungeon roles
```

## ACCEPTANCE CRITERIA

This pass succeeds when:
- no unrelated project content was modified
- at least one coherent environment family is visually inspected
- 2 usable early weapon silhouettes are identified OR explicitly reported missing
- 2 normal enemy + 1 boss-capable visual family is identified OR explicitly reported missing
- suspicious scripts/dependencies are not silently accepted
- representative assets are seen beside R15 scale reference
- no final map is claimed complete
- all approvals are evidence-based from Studio

## TEST ROUTE

This is not a gameplay test.

Visual inspection route:

```text
ReferenceRig
→ environment subset
→ structure subset
→ weapon lineup
→ enemy lineup
→ armor lineup
→ VFX lineup
```

View each important candidate from approximate third-person gameplay camera distance, not only freecam close-ups.

## STOP CONDITIONS

STOP and report instead of continuing if:
- current Studio place belongs to another verified project
- an imported asset contains suspicious/opaque execution behavior
- dependencies are broken
- scale/pivot is severely inconsistent and would require destructive re-authoring
- no coherent asset family can support the requested category
- a paid purchase is required to proceed

Do not solve a missing category by lowering the visual quality bar without approval.
