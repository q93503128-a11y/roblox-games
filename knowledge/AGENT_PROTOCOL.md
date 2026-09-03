# Agent Protocol — How AI Must Use Roblox Godbase

> verified: 2026-09-03

이 문서는 다른 채팅/AI/Codex 세션에서도 Godbase가 실제 행동을 바꾸도록 만드는 실행 규칙이다.

## Before any Roblox implementation

AI는 다음을 수행한다.

1. 현재 `main` HEAD 확인.
2. `knowledge/GODBASE_MANIFEST.json` 읽기.
3. `knowledge/QUICK_REFERENCE.md` 읽기.
4. `knowledge/regressions/FAILURE_LIBRARY.md`에서 관련 failure 확인.
5. 해당 domain 전문 문서 읽기.
6. 기존 project이면 그 project README/docs/current source를 먼저 읽기.
7. 사용자가 요청하지 않은 migration/rewrite를 하지 않기.

## Before starting a new project

필수:
- project start checklist
- toolchain decision
- reference games
- official Template/Feature Package/Module 조사
- art direction
- vertical slice scope
- security boundary
- test route

그 후에만 코드를 대량 생성한다.

## Before inventing a system

다음 순서로 reuse candidate를 찾는다.

1. Roblox official Engine/API
2. official Templates
3. official Feature Packages
4. official Developer Modules
5. approved Godbase library catalog
6. audited Creator Store
7. community code with license
8. custom implementation

Custom이 항상 나쁜 것은 아니지만 **기존 검증 solution을 모른 채 재발명하는 것**을 금지한다.

## Before visual/UI work

- real Roblox reference screenshots/observations
- art/design tokens
- audited/generative asset candidates
- gameplay camera scale
을 확보한다.

Part-only placeholder는 blockout에서만 사용.

## During implementation

- smallest coherent change
- Studio playtest immediately
- output/screenshot inspect
- regression route
- then next change

Studio MCP가 available한데 user에게 첫 structural QA를 맡기지 않는다.

## Before claiming done

`testing/AUTOMATED_ACCEPTANCE_GATES.md`와 project-specific gate를 통과해야 한다.

'코드 작성 완료'와 '게임 테스트 완료'는 다른 상태다.

Allowed status labels:
- `DESIGN`
- `INTERNAL_PROTOTYPE`
- `BOOT_VERIFIED`
- `VERTICAL_SLICE_TESTED`
- `USER_TEST_READY`
- `RELEASE_CANDIDATE`

검증 없이 상위 상태를 주장하지 않는다.

## When a failure occurs

첫 번째:
- root cause
- fix
- regression

같은 subsystem에서 구조 실패가 반복되면:
- patch stacking 중단
- architecture reassessment
- rollback/replacement 고려

새로운 generalizable lesson은 `regressions/FAILURE_LIBRARY.md`로 환류한다.

## Source handling

외부 자료를 발견하면 SOURCE_POLICY 등급을 붙인다.
- S official
- A established OSS
- B useful community
- C discovery only
- Reject

도난/decompile/executor dump/license unclear source를 production reuse하지 않는다.

## Freshness

현재 날짜에 따라 달라지는 것:
- Roblox beta/engine feature
- monetization/policy
- Creator Rewards
- Discovery signals
- tool versions
- library maintenance
- Creator Store asset

은 Godbase 날짜만 믿지 말고 공식 current source를 확인한다.

## User preference vs Godbase

Godbase는 default recommendation이다. 사용자가 명시한 workflow/constraint가 안전하고 합법적인 범위라면 존중한다.

예:
- existing project가 Rojo면 갑자기 Script Sync로 전체 migration 금지.
- user가 Studio-first를 원하면 단순히 repo가 Rojo-friendly하다는 이유로 Rojo 강제 금지.

## No cargo-cult reuse

Godbase에 library 이름이 있다는 이유로 import하지 않는다.
문제와 비용을 비교한다.

예:
- simple 3-button HUD에 giant framework 불필요
- single save value 때문에 full architecture package 불필요할 수 있음

## Quality principle

AI의 목표는 파일 수/코드 줄 수/feature count가 아니다.

우선순위:
1. 실제로 실행
2. 실제로 안전
3. 실제로 재미/사용 가능
4. 실제로 보기 좋음
5. 유지보수 가능
6. 그 다음 content breadth

이 protocol은 모든 Roblox project 대화의 기본 개발 discipline로 취급한다.
