# Action RPG / Open World Starter Recipe

> 검증 기준일: 2026-09-04

## 목표

탐험, 전투, 성장, 장비/스킬 선택이 서로 연결된 Roblox 액션 RPG를 만든다. 핵심은 **숫자 성장보다 전투와 이동의 즉각적인 감각**을 먼저 완성하는 것이다.

## Reference vocabulary

현재 대표적인 참고 축:
- Blox Fruits — 전투 스타일 선택, 보스, 섬 단위 탐험, 장기 성장
- Arcane Odyssey — 세계 탐험, 다중 전투 스타일, 아이템 다양성, 세력/클랜/해상 이동

공개 페이지:
- https://www.roblox.com/games/2753915549/Blox-Fruits
- https://www.roblox.com/games/3272915504/Arcane-Odyssey

## Core loop

```text
landmark 발견
→ 적/이벤트 접촉
→ readable combat
→ loot/xp/resource 획득
→ 즉시 체감되는 upgrade/choice
→ 더 위험하거나 새로운 landmark로 이동
```

## 첫 3분

- 10초 내 이동 가능.
- 30초 내 첫 적 또는 상호작용.
- 60초 내 첫 보상.
- 180초 내 첫 upgrade 또는 새 공격 선택.
- 튜토리얼 텍스트보다 실제 행동으로 가르친다.

## Vertical slice

한 지역만 만든다.
- hub/안전공간 1
- combat field 1
- landmark 3
- 일반 적 2종
- elite/boss 1종
- 무기/스타일 2개
- 장비/loot 6~12개
- 짧은 quest 2개
- secret/chest 2개
- fast travel은 0~1개

플레이어가 5~10분 동안 `탐험 → 전투 → 성장 → 보스 → 새 보상`을 한 번 완주하면 된다.

## Combat acceptance

- hit timing이 animation과 맞음
- 공격마다 range/readability가 다름
- enemy telegraph가 damage보다 먼저 보임
- camera/FOV/shake가 입력을 방해하지 않음
- stun/ragdoll은 짧고 이유가 명확함
- server가 damage/loot/progression 최종 판정
- 모바일에서 같은 핵심 행동 수행 가능

관련 Godbase:
- `combat/COMBAT_FEEL_PLAYBOOK.md`
- `combat/HIT_DETECTION_HITBOXES_PROJECTILES.md`
- `camera/CAMERA_AND_GAME_FEEL.md`
- `animation/ANIMATION_AND_RIGGING_PIPELINE.md`
- `gameplay/INVENTORY_EQUIPMENT_ARCHITECTURE.md`
- `gameplay/QUEST_OBJECTIVE_MISSIONS.md`
- `level-design/LEVEL_DESIGN_WORLD_TRAVERSAL.md`

## World rules

- 길은 목적지가 아니라 landmark를 연결하는 압축된 경험이다.
- 시작 지역을 넓게 만들지 않는다.
- enemy density는 이동의 의미를 망치지 않을 정도만.
- height/bridge/cave/shore 같은 silhouette 차이를 쓴다.
- biome change는 색만 바꾸지 말고 enemy/navigation/reward grammar도 변한다.

## Progression

좋은 초반 progression:
- horizontal choice + noticeable power gain
- 첫 세션에서 신규 행동 최소 1개
- 새 지역은 숫자 gate만이 아니라 플레이 변화도 제공

피할 것:
- 수십 레벨 동안 같은 공격 반복
- 첫 보스 전까지 장비 변화 없음
- 단순 HP/DMG 배수만 늘림
- 모든 item rarity가 실질적으로 같은 역할

## UI

기본 HUD는 최소화:
- HP/resource
- active skill slots
- objective marker
- contextual interaction

inventory/character sheet는 전투 중 화면을 덮지 않는다.

## Starter procurement

우선순위:
1. Roblox official environment/template/asset
2. Godbase S/A environment source subset
3. 검증된 weapon/NPC rig
4. custom hero assets

stylized RPG라면 `Synty Nature Pack`, 공식 Forest Pack 등에서 coherent subset을 먼저 검토한다. 전체 팩을 그대로 ship하지 않는다.

## P0 test routes

1. spawn → 첫 적 처치 → loot 획득 → 장비/스킬 변화 확인
2. 첫 quest 수락 → 목표 완수 → 보상
3. elite/boss telegraph 회피 → 처치 → unique reward
4. 사망 → respawn → 진행 상태 정상
5. 모바일 primary combat route

## Scale gate

아래가 통과하기 전 두 번째 지역을 만들지 않는다.
- 첫 전투가 재미있음
- 첫 boss가 읽힘
- 첫 upgrade가 체감됨
- 시작 지역 screenshot이 placeholder처럼 보이지 않음
- P0 route를 AI가 Studio MCP로 반복 통과
