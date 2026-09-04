# Survival / Extraction / Co-op Starter Recipe

> 검증 기준일: 2026-09-04

## 목표

탐색 중 얻는 loot와 위험이 귀환/생존 결정에 긴장을 주는 co-op survival/extraction 구조를 만든다. 핵심은 **전투 자체보다 risk management와 팀 의사결정**이다.

## Reference vocabulary

대표 참고 축:
- Dead Rails — 장거리 이동/vehicle hub, zombie threat, class/start loadout, co-op journey
- 99 Nights 류 — 장기 생존/기지/주기적 위험 구조 연구용

공개 참고:
- https://www.roblox.com/games/116495829188952/Dead-Rails

## Core loop

```text
준비/역할 선택
→ 안전지대 이탈
→ resource/loot 탐색
→ threat/attrition 발생
→ 더 갈지 돌아갈지 결정
→ extraction/생존
→ persistent unlock 또는 다음 run 준비
```

## Vertical slice

- safe hub 1
- expedition route 1
- POI 3~5개
- enemy 3종
- loot category 4종
- inventory capacity
- heal/repair resource
- extraction/end condition
- 2~4 player co-op
- one class/loadout choice

## Risk design

플레이어가 매 순간 알 수 있어야 한다.
- 현재 보유 가치
- 남은 생존 resource
- 돌아갈 거리/위험
- 다음 POI의 기대 보상

숨긴 숫자로만 난이도를 만들지 않는다.

## Co-op roles

역할은 단순 stat bonus보다 행동 차이를 선호한다.
- scout
- carrier
- medic/support
- combat/control
- engineer/repair

모든 플레이어가 한 명 없으면 게임 진행 불가가 되지 않게 한다.

## Inventory / loot

- 가치와 무게/slot trade-off
- 즉시 사용 vs 보관 decision
- rarity보다 utility를 먼저 설계
- duplicate handling
- death/loss policy 명확

## World

- POI silhouette가 멀리서 읽힘
- safe/unsafe rhythm
- resource density가 route choice를 만듦
- random spawn이 objective reachability를 깨지 않음

## Networking/security

- loot spawn/pickup은 server authority
- inventory delta transaction 기록
- revive/repair/interact distance server 재검증
- vehicle/network ownership 변화 테스트

## P0 routes

1. solo/2-player start → loot → extraction
2. inventory full → swap/drop
3. player down → revive
4. disconnect 중 inventory/loot ownership 처리
5. vehicle 이동 중 ownership/physics 안정성
6. death/loss policy 저장 검증
7. 4 simulated clients join/leave smoke test

## Scale gate

아래 전에는 procedural map/대형 world 금지:
- 한 route에서도 risk/reward decision이 3회 이상 발생
- 2-player co-op가 solo와 실제로 다르게 느껴짐
- loot duplication 기본 공격에 안전
- extraction result가 저장과 정확히 일치
- 이동/전투/POI density가 지루하지 않음
