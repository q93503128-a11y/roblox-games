# Junkyard Empire — Studio MCP Playtest Contract

> Status: Initial contract, target Studio/Place IDs pending
> Last updated: 2026-09-06

This contract defines what Codex/Studio MCP must verify before a development batch is reported as tested.

It is intentionally project-specific and supplements the shared Godbase testing guidance.

---

# 1. Studio target policy

Current exact Place/Universe IDs: **not assigned/documented yet**.

Until IDs are recorded:

1. call the Studio-listing MCP tool;
2. enumerate all open Studio instances;
3. if more than one exists, identify the intended Junkyard Empire instance explicitly before any write;
4. report the selected Studio name/ID in the work log;
5. never modify a different open project because it appeared first in a tool result.

Once TEST/LIVE places exist, record them here.

| Purpose | Universe ID | Place ID | Notes |
|---|---:|---:|---|
| Local/working | TBD | TBD | initial Studio work |
| TEST | TBD | TBD | future automated/manual validation |
| LIVE | TBD | TBD | do not use for experimental edits |

---

# 2. Clean-boot condition

A valid clean test begins from:

- Studio not currently inside an old Play session;
- expected project DataModel loaded;
- no manual runtime objects left over from prior tests;
- player profile/test state known;
- required server/client scripts enabled;
- Output cleared or old errors distinguishable from new run.

Do not count a route as passing if it only works because the developer manually created missing runtime state before pressing Play.

---

# 3. P0.1 primary route

For the first slice, MCP must attempt this exact route:

```text
Start Play
→ player spawns safely
→ player receives/claims exactly one yard
→ starter scrap exists
→ collect one or more scrap objects
→ backpack state visibly changes
→ reach unload point
→ unload accepted
→ processing feedback occurs
→ Cash increases exactly once per valid reward
→ first upgrade becomes affordable/available
→ purchase first upgrade
→ Cash decreases by canonical cost
→ upgrade appears exactly once in world
→ next collection/processing loop still works
```

The result report must say which steps were observed rather than simply saying “works.”

---

# 4. P0.1 negative/abuse checks

Where MCP/tooling permits, verify:

- collecting same scrap twice does not duplicate reward;
- invalid/nonexistent scrap ID is rejected;
- purchase with insufficient Cash fails;
- repeated activation does not buy/instantiate the same one-time upgrade twice;
- player cannot buy another plot owner's node;
- respawn does not allocate a second plot;
- backpack does not exceed canonical capacity through rapid input;
- Cash cannot become negative through purchase race.

If a check cannot be exercised through MCP, mark it `NOT AUTOMATED` rather than pretending it passed.

---

# 5. Output/error gate

During normal P0 route:

Blocking failures:

- red Lua runtime error;
- infinite-yield caused by project hierarchy mistake;
- repeated nil-index spam;
- repeated remote/server error spam;
- plot assignment failure;
- player falls/voids at spawn;
- core prompt missing/broken;
- reward/purchase route fails.

Non-blocking warnings may remain only when their cause is understood and documented.

---

# 6. Visual-state checks

P0.1 must visually verify:

- spawn and path are readable;
- junk is distinguishable from background;
- unload point is discoverable;
- first purchase pad clearly shows purpose/cost;
- purchased machine/upgrade visibly changes the plot;
- HUD Cash and backpack values are readable;
- no obvious overlapping or detached greybox parts.

Later visual passes will add stricter art requirements.

---

# 7. Device matrix

## During P0.1

- desktop Studio Play: required
- mobile-emulation/narrow viewport: basic UI sanity required when UI exists

## Before first public test

At minimum test representative:

- narrow phone portrait/touch layout where applicable;
- common phone landscape if the experience uses landscape;
- desktop 16:9;
- tablet-sized viewport;
- multiplayer server with at least 2 players.

Exact viewport matrix can be expanded when the UI baseline exists.

---

# 8. Multiplayer scenarios

Before public release, required:

1. Player A and B receive different plots.
2. A cannot trigger B's paid upgrade.
3. B leaving cleans the plot.
4. New player C can safely receive the cleaned plot.
5. shared scrap behavior remains fair/consistent.
6. friend bonus, if enabled, updates correctly when players join/leave.
7. one player's prestige/reset does not affect another's factory.

These are not required to claim only the first solo P0.1 route is working, but they are required before broader acceptance.

---

# 9. Persistence scenarios

Once persistence is introduced:

- new profile boot;
- earn Cash/buy upgrade/discover scrap;
- save/leave;
- new session/rejoin;
- state restored;
- missing/new schema fields default safely;
- schema migration when version changes;
- save failure does not silently erase known good state;
- Studio test data is separated from production as needed.

---

# 10. Monetization scenarios

Once monetization is introduced:

- Game Pass owned/not-owned paths;
- missing Product/Pass ID fails safely;
- Developer Product receipt grants once;
- receipt replay does not duplicate reward;
- purchase cancellation does not grant reward;
- UI ownership state refreshes;
- no automatic prompt loop on spawn.

---

# 11. Completion language

Use one of these patterns:

### Passed

> `P0.1 primary route MCP TESTED: spawn, plot assignment, pickup, backpack, unload, Cash award, first purchase and visible upgrade all observed. Output had no blocker errors. Abuse checks X/Y passed; Z remains human/manual.`

### Partial

> `P0.1 IMPLEMENTED but not MCP-accepted: route reaches unload, but purchase duplicates under repeated interaction.`

### Not tested

> `Implementation exists; Studio target was unavailable, so no MCP playtest was performed.`

Never upgrade `IMPLEMENTED` to `MCP TESTED` without actual observation.

---

# 12. Required post-test documentation

After a meaningful MCP validation, update:

- `ROADMAP_AND_STATUS.md`;
- `PROJECT_STATE.json`;
- README baseline if the validation changes the project's main status;
- issue/known limitation notes where appropriate.
