# Roblox Project Start Checklist

> 검증 기준일: 2026-09-03

새 Roblox 프로젝트에서 **코딩을 시작하기 전에** 이 체크리스트를 사용한다. 목표는 개발자를 귀찮게 하는 서류가 아니라, 이미 알려진 실패를 초기에 제거하는 것이다.

## A. 아이디어 / 장르

- [ ] 한 문장으로 게임 fantasy 설명 가능
- [ ] primary core loop 1개 정의
- [ ] target player/platform 정의
- [ ] 첫 30초/3분/10분 목표 정의
- [ ] short/mid/long goal 정의
- [ ] primary reference game 1개 이상
- [ ] combat/action reference 1개 이상
- [ ] UI/reference 1개 이상
- [ ] 장르 Godbase 문서 확인

관련:

- `../design/GAME_DESIGN_AND_FTUE.md`
- `../genre/GENRE_REFERENCE_MATRIX.md`

## B. 제작 방식

먼저 선택:

### Studio-first 권장 후보

```text
Roblox Studio + Studio MCP + Script Sync + Git
```

- [ ] Studio MCP 사용 가능 여부 확인
- [ ] Codex CLI 등 연결 클라이언트 선택
- [ ] Script Sync 적용 범위 선택

### Filesystem-first 필요 시

```text
Studio MCP + Rojo + Git + toolchain
```

- [ ] Rojo가 실제로 필요한 이유가 있음
- [ ] CI/build 재현 필요

**Rojo를 관성적으로 강제하지 않는다.**

관련: `../workflow/STUDIO_MCP_AND_SCRIPT_SYNC.md`

## C. Vertical Slice 범위

첫 build에 넣을 것만 체크.

- [ ] 스폰/작은 플레이 공간
- [ ] 핵심 행동 1개
- [ ] 적/목표 최소 수량
- [ ] reward 1개
- [ ] progression 변화 1개
- [ ] 최소 HUD
- [ ] 종료/다음 목표 tease

첫 slice 전에 보통 금지:

- [ ] 거래
- [ ] guild
- [ ] 30개 클래스
- [ ] 100개 아이템
- [ ] 거대한 월드
- [ ] 복잡한 monetization

필요성이 명확하면 예외지만 "나중에 필요할 것 같아서" 넣지 않는다.

## D. 맵 / 아트

- [ ] greybox에서 movement/camera 검증
- [ ] 첫 landmark
- [ ] art direction/palette
- [ ] Creator Store/asset kit shortlist
- [ ] third-party script audit
- [ ] collision plan
- [ ] mobile graphics target
- [ ] edit-time/runtime duplicate geometry 없음
- [ ] z-fighting 없음

관련:

- `../assets/ASSETS_KITS_AND_PLUGINS.md`
- `../graphics/WORLD_ART_ANIMATION_AUDIO.md`

## E. 캐릭터 / 전투

전투 게임이면:

- [ ] 한 기본 공격이 재미있음
- [ ] animation hit frame 정합
- [ ] server authoritative damage
- [ ] target hit feedback
- [ ] enemy telegraph
- [ ] camera/FOV
- [ ] movement while attacking 규칙
- [ ] mobile/gamepad 입력 전략
- [ ] 한 적 TTK 측정

관련: `../combat/COMBAT_FEEL_PLAYBOOK.md`

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

관련: `../design/UI_UX_PLAYBOOK.md`

## G. Architecture

- [ ] 각 상태의 owner(server/client) 결정
- [ ] server-only secrets/logic 위치
- [ ] shared catalog 위치
- [ ] Remote list 설계
- [ ] Remote validation
- [ ] state machine
- [ ] StreamingEnabled 여부
- [ ] cleanup lifecycle

관련: `../architecture/ENGINE_AND_NETWORKING.md`

## H. 저장 / 경제

첫 slice에 저장이 필요 없으면 나중으로 미뤄도 됨.

필요하면:

- [ ] profile schema
- [ ] schema version
- [ ] migration
- [ ] session locking
- [ ] autosave/close
- [ ] source/sink 표
- [ ] server reward roll
- [ ] paid receipt idempotency

관련: `../data/DATA_ECONOMY_AND_LIVEOPS.md`

## I. Security

- [ ] client trust review
- [ ] Remote 타입/범위/상태/권한 검증
- [ ] rate limit
- [ ] network ownership 고려
- [ ] third-party code audit
- [ ] secrets repository에 없음
- [ ] admin server permission

관련: `../security/SECURITY_AND_ANTICHEAT.md`

## J. Dependency

라이브러리 하나마다:

- [ ] 정말 필요한가
- [ ] license
- [ ] maintenance
- [ ] archived/deprecated 여부
- [ ] 외부 dependencies
- [ ] project size에 과한가

기본 후보는 `../code/OPEN_SOURCE_STACK.md`.

## K. 첫 Playtest 전

- [ ] Studio edit mode에서 map 존재
- [ ] Output red error 없음
- [ ] Play해서 spawn 성공
- [ ] 캐릭터 void/fall 없음
- [ ] core input 직접 수행
- [ ] 핵심 loop 완주
- [ ] respawn
- [ ] UI open/close
- [ ] asset permissions
- [ ] MCP로 자동 smoke test 가능한 항목 정의

## L. 첫 Human Test 전

사용자에게 보내기 전에 AI/개발자가 잡아야 할 것:

- [ ] 서버 부팅 오류
- [ ] 눈/장식 분리 같은 rig 버그
- [ ] 화면 flicker
- [ ] UI 텍스트 잘림
- [ ] 작동하지 않는 버튼
- [ ] basic combat broken
- [ ] spawn 실패

**사용자는 QA 대신 재미/감각/방향성 피드백에 집중하게 한다.**

## M. Human Test 질문

"재밌어?" 대신:

- [ ] 어디로 가야 하는지 바로 알았는가
- [ ] 첫 재미까지 얼마나 걸렸는가
- [ ] 전투/행동 중 가장 구린 부분은 무엇인가
- [ ] 보상을 알아차렸는가
- [ ] 다음 목표를 스스로 알았는가
- [ ] UI에서 찾기 어려운 것이 있었나
- [ ] 다시 할 이유가 있는가

## N. Slice 통과 기준

다음이 아니면 콘텐츠 확장 금지:

```text
stable
+ understandable
+ core action feels good
+ visual direction acceptable
+ UI acceptable
+ no obvious blocker bugs
```

## O. 이후 확장 순서

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

## P. 출시에 가까워질 때

- [ ] TEST/LIVE place 분리
- [ ] data migration
- [ ] security audit
- [ ] performance target device
- [ ] localization
- [ ] accessibility
- [ ] analytics funnel/economy/error
- [ ] icon/thumbnail/store metadata
- [ ] monetization policy
- [ ] rollback plan

관련: `../testing/TESTING_RELEASE_ANALYTICS.md`
