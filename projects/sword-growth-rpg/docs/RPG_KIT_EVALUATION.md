# Sword Growth RPG — RPG Kit Evaluation

Status: PRE-PRODUCTION DECISION SUPPORT
Date: 2026-10-26

## Confirmed project decisions added during this review

- Default game language: **English**.
- Player death has no progression penalty.
- On death, the player respawns at the **starting town** rather than the latest regional checkpoint.
- Healing fountains are a standard world element and can restore players without charging gold.

## Candidate lineage reviewed

### Evercyan's RPG Kit V2

Publicly documented features include:

- simple click-and-hit melee weapons
- ranged weapon support
- armor
- custom backpack/hotbar
- buy/sell shops
- simple mob AI with damage, respawn, animation, drops and ragdoll support
- portals
- level doors
- healing fountains
- melee auto-align
- basic saved levels/gold/items

The published V2 release line dates to 2023. Community reports after release include inventory/item duplication complaints and some EXP/Gold reward problems, so it should not be adopted blindly as production architecture.

### Florence RPG Kit

Florence is a 2026 successor built on the Evercyan -> modified Evercyan lineage. Publicly advertised additions include the base kit features plus systems such as enchanting, reforging, advanced dialogue, multiple shop types, mob/item indexes, and ongoing extensions. PvP and further mob behavior were also announced as development directions.

Florence is the preferred **first audit candidate** because it is the more current lineage, but its extra systems are not automatically desirable for Sword Growth RPG.

## Fit against Sword Growth RPG

### Strong fit / likely reusable

- click/tap melee foundation
- basic melee hit detection / auto-align if it feels good on desktop and mobile
- simple chase-and-attack mob framework
- mob death/respawn framework
- health bars / damage feedback if visually acceptable
- healing fountain implementation
- portal implementation
- level-gate concept, adapted to current **sword level** rather than a generic character level
- basic persistence scaffolding if it can be replaced or hardened without fighting the kit
- mobile-compatible interaction/UI pieces that pass project QA

### Must be replaced or heavily adapted

- generic player level/EXP system -> **uncapped sword level** with project formulas
- generic damage progression -> sword base attack + sword-form milestones + rebirth bonuses + cumulative effects
- generic kill rewards -> project rule: Gold and Sword EXP only from kills, with **5% max-HP damage contribution** for shared credit
- generic death/respawn -> always return to starting town, no progression loss
- generic portal gates -> permanent portal purchase plus current sword-level entry requirement
- generic HP progression -> Health Training + aura multiplier
- generic PvP -> project toggle/combat-lock rules and preserved power disparity
- generic data schema -> project save schema for sword level/EXP, gold, rebirth, permanent effects, portal/fast-travel unlocks, aura state, records, settings

### Remove / do not build around by default

Sword Growth RPG currently does **not** need the kit's conventional RPG breadth:

- armor progression
- equipment loot loop
- conventional backpack/inventory as a core system
- buy/sell item shops
- enchanting
- reforging
- classes
- ordinary quest reward loops
- randomized/cycle/weighted shops
- item index unless later content actually needs one

Keeping these just because the kit contains them would increase UI, save-data and bug surface without supporting the core fantasy.

## Recommended adoption strategy

Do **not** let a third-party RPG kit become the design authority.

Use this workflow:

1. Import the current Florence RPG Kit into a separate quarantine/test place.
2. Inspect every Script/LocalScript/ModuleScript and external dependency before project use.
3. Confirm current source/usage terms and record asset/model IDs.
4. Run the kit unchanged enough to understand its real contracts: melee, mob AI, respawn, fountain, portals, UI, save flow.
5. Build one small test route: starting town -> healing fountain -> 1 hunting field -> normal mob -> boss -> portal/level gate -> death -> starting-town respawn.
6. Test desktop and mobile input, repeated deaths, repeated mob respawns, two-player shared combat, and save/rejoin.
7. Keep only the subsystems that are actually useful. Disable/remove armor, inventory/loot, shops, enchanting, reforging and other unused systems rather than leaving dormant code.
8. Replace progression and reward logic with Sword Growth RPG's project-owned rules before adding content breadth.
9. Treat retained third-party systems as project-owned audited code after adaptation; do not rely on automatic upstream updates without regression testing.

## Current recommendation

**Use Florence RPG Kit as the first implementation scaffold/audit candidate, not as a turnkey game template.**

The strongest reason is that Sword Growth RPG deliberately resembles a classic/simple Roblox RPG in interaction structure. The kit already covers several boring-but-important foundations—melee, simple mobs, portals, healing fountains, mobile handling—while the project's unique part is its sword-growth/rebirth/effect progression.

The largest risk is inheriting too much conventional RPG architecture. The project should therefore keep the kit's reusable infrastructure and replace or remove its progression/inventory/economy assumptions.

If Florence proves tightly coupled, unstable, insecure, or difficult to strip down during Studio audit, fall back to extracting only the useful concepts/components from Evercyan/Florence and implement the project's smaller custom core instead.

## Acceptance gate before committing to the kit

The kit is not approved as the project base until a Studio audit verifies:

- clean boot
- no unexplained runtime errors
- no suspicious/hidden scripts or network dependencies
- melee works reliably on desktop and mobile
- mob chase/attack/death/respawn is stable across repeated cycles
- player death returns to starting town correctly after adaptation
- healing fountain works predictably
- portal/level gate can be adapted to sword level and permanent portal ownership
- two players damaging one mob can support project-owned contribution accounting
- unused inventory/armor/shop systems can be removed without breaking core combat/mobs
- save schema can be safely replaced/hardened
- no kit behavior prevents server authority over valuable progression

Until those pass, status remains **CANDIDATE / NOT PRODUCTION-APPROVED**.
