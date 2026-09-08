# Rebirth RPG Asset Web Prefilter 002

> verified: 2026-09-08
> scope: web / Creator Store metadata only
> IMPORTANT: this document does **not** promote any third-party asset to production.

## 0. Decision rule

Web metadata can remove obviously poor candidates, but it cannot prove Studio suitability.

Promotion remains:

```text
WEB_CANDIDATE
→ STUDIO_QUARANTINE
→ source/script/dependency audit
→ scale/pivot/collision/rig audit
→ gameplay-camera visual fit
→ mobile/performance check
→ PROJECT_APPROVED
```

The first RPG slice remains asset-first:

```text
secure coherent visual vocabulary
→ map visuals to content roles
→ design zone/enemy/item details
→ build one coherent slice
```

Do not invent a required monster/weapon roster before the visual family exists.

---

# 1. Environment visual spine

## A1 — Synty Nature Pack — STRONG WEB PREFERRED

- Asset ID: `6933438443`
- Creator: `@Roblox`
- Store: https://create.roblox.com/marketplace/asset/6933438443/Synty-Nature-Pack
- observed: free / Get Model
- rating observed: 96%, 800+ votes
- MeshParts: 200
- triangle count: 108,816
- content: trees, plants, bushes, flowers, logs, boulders, rocks, outdoor props
- store text states multiple Synty packs were officially licensed for Roblox games and share the same art style

Web decision: `WEB_STRONG_PREFERRED`
Studio decision: `NOT_TESTED`

Why it leads:
- official Roblox distribution/provenance
- coherent stylized low-poly vocabulary
- broad first-field coverage
- no reason to invent primitive production trees/rocks

Need Studio proof:
- scripts/dependencies
- representative pivots/collision
- R15 scale
- repeated foliage cost
- gameplay-camera readability

## A2 — Synty Dungeon Pack: Cave & Castle Interiors — STRONG WEB PREFERRED

- Asset ID: `6934021345`
- Creator: `@Roblox`
- Store: https://create.roblox.com/store/asset/6934021345/Synty-Dungeon-Pack-Cave-Castle-Interiors
- observed: free / Get Model
- rating observed: 97%, 700+ votes
- MeshParts: 271
- triangle count: 162,088
- content: modular castle interior, cave interior, rocks, runes, bridges, tunnels
- same stated Synty visual family

Web decision: `WEB_STRONG_PREFERRED`
Studio decision: `NOT_TESTED`

Potential first-slice role if approved:
- cave / compact dungeon section
- bridge/tunnel landmark
- later castle interior vocabulary

Do not import the full 271-part source pack into final runtime hierarchy.

---

# 2. Medieval structure / prop alternatives

## B1 — Polygon Knights Pack — COHERENT PAID HOLD

- Asset ID: `111508606283106`
- Creator: `@syntystudio`
- Store: https://create.roblox.com/store/asset/111508606283106/Polygon-Knights-Pack
- observed price: $9.99
- MeshParts: 63
- triangles: 52,800
- store metadata states no scripts included
- includes swords/polearms, shields, carts, fences, signs, statues, windows and medieval props

Web decision: `WEB_COHERENT_PAID_HOLD`
Studio decision: `NOT_PURCHASED / NOT_TESTED`

Why interesting:
- same creator/style lineage as Synty ecosystem is promising for coherence
- useful small medieval vocabulary rather than hundreds of random unrelated weapons

Do not buy until:
- free stack is visually insufficient
- preview shows clear style compatibility
- exact first-slice need exists

## B2 — Castle/Medieval Asset Pack — LARGE FREE HOLD

- Asset ID: `12007890134`
- Creator: `@Tridgery`
- Store: https://create.roblox.com/store/asset/12007890134/CastleMedieval-Asset-Pack
- observed: free / Get Model
- rating observed: 98%, 40+ votes
- MeshParts: 306
- triangles: 192,339
- description: castle/medieval village asset pack

Web decision: `WEB_LARGE_HOLD_FOR_STYLE_AUDIT`
Studio decision: `NOT_TESTED`

Risk:
- 306-part library is too large to retain wholesale
- visual match to Synty spine is unproven
- if used, extract a curated project-owned subset only

## B3 — Low Poly Medieval House Pack — OPTIONAL PAID HOLD

- Asset ID: `129929120993235`
- Creator: `@Cyphen_Studios`
- observed price: $2.99
- 10 houses + lamp post
- MeshParts: 29
- triangles: 82,751

Web decision: `WEB_OPTIONAL_PAID`

Only revisit if the safe hub needs premade exterior houses after the environment spine is approved.

---

# 3. Weapon candidates

## W1 — Sword Pack — SMALL FREE PROTOTYPE CANDIDATE

- Asset ID: `10226464132`
- Creator: `@Synrrgy`
- Store: https://create.roblox.com/store/asset/10226464132/Sword-Pack
- observed: free / Get Model
- MeshParts: 6
- triangles: 2,208
- no ratings/reviews of significance observed

Web decision: `WEB_SMALL_PROTOTYPE_CANDIDATE`
Studio decision: `NOT_TESTED`

Why useful:
- small audit surface
- enough silhouettes to test two early melee roles
- does not dictate combat architecture

Studio must check:
- grip/pivot
- R15 scale
- style fit against Synty environment
- third-person readability

If it clashes, reject the family rather than mixing six unrelated replacement swords.

---

# 4. Weapon candidates to reject/defer

## W-R1 — DemonSword 10Set combat system — REJECT FOR CURRENT ARCHITECTURE

- Asset ID: `82026628729754`
- Creator: `@Roblok_studio`
- observed price: $14.99
- MeshParts: 10
- Script Count: 111
- Animation Count: 30
- Audio Count: 60
- Tool Count: 10
- bundled full combat customization system

Decision: `REJECT_BY_ARCHITECTURE_AND_AUDIT_COST`

Reason:
- this project owns its combat/server-authority architecture
- 111 scripts is an unnecessary executable surface to obtain ten visual weapons
- avoid letting a third-party combat kit dictate the game

## W-R2 — giant generic weapon libraries — DEFER

Any 100–300+ weapon library is deferred before the first two combat styles are proven.

Reason:
- style soup risk
- huge curation burden
- content breadth before combat feel

---

# 5. Enemy / character web findings

No enemy family is production-approved.

## E-H1 — Armored Dev Monster NPC — HOLD / VISUAL FIT UNKNOWN

- Asset ID: `89665288942186`
- Creator: `@daku_okarun`
- observed price: $4.99
- triangles: 11,617
- MeshParts: 15
- Script Count: 3
- Animation Count: 27
- Tool Count: 1
- bundled detection/chase/attack AI system

Decision: `WEB_HOLD_NOT_PREFERRED`

Reason:
- paid
- bundled gameplay AI is not wanted
- visual family fit not established
- only consider as visual/rig reference after quarantine if better coherent families are unavailable

## E-R1 — legacy Goblin level 1 — REJECT

- Asset ID: `462605`
- created: 2008
- Script Count: 7
- Audio Count: 144

Decision: `REJECT_BY_LEGACY_AND_AUDIT_COST`

## E-R2 — generic Goblin 13968291587 — HOLD / LOW TRUST VALUE

- Script Count: 3
- Audio Count: 7
- no meaningful ratings/reviews observed

Decision: `WEB_HOLD`

Not enough evidence to make it the project's enemy art direction.

## Enemy search rule after web prefilter

Do **not** search for `goblin because the design document says goblin`.

Search for:

```text
one coherent fantasy enemy family
→ at least two normal-combat silhouettes
→ at least one larger elite/boss-capable silhouette
→ rig/animation feasible
→ minimal or removable executable code
→ compatible with chosen environment visual family
```

Then map actual visuals to game roles:

```text
secured small melee creature → Enemy A
secured ranged/higher silhouette → Enemy B
secured large silhouette → Boss A
```

Names/lore come after approval.

---

# 6. Current procurement decision

## Move to Studio quarantine first

1. `6933438443` Synty Nature Pack
2. `6934021345` Synty Dungeon Pack
3. `10226464132` Sword Pack

## Preview/search but do not purchase

4. `111508606283106` Polygon Knights Pack
5. `129929120993235` Low Poly Medieval House Pack

## Hold unless first three fail

6. `12007890134` Castle/Medieval Asset Pack

## Explicit reject/defer

- `82026628729754` DemonSword scripted combat pack
- `462605` legacy goblin
- giant 100+ weapon catalogs
- random individual monster mashups from unrelated visual families
- any scripted model with opaque or suspicious execution

---

# 7. Next evidence gate

No world theme, enemy names, weapon tier names or boss identity becomes canonical until Studio Asset Pass reports:

```text
source/creator
actual inserted hierarchy
script/module/local counts
requires/dependencies
selected subset
R15 scale
pivot
collision
rig/animation feasibility
texture/material health
gameplay-camera fit
performance concern
APPROVE / HOLD / REJECT
```

After that report, create `ASSET_APPROVAL_001.md` and only then design the first production zone around the approved vocabulary.
