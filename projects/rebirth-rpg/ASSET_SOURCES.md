# Rebirth RPG Asset Sources

> verified web metadata: 2026-09-08
> production status: NONE PROMOTED YET

이 문서는 `discovery`와 `production-approved`를 구분한다.

웹/Creator Store 페이지를 찾았다는 이유만으로 production asset이 아니다.

Promotion flow:

```text
WEB_CANDIDATE
→ STUDIO_QUARANTINE
→ SOURCE/SCRIPT/DEPENDENCY REVIEW
→ SCALE/PIVOT/COLLISION/RIG REVIEW
→ VISUAL FIT
→ MOBILE/PERFORMANCE CHECK
→ PROJECT_APPROVED
```

## A. Preferred visual spine

### A1. Synty Nature Pack

- Asset ID: `6933438443`
- Creator: Roblox
- Creator Store: https://create.roblox.com/marketplace/asset/6933438443/Synty-Nature-Pack
- Price observed: free / Get Model
- Metadata: trees, plants, bushes, flowers, logs, boulders, rocks, outdoor props
- Store statement: Roblox officially licensed multiple Synty packs for use in Roblox games; Synty packs share the same art style.
- Web status: `WEB_PREFERRED`
- Studio status: `NOT_TESTED`

Planned use if approved:
- first outdoor field vocabulary
- rocks/trees/foliage
- route framing and landmarks

### A2. Synty Dungeon Pack: Cave & Castle Interiors

- Asset ID: `6934021345`
- Creator: Roblox
- Creator Store: https://create.roblox.com/store/asset/6934021345/Synty-Dungeon-Pack-Cave-Castle-Interiors
- Price observed: free / Get Model
- Metadata: modular castle interior, cave interior, rocks, runes, bridge/tunnel sections
- Web status: `WEB_PREFERRED`
- Studio status: `NOT_TESTED`

Planned use if approved:
- first dungeon/cave
- later castle/interior vocabulary
- bridge/tunnel transitions

### Why A1 + A2 lead

- official Roblox provenance
- same stated Synty art family
- free
- broad enough for field + dungeon slice
- avoids AI-created primitive production art

This does **not** prove scale, pivot, collision or actual Studio suitability.

## B. Secondary coherent candidates

### B1. Polygon Knights Pack

- Asset ID: `111508606283106`
- Creator: `@syntystudio`
- Creator Store: https://create.roblox.com/store/asset/111508606283106/Polygon-Knights-Pack
- Price observed: `$9.99`
- Metadata observed: 63 assets, no scripts; swords/polearms, shields, props, windows, signs, carts, statues, water-wheel pieces, texture variants
- Web status: `WEB_OPTIONAL_PAID`
- Studio status: `NOT_TESTED`

Reason to consider:
- creator/style lineage is likely easier to reconcile with Synty baseline than unrelated packs
- useful medieval prop/weapon vocabulary

Do not purchase/adopt before Studio preview and actual need.

### B2. Sword Pack

- Asset ID: `10226464132`
- Creator: `@Synrrgy`
- Creator Store: https://create.roblox.com/store/asset/10226464132/Sword-Pack
- Price observed: free / Get Model
- Metadata: 6 MeshParts, 2,208 triangles total
- Web status: `WEB_PROTOTYPE_CANDIDATE`
- Studio status: `NOT_TESTED`

Use only if silhouette/style fits approved environment.

### B3. Castle/Medieval Asset Pack

- Asset ID: `12007890134`
- Creator: `@Tridgery`
- Creator Store: https://create.roblox.com/store/asset/12007890134/CastleMedieval-Asset-Pack
- Price observed: free / Get Model
- Metadata: 306 MeshParts; 98% rating observed; described as castle/medieval village pack
- Web status: `WEB_HOLD_FOR_STYLE_AUDIT`
- Studio status: `NOT_TESTED`

Potential use:
- exterior village/castle vocabulary if it visually matches the chosen spine.

Risk:
- large pack; must extract only needed pieces.

### B4. Low Poly Medieval House Pack

- Asset ID: `129929120993235`
- Creator: `@Cyphen_Studios`
- Creator Store: https://create.roblox.com/store/asset/129929120993235/Low-Poly-Medieval-House-Pack
- Price observed: `$2.99`
- Metadata: 10 houses + lamp post; 29 MeshParts; ~82.7k triangles total
- Web status: `WEB_OPTIONAL_PAID`
- Studio status: `NOT_TESTED`

Only consider if first safe hub actually needs premade exterior houses and style matches Synty baseline.

### B5. Low Poly Mine Asset Pack

- Asset ID: `83935977466934`
- Creator: `@Cyphen_Studios`
- Creator Store: https://create.roblox.com/store/asset/83935977466934/Low-Poly-Mine-Asset-Pack
- Price observed: `$2.99`
- Metadata: mine doorway, rails, carts, bridges, fences, crates and mining props; 56 MeshParts
- Web status: `WEB_OPTIONAL_PAID`
- Studio status: `NOT_TESTED`

Only consider if approved first-region vocabulary naturally supports a mine/cave route.

## C. Rejected / avoid for current slice

### C1. 380 Sword Weapons Pack

- Asset ID: `74460973127629`
- Reason not preferred now:
  - 380 weapons is massive over-supply before combat style is proven
  - large VFX/style diversity risks asset soup
  - paid
- Status: `DEFER`

### C2. Script-heavy generic medieval weapon sets

Example IDs discovered:
- `135295813892129`
- `129593909818956`

Observed:
- scripts included
- 268 MeshParts
- ~504k triangles

Status: `REJECT_BY_OPPORTUNITY_COST_FOR_SLICE`

We can obtain a safer, smaller weapon vocabulary first.

### C3. Nature Pack Studs Trees Bush Grass Flower

- Asset ID: `82060619904561`
- Status: `REJECT/HOLD`
- Reason: recent Creator Store reviews observed during Godbase research explicitly alleged backdoor/virus behavior.

Do not insert into a trusted place.

## D. Enemy/character status

No enemy pack is production-approved yet.

Current policy:
- do not invent a mandatory goblin/wolf/orc roster first
- inspect approved environment source packs for any usable character/creature assets
- if none, search Creator Store from Studio for a **coherent rigged family**, not random individual monsters
- prefer visual-only/low-script rigs
- if scripts exist, quarantine and strip gameplay code before adoption
- require idle/walk/attack/hit/death animation feasibility

Candidate `89665288942186` (Armored Dev Monster NPC) was discovered but is **not preferred** because it bundles gameplay AI scripts and its visual fit is not established.

## E. VFX status

No production VFX pack selected.

Rule:
- first implement combat role and timing
- then pick/normalize only needed effects: swing trail, impact, loot/reward, boss telegraph
- no 100-effect style soup

## F. Required Studio report before promotion

For every candidate actually inserted:

```text
asset id
creator
source URL
script/local/module count
dependencies / requires
model count / selected subset
pivot correctness
avatar-relative scale
collision behavior
material/texture health
rig type if character
animation compatibility
visual-family fit
mobile/performance concern
APPROVE / HOLD / REJECT
```
