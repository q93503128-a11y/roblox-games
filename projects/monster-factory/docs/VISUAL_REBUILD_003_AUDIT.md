# Monster Factory — Visual Rebuild 003 Audit

Date: 2026-09-03
Status: CODE COMPLETE / STUDIO VISUAL VERIFICATION PENDING

## Scope

Visual Rebuild 003 focused on two weak presentation areas exposed by the first Studio smoke test:

1. equipped workers were still represented as colored spheres,
2. the 3D factory did not clearly communicate where the player should Hatch, Collect or Upgrade.

## Worker character layer

Canonical file:
`src/StarterPlayer/StarterPlayerScripts/WorkerCharacters.client.lua`

Behavior:
- observes the existing `ClientWorkerVisuals` presentation folder produced from authoritative worker state,
- converts each short-lived placeholder orb into a richer local character model,
- does not alter inventory, production, equipment slots or rewards,
- rebuilds safely when the authoritative worker folder is replaced after equip/unequip/zone travel,
- removes stale animation entries automatically when old models disappear.

Implemented visual families:
- slime / sandling,
- mushroom,
- bee,
- wolf / jackal / ice wolf,
- golem,
- scarab,
- mummy-style humanoid,
- sphinx,
- snowball,
- penguin,
- yeti,
- frost dragon,
- starter factory bot.

Presentation:
- rarity-colored nameplate,
- displayed production bonus,
- shiny highlight + halo,
- small idle bob and turn motion,
- all worker geometry is client-only, anchored and non-colliding.

Known architectural note:
- the original `ClientBootstrap` still creates a short-lived orb before the visual renderer converts it.
- the orb is destroyed by the renderer and is not retained as the visible canonical worker.
- a later client-controller split may remove that handoff entirely; do not add additional orb-based presentation code.

## In-world interaction layer

Canonical file:
`src/StarterPlayer/StarterPlayerScripts/WorldInteractionGuide.client.lua`

Current-zone anchors:
- `Generator`
- `Collector`
- `<Zone>CapsuleMachine`
- `ZoneMarker`

Added behavior:
- compact BillboardGui labels above the factory anchors,
- Generator subtitle shows level and next upgrade cost,
- Collector subtitle shows pending Cash,
- Capsule subtitle shows hatch price or first-hatch-free state,
- Generator ProximityPrompt -> existing `RequestUpgrade`,
- Collector ProximityPrompt -> existing `RequestCollect`,
- Capsule ProximityPrompt -> existing `RequestHatch`,
- Worlds ProximityPrompt -> opens the existing Zones window.

Prompt safety:
- only prompts in the current logical zone are enabled,
- all state-changing actions still pass through the existing server RemoteEvents,
- existing server rate limits / currency checks / zone checks remain authoritative,
- no client script directly mutates Cash, monsters, upgrades, unlocks or Rebirth data.

Roblox engine contract checked against current Creator Hub documentation:
- ProximityPrompt supports keyboard/gamepad/touch interaction,
- zero HoldDuration provides immediate activation,
- ClickablePrompt is a supported property.

## External art compatibility

Visual Rebuild 003 does not make gameplay depend on procedural worker geometry.

Future sanitized art can replace:
- worker body presentation,
- machine shells,
- environment props,
- UI decorative art.

Do not replace:
- server Remote validation,
- static logical anchor names,
- worker-slot attributes,
- data/economy authority.

Per-zone Creator Store environment art still belongs under each zone's `ExternalArt` folder.

## Studio verification checklist for the next visual test

Do not run this until the next bundled test point.

- [ ] no red errors during boot,
- [ ] no legacy root Baseplate / SpawnLocation,
- [ ] new 002 static world is present,
- [ ] first free hatch creates a character worker rather than a lasting orb,
- [ ] equip/unequip refresh does not leave duplicate workers,
- [ ] worker moves to the current zone after travel,
- [ ] shiny worker gets visible shiny treatment,
- [ ] Generator/Collector/Capsule/Worlds guides appear only in current zone,
- [ ] keyboard E prompt works,
- [ ] clicking prompt works on PC,
- [ ] touch prompt remains usable on mobile emulation,
- [ ] world interaction actions produce the same result as HUD buttons,
- [ ] no duplicate reward/currency changes when rapidly alternating HUD and world prompts.

## Stop conditions

Stop the test and fix before further art intake if:
- worker models multiply after every state update,
- an old zone keeps active interaction prompts after travel,
- a client prompt bypasses server costs or unlock rules,
- a worker renderer error prevents the rest of the client HUD from loading,
- world labels obscure the camera at ordinary play distance.
