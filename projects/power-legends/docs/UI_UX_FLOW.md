# POWER LEGENDS — UI / UX Flow Specification

> Status: IMPLEMENTATION-READY INFORMATION ARCHITECTURE
> Date: 2026-10-01
> Visual style is NOT invented here.
> Codex must research current high-quality Roblox references and derive the final visual system while preserving this information hierarchy.

---

# 1. UX goals

1. First action is discoverable without reading a tutorial wall.
2. Training UI appears only while training.
3. PvP controls are immediately usable but do not cover mobile view.
4. Pets/Rebirth/Shop are easy to reach without permanent button clutter.
5. Important milestones feel rewarding without full-screen spam.
6. User always understands:
   - how strong they are,
   - what they can do now,
   - what becomes available next.

---

# 2. Persistent HUD

Normal exploration state:

## Top / primary economy strip

- Strength
- Gems
- Rebirth count

One dominant stat:
**Strength**

Gems/Rebirth visually secondary.

## Health

- hidden or minimal outside combat if readability is better
- clearly visible during combat/PvP

## Objective

Short contextual objective only.

Examples:

- Lift 25 Strength
- Try the Bench Press
- Claim your first Pet
- Reach 20,000 Strength to Rebirth

Never show a permanent quest log during the first session.

---

# 3. Primary menu

Use one compact menu entry or a small, coherent button stack.

Core destinations:

- Pets
- Rebirth
- Moves
- Stats
- Shop

Secondary surfaces:

- Rewards
- Codes
- Settings
- Collection

Secondary surfaces must not compete with primary loop during onboarding.

---

# 4. First-session UI reveal

## 0–90 sec

Show:
- Strength
- first objective
- training prompt/context

Hide/de-emphasize:
- Rebirth details
- deep Shop
- Collection
- Codes
- multiple rewards surfaces

## 1.5–5 min

Introduce:
- Pets
- free first hatch
- equipped slot result

## 3–10 min

Introduce:
- PvP HP/context
- Moves
- Brawl notice

## Later first run

Introduce:
- Rebirth preview
- deeper Shop
- collection aspiration

---

# 5. Training flow

World:
approach machine/weight.

Prompt:
binding-aware interaction.

On enter:

- character aligns
- normal movement/combat controls suspend appropriately
- Training Context UI appears

Training Context UI:

- current weight
- gain per rep
- next weight or recommended target
- heavier/lighter controls if needed
- Auto Train state if available
- Exit

Important:
Do not require:
`Menu → Training → Machine → Start`.

World interaction must be primary.

## Weight change

Fast flow:
- one or two taps/clicks
- visible required Strength if locked
- no confirmation modal for normal weight changes

## Too heavy

Show:
- brief failed effort animation
- “Requires X Strength”
- next-goal feedback

Do not silently do nothing.

---

# 6. Pet flow

## First Pet

Milestone completion
→ clear reward prompt
→ egg reveal
→ hatch animation
→ Pet card
→ Equip CTA
→ immediately see Training bonus change.

No inventory tutorial wall.

## Pets screen

Primary hierarchy:

1. equipped slots
2. owned Pets grid
3. selected Pet detail
4. collection progress

Pet card:
- icon/model
- rarity
- training bonus
- equipped state

Do not show 10 minor stats.

## Hatch

Before free/gameplay hatch:

- cost
- possible rarity/outcome info where appropriate
- current Gems
- hatch button

Animation:
- skip/fast option after first experience
- repeated hatch should not waste time

Paid-random path is not part of initial design.

---

# 7. Rebirth flow

Before eligibility:

Rebirth screen shows:
- required Strength
- progress
- permanent reward preview
- next content unlocked

When eligible:
- Rebirth button becomes visually clear
- no repeated popup every few seconds

Confirm modal must state:

```text
RESET:
Strength / Toughness / Agility

KEEP:
Pets / Gems / purchases / collection

GAIN:
Rebirth +1
Training multiplier
Next Gym unlock
```

After confirm:
- short milestone presentation
- return to playable state quickly
- objective immediately points to accelerated first action / new Gym

---

# 8. PvP UX

## Entering PvP area

Safe → PvP transition should be readable through world + small UI cue.

Examples:
- boundary treatment
- short “PvP Enabled” contextual toast
- health visibility

Do not force confirmation every time.

## Target feedback

When hitting/targeting another player:
- health
- readable name
- optional relative threat cue
- impact feedback

Avoid giant permanent nameplates for every player.

## Death

Fast flow:
- death cause/attacker short info
- respawn countdown short
- no progression-loss scare
- respawn shield indicator

## Repeated victim

No need to explain anti-farming system loudly.
If KO reward becomes zero, small feedback:
“Reduced reward: repeated target.”

---

# 9. Move controls

Desktop:
- basic attack + 2 clear move bindings

Mobile:
- large enough action buttons
- avoid blocking right-side camera manipulation
- attack/move buttons grouped coherently

Gamepad:
- binding-aware prompts if supported in slice

Moves screen:
- owned/unlocked
- short role
- unlock requirement
- cooldown

No skill tree in first slice.

---

# 10. Brawl flow

## Announcement

Top-center/context surface:

```text
BRAWL IN 30s
[JOIN]
```

Does not interrupt training with a full-screen modal.

## Joined

- status changes to joined
- player can continue normal activity until transfer/start

## Match HUD

Show:
- timer
- score/placement
- HP
- moves

Hide:
- irrelevant economy/menu clutter

## Result

Short podium/result:
- placement
- KOs
- Gems/Fame gained

Return quickly.

---

# 11. Shop UX

Shop should not be the first thing a new player sees.

Categories:

- Popular / Recommended
- Training
- Pets / Convenience
- VIP
- Boosts
- Cosmetics

Every item clearly displays:
- benefit
- permanent vs timed
- owned state
- duration if timed
- price

No:
- fake discount timers
- fake limited stock
- accidental purchase button placement
- purchase spam after every milestone

Initial products should correspond to real friction players already understand.

---

# 12. Milestone feedback

Use three tiers.

## Minor

Example:
+Strength / small weight unlock.

Feedback:
- number
- sound
- small UI motion

## Major

Example:
Body Stage / first Pet / Move unlock.

Feedback:
- centered but short banner
- world/character visual change
- stronger sound

## Meta

Example:
Rebirth / new Gym.

Feedback:
- short cinematic-quality presentation
- immediate return to control

Not every unlock gets confetti/full-screen VFX.

---

# 13. UI design system requirements

Codex must research 3–5 current high-quality Roblox games before visual implementation.

It must record:

- HUD density
- panel shape/radius
- typography hierarchy
- icon treatment
- rarity language
- button states
- modal size
- animation timing
- mobile adaptation

Then define project tokens:

```text
spacing
radius
font roles
surface roles
text roles
semantic states
rarity states
motion durations
stroke/shadow rules
```

Do not copy one reference pixel-for-pixel.

---

# 14. Responsive states

Minimum verification:

- small phone
- common modern phone
- tablet
- 1280×720
- 1920×1080

Primary action must remain usable.

No critical controls:
- under Roblox system UI
- off safe area
- too small for touch
- covered by giant body/player model

---

# 15. UX test routes

## Route A — new player

spawn
→ train
→ heavier weight
→ first Pet
→ equip
→ inspect next goal

## Route B — PvP

leave safe zone
→ punch player
→ take damage
→ use Move
→ die
→ respawn
→ shield expires

## Route C — Brawl

announcement
→ join
→ start
→ score
→ end
→ reward
→ return

## Route D — Rebirth

reach requirement
→ inspect reset/keep
→ confirm
→ respawn/reset
→ verify multiplier
→ enter newly unlocked content

## Route E — purchase

open Shop
→ inspect product
→ prompt
→ cancel
→ prompt
→ purchase test entitlement
→ loading/owned state
→ no duplicate grant

---

# 16. UI failure conditions

Stop content expansion if:

- first player asks “what do I press?”
- Training UI obscures animation
- mobile attack buttons cover camera use
- Shop appears more important than training
- Pet screen requires too many taps for equip
- Rebirth reset/keep information is ambiguous
- Brawl popup interrupts normal play repeatedly
- Body size causes critical HUD/world prompt occlusion
- same action has different button language on different screens
