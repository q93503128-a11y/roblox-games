# Rebirth RPG — Studio Asset + Animation Quarantine Result 001

> date: 2026-09-09
> source: actual Roblox Studio Agent quarantine inspection
> status: PARTIAL APPROVAL / TWO BLOCKERS BEFORE PRESENTATION IMPLEMENTATION

## Weapon findings

Original Sword Pack `10226464132` was rejected by Studio inspection:
- raw MeshParts only
- no textures
- no Handle/grip/PrimaryPart/weapon structure
- unsuitable as direct production weapon source

Alternative found:
- Medieval Weapons Pack `101295938004405`
- creator: RenderFixX
- 12 structured multi-part weapons
- bundled scripts removed during quarantine
- colored MeshParts, no texture dependency required for the selected silhouettes

Approved visual candidate A:
- Longsword
- readable third-person silhouette
- coherent low-poly medieval style
- needs Handle/grip setup before runtime use

Agent also approved a Dagger candidate, but this should NOT automatically map to `weapon_start_b` because the current gameplay config makes Weapon B slower, longer-reach and substantially stronger than Weapon A. A dagger visually communicates the opposite role. Re-select a heavier/longer upgrade silhouette from the same pack unless gameplay stats are intentionally remapped.

## Animation findings

Animation pack inspected in Studio:
- pack ID `139029962127334`
- creator/source reported as Turbo8LMaster4176
- KeyframeSequences `SwordSlice_1_Dummy`, `SwordSlice_2_Dummy`, `SwordSlice_3_Dummy`
- about 0.73–0.75 s each
- R15 full-body sword-compatible motions
- visually coherent as a 3-hit chain
- HumanoidRootPart is animated, so root-motion drift must be neutralized or handled

Critical limitation:
- these are KeyframeSequences, not published production Animation asset IDs
- they cannot yet be treated as final production animation references

A second animation pack (`R15SwordSwingAnimation`, ID `85682205036912`) contained embedded scripts and remained HOLD after cleanup due uncertain quality.

## Current blockers

1. Weapon B visual-role mismatch: Dagger vs current slow/long/strong Weapon B gameplay role.
2. No approved published AnimationId path yet for the 3-hit chain.
3. Selected weapon models still need Handle/grip/attachment preparation.
4. Root-motion handling is required for the selected sword animations.

## Decision

Do not start production map work yet.

Next Studio task should be intentionally narrow:
- choose a same-family heavy/long Weapon B silhouette from Medieval Weapons Pack
- secure an actual published R15 sword animation asset direction, or establish a safe owner-publishing workflow for the approved KeyframeSequences
- confirm Handle/grip strategy and root-motion treatment

After those two blockers are resolved, begin one coherent presentation implementation section: controls + visible equipped weapon + attack animation + first active skill presentation, then inventory/HUD.
