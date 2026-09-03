# Roblox Games

문승준의 Roblox 게임 개발을 한곳에서 관리하는 **공용 monorepo**입니다.

이 저장소는 하나의 게임 전용 저장소가 아닙니다. 여러 Roblox 프로젝트를 `projects/` 아래에서 서로 완전히 분리해 관리하고, Rojo·검증·배포 자동화처럼 여러 게임이 함께 사용할 수 있는 개발 인프라는 저장소 루트 또는 `shared/`, `tools/`에 둡니다.

## 기본 구조

```text
roblox-games/
├─ README.md
├─ .github/
│  └─ workflows/          # 공용/프로젝트별 CI 및 Roblox 배포
├─ projects/
│  ├─ monster-factory/    # Monster Factory Simulator
│  ├─ vaultfall/          # Vaultfall
│  └─ <future-game>/      # 이후 Roblox 프로젝트
├─ shared/
│  ├─ modules/            # 실제로 여러 게임에서 재사용하기로 확정된 모듈
│  └─ tooling/            # 공용 검증/빌드 보조 코드
└─ tools/                 # 개발 도구 설정 및 스크립트
```

## 저장소 운영 원칙

### 1. 프로젝트 간 완전 분리

- 각 게임의 코드·맵·데이터·문서·에셋 정의는 반드시 `projects/<project-name>/` 아래에 둡니다.
- 한 게임의 임시 코드나 데이터가 다른 게임 폴더를 참조하지 않게 합니다.
- 프로젝트 A의 수정 때문에 프로젝트 B가 빌드되거나 동작이 달라지면 안 됩니다.
- 여러 프로젝트에서 실제로 반복 사용되고 검증된 코드만 `shared/`로 승격합니다.
- 공용화를 이유로 아직 서로 다른 게임 로직을 억지로 합치지 않습니다.

### 2. 각 프로젝트의 정본

각 프로젝트 폴더 안의 다음 항목을 정본으로 사용합니다.

- `default.project.json` : Rojo 프로젝트 정의
- `src/` : Studio와 동기화되는 실제 소스/맵 데이터
- `docs/` : 기획서, 설계서, 밸런스, 인수인계, 테스트 문서
- `README.md` : 해당 프로젝트의 현재 상태와 실행 방법

Studio에서 생성된 임시 사본이나 다운로드한 `(1)`, `(2)` 파일을 정본으로 취급하지 않습니다.

### 3. Rojo 우선

- 개발 중 코드와 Rojo 관리 대상 맵은 파일 시스템을 정본으로 합니다.
- Studio는 편집·실행·수동 테스트 환경으로 사용합니다.
- Rojo 연결 상태에서는 동일한 관리 객체를 Studio와 파일 양쪽에서 동시에 수정하지 않습니다.
- Studio에서 직접 만든 객체를 보존해야 하는 영역은 프로젝트 설정에서 `ignoreUnknownInstances` 정책을 명시합니다.
- `.rbxl`/`.rbxlx`는 필요할 때 생성하는 테스트/배포 산출물이며, 가능한 한 소스의 유일한 정본으로 사용하지 않습니다.

### 4. 코드 품질

- 임시 패치를 기존 코드 위에 계속 덧칠하지 않습니다.
- 낡은 구현을 대체할 때는 새 구현과 충돌하는 레거시 코드를 제거합니다.
- 경제, 저장, 구매, Remote, 보상 로직은 서버 권한을 원칙으로 합니다.
- 클라이언트가 재화량, Hatch 결과, 구매 보상, 업그레이드 비용 등을 결정하지 않습니다.
- RemoteEvent/RemoteFunction 입력은 서버에서 타입·범위·소유권·진행 상태·레이트리밋을 검증합니다.
- 반복 콘텐츠는 가능한 한 데이터 기반으로 정의합니다.
- 프로젝트별 데이터 마이그레이션 버전을 명시적으로 관리합니다.

### 5. 외부 에셋

- 출처와 사용 권한을 확인할 수 있는 에셋만 사용합니다.
- Creator Store/외부 모델을 가져올 때 포함된 `Script`, `LocalScript`, `ModuleScript`, 외부 `require(assetId)` 등을 검사합니다.
- 시각 에셋과 게임 로직을 불필요하게 결합하지 않습니다.
- 프로젝트별 `ASSET_SOURCES.md` 또는 동등한 문서에 출처와 변경 사항을 기록합니다.
- 알 수 없는 Free Model 스크립트를 그대로 실행하지 않습니다.

### 6. 수익화

- Roblox 정책을 준수합니다.
- 구매 보상은 서버에서 확정적으로 지급하고 Developer Product는 `ProcessReceipt`를 사용합니다.
- 영수증 재처리로 같은 보상이 중복 지급되지 않게 합니다.
- 상품 ID와 가격 로직을 UI 여러 곳에 하드코딩하지 않습니다.
- 유료 랜덤 아이템은 관련 Roblox 정책을 충족하기 전에는 도입하지 않습니다.
- 기만형 버튼, 허위 할인, 가짜 재고, 강제 구매창 반복 등은 사용하지 않습니다.

### 7. Git 규칙

- 기본 브랜치는 `main`입니다.
- 정상 개발 정본은 `main`을 기준으로 합니다.
- 커밋은 가능한 한 한 프로젝트 또는 한 목적에 집중합니다.
- 프로젝트별 변경 경로가 명확하도록 커밋 메시지를 작성합니다.

예:

```text
monster-factory: add rebirth progression
monster-factory: fix datastore local boot
infra: add Rojo validation workflow
```

- API Key, 토큰, 비밀번호, Roblox Open Cloud Key 같은 비밀정보는 절대 커밋하지 않습니다.
- 배포용 비밀정보는 GitHub Actions Secrets 등 비밀 저장소만 사용합니다.

### 8. CI / 자동 배포

목표 구조:

```text
GitHub main
  ↓
변경된 프로젝트 감지
  ↓
Rojo build
  ↓
정적 검사 / 프로젝트별 검증
  ↓
테스트 Place 자동 배포
  ↓
실제 Studio/Roblox 플레이 테스트
  ↓
승인 후 Production 배포
```

- 자동 배포 대상은 우선 **TEST Place**로 제한합니다.
- 실제 서비스 중인 LIVE Place는 테스트 빌드와 분리합니다.
- 검증 실패 시 Roblox 배포를 진행하지 않습니다.
- 한 프로젝트의 변경으로 다른 프로젝트를 자동 배포하지 않습니다.

## 현재 프로젝트

### Monster Factory Simulator

경로:

```text
projects/monster-factory/
```

현재 개발 방향:

- Factory Tycoon + Monster Collection + Simulator
- Rojo 기반 개발
- 서버 권한 경제/저장/구매 구조
- MVP-005 Rojo 정본 이전 완료, 첫 전체 Studio 플레이테스트 대기
- 테스트 Place와 LIVE Place 분리 예정
- GitHub → Rojo build → Roblox TEST 자동 배포 구축 예정

### Vaultfall

경로:

```text
projects/vaultfall/
```

현재 개발 방향:

- 1~4인 협동 던전 로그라이트
- 외부 Creator Store 에셋은 시각 재료로만 사용하고 게임 로직은 저장소에서 통제
- 서버 권한 전투·방 진행·보상·영구 성장·DataStore 구조
- 8개 방 원정, 엘리트/보스, 임시 무기 드롭, Essence/Power Rank 성장
- 첫 전체 Studio 플레이테스트 준비 단계

## 새 프로젝트 추가 규칙

새 Roblox 게임은 다음 최소 구조로 시작합니다.

```text
projects/<project-name>/
├─ README.md
├─ default.project.json
├─ src/
├─ docs/
└─ ASSET_SOURCES.md
```

새 프로젝트를 추가할 때 루트 README의 `현재 프로젝트` 목록도 함께 갱신합니다.

## 현재 다음 단계

1. GitHub 기준 Rojo 빌드 검증
2. 로컬 Studio ↔ Rojo 연결 확인
3. Roblox TEST Experience / Place 확보
4. Open Cloud 배포 자격증명은 GitHub Secrets에만 등록
5. 프로젝트별 TEST Place 자동 배포 workflow 구축
6. 실제 첫 플레이 테스트 결과를 바탕으로 버그·밸런스·UI 수정