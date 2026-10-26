# Sword Growth RPG — Live Design

This file records decisions explicitly accepted in design discussion. Exact balance numbers remain tunable through playtest, but the structural rules below are canonical until changed deliberately.

## 1. Identity

- Game title: **Sword Growth RPG**.
- Main fantasy: keep growing one sword rather than constantly replacing equipment through a conventional loot system.
- The game can be simple and grind-oriented; it does not need high-complexity action-RPG combat.
- Long-term goal: become stronger than other players, reach 50 rebirths, then continue through post-50 endgame such as an Endless Tower.

## 2. Sword progression

- Sword level has **no maximum level**.
- Kills are the only source of sword EXP.
- Current provisional next-level EXP formula:
  - `RequiredEXP(L) = 25 + 5L + L^2 / 50`
- Current provisional base sword attack formula:
  - `BaseAttack(L) = 10 + 2L + L^2 / 200`
- Sword appearance changes at milestones chosen **after inspecting real sword assets**.
- Milestones should follow visual power progression rather than arbitrary equal level spacing.
- Reaching a new sword appearance milestone also grants a noticeable attack-power jump so that the new form feels stronger, not merely cosmetic.
- Typical milestone bonus target: roughly +10% to +25% depending on how large the visual jump is. Exact values are asset- and playtest-dependent.
- On rebirth, sword level and current sword form reset to the beginning.

## 3. Combat

- Primary attack: click/tap to swing.
- No combo system.
- No attack-speed stat planned as a core progression axis.
- Most enemies simply detect, approach, stay close, and attack the player.
- Bosses do **not** require bespoke combat patterns by default.
- The game should prioritize growth and farming over pattern-reading action combat.

## 4. Monster roles

Official role categories:

- Normal mob
- Boss
- World Boss
- Event mob
- Event Boss

Do not force MMO-style Normal/Enhanced/Elite tiers into the game.

- Normal mobs and bosses may vary freely in HP, damage, size, movement, reward, and respawn behavior.
- Respawn time is **per-monster data**, not a rigid rule based on category.
- A boss may respawn quickly; a rare normal mob may respawn slowly.
- World Bosses are server-scale cooperative targets and can use server-wide announcements when appropriate.
- Event mobs/bosses reuse the same basic combat architecture unless an event specifically needs something else.

### Shared-kill reward eligibility

- A player must deal at least **5% of the monster's maximum HP** as direct damage to qualify for kill rewards/kill credit.
- Qualified players receive full eligible rewards; last-hit ownership is not required.

## 5. Rewards

- **Gold comes only from kills.**
- **Sword EXP comes only from kills.**
- Ordinary quests that pay gold/EXP are not part of the design.
- Effect-unlock objectives/quests exist only to unlock permanent effects or stat bonuses, not to function as routine EXP/gold quests.

## 6. Permanent cumulative effects

- Unlocked effects are permanent and **all stack simultaneously**.
- There is no effect-slot limit and no need to choose one effect over another.
- A late-game sword may simultaneously burn, poison, chain lightning, lifesteal, deal AoE, improve gold gain, etc.
- Effect unlock design is intentionally deferred until regions/assets/content are clearer.

Effect families may include:

- stat increases
- offensive special effects
- survival effects
- conditional effects
- economy/convenience effects

Examples are not a frozen catalog.

### Visual controls

Players must be able to control visuals without disabling gameplay effects:

- own weapon-effect visuals on/off
- other players' weapon-effect visuals on/off
- aura visuals on/off
- other players' aura visuals on/off
- optional reduced-VFX quality mode can be added if needed

Gameplay effects remain active even if their visuals are hidden.

## 7. Rebirth

- Maximum normal rebirth count: **50**.
- Rebirth requirement depends only on current sword level.
- Requirement rises regularly with each rebirth.
- Current accepted requirement rule:
  - target rebirth `R` requires sword level `100 × R`
  - 1st rebirth: Lv.100
  - 10th: Lv.1000
  - 50th: Lv.5000
- Rebirth resets:
  - sword level to Lv.1
  - sword EXP to 0
  - current sword appearance progression
  - health training to 0
  - gold to 0
- Rebirth does **not** erase:
  - rebirth count
  - permanent rebirth bonuses
  - unlocked cumulative effects/stat unlocks
  - permanently purchased portals
  - permanently purchased eligible fast-travel points
  - aura unlocks/appearance options
  - records/settings

### Rebirth bonuses

Current accepted baseline:

- attack: +20% per rebirth
- sword EXP gain: +15% per rebirth
- gold gain: +10% per rebirth
- critical chance: +2 percentage points per rebirth
- attack range: +1% per rebirth, no extra cap beyond the 50-rebirth system
- movement speed growth is provided through the rebirth/aura progression and increases by +1 WalkSpeed per rebirth until rebirth 20

Roblox base WalkSpeed assumption: 16.

Thus the current intended speed progression is:

- R0: 16
- R10: 26
- R20+: 36

### Critical overflow

- Critical chance can exceed 100% mathematically.
- Actual critical probability is capped at 100%.
- Any amount above 100% converts into extra critical damage instead of being wasted.

## 8. Aura system

- Aura visual forms will be selected after inspecting real usable assets.
- Aura progression represents rebirth-based player power, especially survivability/movement growth.
- Aura grants HP scaling and movement-speed progression rather than rebirth directly presenting itself as a raw HP bonus.
- Players can equip the appearance of any aura they have unlocked without losing the statistics of their highest/current progression.
- Players can hide their aura entirely while retaining its stats.
- Visual aura selection and mechanical aura power must be separate systems internally.

Exact HP multipliers and aura milestones are not frozen yet.

## 9. Health training

- Health Training is the primary repeatable gold sink.
- Presented fiction: the player trains their body/HP rather than directly buying HP as a bare stat.
- No hard Health Training level cap.
- Baseline starting HP: 100.
- Current baseline gain: +20 max HP per Health Training level.
- Health Training resets to 0 on rebirth.
- Aura HP multiplier remains through rebirth because aura/rebirth progression is permanent.
- Training cost increases continuously to create a soft cap rather than a hard cap.
- Current provisional cost formula:
  - `NextTrainingCost(T) = 100 × (T + 1)^2`
- Bulk purchase controls should exist, e.g. +1 / +10 / +100 / MAX, so late-game retraining is not repetitive clicking.

## 10. Economy

Current gold uses:

1. Health Training — repeatable, resets each rebirth through the training reset.
2. Permanent portal unlocks.
3. Permanent fast-travel unlocks for appropriate hubs/services.

Do not force artificial gold sinks merely to create more systems.

Not currently desired as standard gold sinks:

- directly buying sword levels
- directly buying sword attack
- temporary EXP/gold buffs
- ordinary cosmetic purchases with gold
- conventional equipment enhancement/repair systems

### Healing

- Healing does not need to cost gold.
- World objects such as fountains, shrines, or equivalent recovery points can restore players.

## 11. World and region progression

- Major hunting areas are gated by **current sword level**, not rebirth count.
- On rebirth, high-level regions naturally become unavailable again because sword level returns to 1.
- A permanently purchased portal remains purchased, but its destination still checks the current entry requirement.
- Exact hunting-area level intervals must be calculated later from actual monster EXP, kill time, and rebirth EXP multipliers.
- Do not freeze equal level gaps before the economy is simulated/playtested.
- The world may combine connected fields and portal-separated areas.

### Portals

- First unlock can cost gold.
- Once purchased, a portal remains permanently unlocked across rebirths.
- Current sword-level entry requirements still apply.

### Fast travel

- Fast-travel unlocks are permanent.
- Current destination entry requirements still apply.
- Fast travel should mainly serve towns, hubs, major services, and appropriate landmarks.
- Do **not** place convenient fast travel directly into ordinary hunting spots in a way that deletes traversal/progression.

## 12. PvP

- PvP can be toggled on/off.
- Only appropriate PvP-enabled players can damage each other.
- Once a player deals or receives PvP damage, they enter combat state.
- PvP cannot be turned off while in combat state.
- Baseline combat-state timeout target: 10 seconds after the last PvP hit; tune through testing.
- Safe zones can disable PvP.
- Death clears combat state.
- Growth disparity is intentional:
  - a veteran should be able to one-shot a sufficiently weak player
  - a new player may be unable to meaningfully damage a veteran with huge HP
- Do not normalize PvP damage to a target's max HP.
- Do not equalize players by level/rebirth.
- Use a global PvP damage coefficient if needed only to tune overall fight speed while preserving relative power.
- Current starting coefficient target: `PvPDamage = FinalDamage × 0.25`.
- Percentage-max-HP effects or similarly scaling effects may require separate PvP limits so they do not bypass intended progression disparity.

## 13. Death

- No meaningful death penalty.
- Do not remove sword EXP, permanent effects, or progression as punishment for dying.

Exact respawn/healing location behavior will be decided with the world layout.

## 14. Endgame

- Rebirth 50 is the end of the normal rebirth ladder, not the end of character growth.
- Sword level remains uncapped.
- Post-50 content should be designed separately after the core loop works.
- Current leading endgame idea: **Endless Tower** with increasingly strong enemies and personal/server/global records or similar competitive progression.
- Exact tower rules and rewards are not frozen.

## 15. Asset-driven decisions intentionally deferred

Do not prematurely freeze these before real asset inspection:

- sword milestone levels and exact sword catalog
- sword names
- aura forms and exact aura HP multipliers
- region themes and exact map count
- detailed effect catalog and unlock conditions
- boss appearances
- production UI skin

Use audited Roblox assets/packages where they improve speed and quality, then adapt exact design milestones to what is actually available rather than forcing placeholder art into a prewritten catalog.
