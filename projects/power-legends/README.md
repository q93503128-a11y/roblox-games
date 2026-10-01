# Power Legends (working title)

> Status: PREPRODUCTION / DESIGN
> Updated: 2026-10-01
> Primary genre: Training / Incremental Simulator + Open-world PvP
> Workflow target: Codex-led implementation + Roblox Studio MCP + Git + Studio playtest

## One-line fantasy

약골로 시작해 훈련하고 몸집과 힘을 키운 뒤, 서버의 다른 플레이어와 자유롭게 싸우며 인간을 초월하는 초거대 강자가 되는 Roblox식 파워 판타지.

## Product direction

이 프로젝트는 현실적인 헬스 시뮬레이션보다 **Muscle Legends 계열의 단순하고 즉각적인 성장감**을 현대화하는 것을 목표로 한다.

핵심 조합:

- Muscle Legends: 자유 PvP, 거대한 신체 성장, Rebirth, Gym 해금, Brawl
- Gym League: 현대적인 훈련 presentation, 기구별 contextual UI, 운동 애니메이션 품질
- Strongman Simulator: 점점 더 황당하게 무거운 물체를 다루는 시각적 성장
- 현대 incremental simulator: 빠른 첫 보상, 명확한 다음 목표, collection aspiration
- Pet/companion system: 수집, 장기 목표, social flex, 장착 슬롯 기반 성장

특정 게임의 UI, 맵, 캐릭터, 에셋을 그대로 복제하지 않는다. 레퍼런스에서는 성공적인 **게임 문법, UX 흐름, progression rhythm, spatial grammar**만 추출한다.

## Core loop

```text
Train
→ Strength/Toughness/Agility 성장
→ 몸/들 수 있는 중량/전투력이 눈에 띄게 변화
→ 더 좋은 기구와 무거운 물체 사용
→ Gems / Pets / Moves / Gym unlock
→ 자유 PvP + Brawl + social flex
→ Rebirth
→ 이전 구간 압축 + 신규 콘텐츠 해금
→ repeat
```

## Design pillars

1. 숫자보다 먼저 몸과 월드가 성장해야 한다.
2. 훈련 10초 안에 보상이 보여야 한다.
3. 강한 플레이어의 크기와 행동이 서버의 살아있는 콘텐츠가 되어야 한다.
4. 자유 PvP의 위험과 장난스러운 긴장감을 유지한다.
5. UI는 적고 명확하게, contextual UI를 우선한다.
6. Pets는 별도 게임이 아니라 training progression을 증폭시키는 collection layer다.
7. 외부/Creator Store asset은 먼저 확보·검수하고 그 vocabulary에 맞춰 아트 방향을 정한다.
8. Codex는 직접 reference research → 구현 → Studio playtest → screenshot review → repair를 반복한다.

## Current scope

첫 production-quality vertical slice:

- Starter Gym 1개
- 다음 Gym tease/unlock 1개
- 핵심 운동 5종
- Body progression 몇 단계
- 자유 PvP
- 기본 Punch + Move 2개
- Rebirth 1회
- Brawl 1종
- Pet collection/equip의 최소 완성 루프
- Shop/HUD/Save
- PC + mobile primary route

세부 기획은 `docs/GAME_DESIGN.md`를 정본으로 사용한다.

## Development rule

기능 수가 아니라 실제 플레이 품질을 진척도로 본다.

```text
research
→ design
→ one coherent vertical slice
→ Studio visual/runtime test
→ repair
→ human feel test
→ scale content
```

첫 slice가 재미/가독성/성장감 기준을 통과하기 전에는 Gym, Pet, Move, 통화를 대량 추가하지 않는다.
