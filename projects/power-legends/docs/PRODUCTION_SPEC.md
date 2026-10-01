# POWER LEGENDS — Production Specification

> Working title: Power Legends
> Status: PREPRODUCTION / IMPLEMENTATION-READY SPEC
> Date: 2026-10-01
> Canonical parent: `GAME_DESIGN.md`
> Purpose: Codex가 임의로 게임 방향을 재설계하지 않고 첫 production-quality vertical slice를 만들 수 있게 하는 제작 정본

---

# 0. Product contract

이 게임의 핵심은 다음 네 가지다.

1. **훈련하면 몸과 파워가 눈에 보이게 커진다.**
2. **강한 플레이어가 같은 서버에 존재하는 것 자체가 콘텐츠다.**
3. **자유 PvP의 장난·추격·복수·위협을 유지한다.**
4. **Pet/Rebirth/Gym은 이 성장 fantasy를 증폭한다.**

게임이 다음 중 하나가 되면 방향 이탈이다.

- 현실 헬스 시뮬레이터
- Pet Simulator 복제품
- Battlegrounds식 복잡한 PvP 게임
- 버튼을 눌러 숫자만 오르는 clicker
- 메뉴/팝업 위주의 방치형 게임

---

# 1. First 30-minute experience

시간은 절대 고정값이 아니라 **Studio test target**이다.

## 0:00–0:10 — Spawn

플레이어가 보는 것:

- 자기 캐릭터
- 가장 가까운 Starter Dumbbell
- Strength HUD
- 멀리 보이는 더 큰 플레이어/Body Stage
- 시야 안 또는 짧은 회전 안에 Next Gym landmark

행동:

- 걷기
- 첫 훈련 진입

금지:

- 전체화면 튜토리얼
- Pet/Shop/Rebirth 팝업 연타
- 10초 이상 걸어야 첫 action 도달

Acceptance:

- spawn → first train interaction 5초 이동 이내 목표
- 10초 내 첫 input 가능

## 0:10–0:30 — First reward

첫 Weight는 portable training이 가능해야 한다. 플레이어는 Weight를 든 채 짧게 이동하고 주변 플레이어를 보면서 rep를 이어갈 수 있다.

첫 rep에서:

- 운동 animation
- weight motion
- impact/exertion sound
- Strength number feedback
- 작은 progress/body feedback

목표:

플레이어가 설명을 읽지 않고
“운동하면 세진다”를 이해.

## 0:30–1:30 — First upgrade

플레이어는 첫 weight/station upgrade에 도달.

예:

```text
Starter Dumbbell
→ heavier dumbbell
→ Bench Press unlock
```

첫 90초 안에 단순 숫자 상승이 아닌 **새 행동/새 중량**을 최소 한 번 경험한다.

## 1:30–3:00 — World aspiration

이 구간에서 최소 두 가지가 자연스럽게 보인다.

- 큰 플레이어가 야외 PvP에서 싸움
- 첫 Pet Egg/Companion node
- Brawl countdown/sign
- Next Gym gate
- Rebirth preview

모두 튜토리얼 화살표로 밀어넣지 않는다.
월드 배치/랜드마크/짧은 objective가 유도한다.

## 3:00–5:00 — First Pet

첫 Pet은 RNG frustration 없이 반드시 경험시킨다.

권장:

```text
milestone reward
→ Starter Egg Ticket 또는 free first hatch
→ hatch presentation
→ equip
→ Training Gain 변화 즉시 체감
```

첫 Pet은 판매 상품이 아니다.

목표:

- Pet system 존재 이해
- collection screen 진입
- equip 결과 이해
- 펫이 주인공이 아니라 자기 훈련이 빨라진다는 인상

## 5:00–10:00 — Social/PvP/Brawl exposure

플레이어가:

- Safe Zone 경계를 이해
- 야외 자유 PvP를 최소 한 번 목격하거나 경험
- Basic Punch 사용
- 첫 Move 후보 해금/preview
- Brawl 참가 기회를 최소 한 번 봄

Brawl이 실제 시작되지 않더라도 UI/arena/카운트다운 구조는 이해 가능해야 한다.

## 7:00–10:00 — Power fantasy escalation

- 여러 training station 경험
- heavier object tier 접근
- Body Stage 변화가 확실히 보임
- 두 번째 또는 세 번째 Pet 후보
- Next Gym/Rebirth 요구치 명확

“처음의 약골”과 현재 캐릭터가 외형/훈련 대상/전투에서 명백히 달라야 한다.

## 10:00–15:00 — First Rebirth target

첫 Rebirth 권장 실제 플레이 목표:
**10–15분**

최적 훈련 위주 baseline:
**약 8–11분**

실제 테스트에서:
- 7분 미만이면 지나치게 가벼운지 검토
- 18분 초과면 첫 prestige가 늦은지 검토

첫 Rebirth 직전에는:

- 무엇이 초기화되는지
- 무엇이 유지되는지
- permanent multiplier
- 다음 Gym/content unlock

을 명확하게 preview.

## 12:00–20:00 — Second-run acceleration

Rebirth 이후:

- 첫 5분 progression을 훨씬 빠르게 재통과
- 이전에 오래 걸렸던 weight를 빠르게 사용
- 신규 Gym 또는 신규 training family가 실제로 열림
- “같은 걸 다시 한다”보다 “이제 이전 구간은 짧아졌다”가 먼저 느껴짐

---

# 2. Core progression layers

## Layer A — Run power

Reset되는 현재 run 성장:

- Strength
- Toughness
- Agility
- current Gym run gates
- temporary boosts 일부

## Layer B — Meta power

Rebirth 후 유지:

- Rebirth count
- permanent Training multiplier
- Pets/Collection
- unlocked meta features
- purchased entitlements
- cosmetics
- persistent achievements

## Layer C — Social status

유지/누적 가능:

- Fame
- titles
- rare Pet flex
- Body cosmetic variants
- leaderboard season data

Social status는 핵심 Strength progression을 막지 않는다.

---

# 3. Player stats

## Strength

Primary stat.

사용:

- training station/weight gate
- Body Stage
- combat attack power curve
- heavy-object interaction
- Gym/Rebirth requirements 일부

## Toughness

Secondary stat.

사용:

- max HP
- knockback resistance
- defensive training unlock

첫 세션에서 복잡하게 설명하지 않는다.

## Agility

Secondary stat.

사용:

- capped movement improvement
- mobility Move requirement 일부

규칙:

- map traversal을 붕괴시키는 무한 speed scaling 금지
- soft cap/hard cap 필수

---

# 4. Body progression contract

Body Stage는 단순 cosmetics가 아니라 progression feedback.

초기 slice target:

| Stage | Working label | Player impression |
|---|---|---|
| B0 | Skinny | 시작 |
| B1 | Fit | 운동 효과가 보임 |
| B2 | Muscular | 명백한 강자 느낌 |
| B3 | Huge | 다른 플레이어가 멀리서 인지 |
| B4 | Titan | 첫 run 후반 aspirational tier |

후속 확장:
Colossus 이상.

정확 threshold는 `ECONOMY_AND_BALANCE.md` config 기준.

Body Stage 변경은 최소 2개 이상의 변화로 읽혀야 한다.

예:

- body scale/proportion
- stance
- idle/walk feel
- aura/outline restraint
- held weight scale
- impact feedback

금지:

- Humanoid scale만 무제한 증가
- door/camera/collision 파괴
- Body Stage 때문에 PvP hitbox가 보이는 몸과 크게 어긋남

---

# 5. Training content contract

Vertical Slice 001 목표:

- polished training family 5개
- family별 weight tier 여러 개
- 최소 1개는 Strength 외 secondary stat을 가르침

Initial candidate set:

1. Dumbbell Curl — Strength
2. Bench Press — Strength
3. Squat — Strength/Toughness
4. Deadlift — Strength
5. Punching Bag 또는 Treadmill — Toughness/Agility

Codex는 최신 reference와 asset/animation availability 조사 후 final set을 바꿀 수 있다.

단, 변경 시:

- 이유 기록
- 첫 30분 pacing 유지
- 5개 모두 서로 다른 animation silhouette 제공

## Portable training

Starter Dumbbell / handheld Weight family는 이동 중 훈련 가능해야 한다.

```text
equip weight
→ rep input/auto state
→ animation + weight motion
→ gain
→ movement/social/PvP context 유지
```

portable training은 Muscle Legends식 자유로운 서버 생태계를 살리는 기본 훈련이다.

## Training station interaction

Bench/Squat/Deadlift 등 고정 기구는 더 높은 효율 또는 특화 stat을 제공한다.

```text
approach
→ prompt
→ server validates station availability
→ align character
→ enter training state
→ context UI
→ rep loop
→ gain
→ exit
```

## Weight progression

플레이어가 다음 중량을 항상 볼 수 있어야 한다.

- current usable
- next heavier
- required Strength

Too Heavy는 아무 반응 없는 disabled 버튼이 아니라:
- 시도 presentation
- requirement feedback
- 다음 목표
를 준다.

---

# 5.1. Power Challenge contract

Strength를 월드에서 직접 사용하는 짧은 challenge를 최소 1개 vertical slice에 넣는다.

예:
- tire flip
- boulder lift
- vehicle push
- breakable strength gate

목표:
- 숫자 외 progression validation
- screenshot-worthy power feedback
- 소량 Gems/bonus

별도 복잡한 미니게임 시스템으로 확장하지 않는다.

---

# 6. Pet progression contract

## First-session Pet

첫 Pet:
- 3–5분 목표
- free guaranteed hatch
- 즉시 equip 가능
- Training Gain 변화 체감

## Base equip slots

Vertical Slice:
**3 slots**

후속:
- progression +1 후보
- paid +1 후보

첫 slice에서는 paid slot을 구현하더라도 밸런스 검증 전 hard-sell하지 않는다.

## Rarity

Initial:
- Common
- Rare
- Epic
- Legendary

## Power model

Pet bonus는 runaway multiplicative stack을 피한다.

권장:

```text
PetTrainingBonus = sum(equipped pet bonus)
EffectiveTrainingGain =
  BaseGain
  × RebirthMultiplier
  × PassMultiplier
  × TemporaryBoost
  × (1 + PetTrainingBonus)
```

Pet끼리는 기본적으로 additive bonus.

Initial rough bonus bands:

- Common: +5% ~ +15%
- Rare: +15% ~ +30%
- Epic: +30% ~ +55%
- Legendary: +55% ~ +90%

실제 값은 progression simulation 후 조정.

## PvP

Pet은 Vertical Slice에서 직접 공격하지 않는다.

Pet이 직접 PvP power를 별도 곱연산하지 않는다.
Training acceleration을 통해 간접적으로만 성장에 기여.

## Duplicate

첫 slice:
- duplicate 보유 가능
- 동일 Pet 여러 장착 허용 여부는 playtest로 결정

후속:
- merge/evolve/shard 중 하나만 채택 가능

첫 slice에서 복잡한 fusion 금지.

---

# 7. Free PvP contract

## Safe

- Spawn protection core
- first-time onboarding pocket
- 정말 필요한 Starter interaction 일부만 제한적 보호

일반/고급 training station은 원칙적으로 자동 Safe Zone이 아니다.

## PvP enabled

- outdoor social route
- PvP Plaza
- optional side spaces

## Player freedom

약자를 공격하는 행위 자체를 금지하지 않는다.

대신 farming 최적화를 막는다.

### Repeated-victim diminishing reward

같은 attacker→victim pair:

```text
1st rewarded KO: 100%
2nd shortly after: 50%
3rd: 20%
4th+: 0% until cooldown/reset
```

수치는 tunable.

## Death

죽어도 잃지 않음:

- Strength
- Pets
- Rebirth
- core progression

죽으면:
- quick respawn
- short shield
- short combat re-entry delay if needed

## Target TTK

동일한 power band:
- Basic Punch 기준 약 5–8 hits

약 2× power 차이:
- 3–5 hits

압도적인 10×+ power:
- 1–3 hits 허용 가능

목표는 완전 공정한 esports가 아니라 **성장 차이가 느껴지되 같은 급에서는 싸움이 성립하는 것**.

직접 Strength 선형 damage는 금지.
Curve/config로 조절.

---

# 8. Combat kit

Vertical Slice:

## Basic Punch

- 항상 사용 가능
- 짧은 startup
- 명확한 hit frame
- 작은 knockback
- spam만으로 permanent stun 금지

## Move 1 — Heavy Strike

역할:
- 느리지만 큰 impact/knockback

## Move 2 — Mobility/Area

최종 형태는 reference/animation availability 후 결정.

후보:
- shoulder rush
- ground slam
- short lunge

복잡한 combo tree는 금지.

---

# 9. Brawl specification

권장 cadence:
**약 7–10분 간격**, 실제 서버 population과 session length로 조정.

Flow:

```text
30 sec announcement
→ opt-in
→ teleport/arena entry
→ 90–150 sec match
→ result
→ rewards
→ return
```

Vertical Slice 기본안:
**KO Score Match**

이유:
- power disparity가 있어도 모두 행동 가능
- early death로 긴 spectator time 없음
- 테스트가 단순

Last-player-standing은 후속 mode 후보.

Rewards rough target:

- participation: 소량 Gems
- KO: diminishing Gems/Fame
- top 3: bonus Gems/Fame
- winner: 강조 presentation + bonus

같은 victim farming rule 적용.

---

# 10. Rebirth specification

First Rebirth:
**10–15분 실제 플레이 target**

Optimal-training baseline:
**8–11분**

Rebirth preview는 threshold 이전부터 보임.

Reset:
- Strength
- Toughness
- Agility
- current run station/gym gates 일부

Persist:
- Pets
- Gems
- purchases
- cosmetics
- collection
- Rebirth count
- permanent meta unlocks

First Rebirth benefit rough target:

- training speed 체감상 최소 +40% 이상
- early onboarding section 재통과 시간이 첫 run의 절반 이하를 목표
- Next Gym/content unlock

정확 multiplier는 simulation.

Rebirth가 단순 `x2 숫자`만 주지 않게:
- 신규 Gym
- 신규 weight family
- 신규 Pet egg tier
중 최소 하나가 실제로 열림.

---

# 11. World spatial plan

## Server population target

- target: **16 players/server**
- performance/readability가 충분하면 20명까지 검토
- StarterTraining / PvPPlaza / main route에서 타 플레이어가 지나치게 희박해지지 않게 설계


절대 좌표는 Studio inspection 전 금지.

Named anchors:

```text
SpawnSafe
StarterTraining
PetCourt
PvPPlaza
BrawlGate
NextGymVista
NextGymPortal
```

## Target travel times

기본 WalkSpeed 기준 초기 목표:

- SpawnSafe → first training: 3–5 sec
- first training → PetCourt: 8–12 sec
- SpawnSafe → PvP boundary: 6–10 sec
- PvP center → BrawlGate: 8–12 sec
- SpawnSafe → NextGymPortal: 10–18 sec equivalent route

Next Gym은 직접 갈 수 없어도 landmark/portal로 보이게.

## Route hierarchy

```text
SpawnSafe
   |
StarterTraining
   |\
   | PetCourt
   |
PvPPlaza ---- social side space
   |
BrawlGate
   |
NextGymVista/Portal
```

## Scale rules

- B0~B4 Body Stage reference rigs로 major clearance 확인
- main social route는 giant bodies 두세 명이 마주쳐도 완전히 막히지 않음
- training station에는 접근/animation/camera/crowd footprint 포함
- safe station과 PvP route가 collision-chaos로 겹치지 않음

Codex는 5개 이상 player-facing object 배치 전 placement table 작성.

---

# 12. UI information architecture

## Persistent HUD

항상 보여줄 최소 정보:

- Strength
- Gems
- Rebirth count

Context:
- HP during/near combat
- Brawl state
- short objective

## Primary menu entry

한 곳에서:

- Pets
- Rebirth
- Moves
- Stats
- Shop

## Context UI

별도:

- Training
- Pet Hatch
- Brawl
- KO/Death
- Rebirth Confirm

## First session disclosure order

0–90 sec:
- Strength
- training context

1.5–5 min:
- Pet

3–10 min:
- PvP/Brawl
- Moves

later:
- Rebirth detail
- Shop deeper surfaces

처음부터 메뉴 8개를 모두 강조하지 않는다.

---

# 13. Monetization launch skeleton

수익 구조는 gameplay가 통과한 뒤 활성화 강도를 높인다.

## Pass candidates

- 2× Training
- Auto Train
- +1 Pet Equip
- VIP
- Extra Pet Storage

## Developer Product candidates

- timed Training Boost
- Starter Pack
- guaranteed premium companion bundle
- event/cosmetic bundle

## Initial avoidance

- paid random egg
- Robux-purchased Gems → random egg
- paid Luck affecting monetized random outcomes
- direct PvP weapon
- instant max-Rebirth purchase

Roblox paid-random policy review 없이 확률형 Robux path를 추가하지 않는다.

---

# 14. Save schema v1 requirements

Save must use stable IDs.

Minimum:

```text
schemaVersion
currencies:
  gems
progression:
  strength
  toughness
  agility
  rebirths
  bodyStage
pets:
  owned[]
  equipped[]
collection:
  discoveredPetIds[]
unlocks:
  gyms[]
  moves[]
settings
claims
purchaseEntitlements
metadata
```

Rules:

- load failure → blank overwrite 금지
- TEST/PROD isolation
- Developer Product receipt idempotency
- removed Pet/content ID migration policy

---

# 15. Server authority

Server authoritative:

- Strength/Toughness/Agility gain
- Pet hatch result
- Pet equip ownership
- multipliers
- Rebirth
- Gym unlock
- damage/KO reward
- Brawl scoring/reward
- purchases
- saves

Client may request intent and run immediate presentation.
Client never submits final reward/damage/currency truth.

---

# 16. Reference research requirement for Codex

Implementation 시작 전 Codex가 직접 최신 자료를 조사한다.

Minimum comparison set:

- Muscle Legends
- Gym League
- Strongman Simulator
- current successful training/muscle simulator 2개 이상

Record:

```text
first 3 min flow
HUD density
training interaction count
animation cadence
body growth presentation
Pet discovery/equip UX
PvP safe-zone rules
Brawl/event cadence
Gym unlock presentation
monetization surfaces
map travel time / spatial grammar
```

레퍼런스의 특정 UI/맵/에셋을 그대로 복제하지 않는다.

---

# 17. Vertical Slice 001 acceptance

다음을 모두 통과하기 전 content scale 금지.

## Runtime

- clean boot
- project-attributable unexpected error 0
- spawn 정상
- respawn 정상
- save/load smoke
- no dead primary button

## First 3 minutes

- first action ≤10 sec
- first reward ≤30 sec
- first meaningful upgrade ≤90 sec
- long-term aspiration ≤180 sec

## Training

- 5 distinct polished actions
- hands/tool/animation alignment acceptable
- next weight goal readable
- 5분 반복 시 visual/audio feedback가 지나치게 지루하지 않음

## Body

- B0→B2 변화가 gameplay camera에서 명백
- collision/camera/doors/routes 정상

## Pet

- free first Pet
- hatch
- equip
- multiplier
- collection
- save/restore
- 3 equipped pets stable

## PvP

- equal-power fight 성립
- large power gap 읽힘
- respawn protection
- repeated victim reward diminishing
- no obvious permanent stun lock

## Brawl

- opt-in
- start/end
- scoring
- reward
- return
- disconnect cleanup

## Rebirth

- reset/persist 정확
- permanent gain 체감
- next content unlock

## UI

- PC 720p/1080p
- small/common phone
- tablet
- no critical clipping
- training/PvP controls usable
- shop/purchase double press protection

## Visual

- hero-facing placeholder 0
- coherent asset family
- gameplay-camera screenshots reviewed
- no obvious floating/buried/z-fighting
- art pass 후 P0 route 재완주

---

# 18. Content expansion gate

Vertical Slice 승인 후에만:

- Gym 3+
- Pet 20+
- Moves 4+
- multiple eggs
- events/live ops
- trading
- complex Pet evolution
- subscription
- paid random items

을 검토한다.

첫 slice가 구리면 콘텐츠 양을 늘려 숨기지 않는다.
