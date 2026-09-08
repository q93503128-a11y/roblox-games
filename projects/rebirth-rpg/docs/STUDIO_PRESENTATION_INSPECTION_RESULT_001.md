# Rebirth RPG — Studio Presentation Inspection Result 001

> date: 2026-09-08
> source: actual Roblox Studio Agent read-only inspection of `REBIRTH_RPG_PHASE0_EMBEDDED_TEST_UNVERIFIED_2026-09-08.rbxlx`
> status: PRESENTATION GAP CONFIRMED / READY FOR ASSET+ANIMATION QUARANTINE

## Confirmed current state

- current test place boots cleanly with the expected RebirthRPG staged logs
- current Output contains no project-attributable errors or warnings in the inspected state
- StarterGui is empty at edit time; all current UI is created at runtime by `ClientBootstrap`
- only client script is `StarterPlayerScripts/RebirthRPG/ClientBootstrap`
- current HUD is explicitly an internal/debug presentation, not a production RPG UI
- there is no inventory grid, item icon system, equipment-slot UI, tooltip, rarity presentation, boss UI, skill cooldown UI, or custom health-bar system

## Input findings

- M1 -> `AttackIntent`
- Q -> unbound
- E -> `SkillIntent`
- R -> `RequestRebirth`
- number keys 1–4 -> unbound
- default Roblox Backpack UI is not explicitly disabled, but there are no Tool instances, so it is effectively unused

## Equipment / weapon findings

`weapon_start_a` and `weapon_start_b` currently exist only as data/config/profile state.

Confirmed absent:
- Tool instances
- Handle parts
- weapon Models
- Attachments for weapon sockets
- character-side visual reconstruction on equip

Equipping Weapon B only updates server profile/equipped state and client UI state. It does not visually change the character.

## Animation findings

No combat presentation animation system exists.

Confirmed absent:
- Animation instances
- AnimationTrack references
- attack animation loading
- swing animation playback

Current combat is server hitbox/damage logic without visible attack motion.

## Enemy / boss presentation findings

- smoke enemies are runtime R15 debug dummies
- no project custom enemy health bar
- only transient player-screen damage feedback exists
- Smoke Boss is primarily distinguished by larger scale/position and higher config stats
- no dedicated boss HP bar, intro, boss visual treatment, or arena presentation exists

## Inventory findings

Server inventory ownership/equipment state exists, but player-facing inventory presentation does not.

Current visible equipment flow is only a debug text state and conditional `Equip Weapon B` button.

## Rebirth findings

- production-facing access is currently bound directly to R
- no dedicated Rebirth screen
- no reset/retain/bonus/milestone preview
- no confirmation modal
- Studio test hooks exist for fast eligibility but are not exposed through a clean test UX

## Human test evidence incorporated

Direct human Play-test already established:
- boot works
- non-Rebirth core routes generally work
- Weapon B reward/equip state works
- Rebirth was not directly tested because natural leveling was too slow
- presentation was judged unacceptable as a player-facing RPG slice

## Decision

The server core is not the immediate bottleneck.

Next work should target one coherent presentation recovery path:

1. inspect and approve two coherent weapon visuals
2. inspect and approve a free/audited R15 melee animation direction
3. remap controls around M1/Q/E/1 and remove production R Rebirth bind
4. build a real persistent HUD + inventory/equipment presentation
5. visually reconstruct equipped weapon on character
6. add custom enemy/boss health presentation and reward feedback
7. add Rebirth menu + confirmation + Studio-only fast eligibility route

Do not begin production map construction until this presentation route is credible and replayed in Studio.
