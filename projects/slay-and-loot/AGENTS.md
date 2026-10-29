# Slay & Loot — project instructions
Current status: DESIGN / FOUNDATION, 2026-10-30.

- Canon: [docs/LIVE_DESIGN.md](docs/LIVE_DESIGN.md). Exact first-slice numbers/IDs: [catalog](docs/specs/first-slice.catalog.json).
- This is a persistent-world **Roblox Combat Loot Simulator**. Historical dungeon-run code/design is deprecated. Do not restore deleted runtime code or generated snapshots.
- Read [HANDOFF.md](HANDOFF.md), [PLAN.md](PLAN.md), [architecture](docs/ARCHITECTURE.md), [acceptance](docs/ACCEPTANCE.md), [asset status](docs/ASSET_SOURCES.md), and ../../knowledge/GODBASE_MANIFEST.json + related domain docs before implementation.
- User communication: Korean. Player-facing strings and internal IDs: English. No computer use; use files, Git and direct Studio MCP.
- Current Place: 121055730304610; list Studios and reverify the exact Place before any edits. Prior confirmation applies to this Place; do not ask again merely because a new turn began.
- No Studio mutations were made in the Foundation pass. Blank Edit DataModel is audited; cloud save/publish status is unknown.
- Build only the explicitly authorized next milestone. Current work prepares, rather than implements, the first slice.
- Weapon types have one persistent entry each. Same-type duplicates add XP immediately. Never introduce duplicate weapon clutter/manual fusion.
- V1 pets: one Egg, six pets, Hatch 1, three equipped slots, Equip Best. Research proposals for other hatch modes/variants are deferred.
- Five server domain modules are sufficient. Valuable state and RNG are server-owned. No client-submitted damage, price, reward or save table.
- Authored floor/spawn must survive bootstrap failure. Map hierarchy and named anchors precede parts; use placement table and avatar/gameplay-camera calibration.
- External candidates require provenance, code/dependency audit and sanitized extraction. No currently imported candidate remains; historical metadata is not current approval.
- Before staging, inspect Git status. Stage only this project. Preserve unrelated working changes.
- A design contract or mocked save test does not prove runtime, real persistence, visual quality or publication.
