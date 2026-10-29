# Decisions
All entries: 2026-10-30, accepted by this Foundation specification.

| ID | Decision | Reason |
|---|---|---|
| D001 | Combat Loot Simulator; historical dungeon direction DEPRECATED | Current user direction |
| D002 | Actual simulator grammar outranks generated images | Prior completed research |
| D003 | One owned weapon entry per definition; automatic same-type XP | Main Slay & Loot identity |
| D004 | First duplicate reaches Lv.2; MAX excess becomes fixed Coins | Immediate learning; no wasted duplicate |
| D005 | One Egg / six pets / Hatch 1 / three equipped slots | Explicit first-slice scope |
| D006 | Pet bonus is additive to direct weapon damage | Simple, visible combat efficiency; no second AI |
| D007 | Coins only; personal 600-Coin Zone 2 gate | Clear next purchase; prevent shared unlock bugs |
| D008 | Shared static enemy sockets; personal participant rewards | Multiplayer farming, no last-hit theft |
| D009 | Five server domain modules + native remotes | Small maintainable slice |
| D010 | ProfileStore behind project ProfileService adapter | Session lock/autosave candidate; no raw save snippets |
| D011 | Persistence provider pinned but not integrated/tested | Foundation must not pretend to ship persistence |
| D012 | Studio + direct MCP; code files + explicit audited sync later | Keep existing Studio-first workflow; no Rojo migration |
| D013 | Existing blank Studio only inspected, not modified/published | No obsolete content remains to clean |
| D014 | Prior deletion changes are preserved and committed for this project | Earlier explicit erase request; source remains in Git history |
| D015 | No asset is currently imported/approved | Empty ServerStorage; old audit metadata is historical only |
| D016 | Auto Fight and all pet variants are deferred | Research suggestions do not expand current V1 |
| D017 | Basic manual Release for unequipped pets; capacity 100 | Avoid permanent full-storage dead end; no Auto Delete |
| D018 | Fixed first-copy Scout protection, visible in loot information | Useful early weapon without silently falsifying base odds |
| D019 | Enemy retaliation is deferred; no player-health progression | Validate attack/loot/upgrade loop first |

New product instructions supersede any earlier research proposal to build two combat zones, early Golden, Hatch 3/10 or Auto Fight. Research remains evidence, not a parallel implementation plan.
