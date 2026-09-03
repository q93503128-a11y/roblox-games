# Combat Feel Playbook

> 검증 기준일: 2026-09-03

전투 시스템은 "데미지가 들어간다"와 "재미있는 전투"가 완전히 다르다. Roblox 전투는 입력 반응, 애니메이션, 카메라, hit feedback, 적 telegraph, 네트워크 권한, 공간 설계가 함께 맞아야 한다.

관련 공식 자료:

- Animation: https://create.roblox.com/docs/animation
- Remote events/functions: https://create.roblox.com/docs/scripting/events/remote
- Server authority: https://create.roblox.com/docs/projects/server-authority
- Raycasting: https://create.roblox.com/docs/workspace/raycasting
- Spatial queries/API는 Engine API 최신 문서 확인
- Effects: https://create.roblox.com/docs/effects
- Input Action System: https://create.roblox.com/docs/input/input-action-system

## 1. 전투를 숫자보다 먼저 정의

```text
player fantasy:
combat pace:
engagement range:
mobility:
defense option:
resource model:
combo depth:
enemy density:
TTK target:
reference games:
```

예: 빠른 action RPG와 느린 tactical RPG는 같은 sword script를 써도 전혀 다른 게임이다.

## 2. Input → Result latency

사용자가 공격 버튼을 누른 직후 **반응이 즉시 보여야 한다.**

권장:

```text
input
→ client presentation 즉시 시작
→ server에 attack intent
→ server 검증/authoritative result
→ damage/state replication
```

클라이언트는 swing animation/VFX를 즉시 보여줄 수 있지만 실제 재화/HP/드랍의 최종 판정은 서버가 한다.

## 3. 공격 4단계

```text
startup
active
impact
recovery
```

튜닝 포인트:

- startup: 반응성 vs 읽힘
- active: 실제 hit window
- impact: hitstop/sound/VFX/camera/damage number
- recovery: 공격 commit와 combo rhythm

애니메이션과 hit timing이 어긋나면 아무리 VFX가 좋아도 싼 느낌이 난다.

## 4. Hit detection 방식

게임에 따라 선택.

### Raycast

- 총기/직선 공격
- 빠른 slash trace

### Spatial query / hitbox volume

- 근접 cone/box/radius
- AoE

### Projectile

- 물리/kinematic projectile
- 서버 검증 + client presentation 조합

### Touched

간단한 world interaction에는 편하지만 고품질 전투의 유일한 hit detection으로 무조건 쓰지 않는다. 물리 접촉 timing/중복 이벤트/ownership을 고려해야 한다.

## 5. Hitbox 원칙

- 보이는 공격 범위와 비슷해야 함
- 공격마다 명확한 data definition
- 동일 target 중복 hit 제어
- team/friendly fire 규칙 명확
- invulnerability frame가 있다면 서버 상태로 관리
- client가 맞은 target 목록이나 damage를 최종 진실로 제출하지 않음

## 6. Hit feel 구성요소

작은 공격 하나에서도 몇 가지를 조합한다.

- animation recoil
- hitstop 또는 짧은 attacker pause
- target reaction
- impact sound
- hit spark
- damage number
- tiny camera impulse
- knockback
- health-bar response

모두 강하게 쓰지 않는다. 공격 tier에 따라 강도를 나눈다.

## 7. Hitstop

아주 짧은 pause가 impact를 키울 수 있다.

주의:

- 전체 서버 simulation을 멈추지 않음
- multiplayer에서 다른 플레이어 경험을 깨지 않음
- animation speed/presentation을 국소적으로 조정
- 반복 공격마다 너무 길면 답답함

## 8. Camera shake

작은 공격은 작게, 큰 공격은 크게.

카메라 shake에서 중요한 것:

- amplitude
- frequency
- duration
- 방향
- 중첩 제한

여러 타격이 겹쳐 카메라가 통제 불가능해지지 않게 budget을 둔다.

## 9. Knockback

knockback은 숫자가 아니라 공간의 리듬을 만든다.

검사:

- 작은 적 vs boss
- 벽/낭떠러지
- combo 지속 가능성
- network ownership
- stun lock
- PvP exploit

모든 hit에 물리 impulse를 크게 주면 전투가 흐트러진다.

## 10. Combo

좋은 combo는 버튼 연타만 늘리는 것이 아니다.

variation 예:

- light chain
- heavy finisher
- launcher
- aerial
- dash cancel
- resource spender
- directional variation

combo depth는 input complexity와 target audience에 맞춘다.

## 11. Enemy telegraph

적 공격은 플레이어가 이유를 이해하고 대응할 수 있어야 한다.

강한 공격:

```text
anticipation animation
+ color/VFX shape
+ sound cue
+ ground/space telegraph
→ active attack
→ recovery opening
```

피격 후에도 "왜 맞았는지" 이해가 안 되면 불공정하게 느낀다.

## 12. 적 다양성

역할 기반으로 설계하면 좋다.

- chaser
- ranged pressure
- tank/blocker
- area denial
- support/healer
- assassin
- summoner
- elite modifier

각 적은 플레이어에게 다른 이동/우선순위 결정을 요구해야 한다.

## 13. Boss

좋은 boss는 HP가 큰 일반몹이 아니다.

최소:

- distinct silhouette
- phase 또는 pattern 변화
- 읽을 수 있는 큰 telegraph
- safe/opening window
- arena interaction 또는 movement demand
- 특별 reward/presentation

phase마다 완전히 새로운 시스템보다 기존 학습을 확장하는 방식이 보통 좋다.

## 14. TTK

Time-to-kill은 장르 감각을 크게 좌우한다.

초반 일반몹은 core action을 배우기 충분히 살아있되 지루하지 않아야 한다.

측정:

- basic attack만
- expected build
- skilled combo
- multiplayer scaling

"HP 100" 자체보다 **몇 번/몇 초에 죽는가**를 본다.

## 15. Resource

mana/stamina/energy/rage를 넣는 이유를 명확히 한다.

좋은 resource는:

- 의사결정을 만듦
- rotation/tempo를 만듦
- build differentiation을 지원

단순히 기다리게만 만드는 resource는 다시 검토.

## 16. Movement와 combat

공격 중 이동 규칙을 정의한다.

- 완전 고정
- 느려짐
- 자유 이동
- root motion-like dash
- 방향 입력으로 변형

게임마다 다르지만 의도 없이 animation이 캐릭터 movement와 싸우게 두지 않는다.

## 17. Targeting

- free aim
- soft aim assist
- lock-on
- nearest target
- tab/selection

모바일/게임패드에서 같은 combat을 어떻게 사용할지 함께 설계한다.

## 18. Multiplayer combat

- player count에 따른 enemy HP만 늘리는 단순 scaling 주의
- enemy aggression target logic
- revive/downed
- reward contribution
- boss telegraph 가시성
- 여러 플레이어 VFX clutter

4명이 때릴 때도 공격을 읽을 수 있어야 한다.

## 19. PvP 추가 주의

- client-reported hit를 맹신하지 않음
- lag compensation은 공정성/abuse trade-off 고려
- movement exploit detection
- network ownership
- rate limit
- impossible-state validation
- false positive가 큰 즉시 ban보다 server-side consequence ladder

## 20. 전투 품질 테스트

한 적/한 무기로 먼저 측정한다.

```text
입력 즉시 반응하는가?
hit frame이 보이는 타격과 맞는가?
타격음이 선명한가?
적이 맞았다는 것이 보이는가?
내가 맞기 전에 공격을 읽을 수 있는가?
왜 죽었는지 이해하는가?
카메라가 전투를 돕는가?
30초 반복해도 피곤하지 않은가?
```

이 테스트가 실패하면 skill tree, rarity, 50개 무기를 추가하지 않는다.

## 21. Reference capture sheet

전투 레퍼런스를 조사할 때 기록:

```text
WalkSpeed 체감
FOV
camera distance
basic attack duration
combo reset time
hit pause
knockback
enemy telegraph duration
projectile speed
mob density
TTK
VFX scale
sound hierarchy
damage number behavior
```

정확한 내부 코드를 알 필요 없이 **관찰 가능한 관계를 추출**한다.
