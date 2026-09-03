# Quests, Objectives, Missions, and Progress Tracking

> verified: 2026-09-03

Official feature package reference:
- Feature Packages / Missions: https://create.roblox.com/docs/resources/feature-packages

Before building a large custom mission system, inspect Roblox's current official Missions package and decide whether to adopt, fork, or only learn from it.

## 1. Quest definition vs player progress

Definition:
```text
questId
title/localization key
requirements
objectives
rewards
next quest(s)
repeat policy
```

Player state:
```text
status
objective counters
accepted/started timestamp if needed
claimed flag
```

Do not duplicate full quest definitions inside every save profile.

## 2. Objective types

Common:
- defeat enemy/category
- collect item
- enter area
- interact
- craft
- complete round/dungeon
- talk to NPC
- use ability

Use typed objective definitions instead of one giant string parser.

## 3. Event-driven progress

Quest system should subscribe to trusted domain events:
```text
EnemyDefeated
ItemGranted
AreaEntered
CraftCompleted
RoundCompleted
```

Do not let client send `QuestProgress +1` as authority.

## 4. Stable semantic events

Domain event includes trusted context:
```text
EnemyDefeated {
 enemyTypeId,
 areaId,
 killerPlayerId,
 partyContribution
}
```

Quest logic decides which objectives match.

This prevents combat scripts from containing quest-specific branches.

## 5. Progress indexing

With many active quests, don't scan every quest/objective for every kill if scale grows.
Index active objectives by event/category where useful.

Prototype can be simple; optimize after real need.

## 6. Accept vs auto-start

Choose deliberately:
- explicit accept: agency/story
- auto-start: lower friction
- hidden progression: achievements/challenges

Do not make player repeatedly walk back just to click accept if it adds no value.

## 7. Claim behavior

Options:
- automatic reward on completion
- explicit claim

Explicit claim should have a product reason (choice, ceremony, UI), not just extra friction.

Claim is server-idempotent.

## 8. Quest chains/graphs

Validate:
- missing references
- impossible prerequisites
- cycles unless intentional repeat loop
- dead ends
- mutually exclusive branch policy

Graph validator belongs in CI for content-heavy RPGs.

## 9. Repeatable/daily/weekly

Time-based quests need:
- server-consistent time source
- reset period/timezone policy
- old server behavior
- no double reset/reward
- missed reset recovery

LiveOps systems may prefer official Feature Packages/current Configs.

## 10. Party/co-op progress

Define contribution:
- killer only
- nearby party
- damage threshold
- shared objective

Never assume client party membership/nearby claims are authoritative.

## 11. Item objectives

"Collect 10" can mean:
- acquire total over time
- possess 10 now
- turn in 10

These are different mechanics; define explicitly.

Turn-in consumes items atomically with reward.

## 12. Area objectives

Use authored area ID/tag/volume, server validates meaningful entry when valuable. Streaming/client trigger can inform UI but shouldn't award rare value without server state.

## 13. UI

Quest tracker:
- 1–3 pinned priorities
- clear progress
- distance/marker only when helpful
- no screen full of objectives

Quest log:
- active/completed/available
- category
- rewards
- navigation

Mobile/gamepad acceptance required.

## 14. Narrative/dialogue separation

Dialogue presentation and quest state should communicate through IDs/events but not be one inseparable script.

NPC art/dialogue can change without rewriting progression state machine.

## 15. Save migration

Persist quest IDs/status/counters. When quest definitions are removed/changed:
- legacy completion mapping
- objective migration
- compensation if needed

Do not crash old players because objective count changed.

## 16. Analytics

Track important funnel steps, not every counter tick.
- accepted
- major objective reached
- completed
- claimed
- abandoned if supported

Use questId as controlled field/category.

## 17. Security

Test:
- fake objective event
- duplicate claim
- complete locked quest
- turn in items not owned
- claim after definition changed
- party abuse from far away

## 18. Acceptance

- [ ] official Missions package inspected first
- [ ] definitions separate from progress
- [ ] domain events server-trusted
- [ ] claim idempotent
- [ ] chain graph validated
- [ ] reset policy for repeatables
- [ ] co-op contribution policy
- [ ] migration for changed quests
- [ ] UI concise/cross-platform
