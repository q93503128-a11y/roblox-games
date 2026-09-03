# Interaction Systems — ProximityPrompt, ClickDetector, DragDetector, Tags

> verified: 2026-09-03

Official:
- ProximityPrompt: https://create.roblox.com/docs/ui/proximity-prompts
- CollectionService: https://create.roblox.com/docs/reference/engine/classes/CollectionService
- Client/server boundary: https://create.roblox.com/docs/scripting/security/client-server-boundary

## 1. Interaction is a server boundary

ProximityPrompt, ClickDetector, DragDetector are not magically trusted because Roblox created the UI/event.
Roblox security docs explicitly warn exploiters can trigger client-triggered instance events outside intended conditions.

Server must revalidate valuable actions.

## 2. ProximityPrompt strengths

Good for:
- doors
- NPC talk
- chests
- pickup/harvest
- stations
- contextual world actions

Built-in advantages:
- keyboard/gamepad/touch prompts
- hold duration
- object/action text
- exclusivity
- global ProximityPromptService handling

Do not recreate a custom `Press E` system unless design requires it.

## 3. Security specifics

Current official security notes:
- client can manipulate prompt visibility/properties locally
- `Triggered` has a server-side distance check
- other hold/end events do not provide equivalent distance trust
- ClickDetector server events have no distance protection
- DragDetector has limited built-in checks, not complete game-state validation

Therefore server action handler checks:
- expected tag/type
- Enabled state
- player alive/state
- actual server position distance
- LOS if design requires
- ownership/unlock
- cooldown/rate
- one-time/claim state

## 4. Global interaction router

Prefer a central router over scripts copied into 200 objects.

Example authoring:
```text
Tag: Interactable
Attributes:
  InteractionId = "chest_basic"
  Radius = 10
  RequiresQuest = "quest_01" optional
```

Server router:
```text
prompt triggered
→ identify tagged model
→ lookup interaction definition
→ validate
→ execute domain service
```

## 5. CollectionService

Tags are serialized and server tags replicate. CollectionService is useful when many instances share behavior.

Use:
- Interactable
- DamageZone
- SpawnPoint
- QuestNPC
- HarvestNode
- ShopTerminal

Handle both:
- existing `GetTagged()` objects
- `GetInstanceAddedSignal()`
- `GetInstanceRemovedSignal()` cleanup

Streaming can unload/reload client instances, so client behavior registration must tolerate lifecycle changes.

## 6. Attributes

Attributes are useful authored configuration:
- stable IDs
- visual variant
- interaction parameters
- spawn group

Do not store secrets or trust client-modified replicated attributes for authoritative reward decisions.

Server may use server-known attributes on authored objects as configuration, while player-supplied claims remain untrusted.

## 7. Interaction ID > object name

Use stable IDs instead of display names/path assumptions.

Good:
`InteractionId = "forge_blacksmith_01"`

Bad:
`if part.Parent.Name == "Cool Blacksmith FINAL"`

This survives art renames/hierarchy cleanup.

## 8. UI state

Prompt should communicate:
- object
- action
- unavailable reason when useful

Don't show a prompt that always fails after input.
Possible:
- hide/disable when clearly unavailable
- contextual label `Requires Level 10`

Still validate server-side.

## 9. Hold interactions

Hold is useful for deliberate actions:
- revive
- capture
- long harvest

But don't treat hold duration as security. Server needs its own state/timing validation for valuable channelled actions.

## 10. Multi-player contention

For chest/node/lever used by multiple players, define:
- shared vs per-player
- reservation/lock
- respawn
- simultaneous trigger resolution

Authoritative server state prevents duplicate reward.

## 11. Interaction lifecycle

An interaction can disappear mid-action because:
- streaming
- destruction
- round reset
- another player uses it

Handler should validate instance still exists/eligible at commit time.

## 12. Mobile/gamepad

Built-in prompt system already adapts input. Custom prompt UI must preserve:
- touch target
- current binding
- gamepad selection/context
- safe screen space

## 13. Distance

Use server character/root position and interaction anchor/pivot.
For large models define a meaningful interaction attachment rather than model center.

## 14. Rate limits

All server-triggered interactions have maximum sensible frequency.
Examples:
- chest claim once
- door toggle 2/s
- shop request low rate

Rate limiting also protects expensive DataStore/clone/API work.

## 15. Acceptance

- [ ] built-in prompt considered before custom UI
- [ ] server distance/state validation
- [ ] ClickDetector not trusted for distance
- [ ] hold events not trusted as elapsed-time proof
- [ ] stable interaction IDs
- [ ] tags lifecycle handles streaming/add/remove
- [ ] duplicate reward impossible
- [ ] simultaneous players tested
- [ ] touch/gamepad works
