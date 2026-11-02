# Asset sources / availability

## BASELINE_HISTORY
Historical candidates recorded in commit 58746a05d609e3e061c5acba72e1eaaa760240d2:
- Synty Dungeon / SyntyDungeon_Q: Creator Store 6934021345, 271 MeshParts, 0 scripts observed, QUARANTINED, HISTORICAL / ABSENT
- Goblin King / Goblin_Q: Creator Store 13557888509, 75 BaseParts, 57 Motor6D, 0 scripts observed, CANDIDATE then, HISTORICAL / ABSENT
- Baseplate_Original: former quarantined original Part, HISTORICAL / ABSENT

These models were removed by earlier erase request. Git preserves audit metadata, not binaries.

## CURRENT_STUDIO_STATE
Current Studio contains Build 1 candidate visuals:
- Slime visual: Creator Store 1223370964, Firefan102 — CANDIDATE_IN_STUDIO, not approved
- Rusty Sword visual: Creator Store 394537937, s2Theronks2 — CANDIDATE_IN_STUDIO, no scripts observed, not approved
- Environment Trees/Fence: Creator Store 68938776, williamsboys — CANDIDATE only, ~280 descendants, not promoted

## TECHNICAL_PLACEHOLDER
- Prior primitive Slime/Sword/UI were placeholders; candidate visuals now partially replace them
- Structural Greenvale parts are blockout, not production art

## CANDIDATE_IN_STUDIO
- Slime and Rusty Sword candidate visuals are present in Studio
- Environment candidate remains in ServerStorage

## AUDITED_CANDIDATE
- Rusty Sword: no scripts observed after insert
- Slime: simple part candidate
- Environment: not yet audited for production use

## APPROVED_PRODUCTION
- None

## REJECTED
- None newly rejected in this pass

## PROCUREMENT ORDER
Roblox official → verified Package → audited Creator Store → approved permissive external/internal → custom

## PROMOTION GATE
Discovery → metadata triage → quarantine audit → script-free visual extraction → ApprovedAssets → camera/rig/dependency/mobile test
No free-model damage, rewards, remotes, persistence, purchases, or ownership code enters project authority.

## NOTE
Current Studio object state is NOT durably saved in Git. A local .rbxl backup was reported but not found at the stated path during this pass.
