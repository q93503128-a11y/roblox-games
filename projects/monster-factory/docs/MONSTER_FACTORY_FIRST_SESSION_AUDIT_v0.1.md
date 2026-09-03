# Monster Factory Simulator — First Session Flow Audit v0.1

Build: MVP-005

## Intended first session

### 0:00–0:30
- Player spawns in Green Meadows.
- Factory already produces Cash into Collector.
- Onboarding says: collect Cash.
- No forced purchase prompt.

### 0:30–1:30
- First Meadow hatch is free.
- First worker auto-equips if a slot exists.
- Worker becomes visible on a factory Worker Station.
- Starter Pack recommendation may appear as a dismissible card.

### 1:30–4:00
- Player upgrades Generator.
- Repeated Collector interactions establish the manual loop.
- Auto Collect recommendation is not eligible until lifetime collected Cash reaches 5,000.

### 4:00–10:00
- Multiple Meadow hatches.
- Equip Best / fusion become understandable.
- Desert unlock target: 10,000 Cash.

### 10:00–20:00
- Desert x4 production multiplier creates a clear acceleration spike.
- Desert Capsule provides a stronger worker tier.
- Frozen target becomes visible.

### 20:00–35:00
- Frozen x16 multiplier.
- Frozen worker upgrades.
- First Rebirth target: 3,000,000 Cash.

## Monetization pacing rules

1. Never force a purchase prompt from a contextual recommendation.
2. Context recommendation has VIEW OFFER and NO THANKS.
3. Maximum one contextual recommendation per 12 minutes.
4. Generic Shop remains manually accessible at all times.
5. Free progression remains possible through all current content.

## Initial pacing judgment

The progression has a valid exponential spine:
Meadow -> Desert -> Frozen -> Rebirth.

The exact real-world minute targets remain hypotheses until Studio runtime testing.

## Test focus

During first playtest record:
- seconds to first collection,
- seconds to first hatch,
- seconds to first Generator Lv.2,
- seconds to Desert,
- seconds to Frozen,
- seconds to first Rebirth,
- number of manual collections before Auto Collect recommendation,
- whether any UI blocks movement or Hatch/Collect controls.
