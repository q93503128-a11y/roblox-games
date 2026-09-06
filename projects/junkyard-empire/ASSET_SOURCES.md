# Junkyard Empire — Asset Sources & Sanitation Log

> Status: No production external assets accepted yet
> Last updated: 2026-09-06

This file is the provenance and sanitation record for Creator Store / Marketplace / external visual assets used by Junkyard Empire.

The project intentionally depends on external art for production speed. Therefore this log is **mandatory**, not optional housekeeping.

---

# Rules

For every imported external asset that survives into the project, record:

- semantic asset key/name;
- source platform;
- asset ID or exact source URL;
- creator/publisher name;
- date reviewed/imported;
- intended use;
- whether code/scripts were present;
- sanitation performed;
- licensing/reuse notes if applicable;
- current status.

Status values:

- `QUARANTINED`
- `REJECTED`
- `VISUAL_ONLY_ACCEPTED`
- `DEPENDENCY_ACCEPTED`
- `REMOVED`

Unknown free-model scripts are never considered trusted merely because the model is popular.

Shared checklist:

`../../knowledge/checklists/ASSET_IMPORT_CHECKLIST.md`

---

# Sanitation checklist

Before `VISUAL_ONLY_ACCEPTED`:

- [ ] descendants inspected
- [ ] Script checked
- [ ] LocalScript checked
- [ ] ModuleScript checked
- [ ] numeric/external `require(...)` checked
- [ ] HTTP/network loader patterns checked
- [ ] InsertService/dynamic asset-loader patterns checked
- [ ] suspicious admin/backdoor objects checked
- [ ] unnecessary scripts removed
- [ ] unexpected constraints/welds reviewed
- [ ] anchors reviewed
- [ ] collisions reviewed
- [ ] pivots reviewed
- [ ] scale reviewed against R15 avatar/world
- [ ] texture/material consistency reviewed
- [ ] unnecessary lights/particles removed or bounded
- [ ] visual fit confirmed
- [ ] performance risk noted

---

# Accepted / reviewed assets

None yet.

Use the table below when assets are reviewed.

| Asset key | Source / ID | Creator | Intended use | Scripts found | Sanitation | License/reuse note | Status | Reviewed |
|---|---|---|---|---|---|---|---|---|
| _example only_ | Creator Store `ID` | creator | decorative crusher shell | yes/no | describe removals/fixes | verify source terms | QUARANTINED | YYYY-MM-DD |

Delete the example row when the first real entry is added.

---

# Preferred search categories

High-priority art categories for this project:

- scrapyard / junkyard props
- scrap piles
- wrecked cars
- tires / engines / batteries
- conveyor meshes
- industrial crusher / compactor
- furnace / smelter shell
- warehouse kit
- fences / gates
- road / concrete kit
- pallets / barrels / pipes
- forklift
- crane
- truck / dumpster
- industrial signage
- lights / warehouse fixtures

Prefer coherent asset families over randomly mixing many unrelated packs.

---

# External-code rule

If an asset contains useful gameplay code:

1. do not execute/adopt it automatically;
2. quarantine and inspect it;
3. decide whether the behavior is worth recreating in project-owned architecture;
4. if a third-party dependency is intentionally adopted, record exact source/version/license and why it is preferable to project-owned code;
5. never let a free tycoon kit silently own economy, saving, remotes or monetization.

---

# Rejected assets

Record important rejected assets too when rejection prevents rediscovery/reimport later.

| Asset/source | Reason rejected | Date |
|---|---|---|
| None yet | — | — |
