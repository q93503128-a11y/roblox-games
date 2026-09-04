# Roblox Godbase — Next Chat Handoff

> 검증 기준일: 2026-09-04
> 상태: `INITIAL_FOUNDATION_COMPLETE`

이 파일은 Roblox Godbase 구축 작업을 다른 채팅/Codex 세션으로 넘길 때 사용하는 정본 인수인계다.

## 저장소

- repository: `q93503128-a11y/roblox-games`
- branch: `main`
- Godbase root: `knowledge/`

**절대로 이 파일에 적힌 과거 SHA를 최신이라고 가정하지 않는다.** 새 세션은 항상 GitHub `main` 최신 HEAD를 직접 확인한다.

## 현재 단계

Godbase의 **초기 기반 구축은 완료**되었다.

다시 처음부터 Roblox 문서를 정리하거나 폴더 구조를 재설계하지 않는다.

현재 Godbase에는 다음이 이미 있다.

- official docs / engine / Open Cloud map
- Studio MCP + Script Sync workflow
- Studio MCP autonomous build/playtest harness
- MCP playtest contract + validator
- Luau/client-server/networking/security/data/performance knowledge
- OSS/library current-vs-legacy catalog
- Creator Store search/triage/quarantine/audit/promotion pipeline
- official/community asset supply catalog
- UI/UX/world/animation/audio/VFX/camera/combat playbooks
- analytics/discovery/retention/monetization/LiveOps/publishing
- 10 major genre starter recipes + machine-readable routing matrix
- regression/failure library
- Godbase CI + unit tests
- continuous research roadmap

초기 Foundation 종료 감사:

`knowledge/research/INITIAL_FOUNDATION_FINAL_AUDIT_2026-09-04.md`

## 새 세션에서 가장 먼저 할 일

1. GitHub `main` 최신 HEAD 직접 확인.
2. 다음 정본 읽기:
   - `knowledge/GODBASE_MANIFEST.json`
   - `knowledge/AGENT_PROTOCOL.md`
   - `knowledge/QUICK_REFERENCE.md`
   - `knowledge/research/INITIAL_FOUNDATION_FINAL_AUDIT_2026-09-04.md`
3. 실제 게임 작업이면 해당 프로젝트 README/docs/current source를 먼저 읽기.
4. 새 게임이면 `knowledge/genres/README.md`와 `STARTER_RECIPE_MATRIX.json`에서 primary genre recipe를 선택.
5. 필요한 domain 문서만 추가로 읽기.
6. Studio MCP가 로컬에서 연결 가능하면 AI가 user보다 먼저 Playtest.

## 절대 하지 말 것

- Godbase가 없던 것처럼 Baseplate에서 모든 시스템 재발명
- 모든 Roblox 문서를 다시 처음부터 수집
- 유명하다는 이유만으로 archived/legacy library 채택
- Creator Store model/plugin을 격리검사 없이 production에 삽입
- reference 없이 UI/맵/전투를 기억으로 생성
- 핵심 loop가 검증되지 않았는데 content breadth 확장
- Studio Play 없이 `완성`, `테스트 완료`, `READY_FOR_USER_TEST` 주장
- 기존 프로젝트를 Godbase에 맞춘다는 이유로 불필요하게 전면 migration

## 신규 게임 기본 루프

```text
latest main 확인
→ Manifest / Agent Protocol / Quick Reference
→ genre recipe 선택
→ 실제 Roblox reference 선정
→ official template/module/asset/OSS 후보 검토
→ 5~10분 vertical slice scope
→ project-specific MCP playtest contract
→ Studio에서 구현
→ Play / 실제 입력 / Output / screenshot
→ 실패 수정 / regression
→ user에게 feel/direction 테스트 요청
```

## Godbase maintenance가 필요한 경우

다음이 발생했을 때만 관련 부분을 갱신한다.

- Roblox 공식 API/Studio 기능/정책 변경
- library archived/후속 프로젝트 등장/license 변경
- 더 좋은 official/Creator Store asset 발견 및 Studio audit 완료
- 실제 프로젝트에서 일반화 가능한 실패/성공 패턴 발견
- 장르 recipe의 실측값이 실제 게임에서 틀렸음이 확인
- CI/자동화 도구 자체 오류 발견

## 다음 장기 연구 backlog

우선순위는 Godbase 문서 수를 늘리는 것보다 실전 증거다.

1. 실제 프로젝트에서 Studio MCP autonomous loop 반복 검증
2. Creator Store S/A-tier catalog를 장르별 실제 수요에 맞춰 확장
3. official Feature Package / Developer Module isolated Studio 실험
4. 장르별 reference의 camera/timing/FTUE/UI/map density 실측
5. 공용 코드 후보를 2개 이상 프로젝트에서 검증 후 `shared/` 승격
6. Roblox official docs/engine/policy freshness sweep

## 다음 채팅 시작 문구

새 채팅에서는 `knowledge/NEXT_CHAT_PROMPT.md` 내용을 사용하거나, 아래처럼 시작하면 된다.

> Roblox Godbase 초기 기반 구축이 완료된 `q93503128-a11y/roblox-games`의 작업을 이어간다. 새 프로젝트처럼 다시 만들지 말고 먼저 main 최신 HEAD를 직접 확인한 뒤 `knowledge/GODBASE_MANIFEST.json`, `AGENT_PROTOCOL.md`, `QUICK_REFERENCE.md`, `research/INITIAL_FOUNDATION_FINAL_AUDIT_2026-09-04.md`, `GODBASE_NEXT_CHAT_HANDOFF.md`를 읽어라. Godbase 자체 문서 늘리기가 기본 목표가 아니라 실제 Roblox 프로젝트에 적용하고, 그 과정에서 검증된 성공/실패만 다시 Godbase에 환류하는 단계다.
