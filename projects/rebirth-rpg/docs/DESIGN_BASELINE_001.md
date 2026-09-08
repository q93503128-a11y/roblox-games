# Design Baseline 001

> date: 2026-09-08
> status: canonical preproduction direction

## 1. Player fantasy

강한 설정 설명 없이도 바로 이해되는 Roblox 판타지 RPG.

플레이어는:
- 몹을 빠르게 잡고
- 눈에 띄게 강해지고
- 더 좋은 장비를 얻고
- 새 지역으로 이동하고
- 보스를 잡고
- 일정 진행 후 환생하여
- 이전 구간을 더 빠르게 돌파하고
- 새 시스템/지역을 연다.

핵심 감정은 `공략 성공`보다 **성장 속도와 드랍 기대감**이다.

## 2. Complexity budget

이번 게임은 intentionally simple하다.

### Keep simple
- 일반 몹 AI
- 퀘스트 문법
- 보스 패턴
- 빌드 선택
- 환생 규칙
- 지역 진입 조건

### Polish instead
- 공격 반응성
- hit timing
- hit sound / VFX / damage feedback
- 몹이 죽을 때의 보상감
- loot rarity readability
- 장비 교체 체감
- 지역 도착 순간의 시각적 보상
- 이동 속도와 사냥 cadence

## 3. Reference extraction

### Blox Fruits
Official page checked 2026-09-08:
https://www.roblox.com/games/2753915549/Blox-Fruits

Observed public description:
- swords / powers as parallel combat progression
- tough enemies + boss battles
- sailing between areas
- hidden secrets
- current page advertises level cap 2800

Use:
- very long numerical progression is acceptable
- region progression can stay easy to understand
- multiple combat equipment/ability sources can coexist

Do not copy:
- fruit/IP/theme
- exact island structure
- exact UI/progression values

### Dungeon Quest
https://www.roblox.com/games/2414851778/Dungeon-Quest-RPG-Adventure

Observed:
- repeated dungeon clear
- boss at the end
- rare armor/weapons
- class identity
- co-op

Use:
- short repeatable reward loop
- boss chest/loot climax
- rarity chase

### World // Zero
https://www.roblox.com/games/2727067538/World-Zero-Anime-RPG

Observed:
- quests
- dungeons
- bosses
- class unlocks
- lots of loot
- multiple worlds
- pets/guilds/accessories

Use now:
- visible quest target
- loot quantity/readability
- region/world milestones

Defer:
- guilds
- battlepass-like breadth
- pet system until core loop proves itself

### Swordburst 3
https://www.roblox.com/games/11523257493/Swordburst-3

Observed:
- quests / levels
- dungeons / raids
- boss progression
- rare loot
- 7 world floors
- mounts for faster travel

Use:
- later regions can represent a major chapter/floor/world milestone
- movement upgrades help old content compress

### SHADOVIS RPG
https://www.roblox.com/games/9585537847/SHADOVIS-RPG

Observed:
- loot + purchased gear
- 7 realms
- weapon-specific special moves
- permanent XP power-up collectibles

Use:
- permanent progression can coexist with resets
- weapon silhouette can imply one simple special action

### Voxlblade
https://www.roblox.com/games/8651781069/Voxlblade

Observed:
- simple sword upgrades into evolutions
- light/heavy/block/run/weapon-art controls

Use:
- selected gear can visibly evolve instead of only increasing numbers
- do not implement deep combat input at the start

## 4. Combat baseline

Target: easy PvE farming, not soulslike combat.

Initial player verbs:
- basic attack chain
- dash/run
- 1 simple weapon skill or active ability

Possible later verbs only after slice:
- heavy attack
- second/third skill
- block

Boss baseline:
- readable basic attack
- one obvious area attack
- optionally one charge/projectile

No rebirth-specific phase rewrite.

Boss scaling primarily:
- HP
- damage
- reward
- rarity table

## 5. Rebirth baseline

Rebirth exists to make the game faster and wider, not tactically deeper.

Permanent effects candidates:
- XP multiplier
- Gold multiplier
- small loot luck multiplier
- higher starting stats
- early-region fast travel
- reduced/auto-completed trivial early objectives

Unlock examples:
- first dungeon
- equipment enhancement
- new continent/world
- raid
- higher rarity tier
- later permanent growth axis

Do not launch all of these at once.

### Rebirth rule

```text
Rebirth N
→ reset selected run progression
→ permanent multiplier / convenience gain
→ old opening takes less time
→ at milestone N, one new content layer unlocks
```

No giant rebirth skill tree in the first production version.

## 6. Progression readability

Primary visible numbers:
- Level
- HP
- Damage/Power summary
- Gold
- Rebirth count

Avoid launching with:
- 5+ currencies
- 10 independent upgrade trees
- gear score + power score + combat rating all at once

First session must contain:
`reward → spend/equip → noticeable power gain`.

## 7. Asset-first world rule

World/enemy/item names stay provisional until Studio asset intake.

Allowed before asset validation:
- `SafeHub`
- `FieldA`
- `DungeonA`
- `EnemyA/B`
- `BossA`
- `WeaponSetA/B`

Forbidden before asset validation:
- demanding exact creature silhouettes that no approved rig supports
- inventing 20 armor sets before visuals exist
- designing a biome whose required props are not available

After asset validation:
```text
approved visual vocabulary
→ enemy taxonomy
→ item taxonomy
→ biome/theme names
→ encounter placement
→ loot table
```

## 8. First 30 sec / 3 min / 10 min

### 30 sec
- movement understood
- first enemy visible/reachable
- no long tutorial dialog

### 3 min
- first loot equipped or first meaningful upgrade
- player knows where the next stronger enemy/area is

### 10 min
- field loop completed
- elite/boss defeated
- noticeable power difference from spawn
- next area/rebirth path teased

## 9. Scope gate

Do not build Region 2 until:
- first basic attack feels good
- one enemy dies satisfyingly
- loot is readable and equippable
- boss is understandable
- first field has production-quality art direction
- spawn → enemy → loot → upgrade → boss route passes in Studio
- desktop/mobile primary controls work
