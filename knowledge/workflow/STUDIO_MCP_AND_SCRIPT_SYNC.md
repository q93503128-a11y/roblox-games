# Studio MCP + Script Sync Workflow

> 검증 기준일: 2026-09-03

2026년 Roblox Studio의 공식 MCP 서버는 이 monorepo의 개발 방식에 가장 큰 변화를 주는 기능이다. 과거처럼 AI가 `.rbxlx`를 외부에서 추측 생성하고 사용자가 대신 플레이테스트하는 구조보다, **AI 클라이언트가 열린 Studio 세션을 직접 읽고 수정하고 테스트**하는 루프가 훨씬 신뢰성이 높다.

공식 문서:

- Studio MCP: https://create.roblox.com/docs/studio/mcp
- AI workflows: https://create.roblox.com/docs/ai/accelerated-workflows
- Script Sync: https://create.roblox.com/docs/scripting/sync

## Studio MCP가 제공하는 핵심 능력

공식 MCP 서버는 로컬 Studio 세션과 stdio로 통신하며 다음 계열의 도구를 제공한다.

### 스크립트

- `script_read` — Studio 데이터모델의 Script/LocalScript/ModuleScript를 경로로 읽기
- `multi_edit` — 기존 스크립트 여러 구간 수정 또는 새 스크립트 생성

### 플레이어 입력 / 실제 테스트

- `character_navigation` — 플레이어 캐릭터를 특정 위치 또는 인스턴스로 이동
- `user_keyboard_input` — 키 입력, 텍스트 입력, 대기
- `user_mouse_input` — 이동, 클릭, 스크롤, 버튼 down/up

### 문서

- `http_get` — 허용된 Roblox 공식 문서 URL을 직접 조회
- `skill` — 디버깅, 장치 시뮬레이션, 문서 검색 등 Studio 관련 스킬 조회

### 세션

- `list_roblox_studios` — 실행 중인 Studio 창을 나열하고 정확한 대상 세션을 선택

공식 문서상 연결된 AI 클라이언트는 Studio 데이터모델을 탐색하고, Luau 코드를 실행하고, **Play mode에서 게임을 테스트**할 수 있다.

## 지원되는 Quick Connect 클라이언트

2026-09-03 공식 문서 기준:

- Codex CLI
- Claude Code
- Claude Desktop
- Cursor
- Gemini CLI
- Visual Studio Code
- Antigravity

이 저장소의 AI-assisted Roblox 개발에서는 **Codex CLI + Studio MCP**를 우선 후보로 본다.

## Windows 설정

Studio:

1. Roblox Studio 최신 버전 실행
2. Assistant 열기
3. `…` → `Manage MCP Servers`
4. `Enable Studio as MCP server` 활성화
5. Quick Connect에서 Codex CLI가 보이면 활성화

Quick Connect를 쓰지 않는 클라이언트의 기본 Windows MCP command:

```text
cmd.exe /c %LOCALAPPDATA%\Roblox\mcp.bat
```

일반 JSON 설정 예:

```json
{
  "mcpServers": {
    "Roblox_Studio": {
      "command": "cmd.exe",
      "args": [
        "/c",
        "%LOCALAPPDATA%\\Roblox\\mcp.bat"
      ]
    }
  }
}
```

신뢰할 수 없는 MCP 클라이언트를 Studio에 연결하지 않는다. 연결된 클라이언트는 열린 place를 읽고 변경할 수 있다.

## 권장 AI 개발 루프

```text
1. 목표/레퍼런스 확정
2. Studio place 열기
3. AI가 list_roblox_studios로 정확한 세션 선택
4. 현재 DataModel/스크립트 읽기
5. 작은 변경 1개 적용
6. Play 시작
7. 캐릭터 직접 이동/입력
8. Output/증상 확인
9. 수정
10. 재테스트
11. 품질 기준 통과 후 다음 기능
```

중요: **5~10개 시스템을 한꺼번에 만든 후 사용자에게 테스트를 넘기지 않는다.** 한 vertical slice에서 반복한다.

## MCP를 Roblox 게임 품질에 사용하는 방법

### 맵

- Studio에서 실제 배치 상태 확인
- 카메라와 캐릭터로 직접 이동
- 충돌/막힘/낙하/스폰 위치 확인
- Play 중 생기는 runtime-only 객체와 edit-mode 객체 중복 확인

### UI

- 실제 PlayerGui 구조 확인
- 마우스/키보드 입력을 직접 보내며 flow 확인
- 다른 장치 에뮬레이션과 조합
- 버튼이 눌리는지, 모달이 중첩되는지, 텍스트가 잘리는지 검사

### 전투

- 공격키를 실제 입력
- 이동하면서 공격/회피/점프 조합 확인
- 적 AI 거리, 타격 피드백, 공격 템포, 카메라 흔들림을 반복 조절
- 네트워크/서버 판정은 별도 멀티클라이언트 테스트

### 버그

- Output 오류를 사용자 스크린샷까지 기다리지 않고 즉시 조사
- 관련 스크립트를 경로로 읽고 좁은 패치
- 같은 세션에서 재현 → 수정 → 재현 실패 확인

## Script Sync

Rojo가 부담스러운 프로젝트에서는 Roblox 공식 **Script Sync**를 우선 고려한다.

Script Sync는 Studio 데이터모델의 스크립트와 로컬 디스크 `.luau` 파일을 양방향 동기화한다.

적합한 경우:

- Studio를 맵/객체/플레이테스트 정본 환경으로 유지
- 코드만 Git/VS Code/Codex에서 편집하고 싶음
- Rojo의 전체 파일시스템 소스-of-truth가 필요하지 않음
- 기존 Studio place에 점진적으로 적용

Rojo가 더 적합한 경우:

- 스크립트뿐 아니라 모델/인스턴스 구조 전체를 파일시스템에서 관리
- 재현 가능한 CLI build가 핵심
- large-scale automation / package library / CI에서 place 생성 필요

## Script Sync 핵심 제한

공식 문서 기준:

- Script, LocalScript, ModuleScript, Folder만 sync
- 최상위 sync instance당 최대 10,000 scripts
- 최대 128 top-level sync instances
- attributes/tags가 붙은 스크립트는 주의 — Script Sync가 이 메타데이터를 디스크에 보존하지 않음
- 패키지 sync 가능하지만 PackageLink 자체는 디스크에 쓰이지 않음
- 동일 스크립트를 여러 사람이 동시에 sync/edit하면 overwrite 위험
- 외부 환경에서 Studio debugger 자체를 제어하는 것은 아직 불가능

## 권장 LSP/포맷/린트

Roblox 공식 Script Sync 문서가 추천하는 커뮤니티 도구:

- Luau Language Server + Companion
- selene
- StyLua

Godbase는 이를 현재 기본 코드 편집 보조 스택으로 취급한다.

## 프로젝트별 권장 선택

### 혼자 빠르게 게임 제작 / Studio-first

```text
Studio + MCP + Script Sync + Git
```

가장 우선.

### 전체 데이터모델을 파일시스템에서 재현해야 하는 프로젝트

```text
Studio + MCP + Rojo + Git + CI
```

### 기존 Rojo 프로젝트

당장 강제 전환하지 않는다. Studio MCP를 추가해서 **실제 Playtest loop를 강화**한다.

## 금지 패턴

- AI가 Studio를 보지 못하는 상태에서 큰 `.rbxlx`를 XML로 추측 생성하고 "완성"이라 주장
- Output을 보지 않은 채 런타임 오류가 없다고 가정
- `Play`를 한 번도 하지 않고 UI/맵/전투 품질 완료 판정
- MCP에서 여러 Studio 창이 열려 있는데 `studio_id` 확인 없이 수정
- 라이브 production place에서 위험한 자동 변경부터 시작

항상 TEST place / 로컬 사본부터 사용한다.
