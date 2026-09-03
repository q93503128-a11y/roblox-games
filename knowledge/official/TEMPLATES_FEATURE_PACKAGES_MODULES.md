# Official Templates, Feature Packages, and Developer Modules

> verified: 2026-09-03
> trust: S — Roblox official

## 왜 이 문서가 중요한가

Roblox에서 흔한 기능을 처음부터 다시 만들기 전에 **Roblox가 직접 제공하는 작동 예제와 feature package를 확인**한다. 공식 Template은 uncopylocked starting experience이며, Feature Package는 back-end + UI + analytics를 함께 제공한다.

## Templates

Official docs: https://create.roblox.com/docs/resources/templates

### Platformer
포함:
- double jump
- dash
- roll
- long jump
- moving platforms
- one-way platforms
- coin pickup
- example tower course

연구 가치:
- character state/movement
- platform interaction
- action input
- traversal feel

### Laser Tag
연구 가치:
- blaster damage/ammo/recoil/spread
- teams/rounds
- hit detection
- polished arena reference

Gameplay Scripting official curriculum도 큰 laser-tag project를 기반으로 한다.

### FPS System
- blasters
- targets
- FPS baseline

### Racing / Classic Racing
- vehicle behavior
- modular track
- race progression reference

### Combat
- sword
- pistol
- health pack

작은 action game의 baseline을 보기에 적합하다.

### Concert
- live event / cutscene sequencing
- Event Sequencer reference

### Modern City / Village / Mansion of Wonder
환경 kit, modular construction, VFX/visual composition 연구에 활용.

### Move It Simulator / Island of Move
Simulator/animation/character interaction 학습 reference.

### UGC Homestore
avatar commerce flow와 shop presentation reference.

### 기타 공식 시작점
Baseplate, Flat Terrain, Starting Place, Line Runner, Capture the Flag, Team/FFA Arena 등.

## Template 사용 규칙

1. 먼저 원본을 별도 test place에서 실행한다.
2. 기능/데이터/아트의 경계를 표시한다.
3. 그대로 들고 갈 코드와 학습만 할 코드를 구분한다.
4. 프로젝트가 필요 없는 시스템은 삭제한다.
5. 원본 업데이트에 의존할지 fork 후 ownership할지 결정한다.
6. 최종 게임의 art direction과 identity는 별도 확립한다.

---

# Feature Packages

Docs: https://create.roblox.com/docs/resources/feature-packages

Roblox는 Feature Package를 fully functional/customizable drag-and-drop feature로 설명한다. 일반적으로 다음을 포함한다.
- functional back-end code
- default UI
- game design / UI UX best practices
- funnel analytics / insights

## Core
Creator Store asset ID: `94918533221001`
Role: 다른 Feature Package의 shared dependency.

## Bundles
Asset ID: `72975253516300`
Use:
- 여러 item 묶음 판매
- discount/prompt 흐름
- currency/item registration

## Missions
Asset ID: `89760436366160`
Use:
- task/goal tracking
- mission reward loop
- progression engagement

## Season Passes
Asset ID: `89781974928804`
Status at verification: beta.
Dependencies: Core + Missions 확인 필요.
Use:
- seasonal progression track
- repeat engagement

## Engagement Rewards
Asset ID: `80053655757903`
Use:
- engagement milestone reward patterns

## Feature Package integration rule

Feature Package는 hierarchy와 내부 연결을 전제로 할 수 있다. 따라서:
- vendor package처럼 취급
- package 내부 구조를 무지성으로 재배치하지 않음
- customization seam부터 찾음
- server/client security review
- DataStore namespace/test place 분리
- funnel event가 프로젝트 analytics taxonomy와 충돌하지 않는지 검사

라이브 게임의 실제 DataStore를 Studio에서 테스트하지 않는다.

Change log:
https://create.roblox.com/docs/resources/feature-packages/changelog

---

# Developer Modules

Docs: https://create.roblox.com/docs/resources/modules

공식 Developer Module은 social/experience feature를 빠르게 추가하는 목적으로 제공된다.

현재 공식 목록에서 확인된 주요 모듈:
- Selfie Mode
- Merch Booth
- Friends Locator
- Spawn With Friends
- Emote Bar
- Profile Card
- Photo Booth
- Surface Art
- Scavenger Hunt
- Social Interactions
- Event Sequencer

## Friends Locator
Known official asset ID: `11338008960`
Use:
- 친구 위치 표시
- friend teleport/social navigation

## Selfie Mode
Known official asset ID: `11338094218`
Use:
- social capture / pose UX

## Merch Booth
Known official asset ID: `11338021801`
Use:
- avatar assets
- passes / developer products (current docs 확인)

Third-party asset sales와 commerce 설정은 항상 최신 Roblox policy/settings를 다시 확인한다.

## Spawn With Friends
Docs: https://create.roblox.com/docs/resources/modules/spawn-with-friends
- friend near-spawn
- free-space validation
- configurable behavior

## Emote Bar
Docs: https://create.roblox.com/docs/resources/modules/emote-bar
- emote bar/wheel
- social expression

## Scavenger Hunt
Docs: https://create.roblox.com/docs/resources/modules/scavenger-hunt
- exploration collectible pattern
- persistent collection
- CollectionService tags 활용

## Event Sequencer
Docs: https://create.roblox.com/docs/resources/modules/event-sequencer
- scheduled live event/cutscene framework
- scene sequence
- audio/animation/tween timing
- preview/seek workflows

Concert template와 함께 연구 가치가 높다.

## 사용 기준

공식 모듈이라고 무조건 넣지 않는다.

채택 질문:
- core loop를 실제로 강화하는가?
- maintenance ownership을 감당할 수 있는가?
- UI가 현재 design system과 맞는가?
- mobile/gamepad에서 검증했는가?
- persistent data namespace가 안전한가?
- analytics events가 정의되어 있는가?

## Godbase 규칙

새 기능 요청이 `missions / pass / bundle / social friend feature / scavenger hunt / live event / emote / shop` 계열이면 **custom implementation 계획을 쓰기 전에 이 문서를 먼저 확인**한다.

알 수 없는 Asset ID는 추측해 기록하지 않는다. Creator Store ID가 공식 source에서 확인될 때만 catalog에 넣는다.
