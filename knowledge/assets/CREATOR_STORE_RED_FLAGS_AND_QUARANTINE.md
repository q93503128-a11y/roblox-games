# Creator Store Red Flags and Quarantine

> verified: 2026-09-04

Creator Store is useful because it contains millions of reusable assets, but the supply chain is mixed. Treat search results as untrusted input until inspected.

## Hard rule

Never insert a third-party scripted model directly into a trusted production place.

Use:

`search/web/API discovery → quarantine place → source/dependency scan → visual/technical inspection → sanitized extraction → project-specific playtest`

## Immediate reject or hold signals

### Security reports in reviews

A strong rating does not cancel specific backdoor/virus reports. Example discovered during this sweep: asset `82060619904561` showed an 89% aggregate rating while recent reviews explicitly alleged backdoor/virus behavior. This is a reject until independently disproven in an isolated environment.

### Opaque bulk model

Generic names such as `free`, no useful description, dozens of scripts, large audio/decal/tool dependency surfaces, and no provenance are not worth auditing when better alternatives exist.

Example: asset `17300868459` exposed 56 scripts, 53 mesh parts, 18 decals, 17 audio assets, and over 500k triangles under the title `free`. Godbase policy is reject-by-opportunity-cost, not curiosity-driven insertion.

### Search-keyword spam

Descriptions packed with unrelated trending game names/keywords are a trust-quality signal. They do not prove malware, but they indicate poor curation and ranking manipulation. Prefer better-provenanced assets.

Example: asset `84153348982194` had unrelated trending-keyword spam and no useful rating history.

### Broken dependency reports

High-quality visual packs can still be unusable if texture/audio dependencies disappear. Example: Synty City Pack reviews repeatedly reported removed textures. Keep such assets on HOLD until current Studio insertion proves the dependencies resolve legally and reliably.

### Excessive script surface

Script count is not a verdict, but it predicts review cost.

- 0 scripts: lower code risk; still inspect dependencies and instances.
- 1–3 scripts: targeted review.
- 4–20 scripts: medium kit audit.
- 20+ scripts: quarantine/high review cost.
- 50–100+ scripts: source-library treatment unless the project explicitly needs the whole system.

Official Roblox packs can also contain many scripts. Official provenance reduces supply-chain uncertainty but does **not** make every script appropriate for the current architecture.

## Script scan checklist

Inspect every Script, LocalScript, ModuleScript and executable package path for:

- numeric or remote `require(...)` patterns
- `HttpService` calls
- runtime asset/model insertion
- obfuscation, encoded payloads, huge meaningless strings
- unexpected DataStore/Open Cloud/Marketplace calls
- admin command injection
- remote-event handlers that trust client values
- hidden scripts under meshes, tools, accessories, effects or descendants
- code that reparents/duplicates itself
- unusual `GetService` combinations unrelated to the asset purpose

Do not rely only on keyword scans. Read execution flow and test behavior in quarantine.

## Review-signal weighting

Useful signals:
- concrete bug reports with reproducible details
- multiple independent security reports
- current dependency failures
- creator responses/fixes
- exact setup problems

Weak signals:
- meme reviews
- generic praise/hate
- aggregate rating without review detail
- raw vote count

A single detailed security report can outweigh hundreds of generic positive votes until verified.

## Official Roblox assets

Roblox itself publishes high-quality packs and developer modules. These are preferred discovery sources because provenance is stronger and official docs often explain intended use.

Still inspect because:
- examples may target older engine assumptions
- demo scripts may not match current architecture
- entire packs can be too large
- scripted showcase behavior can be unnecessary
- textures/materials may need project normalization

## Large-pack extraction

Never treat a 500–1800 mesh source library as one production asset.

1. Insert into quarantine.
2. Identify only the required models.
3. Remove demo scripts, cameras, spawn points and presentation scaffolding.
4. Normalize pivots, names, collisions, attributes and materials.
5. Move approved assets into a project-owned package/folder.
6. Record original Creator Store asset ID and creator.
7. Benchmark repeated use on target mobile hardware/settings.
8. Keep the original source pack outside the shipped runtime hierarchy.

## Paid assets

Price is not a quality signal. Before purchase:
- check screenshots/reviews/technical details
- read explicit usage restrictions
- compare strong free/official alternatives
- estimate audit cost
- confirm the art style matches the project
- confirm needed rig/R6/R15/device support

Do not buy giant packs because they appear to solve future unknown problems.

## Plugins

Plugins receive Studio capabilities rather than just runtime presence. Test unknown plugins on an expendable source-controlled place. Prefer built-in Studio tools or reputable/open-source plugins when possible.

An old Creator Store plugin can also be obsolete even if published by Roblox. Example: the old Roblox Animation Editor listing explicitly says not to install it and to use Studio's built-in Animation Editor.

## Promotion rule

No third-party asset becomes `S` from web metadata alone.

Promotion requires:
- provenance/terms cleared
- scripts/dependencies cleared
- visual inspection
- pivots/collisions/rig correct
- repeated-use performance test
- mobile test
- art-direction fit
- clean production extraction

Only then can an asset move from `WEB_*` to canonical `S/A/B` production status.
