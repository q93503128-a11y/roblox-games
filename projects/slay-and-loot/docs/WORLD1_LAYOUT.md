# World 1 / first-slice spatial plan
Status: planned relative layout; **nothing in this table has been built**.
Current measurements: [audit](CURRENT_STATE_AUDIT.md). Exact anchor/socket offsets: [catalog](specs/first-slice.catalog.json).

## Calibration and origin
WorldOrigin = SpawnLocation position projected to the measured walkable floor top. Forward = upright Spawn.LookVector, Right = Spawn.RightVector.
Currently Spawn has identity rotation, floor top Y=0, floor X/Z bounds -64..64. Existing floor is insufficient for the whole forward route.
B01 proposal: extend the existing floor **64 studs forward**, keeping the rear edge and floor top. This derives a 128×192 envelope centered 32 studs forward of the original floor center; do not create a second coplanar floor. Re-measure if the scene changes before build.
Planned gate at forward104 and landing ending124 fit within derived forward boundary128. Back/side safety edges stay explicit.
Starter tile top is Y=1 while Baseplate top is0. In B01 decide by measured ground contact to make the spawn marker non-obstructing/flush; do not stack duplicate walkable surfaces.
Do not apply coordinates until a real avatar/reference rig and gameplay camera are calibrated. FOV70 and WalkSpeed16 are initial references; current Camera.Fixed is an Edit camera, not approved gameplay behavior.

## Placement table — required before 5+ objects
Units are studs relative to WorldOrigin, not guessed absolute coordinates.

| Object / role | Named anchor (right, forward) | Footprint | Facing / front clearance | Neighbor / forbidden overlap |
|---|---|---|---|---|
| Spawn / onboarding | WorldOrigin (0,0) | existing12×12, safe area64×36 | face farming; 18-wide clear route | no enemy socket/service queue on spawn |
| Meadow Egg / reward conversion | MeadowEgg (22,4) | 8×8 model | face safe-area center; 12 approach | near FarmEntry; outside main path |
| Farm entry / orientation | FarmEntry (0,18) | route18 wide | forward | see first Slime and gate direction |
| Normal A bay / first farm | NormalABay (-32,36) | about24×24 incl. clear space | face route; four sockets ±8/±8 | first target distance≈37 studs; no path intrusion |
| Normal B bay / new weapon | NormalBBay (32,56) | about24×24 | face route; four sockets ±8/±8 | visually deeper, distinct silhouette |
| Strong bay / higher payout | StrongBay (-36,76) | about28×14 | face route; two sockets ±8 | no camera/fence overlap |
| Mini-Boss / optional aspiration | MiniBossBay (34,82) | about24×24 including approach | toward center route | clear center path; no gate queue overlap |
| Gate approach / purchase | NextGate forward approach (0,96) | 28×12 | face gate; no enemy sockets | Coins+next biome visible |
| Zone Gate / progression | NextGate (0,104) | 28×4 art footprint | faces spawn, height calibrated | collision boundary derived from zone bounds |
| Zone 2 safe landing / end of slice | Zone2Landing (0,116) | 40×16 | view next biome | safety boundary; no extra active enemies/Egg |

Hierarchy: Experience → World1 → Zone → FarmingArea/ServiceArea → reusable module → Part.
Sockets are named instances with IDs matching the catalog, parented under their zone. Models move/scale as a whole; use visual bounds/pivots and ground raycasts/sockets.

## Required views and route
Spawn vista → first attack → service return → Normal B/Strong choice → Mini-Boss side approach → gate purchase → landing → return.
Entry, center, interaction, combat and wall-near camera checks are required after blockout AND after production assets.
8-player clearance must include Egg crowding, gate passage, target selection and 24 following pet visuals.
No art placement inside the 18-wide central corridor. Small decorative collision off; simple floor/fence proxies.

## Scope
World1 later: Greenvale → Goblin Camp → Ruined Keep → Goblin Citadel/World Boss.
This pass only plans; B01 builds Greenvale + gate/landing preview. No complete second farming zone or final boss is implied by the concept image.
