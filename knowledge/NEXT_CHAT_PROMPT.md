# Roblox Godbase — Next Chat Prompt

> 검증 기준일: 2026-09-04

Roblox 개발 공용 저장소의 Godbase 작업을 이전 채팅에서 그대로 이어간다.

이 채팅은 새 Godbase를 만드는 채팅이 아니다. **초기 Foundation은 이미 완료**되었으므로 구조를 처음부터 다시 설계하거나 같은 Roblox 기초 자료를 반복 수집하지 마라.

저장소:
`https://github.com/q93503128-a11y/roblox-games`

브랜치:
`main`

가장 먼저 반드시 수행:

1. GitHub `main` 최신 HEAD를 직접 다시 확인한다.
2. 아래 정본을 읽는다.
   - `knowledge/GODBASE_MANIFEST.json`
   - `knowledge/AGENT_PROTOCOL.md`
   - `knowledge/QUICK_REFERENCE.md`
   - `knowledge/research/INITIAL_FOUNDATION_FINAL_AUDIT_2026-09-04.md`
   - `knowledge/GODBASE_NEXT_CHAT_HANDOFF.md`
   - `knowledge/research/CONTINUOUS_RESEARCH_ROADMAP.md`
3. `tools/godbase/validate.py`와 최근 `Roblox Godbase Check` CI 상태를 확인한다.
4. main이 handoff 시점 이후 바뀌었다면 무조건 최신 main을 정본으로 사용한다.

현재 단계:

`INITIAL_FOUNDATION_COMPLETE → PROJECT_USAGE_AND_EMPIRICAL_FEEDBACK`

앞으로의 기본 목표는 Godbase 문서를 끝없이 늘리는 것이 아니다.

- 실제 Roblox 프로젝트에 Godbase를 적용한다.
- 새 게임이면 genre starter recipe를 선택한다.
- actual Roblox reference를 먼저 조사한다.
- official engine/template/feature package/developer module을 먼저 검토한다.
- Creator Store/OSS는 Godbase catalog와 quarantine 규칙을 따른다.
- 가능하면 Studio MCP에서 AI가 직접 구현/Play/Input/Output/Screenshot/수정 loop를 수행한다.
- 사용자에게 넘기기 전에 project-specific P0 route를 AI가 먼저 완주한다.
- 그 과정에서 새로 검증된 성공/실패만 Godbase에 환류한다.

특히 금지:

- Godbase가 없던 것처럼 맨땅 제작
- reference 없는 generic UI/map/combat
- primitive placeholder를 production art처럼 확장
- Creator Store script 무검사 실행
- archived/legacy library를 예전 튜토리얼만 보고 채택
- Playtest 없이 완료 주장
- core quality가 낮은데 content breadth부터 늘리기

사용자가 새 게임을 만들자고 하면 질문/계획만 길게 적고 멈추지 말고, Godbase 라우팅과 실제 프로젝트 맥락을 확인한 뒤 바로 작은 vertical slice 제작 workflow로 진입한다.
