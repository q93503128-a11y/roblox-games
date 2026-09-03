# Toolchain Decision Matrix

> verified: 2026-09-03

Roblox 프로젝트는 하나의 개발 방식으로 통일할 필요가 없다. **무엇을 정본(source of truth)으로 둘지**에 따라 도구를 선택한다.

## 권장 의사결정

### Studio-first
선택 조건:
- 맵/모델/UI를 Studio에서 많이 편집
- 혼자 또는 소규모 개발
- AI가 Studio 자체를 조작/플레이테스트하는 것이 중요
- `.rbxl/.rbxlx`와 Team Create가 자연스러운 작업 단위

권장 스택:
- Roblox Studio
- Studio MCP
- Script Sync
- Git
- Luau LSP
- StyLua
- selene

장점:
- 실제 게임 화면과 DataModel을 기준으로 개발
- AI 자동 playtest 가능
- Rojo 설정 부담 감소
- Studio-native collaboration과 충돌이 적음

주의:
- Script Sync는 Script/LocalScript/ModuleScript/Folder 중심이다.
- non-code DataModel 전체를 Git에서 완전히 재현하는 용도는 아니다.

### Filesystem-first / Rojo
선택 조건:
- 전체 프로젝트가 코드 리뷰/CI/diff 가능한 파일이어야 함
- 큰 팀
- 생성/배포 pipeline이 파일시스템을 기준으로 함
- 반복되는 DataModel을 선언적으로 관리

권장 스택:
- Rojo
- Rokit
- Wally
- Git
- StyLua
- selene
- Luau LSP
- Studio MCP를 QA에 추가

주의:
- Studio에서 Rojo 관리 객체와 파일을 동시에 편집하면 충돌 가능.
- Studio-only asset/art 영역의 ownership 정책을 명시한다.

## 핵심 도구 상태

### Roblox Studio MCP — CURRENT / S
공식 내장. AI가 열린 Studio의 DataModel, scripts, Luau, Play mode에 접근한다.

Use for:
- inspection
- coding
- playtest
- screenshot
- regression check

### Script Sync — CURRENT / S
공식 Studio 기능. scripts ↔ local disk bidirectional sync.

Use for:
- Studio-first + Git
- external editor
- LSP/format/lint

Don't use as:
- full DataModel serializer

Official docs say Rojo is a better fit if the entire project must live in version control/filesystem.

### Rojo — CURRENT / A
MPL-2.0 community tool. Filesystem ↔ Roblox project workflow.

Use for:
- large codebase/monorepo
- CI build
- reproducible DataModel

### Rokit — CURRENT / A
MIT community toolchain manager. New community projects should prefer Rokit over blindly starting with older Foreman/Aftman recipes unless a project already has a stable legacy setup.

Use for:
- pinning Rojo/Wally/StyLua/selene/Lune/etc.

### Wally — CURRENT / A
MPL-2.0 Luau package manager/registry.

Use for:
- explicit packages with locked versions

Caution:
- read the package source/license.
- package registry presence is not a security guarantee.

### StyLua — CURRENT / A
Automatic Lua/Luau formatting. CI formatting gate 권장.

### selene — CURRENT / A
Static linting. Roblox standard library config와 함께 사용.

### Luau Language Server — CURRENT / A
External editor type/autocomplete/navigation. Script Sync 공식 문서도 companion Studio plugin과 함께 권장한다.

### Foreman / Aftman — LEGACY / CONDITIONAL
기존 프로젝트가 안정적으로 사용 중이면 즉시 교체할 이유는 없다. 신규 project bootstrap은 현재 maintenance와 ecosystem 문서를 확인하고 Rokit을 우선 검토한다.

## Package 선택 원칙

패키지를 도입하기 전 7문항:
1. Roblox 기본 API로 짧고 명확하게 해결 가능한가?
2. 라이브러리가 제거 가능한가?
3. 유지보수/라이선스가 명확한가?
4. API surface가 문제보다 더 복잡하지 않은가?
5. server/client realm이 명확한가?
6. transitive dependency가 과도하지 않은가?
7. 실제 vertical slice에서 이득을 확인했는가?

## UI Framework 결정

- 작은 HUD/메뉴: vanilla Instances도 충분할 수 있음.
- 복잡한 reactive UI: Fusion/Vide/React Lua 등 현재 유지되는 framework 후보 비교.
- UI framework 자체를 배우는 비용보다 UI 상태 복잡도가 낮으면 framework를 억지로 넣지 않는다.
- storybook/component preview 도구는 복잡한 UI에서 유용하지만 source/maintenance를 별도 검증한다.

## Toolchain lock 원칙

`latest`를 CI에서 매번 자동 설치하지 않는다.
- version pin
- lock manifest commit
- upgrade는 별도 commit
- Studio 업데이트 후 regression test
- deprecated API/tool은 migration note 기록

## 권장 기본 폴더 (Studio-first 예)

```text
project/
├─ README.md
├─ docs/
├─ scripts/        # Script Sync root(s)
├─ tests/
├─ tools/
├─ ASSET_SOURCES.md
└─ rokit.toml      # CLI를 쓸 경우
```

## 권장 기본 폴더 (Rojo 예)

```text
project/
├─ default.project.json
├─ src/
├─ docs/
├─ tests/
├─ ASSET_SOURCES.md
├─ wally.toml
└─ rokit.toml
```

## 공식 근거
- Script Sync: https://create.roblox.com/docs/scripting/sync
- Studio MCP: https://create.roblox.com/docs/studio/mcp
- Creator Docs: https://create.roblox.com/docs/llms.txt

Community candidates:
- https://github.com/rojo-rbx/rojo
- https://github.com/rojo-rbx/rokit
- https://github.com/UpliftGames/wally
