# Horror / Run-Based Starter Recipe

> 검증 기준일: 2026-09-04

## 목표

긴 cutscene보다 **공간 읽기, anticipation, 규칙 학습, death-as-information, 빠른 재시도**가 작동하는 Roblox horror를 만든다.

## Reference vocabulary

대표 참고 축:
- DOORS — room progression, entity rule learning, death as lesson, audio/visual cue hierarchy
- Pressure — run structure, environmental storytelling, threat variation 연구용

참고:
- https://www.roblox.com/games/6516141723/DOORS

DOORS 공식 공개 설명도 guide 없이 trial-and-error를 권하고, 죽음을 lesson으로 사용하는 구조를 명시한다.

## Core loop

```text
안전한 탐색
→ 미묘한 cue
→ 위험 규칙 추론
→ 대응 input/route
→ 생존 또는 death
→ 정보 획득
→ 즉시 retry / deeper run
```

## Vertical slice

- 8~12 room 또는 1 compact facility
- threat 3종: audio-led / visual-led / chase or spatial
- safe room 1
- loot/item 3~5개
- death feedback
- checkpoint 또는 rapid restart
- ambient audio layers
- one scripted set piece

## Fear rules

- 점프스케어는 보상이지 core mechanic이 아니다.
- threat cue는 반복 플레이에서 학습 가능해야 한다.
- fake cue를 남발하지 않는다.
- darkness가 정보 부족과 동일하지 않게 한다.
- player가 죽고도 `왜 죽었는지` 모르면 design failure로 본다.

## Audio

우선순위:
1. lethal cue
2. interaction/state cue
3. spatial ambience
4. music

모든 층이 큰 소리이면 공포가 아니라 noise가 된다.

## Environment

- silhouette/lighting로 route를 안내
- prop clutter는 story와 hiding/navigation에 기여
- door/locker/vent 등 interactive vocabulary 일관
- dead end는 의도적 tension 아니면 최소화

## Randomization

좋은 randomization:
- room order
- item spawn
- threat timing 범위
- side event

나쁜 randomization:
- counterplay 없는 instant death
- essential objective가 unreachable
- cue와 threat rule이 매번 달라짐

## P0 routes

1. first-time route: threat 1의 cue → correct response
2. intentionally fail → death explanation → retry
3. threat overlap edge case
4. hiding spot enter/exit
5. chase path complete
6. audio off 또는 낮은 volume에서 accessibility fallback 검토
7. mobile interaction/chase

## Scale gate

아래 전에는 entity 10개 추가 금지:
- 3 threat가 서로 다른 학습을 요구
- death reason이 명확
- 10분 run tension curve가 있음
- restart friction이 낮음
- lighting/post FX가 gameplay cue를 가리지 않음
