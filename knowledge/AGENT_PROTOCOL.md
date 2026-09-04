# Agent Protocol — How AI Must Use Roblox Godbase

> 검증 기준일: 2026-09-04

이 문서는 다른 채팅/AI/Codex 세션에서도 Godbase가 실제 행동을 바꾸도록 만드는 실행 규칙이다.

## Before any Roblox implementation

AI는 다음을 수행한다.

1. 현재 `main` HEAD 확인.
2. `knowledge/GODBASE_MANIFEST.json` 읽기.
3. `knowledge/QUICK_REFERENCE.md` 읽기.
4. `knowledge/regressions/FAILURE_LIBRARY.md`에서 관련 failure 확인.
5. 새 게임이면 `knowledge/genres/STARTER_RECIPE_MATRIX.json`에서 primary genre recipe 선택.
6. 해당 domain 전문 문서 읽기.
7. 기존 project이면 project README/docs/current source를 먼저 읽기.
8. 사용자가 요청하지 않은 migration/rewrite를 하지 않기.

## Before starting a new project

필수:

- project start checklist
- toolchain decision
- primary genre recipe
- primary real Roblox reference 1개 + secondary references
- official Template/Feature Package/Developer Module 조사
- art direction
- 5~10분 vertical slice scope
- security boundary
- P0 test route
- Studio MCP를 쓸 수 있으면 project-specific playtest contract

그 후에만 코드를 대량 생성한다.

## Before inventing a system

다음 순서로 reuse candidate를 찾는다.

1. Roblox official Engine/API
2. official Templates
3. official Feature Packages
4. official Developer Modules
5. approved Godbase library catalog
6. audited Creator Store
7. community code with clear license
8. custom implementation

Custom이 항상 나쁜 것은 아니지만 **기존 검증 solution을 모른 채 재발명하는 것**을 금지한다.

## Before visual/UI work

먼저 확보:

- real Roblox reference screenshots/observations
- art/design tokens
- audited/generative asset candidates
- gameplay camera scale
- target device UI constraints

Part-only placeholder는 blockout에서만 사용. production look으로 확장하지 않는다.

## During implementation

표준 loop:

```text
inspect current state
→ smallest coherent change
→ Studio Play
→ actual input/navigation
→ Output
→ screenshot
→ acceptance/reference compare
→ root-cause fix
→ failed route replay
→ regression
```

Studio MCP가 available한데 user에게 첫 structural QA를 맡기지 않는다.

## Studio MCP rule

실행 정본:

- `knowledge/workflow/STUDIO_MCP_AUTONOMOUS_BUILD_HARNESS.md`
- `knowledge/testing/MCP_PLAYTEST_CONTRACT_SCHEMA.json`

여러 Studio가 열려 있으면 explicit `studio_id`를 고정한다. `execute_luau`로 production user route를 우회해서 테스트 통과를 꾸미지 않는다.

멀티플레이는 필요한 경우 `StudioTestService` 계열 시나리오를 설계하고, UI-heavy 작업은 Device Simulator matrix를 포함한다.

## Before claiming done

`knowledge/testing/AUTOMATED_ACCEPTANCE_GATES.md`와 project-specific contract를 통과해야 한다.

`코드 작성 완료`와 `게임 테스트 완료`는 다른 상태다.

Allowed status labels:

- `DESIGN`
- `INTERNAL_PROTOTYPE`
- `BOOT_VERIFIED`
- `VERTICAL_SLICE_TESTED`
- `READY_FOR_USER_TEST`
- `RELEASE_CANDIDATE`

검증 없이 상위 상태를 주장하지 않는다.

## When a failure occurs

첫 번째:

- evidence
- root cause
- fix
- exact route regression

같은 subsystem에서 구조 실패가 반복되면:

- patch stacking 중단
- architecture reassessment
- rollback/replacement 고려

새로운 generalizable lesson은 `knowledge/regressions/FAILURE_LIBRARY.md`로 환류한다.

## Creator Store / external source

Creator Store 결과를 production에 바로 넣지 않는다.

```text
discovery
→ metadata triage
→ quarantine audit
→ visual/production-fit review
→ catalog promotion
```

외부 자료는 source grade를 붙인다.

- S official
- A established OSS / independently validated source
- B useful community
- C discovery only
- Reject

도난/decompile/executor dump/license unclear source를 production reuse하지 않는다.

## Freshness

현재 날짜에 따라 달라지는 것:

- Roblox beta/engine feature
- policy/monetization/discovery
- tool versions
- library maintenance/license
- Creator Store asset/dependency

은 Godbase 날짜만 믿지 말고 adoption/release 직전에 current source를 확인한다.

## User preference vs Godbase

Godbase는 default recommendation이다. 사용자가 명시한 workflow/constraint가 안전하고 합법적인 범위라면 존중한다.

예:

- existing project가 Rojo면 갑자기 Script Sync로 전체 migration 금지.
- user가 Studio-first를 원하면 관성적으로 Rojo 강제 금지.

## No cargo-cult reuse

Godbase에 library/asset 이름이 있다는 이유로 import하지 않는다. 문제와 비용을 비교한다.

예:

- simple HUD에 giant framework 불필요
- single value 때문에 full persistence architecture 불필요할 수 있음
- official source pack도 필요한 subset만 ship하는 편이 나을 수 있음

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
