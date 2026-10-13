# Button Layers — Live Design

Status: **accepted launch design; implementation and Studio validation pending**

## Product

Current title: **Button Layers**

Promise:

> Step on buttons, climb reset layers, automate old work, find secrets, and complete the button catalog.

Launch excludes combat, pets, mining, crafting, trading, equipment, clans, and unrelated gacha systems.

## Main progression

```text
Cash → Multiplier → Rebirth → Ultra Rebirth → Prestige → Ascension
```

Reset hierarchy:
- Rebirth resets Cash + Multiplier
- Ultra resets Cash + Multiplier + Rebirth
- Prestige resets Cash + Multiplier + Rebirth + Ultra
- Ascension resets Cash + Multiplier + Rebirth + Ultra + Prestige

Never reset lifetime records, achievements, secrets, button discovery, permanent area unlocks, or settings.

## Target pacing

| Milestone | Target |
|---|---:|
| First button | 3–8 sec |
| First Rebirth | 1.5–2.5 min |
| First Ultra | 8–13 min |
| First Prestige | 25–40 min |
| First Ascension | 90–150 min |
| Most main tree | 5–8 hr |
| Initial 100% | ~10–20 hr |

Simulation is a tuning aid, not runtime proof. Studio walking time, readability, occupancy behavior, automation and actual user input must be measured.

## Button interaction

Cost buttons:
- reusable occupancy-repeat plates
- server validates each transaction
- repeat while the player remains validly on the plate
- candidate interval ~0.35–0.55 sec, tuned in Studio

Reset buttons:
- one activation per entry
- show what is lost and gained
- tier/settings confirmation policy
- no repeated reset while standing on the plate

## Areas

### Area 1 — Foundation / Fan Court
M01–M06 + R01. Teach core loop and First Rebirth.

### Area 2 — Rebirth / Horseshoe
M07–M11 + R02–R08 + U01. Denomination acceleration and First Ultra.

### Area 3 — Ultra / Ring Court
M12–M14 + R09–R10 + U02–U04 + P01. Automation begins and First Prestige.

### Area 4 — Prestige / Split Terrace
M15–M17 + R11 + U05–U07 + P02–P04 + A01. Automation centerpiece and Ascension goal.

### Area 5 — Ascension / Crown Court
M18–M20 + R12 + U08 + P05–P06 + A02–A04. Launch endgame and completion.

Spatial acceptance:
- Spawn → first button: 2–5 sec
- consecutive useful button: 1–3 sec
- reset → useful cost row: 2–5 sec
- no meaningless straight walk >8 sec
- next target visible or spatially inferable
- secrets never block P0 or require physics exploits
- gameplay-camera readability mandatory

## Automation

Candidate progression:
- First Ultra → Quick Travel + Auto Multi
- Ultra progression → Auto Rebirth
- First Prestige → Auto Ultra + presets
- First Ascension → Auto Prestige

Automation is mastery/compression, not a separate economy.

## Meta

Launch includes:
- 48 internal Achievements
- 8 Secrets
- 50-button Collection
- Stats & Records
- major milestone Roblox Badge hooks

No Achievement or Secret gates the main path.

## UI

Persistent HUD:
- top-left unlocked Stat Stack
- top-center Objective Pill
- top-right Menu
- Quick Travel appears only after unlock

Full-screen surfaces:
- Achievements
- Collection
- Secrets
- Automation
- Stats & Records
- Quick Travel
- Settings

Do not expose all locked systems at spawn.
Responsive/adaptive layout, mobile safe areas, camera/movement thumb space and gamepad navigation matter.

## Art direction — Clean Layered Arcade

- clean stylized Roblox geometry
- matte base materials
- modular trim/bevels
- controlled emissive accents
- large readable landmarks
- no pet-simulator visual clutter
- no excessive neon

Tier language uses color + symbol + shape:
- Cash: green / coin
- Multiplier: blue / ×
- Rebirth: purple / circular reset arrow
- Ultra: cyan / double-ring or double-arrow
- Prestige: orange / star-prism
- Ascension: gold-white / upward crown/chevron

## Save/security/performance

- versioned save schema
- server-authoritative valuable state
- manual/auto share transaction functions
- no per-button Heartbeat loops
- event/dirty-driven UI affordability refresh
- centralized automation scheduling
- mobile performance baseline from early slices
