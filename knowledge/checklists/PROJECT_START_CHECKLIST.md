# Roblox Project Start Checklist

> 검증 기준일: 2026-09-04

새 Roblox 프로젝트에서 **코딩을 시작하기 전에** 이 체크리스트를 사용한다. 목표는 개발자를 귀찮게 하는 서류가 아니라 이미 알려진 실패를 초기에 제거하는 것이다.

## A. 아이디어 / 장르

- [ ] 한 문장으로 game fantasy 설명 가능
- [ ] primary core loop 1개 정의
- [ ] target player/platform 정의
- [ ] 첫 30초 / 3분 / 10분 목표 정의
- [ ] short / mid / long goal 정의
- [ ] `../genres/STARTER_RECIPE_MATRIX.json`에서 primary genre recipe 선택
- [ ] primary 실제 Roblox reference 1개
- [ ] secondary reference 2~4개 필요 여부 결정
- [ ] combat/action reference 필요 시 선정
- [ ] UI/reference 선정

관련:
- `../genres/README.md`
- `../genres/STARTER_RECIPE_MATRIX.json`
- `../genre/GENRE_REFERENCE_MATRIX.md` — 범용 장르 분석 background
- `../design/GAME_DESIGN_AND_FTUE.md`

## B. 제작 방식

### Studio-first 후보

```text
Roblox Studio + Studio MCP + Script Sync + Git
```

- [ ] Studio MCP 사용 가능 여부 확인
- [ ] MCP client 선택
- [ ] Script Sync 적용 범위 선택
- [ ] 대상 Studio/place/studioId 식별 전략 정의

### Filesystem-first 필요 시

```text
Studio MCP + Rojo + Git + toolchain
```

- [ ] Rojo가 실제로 필요한 이유가 있음
- [ ] DataModel을 filesystem 정본으로 둘 필요가 있음
- [ ] CI/build 재현 요구가 있음

**Rojo를 관성적으로 강제하지 않는다.**

관련:
- `../workflow/TOOLCHAIN_DECISION_MATRIX.md`
- `../workflow/STUDIO_MCP_AND_SCRIPT_SYNC.md`
- `../workflow/STUDIO_MCP_AUTONOMOUS_BUILD_HARNESS.md`

## C. Vertical Slice 범위

첫 build에 넣을 것만 체크.

- [ ] 스폰/작은 플레이 공간
- [ ] 핵심 행동 1개
- [ ] 적/목표 최소 수량
- [ ] reward 1개
- [ ] progression 변화 1개
- [ ] 최소 HUD
- [ ] 종료/다음 목표 tease
- [ ] genre recipe의 firstSlice와 비교
- [ ] genre recipe의 qualityGate 기록

첫 slice 전에 보통 금지:

- [ ] 거래
- [ ] guild
- [ ] 30개 클래스
- [ ] 100개 아이템
- [ ] 거대한 월드
- [ ] 복잡한 monetization

필요성이 명확하면 예외지만 "나중에 필요할 것 같아서" 넣지 않는다.

관련:
- `../checklists/VERTICAL_SLICE_DONE_DEFINITION.md`

## D. 맵 / 아트

- [ ] greybox에서 movement/camera 검증
- [ ] 첫 landmark
- [ ] art direction / shape language / palette
- [ ] Creator Store / official asset kit shortlist
- [ ] third-party script audit plan
- [ ] collision/pivot plan
- [ ] mobile graphics target
- [ ] edit-time/runtime duplicate geometry 없음
- [ ] z-fighting 없음

관련:
- `../assets/ASSETS_KITS_AND_PLUGINS.md`
- `../assets/ASSET_SELECTION_BY_GENRE.md`
- `../graphics/VISUAL_QUALITY_PIPELINE.md`
- `../graphics/TERRAIN_ENVIRONMENT_PIPELINE.md`
- `../graphics/WORLD_ART_ANIMATION_AUDIO.md` — broad overview

## E. 캐릭터 / 전투

전투 게임이면:

- [ ] 한 기본 공격/핵심 행동이 재미있음
- [ ] animation hit frame 정합
- [ ] server authoritative valuable combat state
- [ ] target hit feedback
- [ ] enemy telegraph
- [ ] camera/FOV
- [ ] movement while attacking 규칙
- [ ] mobile/gamepad 입력 전략
- [ ] 한 적 TTK 측정
- [ ] VFX/audio/camera와 실제 hitbox 정합

관련:
- `../combat/COMBAT_FEEL_PLAYBOOK.md`
- `../combat/HIT_DETECTION_HITBOXES_PROJECTILES.md`
- `../animation/ANIMATION_AND_RIGGING_PIPELINE.md`
- `../camera/CAMERA_AND_GAME_FEEL.md`

## F. UI / UX

- [ ] player task hierarchy
- [ ] wireframe 먼저
- [ ] design tokens
- [ ] HUD 항상 필요한 정보만
- [ ] contextual UI
- [ ] responsive layout
- [ ] touch target
- [ ] controller navigation 필요 여부
- [ ] close/back convention
- [ ] text localization 길이 고려

관련:
- `../design/UI_UX_PLAYBOOK.md`
- `../ui/CROSS_PLATFORM_ACCESSIBILITY_LOCALIZATION.md`

## G. Architecture

- [ ] 각 상태의 owner(server/client) 결정
- [ ] server-only secrets/logic 위치
- [ ] shared catalog 위치
- [ ] Remote list 설계
- [ ] Remote validation
- [ ] state machine
- [ ] StreamingEnabled 여부
- [ ] cleanup lifecycle

관련:
- `../architecture/ENGINE_AND_NETWORKING.md`
- `../architecture/PROJECT_STRUCTURE_PATTERNS.md`

## H. 저장 / 경제

첫 slice에 저장이 필요 없으면 나중으로 미뤄도 됨.

필요하면:

- [ ] profile schema
- [ ] schema version
- [ ] migration
- [ ] session locking 필요 여부
- [ ] autosave/close
- [ ] source/sink 표
- [ ] server reward roll
- [ ] paid receipt idempotency

관련:
- `../data/CLOUD_SERVICES_DECISION_MATRIX.md`
- `../data/SAVE_SCHEMA_MIGRATION_RECOVERY.md`
- `../data/ECONOMY_BALANCING_INFLATION.md`
- `../data/DATA_ECONOMY_AND_LIVEOPS.md` — broad overview

## I. Security

- [ ] client trust review
- [ ] Remote 타입/범위/상태/권한 검증
- [ ] rate limit
- [ ] network ownership 고려
- [ ] third-party code audit
- [ ] secrets repository에 없음
- [ ] admin server permission

관련:
- `../security/SECURITY_AND_ANTICHEAT.md`

## J. Dependency / Asset

라이브러리 하나마다:

- [ ] 정말 필요한가
- [ ] license
- [ ] maintenance
- [ ] archived/deprecated 여부
- [ ] 외부 dependencies
- [ ] project size에 과한가

에셋 하나마다:

- [ ] creator/source
- [ ] reuse/attribution terms
- [ ] scripts/module scripts
- [ ] suspicious require/HTTP/loadstring/InsertService pattern
- [ ] pivot/scale/collision
- [ ] visual style fit
- [ ] performance/repetition cost

관련:
- `../catalogs/LIBRARY_CATALOG.json`
- `../catalogs/DEPRECATED_LEGACY_WATCHLIST.md`
- `../assets/CREATOR_STORE_RED_FLAGS_AND_QUARANTINE.md`

## K. MCP Playtest Contract

Studio MCP를 사용한다면 사용자에게 넘기기 전에 project-specific contract를 만든다.

- [ ] `studioTarget` / explicit Studio ID policy
- [ ] clean boot 조건
- [ ] P0 primary route 최소 1개
- [ ] required visual states
- [ ] device matrix
- [ ] multiplayer 필요 여부와 scenarios
- [ ] completion gate

Template:
- `../testing/MCP_PLAYTEST_CONTRACT_SCHEMA.json`

Validator:
- `../../tools/godbase/mcp_contract_validate.py`

## L. 첫 Playtest 전

- [ ] Studio edit mode에서 핵심 map/instances 존재
- [ ] Output red error 없음
- [ ] Play해서 spawn 성공
- [ ] 캐릭터 void/fall 없음
- [ ] core input 직접 수행
- [ ] 핵심 loop/P0 route 완주
- [ ] respawn/reset
- [ ] UI open/close
- [ ] asset permissions/dependencies
- [ ] screenshot state 정의

## M. 첫 Human Test 전

사용자에게 보내기 전에 AI/개발자가 잡아야 할 것:

- [ ] 서버/bootstrap 오류
- [ ] detached rig/model parts
- [ ] 화면 flicker/z-fighting
- [ ] UI 텍스트 잘림
- [ ] 작동하지 않는 버튼
- [ ] basic combat/core mechanic broken
- [ ] spawn 실패
- [ ] desktop/mobile 핵심 UI blocker
- [ ] known limitations 기록

**사용자는 구조 QA 대신 재미/감각/방향성 피드백에 집중하게 한다.**

## N. Human Test 질문

"재밌어?" 대신:

- [ ] 어디로 가야 하는지 바로 알았는가
- [ ] 첫 재미까지 얼마나 걸렸는가
- [ ] 전투/행동 중 가장 구린 부분은 무엇인가
- [ ] 보상을 알아차렸는가
- [ ] 다음 목표를 스스로 알았는가
- [ ] UI에서 찾기 어려운 것이 있었나
- [ ] 다시 할 이유가 있는가

## O. Slice 통과 기준

다음이 아니면 콘텐츠 확장 금지:

```text
stable
+ understandable
+ primary action feels good
+ visual direction acceptable
+ UI acceptable
+ P0 route passes
+ no obvious blocker bugs
```

## P. 이후 확장 순서

```text
core quality
→ content variation
→ progression depth
→ social
→ persistence/economy hardening
→ monetization
→ analytics/liveops
→ scale/performance
```

게임마다 달라질 수 있지만 **품질이 낮은 코어에 시스템을 계속 덧칠하지 않는다.**

## Q. 출시에 가까워질 때

- [ ] TEST/LIVE place 분리 필요 여부
- [ ] data migration
- [ ] security audit
- [ ] performance target device
- [ ] localization
- [ ] accessibility
- [ ] analytics funnel/economy/error
- [ ] icon/thumbnail/store metadata
- [ ] monetization policy
- [ ] rollback plan

관련:
- `../testing/AUTOMATED_ACCEPTANCE_GATES.md`
- `../testing/DEVICE_NETWORK_TEST_MATRIX.md`
- `../checklists/SHIP_CHECKLIST.md`
- `../workflow/OPEN_CLOUD_CI_RELEASE_AUTOMATION.md`
