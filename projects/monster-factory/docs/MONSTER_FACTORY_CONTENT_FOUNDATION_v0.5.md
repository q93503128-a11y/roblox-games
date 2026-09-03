# Monster Factory Simulator — Content Foundation v0.5

Build: MVP-004

## Newly implemented

### Onboarding
5-step onboarding:
1. collect factory Cash,
2. first hatch,
3. activate a worker,
4. generator upgrade,
5. unlock Desert.

The system derives progress from canonical player state.
It does not keep a second copy of progression.

### Offline earnings
- max 8 hours
- 25% base efficiency
- VIP adds +10 percentage points
- credited on join before the live economy loop resumes

### Worker visuals
Active workers are represented client-side as lightweight colored orbs attached around the player.
This is a placeholder visual layer only; gameplay does not depend on the visual objects.

### Achievements
7 achievements with deterministic rewards.

### Monster index
Free-play monsters are tracked as discovered based on owned inventory.
Exclusive paid monster is excluded from free collection completion.

### Friend bonus
+5% production per friend in the same server.
Maximum +20%.

### Contextual monetization
Server-driven contextual offers:
- Starter Pack after first hatch,
- Auto Collect after collection pressure,
- Extra Equip under worker-slot pressure,
- Bigger Storage near capacity.

One context offer maximum per 12-minute cooldown.
Offers remain dismissible.

### Analytics contract
Server event names are now centralized and structured.
MVP-004 currently logs to output instead of sending to an external provider.

## Content-foundation status

The system foundation is now broad enough that future content can be added without redesigning the core architecture.

Core layers now exist for:
- economy,
- collection,
- factory upgrades,
- zone progression,
- rebirth,
- quests,
- rewards,
- achievements,
- onboarding,
- offline progression,
- social bonus,
- monetization,
- analytics,
- worker visual representation.

However, **I am still not declaring the project ready for the user's full playtest yet.**

One more consolidation milestone is recommended before that handoff:
- active worker visuals should be moved from player orbit to factory stations,
- basic machine/zone art differentiation,
- developer product / pass IDs integration checklist,
- anti-exploit audit across every Remote,
- end-to-end content flow audit,
- final first-session pacing check.

Recommended next build:
MVP-005 — pre-test consolidation.
