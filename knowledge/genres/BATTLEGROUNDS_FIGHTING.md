# Battlegrounds / Fighting Starter Recipe

> 검증 기준일: 2026-09-04

## 목표

짧은 학습 시간, 높은 표현력, 즉시 PvP가 가능한 Roblox battlegrounds/brawler를 만든다. 장르의 핵심은 content breadth보다 **타격감·회피·combo·readability·재진입 속도**다.

## Reference vocabulary

대표 참고 축:
- The Strongest Battlegrounds — moveset 기반 open lobby PvP, block/dash/ragdoll/evasive/ultimate
- Jujutsu Shenanigans — arena chaos, awakening/ultimate spectacle, environmental interaction 연구용

현재 공개 Roblox 페이지에서 The Strongest Battlegrounds 계열 설명은 mobile/PC/console 대응, block/dash/run/punch/ultimate control grammar를 명시한다.

참고:
- https://www.roblox.com/games/10449761463/The-Strongest-Battlegrounds
- https://www.roblox.com/games/9391468976/Jujutsu-Shenanigans

## Core loop

```text
moveset 선택
→ 5초 내 상대 탐색
→ neutral
→ hit confirm / combo / escape
→ KO 또는 disengage
→ 즉시 재진입
→ mastery/cosmetic/character expression
```

## Vertical slice

- arena 1개
- moveset 2개
- 각 moveset: M1 chain + mobility + defense + 3 skills + ultimate 1
- dummy 1
- 1v1 가능한 live combat
- respawn
- minimal leaderboard/KO feedback
- mobile controls

새 캐릭터 10명을 만들기 전에 이 2개가 서로 다른 playstyle로 느껴져야 한다.

## Combat grammar

### Neutral
- walk/run/dash distance가 명확
- hitbox가 visual보다 과도하게 크지 않음
- whiff punishment 가능
- block가 무조건 안전하지 않음

### Combo
- starter → extender → finisher 구분
- infinite 방지
- hitstun/knockback/ragdoll duration 표준화
- combo escape/evasive는 명확한 resource/cooldown

### Ultimate
- meter 획득 원리가 이해됨
- activation이 즉시 판정승 버튼이 아님
- spectacle와 telegraph 둘 다 존재

## Feel acceptance

- animation marker와 hit frame 일치
- SFX/impact/VFX/hitstop 우선순위 일관
- camera shake는 target reading을 방해하지 않음
- ragdoll camera가 멀미/입력 손실을 만들지 않음
- latency에서 hit result가 불합리하게 뒤집히지 않음
- valuable combat state는 server authoritative

## Map

Battleground arena는 화려한 open world가 아니다.
- sightline 관리
- fight density 유지
- spawn protection
- traversal landmark
- 환경 파괴가 있으면 reset policy
- 벽/모서리 infinite combo 방지

## UI

전투 중 보여줄 것만:
- HP
- skill cooldown
- ultimate meter
- target/lock-on 상태가 있으면 그 정보

inventory-style clutter 금지.

## Progression

가급적 power grind보다 expression 중심:
- mastery badge/title
- cosmetics
- emotes
- kill effects
- alternate visual variants

PvP power advantage를 결제/장기 grind로 과도하게 만들면 new-user bounce가 커질 수 있다.

## P0 routes

1. spawn → moveset 선택 → dummy에 full basic combo
2. player A vs B: block/dash/skill/KO
3. ragdoll → evasive → combat 복귀
4. ultimate charge → activate → expiry
5. death/respawn 후 cooldown/state reset
6. mobile skill activation + camera control
7. artificial latency/network simulation에서 핵심 hit flow

## Scale gate

아래 전에는 3번째 moveset 금지:
- 두 moveset 모두 재미있음
- mirror match와 cross-match 둘 다 무한 combo 없음
- 10분 PvP에서 Output error 0
- mobile에서 조작 가능
- screenshot/video frame상 impact가 reference 수준의 명확한 hierarchy를 가짐
