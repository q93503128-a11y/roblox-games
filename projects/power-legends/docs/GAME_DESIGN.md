# POWER LEGENDS — Game Design Document

> Working title: Power Legends
> Status: PREPRODUCTION / DESIGN
> Canonical date: 2026-10-01
> Primary genre: Training / Incremental Simulator
> Secondary: Open-world PvP / Collection
> Target: broad Roblox audience, PC + mobile first
> Implementation target: Codex-led development with Roblox Studio MCP, Script Sync/Git as appropriate

---

## 1. Product thesis

Power Legends는 현실적인 헬스 게임이 아니다.

핵심 fantasy:

> **약골로 시작해서 운동하고 몸집을 키우고, 더 무거운 것을 들고, 다른 플레이어와 싸우며 서버 안에서 압도적으로 강한 존재가 된다.**

성장의 핵심은 숫자가 아니라 **눈에 보이는 변화**다.

- 캐릭터 체격 변화
- 더 무거운 운동 도구
- 더 강한 hit reaction / knockback
- 더 높은 Gym 접근
- 희귀 Pet/Companion
- 다른 플레이어가 나를 보고 위험도를 즉시 알아봄

---

## 2. Reference synthesis

### 2.1 Muscle Legends

가져올 것:

- Train → Gym unlock → Rebirth의 단순한 성장 구조
- 자유 PvP가 만드는 서버 내 자연스러운 사건
- 몸 크기 자체가 status와 threat indicator가 되는 구조
- Brawl 같은 주기적 경쟁 이벤트
- Moves / Pets / Rebirth가 core training 위에 얹히는 방식

개선할 것:

- 오래된 HUD 과밀
- 약한 플레이어를 반복해서 죽이는 것이 최적화되는 상황
- 운동 presentation의 반복감
- 메뉴와 시스템의 낡은 정보 구조

Reference:
https://www.roblox.com/games/3623096087/Muscle-Legends

### 2.2 Gym League

가져올 것:

- 기구별 운동 presentation
- 실제로 '운동한다'는 느낌이 나는 animation/camera/context UI
- 중량 선택과 추천 중량을 상황 UI로 보여주는 구조
- 현대적인 menu hierarchy와 visual polish

가져오지 않을 것:

- 지나치게 세부적인 현실 헬스 관리
- 자유 PvP/social chaos를 약화시키는 방향

Reference:
https://www.roblox.com/games/17450551531/Gym-League

### 2.3 Strongman Simulator

가져올 것:

- 더 무거운 물체를 다룬다는 성장의 명확한 시각화
- 다음 목표가 월드에서 직접 보이는 구조
- '이제 이것도 가능하다'가 progression feedback이 되는 방식

가져오지 않을 것:

- 불필요하게 training loop를 여러 currency/action으로 중첩하는 구조

Reference:
https://www.roblox.com/games/6766156863/Strongman-Simulator

### 2.4 Modern incremental / break-through simulators

가져올 것:

- 첫 action과 reward가 매우 빠름
- 다음 gate가 항상 보임
- 능력 증가가 world interaction을 바로 바꿈
- 짧은 반복 loop가 visual destruction/progression과 결합됨

### 2.5 Pet/collection simulators

가져올 것:

- rarity aspiration
- collection completion
- equip slot progression
- visible social flex
- update-friendly content layer

주의:

Pet system이 Training/PvP보다 게임의 주인공이 되어서는 안 된다.

---

## 3. Design pillars

### P1. Visible power

Strength +10보다:

- 팔/몸이 커짐
- 더 큰 weight가 사용 가능
- 이전에 못 들던 물체를 듦
- 공격 knockback이 달라짐
- 이전 gate가 열림

이 먼저 보여야 한다.

### P2. Freedom creates stories

월드는 완전히 안전한 lobby가 아니다.

- Spawn/Safe interior만 보호
- 야외와 PvP plaza는 자유 전투
- 강한 플레이어가 지나가는 것 자체가 사건
- 약한 플레이어도 도망/구경/장난/도전할 수 있음

### P3. Training must feel physical

한 버튼을 눌러 +1만 뜨는 것이 아니라:

- animation
- tool/weight movement
- exertion timing
- sound
- number feedback
- body/progress response

가 겹쳐야 한다.

### P4. Simple surface, deep aspiration

첫 3분은 복잡하면 안 된다.

초반 player-facing resource:

- Strength
- Gems
- Rebirth

Toughness/Agility는 보이더라도 secondary priority.

Pet, Moves, Brawl, Gym, Rebirth는 순서대로 드러난다.

### P5. Collection supports the fantasy

Pet은 귀엽기만 한 장식이 아니라:

- Training multiplier
- 희귀도
- equip choice
- collection completion
- social flex

를 제공한다.

---

## 4. Core loop

```text
Train
→ immediate Strength gain
→ body / usable weight 변화
→ better training station
→ Gems / Pet / Move / next Gym aspiration
→ free PvP / Brawl / social flex
→ Rebirth
→ permanent multiplier + content unlock
→ earlier section becomes fast
→ repeat
```

Side loop:

```text
Train / events / achievements
→ earn Pet currency / egg access
→ hatch or guaranteed acquisition
→ equip / collect / upgrade
→ training efficiency 증가
→ reach next progression target faster
```

---

## 5. First-session pacing targets

Godbase simulator 기준을 따른다.

### 0–10 sec

- spawn
- 가장 가까운 Dumbbell 또는 starter action이 즉시 보임
- 긴 tutorial dialog 없음
- 첫 입력 가능

### ≤30 sec

- 첫 Strength reward
- animation + sound + number + small body/progress feedback

### ≤90 sec

- 첫 meaningful improvement
- 더 무거운 weight 또는 두 번째 station 사용 가능

### ≤3 min

플레이어가 최소 2개를 인지:

- 더 강한 다른 플레이어
- 자유 PvP
- Pet egg / collection
- 다음 Gym
- Brawl
- Rebirth tease

### 10 min

- 여러 training types 경험
- 첫 Pet 획득
- PvP 최소 1회 경험 또는 목격
- Brawl 접근 가능
- 다음 Gym의 조건 이해

### 10–15 min target

- 첫 Rebirth 후보
- 최적 훈련만 할 경우 약 8–11분 baseline을 목표

실제 시간은 Studio test/analytics로 튜닝한다.

---

## 6. Player stats

### Strength — primary

영향:

- training progression
- 사용할 수 있는 weight/station
- 기본 combat damage
- Body Stage
- 일부 world interaction gate

### Toughness — secondary

영향:

- max HP
- knockback resistance 일부
- defensive training content

### Agility — secondary

영향:

- movement speed의 제한된 성장
- 일부 mobility content

안전 규칙:

- Agility scaling으로 맵 traversal/camera가 붕괴하지 않게 hard/soft cap 필요
- Strength 차이가 PvP를 결정하되 input/positioning이 완전히 무의미해질 정도로 direct one-shot curve를 남발하지 않는다

---

## 7. Body progression

목표:

다른 플레이어가 숫자를 읽지 않아도 대략적인 power tier를 알아야 한다.

초기 단계 예시:

1. Skinny
2. Fit
3. Muscular
4. Heavy
5. Huge
6. Titan
7. Colossus

이 이름은 working vocabulary이며 실제 production naming은 reference/asset vocabulary를 보고 Codex가 조사 후 제안한다.

구현 원칙:

- 단순 R15 scale 무한 증가 금지
- camera / door / collision / PvP arena가 깨지지 않는 범위에서 physical scale
- 이후 stage는 stance, proportion-safe attachments, aura, animation variation 등을 병행
- gameplay hitbox와 보이는 몸 크기 불일치 최소화
- giant player가 indoor training을 완전히 가리지 않도록 Gym 공간 설계

---

## 8. Training system

첫 slice의 5종 후보:

1. Dumbbell Curl
2. Bench Press
3. Squat
4. Deadlift
5. Punching Bag 또는 Treadmill

Codex는 실제 Training Simulator와 Creator Store/animation 공급을 조사해 final 5종을 선정할 수 있다.

### Portable + Station training

기본 Weight 계열은 **들고 이동하며 어디서든 훈련 가능한 portable training**을 우선한다. 이 상태에서도 다른 플레이어와 마주치고, 도망가고, 싸움이 발생할 수 있어야 한다.

Bench / Squat / Deadlift 같은 고정 기구는:
- 더 높은 효율
- 특정 stat 성장
- 더 강한 presentation
중 하나 이상의 이유로 선택하게 한다.

고정 기구 flow:

Approach
→ interact
→ station ownership/slot 확인
→ character align
→ contextual training UI
→ repeated reps
→ exit

### Weight model

각 station은 여러 weight tier를 가진다.

- Light: 빠름, 낮은 gain
- Recommended: 정상 cadence, 효율적
- Heavy: 느림, 높은 gain
- Too Heavy: 사용 불가 또는 실패 presentation

목표는 spreadsheet min-max가 아니라:

> “조금만 더 강해지면 저걸 들 수 있다.”

를 계속 만드는 것.

### Context UI

운동 중만 표시:

- weight
- Strength / rep
- recommended weight
- change weight
- auto-train state if owned/unlocked
- exit

일반 HUD를 덮지 않는다.

---

## 9. Heavy-object fantasy

중후반에는 gym equipment만 계속 커지는 것을 피한다.

예시 vocabulary:

- large plates
- industrial tire
- engine block
- boulder
- motorcycle
- car
- truck component
- absurd heavy object

정확한 production object line은 asset procurement 후 결정.

목표:

새 weight tier가 단순 reskin이 아니라 **“이제 저걸 든다”**라는 screenshot-worthy progression이 되게 한다.

### Power Challenges

Strength가 실제 월드 규칙을 바꾼다는 것을 짧게 증명하는 활동을 넣는다.

후보:
- 타이어 뒤집기
- 바위 들기
- 자동차 밀기
- 벽/문 파괴
- 짧은 strongman checkpoint

이들은 별도 메인 장르가 아니라 **성장 확인 + Gems/보너스 + 시각적 만족**을 위한 짧은 side challenge다.

---

## 10. Free PvP

### Rules

- Spawn 및 첫 onboarding pocket: Safe
- 초기 Starter interaction의 일부만 보호 가능
- 일반/고급 training 공간, outdoor route, PvP plaza: 기본적으로 PvP enabled
- 기구를 사용 중이라는 이유만으로 장시간 완전 무적 상태가 되지 않게 함
- Brawl: 별도 ruleset

### Why

자유 PvP는 단순 battle mode가 아니다.

서버에 다음을 만든다:

- 위험
- 추격
- 장난
- 복수
- 구경
- 강자 social status
- 자연 발생 이벤트

### Anti-frustration

- respawn shield
- 동일 약자 반복 KO 보상 diminishing
- training machine 사용 중 직접 spawn-camp 불가능
- death로 핵심 Strength/Rebirth 진행 손실 없음
- 더 강하거나 비슷한 상대와 싸울 이유가 있는 Fame/Bounty 후보

약자를 공격하는 자유 자체를 제거하지 않는다.

---

## 11. Combat

Training simulator가 Battlegrounds가 되어서는 안 된다.

### Initial kit

- Basic Punch
- Move A: power strike / knockback-oriented
- Move B: short mobility or area move

후속 update에서 3–4 moves까지.

### Feel requirements

모든 공격:

```text
input
→ immediate presentation
→ startup
→ active hit window
→ impact
→ recovery
```

필수:

- animation/hit-frame alignment
- server authoritative damage
- hit sound
- target reaction
- controlled knockback
- damage feedback
- modest camera impulse
- stun-lock prevention

---

## 12. Brawl

주기적 server event.

Flow:

```text
announcement
→ opt-in
→ arena
→ short match
→ winner + participation rewards
→ return
```

초기 mode:

- KO score 또는 last-player-standing 중 playtest 후 선택

Rewards:

- Gems
- Fame
- temporary boost
- cosmetic/collection progression 일부

약한 플레이어도 참가 자체가 완전 손해가 아니게 한다.

---

## 13. Rebirth

첫 Rebirth 목표: 약 **10–15분 실제 플레이** 테스트 범위. 최적 훈련만 할 경우 약 **8–11분** baseline을 목표로 한다.

Reset 후보:

- Strength
- Toughness 일부/전부
- Agility 일부/전부
- temporary progression

Persist:

- Pets
- collection
- permanent unlocks
- purchases
- cosmetics
- Rebirth count
- permanent multipliers
- selected meta progression

Reward:

- Gems
- permanent training multiplier
- higher Gym access
- Pet tier / egg access
- Moves / body content unlock

원칙:

첫 Rebirth 뒤 초반이 **명백하게 빨라져야 한다.**

---

# 14. Pet / Companion system

## 14.1 Why Pets are in the game

Pets는 launch 후 억지 수익화 부착물이 아니라:

- collection aspiration
- rarity chase
- visual social flex
- equip-slot progression
- update content
- monetization surfaces

를 제공하는 장기 loop다.

하지만 core loop보다 앞에 나오지 않는다.

## 14.2 Pet role

초기 기능:

- Training Gain multiplier
- 일부 Pet은 특정 training family bonus 후보
- visual follow/orbit
- rarity + collection entry

초기에는 Pet이 직접 PvP attack을 하지 않는다.

이유:

- combat readability 유지
- pay-to-win perception 완화
- network/AI 부담 감소
- character power fantasy가 Pet에게 빼앗기지 않음

## 14.3 Equip slots

예시:

- base: 3
- progression unlock: +1 후보
- paid pass: extra slot 후보

정확 수치는 economy test 후 결정.

## 14.4 Acquisition

초기 safest structure:

### Earned eggs

- gameplay-only earnable currency 또는 activity access
- random hatch
- rarity odds 표시 가능하지만 paid-random 규정의 직접 대상이 되지 않도록 paid currency와 분리

### Guaranteed/direct premium offers

- 특정 Pet 또는 cosmetic variant 직접 구매
- 결과가 구매 전에 명확함

### Do NOT casually do

Robux로 Gems 구매
→ Gems로 random egg hatch

이 구조는 간접 **paid random item**으로 취급될 수 있다.

Roblox 정책에 따르면 Robux 또는 Robux로 산 통화로 random item을 얻는 경우:

- 실제 numerical odds disclosure
- PolicyService eligibility/restriction 처리
- 제한된 사용자에게 hide/block/alternative path 등
- 관련 compliance 처리

가 필요하다.

따라서 paid random eggs를 도입할 경우 별도 compliance/monetization review gate를 통과한다.

Official:
https://create.roblox.com/docs/production/monetization/paid-random-items

## 14.5 Pet rarity

첫 vertical slice에서는 소수만 필요.

예:

- Common
- Rare
- Epic
- Legendary

최종 rarity count는 collection readability가 확보된 뒤 확장.

## 14.6 Duplicate handling

후속 후보:

- merge/evolve
- salvage/shards
- collection mastery

첫 slice에 복잡한 fusion tree를 만들지 않는다.

## 14.7 Pet visual direction

AI가 임의로 저품질 pet 30종을 생성하지 않는다.

순서:

1. cohesive external/Creator Store/approved asset family 조사
2. source/license/script/security audit
3. art direction 선정
4. 몇 종만 production quality로 검증
5. scale

---

## 15. Economy

초기 currencies:

### Strength

progression stat.

### Gems

meta reward.

사용 후보:

- Pet acquisition
- Moves
- cosmetic/meta unlock
- 일부 non-Robux convenience

통화를 초반부터 4~5개 만들지 않는다.

### Economy design principle

cost 숫자보다 먼저:

- time to first upgrade
- time to next meaningful choice
- time to first Pet
- time to first Brawl reward
- time to first Rebirth

를 측정한다.

---

## 16. Monetization

목표:

게임의 재미를 만든 뒤 자연스럽게 시간을 절약하거나 collection/social flex를 확장한다.

### Strong candidates

- 2× Training pass
- Auto Train
- VIP
- Extra Pet Equip slot
- temporary Training Boost developer products
- Starter Pack
- direct cosmetic/aura/body style
- guaranteed premium companion
- subscription candidate after retention proves itself

### Avoid at initial release

- direct paid PvP weapon that invalidates training
- fake scarcity
- restarting fake countdown
- purchase spam
- unclear odds
- paid random system without PolicyService handling
- monetization popup wall during FTUE

Official monetization:
https://create.roblox.com/docs/production/monetization

---

## 17. World structure

### Server population target

- 초기 목표: **16 players/server**
- Body/Pet/network/UI 가독성과 성능이 충분하면 20명 검토
- 목표는 Starter Gym/PvP route에서 항상 다른 플레이어의 존재를 느끼는 밀도


First slice macro structure:

```text
Spawn / Safe Plaza
      ↓
Starter Training Zone
      ↔
PvP Plaza / outdoor social route
      ↓
Pet / Reward node
      ↓
Brawl Arena access
      ↓
Next Gym gate/portal visible
```

### Spatial principles

- spawn에서 first training station 즉시 인식
- 다음 Gym의 존재가 초기부터 보이거나 명확히 tease
- training machine 앞 crowd/camera clearance
- giant bodies 기준 corridor와 station spacing
- PvP가 safe interaction footprint를 침범하지 않음
- freecam이 아니라 gameplay camera로 승인

절대 좌표는 Studio 현황을 측정하기 전에 확정하지 않는다.

---

## 18. UI / UX

### Persistent HUD

최소:

- Strength
- Gems
- Rebirth

상황에 따라:

- HP
- PvP/Fame
- objective

### Menu

한 menu entry에서:

- Stats
- Rebirth
- Pets
- Moves
- Shop

Rewards/Codes/Daily는 핵심 hierarchy를 방해하지 않는 secondary surface.

### Context surfaces

- Training
- Egg hatch
- PvP target/KO
- Brawl
- Rebirth confirmation

모든 것을 HUD에 상시 노출하지 않는다.

### Device

PC + mobile primary.

필수:

- responsive layout
- large touch targets
- Input Action System/binding-aware prompts
- small phone viewport
- tablet
- 720p
- 1080p

---

## 19. Art / animation strategy

AI placeholder를 production이라고 부르지 않는다.

### Procurement order

1. Roblox official capability/assets
2. verified package
3. audited Creator Store
4. procedural/generated mesh where suitable
5. approved external/OSS
6. custom

### Codex research responsibility

Codex는 implementation 전에 스스로:

- current successful Training Simulator 조사
- UI screenshots/video/reference 조사
- training animation vocabulary 조사
- Creator Store asset families 조사
- suitable existing animation/assets 조사

를 수행하고 출처와 선택 이유를 기록한다.

### Animation quality gate

운동마다 최소:

- body alignment
- hands/tool contact
- weight motion
- believable timing
- no obvious clipping
- camera angle
- loop transition

공격마다:

- hit frame alignment
- reaction
- impact feedback

---

## 20. Vertical Slice 001

Production-quality slice:

### World

- Starter Gym
- safe spawn
- outdoor PvP area
- next Gym tease
- Brawl access

### Training

- 5 polished training actions
- multiple weight tiers
- visible Strength/body response

### Progression

- Strength
- Toughness/Agility minimal
- first Rebirth
- next Gym gate

### Collection

- small Pet set sufficient to prove:
  - acquire
  - reveal
  - equip
  - multiplier
  - collection
  - save

No mass pet content yet.

### PvP

- Punch
- 2 Moves
- death/respawn
- spawn protection
- KO reward rules

### Event

- Brawl

### UI

- HUD
- training context
- Pets
- Rebirth
- Moves
- Shop skeleton
- mobile layouts

### Persistence/security

- profile save/load
- server authority
- Remote validation
- paid receipt structure only where needed

---

## 21. Slice acceptance gates

새 Gym/Pet/Move 대량 추가 전에:

### Runtime

- clean boot
- project-attributable unexpected runtime error 0
- normal spawn
- save/load
- respawn
- no dead critical buttons

### First-session

- first action ≤10 sec
- first reward ≤30 sec
- meaningful progression ≤90 sec
- long-term aspiration visible ≤3 min

### Training

- 5분 반복해도 animation/feedback가 견딜 만함
- weight upgrade가 체감됨
- body progression이 보임

### PvP

- hit feels connected to animation
- spawn camping mitigated
- giant/small character collisions do not break combat
- same-player farming is not optimal reward strategy

### Pets

- acquire/equip/unequip/save stable
- multiplier authoritative
- collection understandable
- Pet UI does not dominate first session

### UI

- primary action immediately discoverable
- PC/mobile no clipping
- world visibility preserved

### Visual

- player-facing hero placeholder 0
- gameplay-camera review
- coherent art kit
- no obvious floating/clipping/z-fighting
- major asset scale validated against avatar/body stages

---

## 22. Codex autonomous workflow

Codex에게 단순 구현만 시키지 않는다.

```text
1. pull latest main
2. read Godbase mandatory docs
3. research current reference games
4. record reference findings
5. inspect actual Studio/DataModel
6. create spatial/system plan
7. implement one coherent section
8. Studio Playtest
9. inspect console
10. capture/review gameplay screenshots
11. repair
12. replay exact route
13. commit coherent change
14. repeat
```

대규모 one-shot map generation 금지.

Studio에서 보지 않은 결과를 production-ready라고 부르지 않는다.

---

## 23. Metrics after release

초기 funnel:

```text
SessionStart
→ FirstTrain
→ FirstWeightUpgrade
→ FirstPet
→ FirstPvPContact
→ FirstBrawl
→ FirstRebirth
→ NextGymUnlock
```

추가 질문:

- FirstTrain까지 얼마나 걸리는가?
- 첫 Pet 전에 이탈하는가?
- 자유 PvP가 retention을 올리는가 아니면 초보 이탈을 만드는가?
- Rebirth 요구 시간이 적절한가?
- 어떤 pass/product가 실제로 사용 가치를 주는가?
- Pet collection이 progression 목표로 읽히는가?

---

## 24. Current decisions

확정:

- Training Simulator 진행
- Muscle Legends 계보의 현대화
- 자유 PvP 유지
- visible body growth 중요
- Pets 포함
- Pet은 core training을 증폭하는 collection layer
- 첫 slice부터 Pet loop 최소 구현
- 대량 Pet 콘텐츠는 quality gate 이후
- Codex가 reference/asset research를 스스로 수행
- Codex가 Studio를 직접 보고 반복 수정하는 workflow 목표
- 외부 에셋 적극 사용하되 audit 필수

미확정:

- 최종 게임명
- Body Stage final names/count
- 정확한 Gym themes
- Pet visual theme
- first 5 training stations final selection
- Brawl scoring format
- exact monetization prices
- exact economy numbers
- subscription 여부
- trade 여부

미확정 항목은 실제 asset supply, reference research, Studio vertical slice 결과를 보고 결정한다.
