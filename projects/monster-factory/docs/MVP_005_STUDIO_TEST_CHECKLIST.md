# Monster Factory Simulator — MVP-005 Studio Test Checklist

This is the first build formally approved for a full user Studio playtest.

## A. Boot
- [ ] Place opens with no red errors in Output.
- [ ] Character spawns in Green Meadows.
- [ ] Meadow/Desert/Frozen environments exist.
- [ ] HUD is visible and usable.

## B. Economy
- [ ] Collector balance increases once per second.
- [ ] COLLECT moves PendingCash into Cash.
- [ ] Generator upgrade spends the correct Cash.
- [ ] Production increases after upgrade.

## C. Hatching / Monsters
- [ ] First Meadow hatch is free.
- [ ] Second Meadow hatch costs 100 Cash.
- [ ] Hatch cannot be used for locked zones.
- [ ] Hatched monster appears in Monsters.
- [ ] Equip / Unequip works.
- [ ] Equip Best works.
- [ ] Worker visual appears on a factory Worker Station.
- [ ] Worker visual moves to the current zone's factory after travel.
- [ ] Five unequipped duplicates can fuse to Shiny.

## D. Zones
- [ ] Desert unlock requires 10,000 Cash.
- [ ] Frozen unlock requires 250,000 Cash.
- [ ] Zone unlock happens only in order.
- [ ] Travel works between unlocked zones.
- [ ] Desert gives x4 zone multiplier.
- [ ] Frozen gives x16 zone multiplier.

## E. Rebirth
- [ ] First Rebirth requires 3,000,000 Cash.
- [ ] Rebirth resets Cash, Collector, Generator, zones.
- [ ] Monsters remain.
- [ ] Purchases remain.
- [ ] Rebirth count increases.
- [ ] Rebirth Token increases.
- [ ] Permanent production multiplier increases.

## F. Quests / Achievements / Rewards
- [ ] Quest progress updates.
- [ ] Completed quest can be claimed once.
- [ ] Achievement progress updates.
- [ ] Completed achievement can be claimed once.
- [ ] Daily reward can be claimed once when available.
- [ ] Playtime rewards unlock at their thresholds.

## G. Offline / Social
- [ ] Rejoin after >60 seconds grants offline earnings.
- [ ] Offline earnings are capped at 8 hours.
- [ ] Friend in same server gives +5% production.
- [ ] Friend bonus caps at +20%.

## H. Monetization UX
- [ ] Shop opens manually.
- [ ] Product IDs at 0 show DEV / configured warning instead of a real prompt.
- [ ] Context offer never auto-opens a purchase prompt.
- [ ] VIEW OFFER opens the pass prompt only when a real ID exists.
- [ ] NO THANKS dismisses the context offer.
- [ ] Context offers do not spam.

## I. Mobile / UI
Test at minimum:
- [ ] 360x640
- [ ] 390x844
- [ ] 412x915
- [ ] 768x1024
- [ ] 1280x720
- [ ] 1920x1080

Verify:
- [ ] narrow-screen responsive scaling activates,
- [ ] left/right control groups do not overlap,
- [ ] onboarding banner does not block top HUD,
- [ ] left buttons remain clickable,
- [ ] right buttons remain clickable,
- [ ] modal close buttons are visible,
- [ ] scrolling works,
- [ ] no important text overflows.

## J. Exploit sanity
Using Studio client:
- [ ] spam COLLECT,
- [ ] spam UPGRADE,
- [ ] spam HATCH,
- [ ] spam REBIRTH,
- [ ] spam zone travel/unlock,
- [ ] spam claim buttons.

Expected:
- no duplicate rewards,
- no negative currency,
- no free zone unlock,
- no duplicate Rebirth,
- no server error storm.

## Stop-test conditions

Stop immediately and report if:
- profile fails to load,
- Cash becomes negative,
- paid receipt is granted twice,
- Rebirth deletes monsters,
- zone progression corrupts,
- Output shows repeating server errors,
- UI becomes unusable on mobile.
