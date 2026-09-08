# Vertical Slice 001

> status: DESIGN-SHELL / WAITING FOR STUDIO ASSET INTAKE
> target playtime: 5–10 minutes

## Goal

첫 지역 하나에서 아래 루프를 실제 플레이로 증명한다.

```text
spawn
→ first enemy
→ loot
→ equip/upgrade
→ stronger encounter
→ boss
→ major reward
→ next-region / rebirth tease
```

## Content budget

Godbase Action RPG recipe 기준:
- safe hub: 1
- combat field: 1
- landmarks: 3
- normal enemies: 2 archetypes
- elite/boss: 1
- playable weapon/style: 2
- loot: 6–12
- short quests: 2
- secrets/chests: 2

단, **구체적인 적 이름/지역 미술/장비 이름은 Asset Intake 001 뒤 확정한다.**

## Gameplay simplicity

### Enemy A
- approach
- one normal attack
- hit reaction
- death/loot

### Enemy B
- same overall AI simplicity
- visibly different range/silhouette or attack cadence

### Boss A
- basic attack
- one obvious AoE
- optional charge/projectile if asset/animation supports it

No:
- phase 2
- rebirth-specific pattern changes
- puzzle mechanics
- complex status stack

## Player combat baseline

Launch slice with:
- M1/basic attack chain
- run/dash
- one weapon skill

Second style must feel meaningfully different by range/cadence/silhouette, but does not need a deep combo tree.

## Loot baseline

6–12 items total means actual gameplay roles, not 12 color reskins.

Preferred categories after asset inspection:
- 2–4 weapons
- 2–4 armor/equipment pieces
- 1–2 boss/rare pieces
- 1–2 utility/reward items if visually supported

Item naming and rarity presentation follow actual secured visuals.

## First-session economy

Only one standard spend currency is required for slice: `Gold`.

Rebirth currency is allowed as a later persistent value but does not need a full store in Slice 001.

Player must experience:

```text
kill/reward
→ receive Gold/loot
→ equip or spend
→ time-to-kill visibly improves
```

## Rebirth preview

Full rebirth loop is not required to be naturally reached within a 5–10 min slice.

But development build must expose a controlled test route for:
- meeting rebirth requirement through debug/test profile
- confirming selected run state resets
- confirming permanent rebirth count/multiplier persists
- confirming old opening becomes faster
- confirming first milestone unlock flag works

Do not create a giant rebirth tree.

## Spatial shell

Do not assign raw coordinates here.

Required semantic zones after Studio inspect:

```text
SafeHub
FirstVista
FieldA
LandmarkA
LandmarkB
DungeonOrBossApproach
BossArena
RewardReturn
```

Placement rules:
- spawn can see or infer FirstVista
- first enemy reachable in <=30 sec
- first reward in <=60 sec target
- first meaningful equip/upgrade by <=180 sec target
- boss/major reward by end of 5–10 min slice
- route must not require wandering through a huge empty field

Exact layout waits for:
- floor/terrain
- spawn transform
- avatar scale
- camera/FOV
- actual asset bounds
- first approved landmarks

## Art gate

Slice is not approved if:
- Synty/other source packs are left as uncurated dump folders in runtime world
- styles clash visibly
- house/tree/rock/weapon scale is inconsistent
- placeholder Parts remain as hero assets
- freecam looks acceptable but gameplay camera is obstructed
- imported props narrow the main route after graybox verification

## UI budget

HUD only:
- HP
- XP / Level
- Gold
- Rebirth count
- active skill input
- current simple objective

Menus needed for slice:
- inventory/equipment
- minimal stats/rebirth preview if required for test

Avoid launching with:
- battle pass
- guild
- trading
- pets
- 5 currencies
- crafting matrix
- giant skill tree

## P0 routes

### P0-01 Core RPG loop
spawn → Enemy A → loot → equip → Enemy B/elite → boss → major reward

### P0-02 Death
fight → die → respawn → equipped/progression state reconstructs correctly

### P0-03 Rebirth test profile
prepared eligible profile → rebirth → reset expected run state → permanent gain retained → first route measurably faster

### P0-04 Mobile
mobile profile → move → attack → skill → loot/equip → boss route remains playable

## Done gate

Do not call Slice 001 complete until:
- clean boot
- project-attributable unexpected runtime error 0
- normal spawn
- P0-01 passes
- P0-02 passes
- P0-03 passes
- primary mobile route works
- server owns damage/reward/equipment/rebirth decisions
- animation hit timing is acceptable
- one normal enemy is satisfying to farm repeatedly
- boss is readable without requiring study
- first upgrade is clearly noticeable
- gameplay-camera screenshots no longer look like placeholder build
- user can be asked about fun/taste rather than missing-map/basic-bug discovery
