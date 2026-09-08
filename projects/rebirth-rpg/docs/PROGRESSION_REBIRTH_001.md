# Progression & Rebirth 001

> status: TUNING BASELINE / VALUES NOT FINAL
> design goal: brain-off growth, obvious acceleration, low cognitive load

## 1. Progression layers

Launch target uses only these major layers:

```text
Run progression
- Level
- Gold
- normal equipment
- current region progress

Permanent progression
- Rebirth count
- Rebirth milestone unlock flags
- permanent collection/achievement records if later needed
```

Do not start with:
- rebirth currency + ascension currency + soul currency + rune currency simultaneously
- giant passive tree
- multiple prestige tiers

## 2. Rebirth fantasy

Player should feel:

```text
First run:
I am slowly opening the game.

Later run:
I already conquered this opening, so I tear through it quickly.
```

Rebirth is not intended to create a harder tactical version of old bosses.

## 3. Reset policy baseline

### Reset on Rebirth
- Level → 1
- normal Gold → reset or small carryover depending on economy test
- current region quest/progress gates → reset where needed for the run loop
- normal run-only temporary boosts → reset

### Keep
- Rebirth count
- milestone unlocks
- cosmetics
- index/collection records
- achievements
- settings
- later: explicitly marked heirloom/legacy item state only if the system proves useful

Equipment reset policy is **not final** until actual equipment flow is tested.

Avoid destroying rare player-facing items without a clear retention/conversion rule.

## 4. Automatic Rebirth benefits

Keep benefits automatic so the player does not need to manage a large tree.

Initial tuning candidate for Rebirth count `R`:

```text
XP multiplier   = 1 + 0.40 * R
Gold multiplier = 1 + 0.25 * R
Luck bonus      = min(0.02 * R, 0.20)   -- +2 percentage-point style bonus, tuning depends on loot implementation
StartPower      = 1 + 0.10 * R
```

These numbers are placeholders for playtest fitting, not final balance.

Important:
- do not apply unlimited movement-speed growth
- do not let luck make rarity meaningless
- multiplicative item/build systems need caps later

## 5. Early-content compression

Use several simple mechanisms instead of one giant multiplier.

Candidates:

```text
A. XP/Gold multipliers
B. stronger starting power
C. earlier fast-travel access
D. trivial early quest requirements reduced/removed
E. later milestone: optional starting-region skip
```

Do not enable all mechanisms at Rebirth 1.

### Target run-time compression

Design target, not a hard promise:

```text
First completion of opening segment: 100% baseline time
R1: ~70–80%
R3: ~45–60%
R5+: ~25–40%
Late milestone: trivial opening may become optional
```

The saved time must lead into newer/higher content, not just make the session shorter.

## 6. Milestone unlocks

Simple automatic milestones are preferred.

Candidate sequence:

```text
R1  → Dungeon access
R2  → Equipment enhancement/forge
R3  → next major world/continent layer
R5  → Raid access
R7  → higher equipment rarity family
R10 → one new permanent progression layer
```

These are content-planning slots, not promises that all systems ship in v1.

Only unlock a system when its underlying gameplay is ready.

## 7. Rebirth requirement

Do not rebirth from a menu after only farming a number.

Preferred understandable requirement:

```text
required level
+ final currently-required region/boss clear flag
→ Rebirth available
```

This preserves the RPG route while remaining simple.

Exact level cap waits for content scope.

## 8. Level curve philosophy

Roblox references show that very high level ceilings are acceptable, but the number itself is not the design goal.

We want:
- frequent early levels
- visible power increases
- region milestones that remain understandable
- later fast gains after rebirth

Formula selection happens after target clear times are measured.

Do not choose a pretty exponential formula first and force the game around it.

## 9. Gear power

Equipment should beat tiny stat allocation decisions for this game's target feel.

Preferred:

```text
Level raises baseline power
Equipment causes noticeable jumps
Rare/boss equipment causes exciting spikes
Rebirth raises the floor and acceleration
```

Avoid:
- every rarity being a +3% reskin
- hundreds of meaningless tiny stat rolls in first version

## 10. First production balance questions

Measure in Studio:
- Enemy A TTK with starter gear
- Enemy A TTK after first upgrade
- Enemy B TTK
- boss TTK
- minutes to first meaningful loot
- minutes to first region clear
- effective speed difference between R0 / R1 / R3 test profiles

Only after this data exists should final XP/cost formulas be fitted.

## 11. Acceptance

Rebirth system is good only if:
- player immediately understands what reset and what stayed
- next run is visibly faster within first minutes
- permanent benefits are visible in UI without reading a manual
- old content becomes shorter, not more tedious
- milestone unlock gives a real new reason to continue
- no client can award Rebirth or permanent multipliers to itself
