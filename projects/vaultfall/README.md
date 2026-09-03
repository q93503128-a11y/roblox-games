# Vaultfall

`Vaultfall`은 1~4인 협동 던전 로그라이트 Roblox 프로젝트입니다.

이번 프로젝트의 제작 원칙은 **외형은 검증된 공개 에셋을 우선하고, 게임 로직은 저장소에서 통제한다**입니다. 외부 Free Model의 스크립트는 실행하지 않으며, Studio 설치 도구가 시각 에셋에서 `Script`/`LocalScript`/`ModuleScript`를 제거합니다.

## 현재 플레이 루프

1. 허브에서 `ENTER VAULT` 프롬프트 사용
2. 서버의 모든 현재 플레이어가 한 원정 파티로 입장
3. 일반 전투 → 보물 → 전투 → 엘리트 → 성소 → 전투 → 심층 전투 → 보스 순으로 진행
4. 좌클릭 기본 공격 / `E` 강공격 / `Q` 대시 / `R` 회전 공격
5. 방을 클리어하면 무기 제안이 등장하며 장비를 교체할 수 있음
6. 보스를 처치하면 Essence와 영구 Power Rank 획득
7. 허브의 Attack/Health 제단에서 Essence로 영구 강화

## 핵심 시스템

- 서버 권한 전투 판정과 공격 레이트리밋
- 8개 방 원정과 방 봉쇄/해금
- 일반/원거리/브루트/엘리트/보스 적
- 인원 수에 따른 적 체력/수량 스케일링
- 무기 희귀도 및 빠른 전투력 상승
- 방 클리어 보상과 장비 교체
- Essence / Power Rank / 영구 공격력·체력 강화
- DataStore 저장 + Studio/API 실패 시 세션 폴백
- 런 실패/완료 후 허브 복귀
- PC와 모바일 입력
- 외부 던전/무기/몬스터/환경 모델을 시각 에셋으로만 사용하는 안전 설치 도구

## Rojo

```powershell
cd projects/vaultfall
rojo serve
```

또는 빌드:

```powershell
rojo build default.project.json -o Vaultfall.rbxlx
```

## 첫 Studio 설치

1. `ASSET_SOURCES.md`의 무료 에셋을 Creator Store에서 계정에 추가합니다.
2. `tools/INSTALL_VISUAL_ASSETS.server.lua` 내용을 임시 Studio Script 또는 Command Bar 실행 환경에서 한 번 실행합니다.
3. 생성된 `ServerStorage/VaultfallAssets`를 Place에 보존합니다.
4. Rojo를 연결하고 Play 테스트합니다.

에셋 설치를 하지 않아도 게임 로직은 폴백 외형으로 실행되지만, 실제 테스트는 에셋 설치 후를 정본으로 봅니다.

## 정본

- `default.project.json`: Rojo 구조
- `src/ReplicatedStorage`: 공유 설정/드롭 로직
- `src/ServerScriptService`: 서버 권한 게임 로직
- `src/StarterPlayer/StarterPlayerScripts`: 입력/HUD
- `tools/INSTALL_VISUAL_ASSETS.server.lua`: Studio 전용 시각 에셋 설치기
- `ASSET_SOURCES.md`: 외부 에셋 출처와 처리 정책
- `docs/TEST_CHECKLIST.md`: 첫 전체 플레이테스트 체크리스트
