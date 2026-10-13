# Button Layers — Content Catalog

Status: accepted launch content. Exact numeric balance is Studio-tunable through `data/BALANCE_CONFIG.json`.

## Main Buttons — 50

### Multiplier Buttons

| ID | Area | Cash Cost | Base Multi | Unlock |
|---|---|---:|---:|---|
| M01 | Area1 | 10 | 1 | `START` |
| M02 | Area1 | 50 | 3 | `START` |
| M03 | Area1 | 250 | 12 | `START` |
| M04 | Area1 | 2,000 | 75 | `START` |
| M05 | Area1 | 25,000 | 800 | `START` |
| M06 | Area1 | 400,000 | 15,000 | `START` |
| M07 | Area2 | 8e+06 | 300,000 | `LIFETIME_REBIRTH_1` |
| M08 | Area2 | 1.5e+08 | 6e+06 | `LIFETIME_REBIRTH_10` |
| M09 | Area2 | 3e+09 | 1.5e+08 | `LIFETIME_REBIRTH_100` |
| M10 | Area2 | 8e+10 | 5e+09 | `LIFETIME_REBIRTH_1K` |
| M11 | Area2 | 2e+12 | 1.5e+11 | `LIFETIME_REBIRTH_10K` |
| M12 | Area3 | 6e+13 | 6e+12 | `LIFETIME_ULTRA_1` |
| M13 | Area3 | 2e+15 | 2.5e+14 | `LIFETIME_ULTRA_10` |
| M14 | Area3 | 8e+16 | 1.2e+16 | `LIFETIME_ULTRA_100` |
| M15 | Area4 | 4e+18 | 8e+17 | `LIFETIME_PRESTIGE_1` |
| M16 | Area4 | 2e+20 | 5e+19 | `LIFETIME_PRESTIGE_10` |
| M17 | Area4 | 1e+22 | 3e+21 | `LIFETIME_PRESTIGE_100` |
| M18 | Area5 | 8e+23 | 3e+23 | `LIFETIME_ASCENSION_1` |
| M19 | Area5 | 8e+25 | 4e+25 | `LIFETIME_ASCENSION_10` |
| M20 | Area5 | 1e+28 | 7e+27 | `LIFETIME_ASCENSION_100` |

### Rebirth Buttons

| ID | Area | Required Multi | Base Rebirth | Unlock |
|---|---|---:|---:|---|
| R01 | Area1 | 500,000 | 1 | `START` |
| R02 | Area2 | 5e+06 | 10 | `LIFETIME_REBIRTH_1` |
| R03 | Area2 | 5e+07 | 100 | `LIFETIME_REBIRTH_10` |
| R04 | Area2 | 5e+08 | 1,000 | `LIFETIME_REBIRTH_100` |
| R05 | Area2 | 5e+09 | 10,000 | `LIFETIME_REBIRTH_1K` |
| R06 | Area2 | 5e+10 | 100,000 | `LIFETIME_REBIRTH_10K` |
| R07 | Area2 | 1e+12 | 1e+06 | `LIFETIME_REBIRTH_100K` |
| R08 | Area2 | 1e+18 | 1e+07 | `LIFETIME_REBIRTH_1M` |
| R09 | Area3 | 1e+14 | 1e+08 | `LIFETIME_ULTRA_1` |
| R10 | Area3 | 1e+15 | 1e+09 | `LIFETIME_ULTRA_10` |
| R11 | Area4 | 1e+16 | 1e+10 | `LIFETIME_PRESTIGE_1` |
| R12 | Area5 | 1e+18 | 1e+11 | `LIFETIME_ASCENSION_1` |

### Ultra Rebirth Buttons

| ID | Area | Required Rebirth | Base Ultra | Unlock |
|---|---|---:|---:|---|
| U01 | Area2 | 1e+07 | 1 | `START` |
| U02 | Area3 | 1e+08 | 10 | `LIFETIME_ULTRA_1` |
| U03 | Area3 | 1e+09 | 100 | `LIFETIME_ULTRA_10` |
| U04 | Area3 | 1e+10 | 1,000 | `LIFETIME_ULTRA_100` |
| U05 | Area4 | 5e+10 | 10,000 | `LIFETIME_PRESTIGE_1` |
| U06 | Area4 | 5e+11 | 100,000 | `LIFETIME_PRESTIGE_10` |
| U07 | Area4 | 5e+12 | 1e+06 | `LIFETIME_PRESTIGE_100` |
| U08 | Area5 | 1e+14 | 1e+07 | `LIFETIME_ASCENSION_1` |

### Prestige Buttons

| ID | Area | Required Ultra | Base Prestige | Unlock |
|---|---|---:|---:|---|
| P01 | Area3 | 16,000 | 1 | `START` |
| P02 | Area4 | 160,000 | 10 | `LIFETIME_PRESTIGE_1` |
| P03 | Area4 | 1.6e+06 | 100 | `LIFETIME_PRESTIGE_10` |
| P04 | Area4 | 1.6e+07 | 1,000 | `LIFETIME_PRESTIGE_100` |
| P05 | Area5 | 1.6e+08 | 10,000 | `LIFETIME_ASCENSION_1` |
| P06 | Area5 | 1.6e+09 | 100,000 | `LIFETIME_ASCENSION_10` |

### Ascension Buttons

| ID | Area | Required Prestige | Base Ascension | Unlock |
|---|---|---:|---:|---|
| A01 | Area4 | 2,000 | 1 | `START` |
| A02 | Area5 | 10,000 | 10 | `LIFETIME_ASCENSION_1` |
| A03 | Area5 | 100,000 | 100 | `LIFETIME_ASCENSION_10` |
| A04 | Area5 | 1e+06 | 1,000 | `LIFETIME_ASCENSION_100` |

## Area membership

- **Area1:** M01, M02, M03, M04, M05, M06, R01
- **Area2:** M07, M08, M09, M10, M11, R02, R03, R04, R05, R06, R07, R08, U01
- **Area3:** M12, M13, M14, R09, R10, U02, U03, U04, P01
- **Area4:** M15, M16, M17, R11, U05, U06, U07, P02, P03, P04, A01
- **Area5:** M18, M19, M20, R12, U08, P05, P06, A02, A03, A04

## Achievements — 48

| ID | Category | Name | Requirement | Hidden |
|---|---|---|---|---|
| PR01 | Progression | First Press | Use your first Main Button. | No |
| PR02 | Progression | Multiplied | Reach 1,000 Multiplier. | No |
| PR03 | Progression | Seven Digits | Reach 1,000,000 Multiplier. | No |
| PR04 | Progression | Reborn | Perform your first Rebirth. | No |
| PR05 | Progression | Rebirth x10 | Earn 10 lifetime Rebirth. | No |
| PR06 | Progression | Rebirth x1K | Earn 1,000 lifetime Rebirth. | No |
| PR07 | Progression | Rebirth x1M | Earn 1,000,000 lifetime Rebirth. | No |
| PR08 | Progression | Ultra | Perform your first Ultra Rebirth. | No |
| PR09 | Progression | Ultra x10 | Earn 10 lifetime Ultra Rebirth. | No |
| PR10 | Progression | Ultra x1K | Earn 1,000 lifetime Ultra Rebirth. | No |
| PR11 | Progression | Prestigious | Perform your first Prestige. | No |
| PR12 | Progression | Prestige x10 | Earn 10 lifetime Prestige. | No |
| PR13 | Progression | Prestige x100 | Earn 100 lifetime Prestige. | No |
| PR14 | Progression | Ascended | Perform your first Ascension. | No |
| PR15 | Progression | Ascension x10 | Earn 10 lifetime Ascension. | No |
| BC01 | Collection | Button Sampler | Use 5 unique Main Buttons. | No |
| BC02 | Collection | Button Shelf | Use 15 unique Main Buttons. | No |
| BC03 | Collection | Button Catalog | Use 25 unique Main Buttons. | No |
| BC04 | Collection | Button Archive | Use 40 unique Main Buttons. | No |
| BC05 | Collection | Every Button | Use all 50 Main Buttons. | No |
| BC06 | Collection | All Multipliers | Use M01 through M20 at least once. | No |
| BC07 | Collection | All Rebirths | Use R01 through R12 at least once. | No |
| BC08 | Collection | All Higher Resets | Use every Ultra, Prestige, and Ascension button. | No |
| AC01 | Activity | Hands On | Manually activate 100 Main Button transactions. | No |
| AC02 | Activity | Still Pressing | Manually activate 1,000 Main Button transactions. | No |
| AC03 | Activity | Production Line | Complete 10,000 total Main Button transactions. | No |
| AC04 | Activity | Button Factory | Complete 100,000 total Main Button transactions. | No |
| AC05 | Activity | One Hour In | Accumulate 1 hour of active playtime. | No |
| AC06 | Activity | Regular | Accumulate 10 hours of active playtime. | No |
| CH01 | Challenge | Quick Rebirth | After unlocking Ultra, perform a Rebirth within 60 seconds of the previous Rebirth. | No |
| CH02 | Challenge | Quick Ultra | Perform an Ultra Rebirth within 5 minutes of the previous Ultra-cycle start. | No |
| CH03 | Challenge | Quick Prestige | Perform a Prestige within 15 minutes of the current Prestige cycle. | No |
| CH04 | Challenge | Manual Prestige | Complete a full Prestige cycle without using automation. | No |
| CH05 | Challenge | Exact Rebirth | Use a Rebirth button with no more than 5% excess Multiplier. | No |
| CH06 | Challenge | Exact Ultra | Use an Ultra button with no more than 5% excess Rebirth. | No |
| CH07 | Challenge | Back to Basics | After your first Ultra, earn a Rebirth using only Area 1 Multiplier buttons during that Rebirth cycle. | No |
| CH08 | Challenge | Clean Ultra | After automation is unlocked, complete an Ultra cycle without using automation. | No |
| SE01 | Secret | Something Hidden | Find your first Secret. | No |
| SE02 | Secret | Looking Around | Find 3 Secrets. | No |
| SE03 | Secret | Off the Main Route | Find 5 Secrets. | No |
| SE04 | Secret | Secret Hunter | Find all 8 Secrets. | No |
| SE05 | Secret | Echo | ??? | Yes |
| SE06 | Secret | Relay | ??? | Yes |
| SE07 | Secret | Sealed | ??? | Yes |
| LT01 | Lifetime | Thirty Orders | Reach 1e30 Cash at least once. | No |
| LT02 | Lifetime | Fifty Orders | Reach 1e50 Multiplier at least once. | No |
| LT03 | Lifetime | Reset Veteran | Perform 1,000 total reset transactions. | No |
| LT04 | Lifetime | Lifetime Economy | Earn 1e60 total Cash across all runs. | No |

## Achievement Star rewards

| Stars | Reward |
|---:|---|
| 5 | AllGainPercent=2 |
| 10 | Feature=Pinned Achievement Slot |
| 15 | AllGainPercent=2 |
| 20 | Cosmetic=Arcade Button Skin |
| 25 | AllGainPercent=2 |
| 30 | Feature=Secret Hint Toggle |
| 36 | AllGainPercent=2 |
| 42 | Cosmetic=Collector Title + Toast Frame |
| 48 | AllGainPercent=3, Cosmetic=Completionist Title + Gold Button Skin |

## Secrets — 8

| ID | Name | Area | Unlock | Player clue | Reward |
|---|---|---|---|---|---|
| S01 | Behind the Numbers | Area1 | First Rebirth | The first reset platform has a back side too. | CashGainPercent=2 |
| S02 | Against the Flow | Area2 | Area2 | Not every arrow should be followed. | MultiplierGainPercent=2 |
| S03 | Echo Sequence | Area2 | Lifetime Rebirth 100 | Four symbols repeat the same story. | RebirthGainPercent=2 |
| S04 | Second Look | Area1 | First Ultra | Something old changed after Ultra. | UltraGainPercent=2 |
| S05 | False Face | Area3 | Area3 | One wall panel does not match the others. | PrestigeGainPercent=2 |
| S06 | Long Way Around | Area4 | First Prestige | The visible button is not reached from the front. | AllGainPercent=2 |
| S07 | Relay | Areas2-4 | First Prestige | Three small lights belong to one circuit. | AutomationIntervalPercent=-3 |
| S08 | Completion Seal | Area5 | First Ascension + S01-S07 | Seven marks fit around the final seal. | AllGainPercent=4, Cosmetic=Sealed Button Skin |

### Secret implementation concepts

#### S01 — Behind the Numbers
A side gap behind the R01 landmark leads to a small hidden plate. No jump exploit required.

#### S02 — Against the Flow
The Area2 return lane is visually one-way. Walking against its arrows reaches a maintenance alcove with a secret plate.

#### S03 — Echo Sequence
Four non-economic secret plates sit near the Rebirth row. A nearby mural gives a four-symbol order. Wrong input resets only the puzzle.

#### S04 — Second Look
After the first Ultra, a previously dark panel on the back of the original R01 landmark lights up. Returning to Area1 reveals the plate.

#### S05 — False Face
A wall/trim module in Area3 has a deliberately inverted motif. A walkable side opening behind it leads to the secret; no fake collision trick on the main route.

#### S06 — Long Way Around
A secret plate is visible through glass from the main route. The player must follow a short alternate return path around the Automation landmark.

#### S07 — Relay
Three persistent switches, one each in Areas 2, 3, and 4. No timer. Activating all three opens a small terminal beside Area4's landmark.

#### S08 — Completion Seal
Area5 contains a visible sealed pedestal from first entry. It opens only after first Ascension and the other seven Secrets.

## Platform Badge candidates
- `PR04`
- `PR08`
- `PR11`
- `PR14`
- `BC05`
- `SE01`
- `SE04`
- `SE07`

## Collection milestones

| Unique Main Buttons | Reward |
|---:|---|
| 10 | Collection menu accent |
| 25 | Catalog button border |
| 40 | Collector title |
| 50 | Master Catalog frame |
