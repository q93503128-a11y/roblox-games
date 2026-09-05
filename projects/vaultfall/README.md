# BREACH PROTOCOL / Vaultfall

`Vaultfall`은 1~4인 협동 PvE 로그라이트 Roblox 프로젝트이며, 현재 게임 내 타이틀은 **BREACH PROTOCOL**입니다.

현재 빌드는 외부 Creator Store 모델이 없어도 플레이 가능한 자체 포함형 월드/무기/적 프레젠테이션을 기본값으로 사용합니다. 검증된 외부 시각 에셋은 선택적으로 추가할 수 있지만, 게임 로직과 첫 전체 테스트는 저장소만으로 성립해야 합니다. 외부 모델을 사용할 때는 Script / LocalScript / ModuleScript / Remote / Prompt 등을 제거하고 시각 요소만 사용합니다.

## 현재 플레이 루프

1. Safehouse에서 Breach 출격 인터랙션 사용
2. 최대 4명의 현재 파티가 12개 섹터 원정 시작
3. Combat / Treasure / Elite / Shrine / DeepCombat / Boss 섹터를 진행
4. 중간 섹터에서 Uplink / Holdout / Recovery / Sabotage 같은 별도 목표 수행
5. Carbine / SMG / Shotgun / Rail Rifle 중 무기를 교체하며 전투
6. 방 클리어, 목표 완료, HVT 및 Optional Op를 통해 무기와 Augment를 강화
7. 4 / 7 / 9 / 11 섹터에서 Emergency Extraction을 선택해 현재 미확보 Essence와 깊이 보너스를 확보하거나 더 깊게 진행
8. 최종 Vault Warden을 처치하면 원정 완료 보상과 영구 진행도 획득
9. Safehouse에서 Essence 기반 성장, Mastery / Career / Contract 진행을 관리

## 핵심 시스템

- 서버 권한 총기 전투 판정 및 발사 / 재장전 / 대시 상태 검증
- 12개 섹터 비선형 경로와 방 봉쇄 / 해금
- Carbine / SMG / Shotgun / Rail Rifle 4개 무기 아키타입
- 무기 희귀도, Traits, Loot Offer, 무기별 1인칭 실루엣과 손 애니메이션
- 일반 적 / 원거리 / 브루트 / Elite / HVT 3종 / Vault Warden
- 인원 수와 깊이에 따른 적 체력 / 수량 / 압박 스케일링
- 보스 3페이즈와 원형 / 직선 / 교차 / 표적형 텔레그래프 패턴
- Uplink / Holdout / Recovery / Sabotage 목표
- Optional Ops / HVT / Augment / Sector Modifier / Reinforcement 연동
- Emergency Extraction 위험-보상 선택
- Essence / Power Rank / Mastery / Career / Contracts 영구 진행
- DataStore 저장 + Studio/API 실패 시 세션 폴백
- 사망 / 탈락 / 이탈 / 추출 / 완료 / 실패 후 허브 복귀 처리
- PC와 모바일 입력
- 자체 포함 Safehouse / 전투 섹터 장식과 선택적 외부 시각 에셋 사용
- 단일 CombatAudio 믹스에서 무기음 / UI 피드백 / 앰비언스 관리

## 빌드

```powershell
cd projects/vaultfall
rojo serve
```

또는 독립 테스트 Place 생성:

```powershell
rojo build default.project.json -o Vaultfall.rbxlx
```

GitHub의 `Vaultfall CI`도 `selene src tools`와 Rojo 빌드를 수행하고, 성공 시 `vaultfall-rbxlx` 아티팩트를 업로드합니다.

## 첫 전체 플레이테스트

외부 에셋 설치는 필수 조건이 아닙니다. 먼저 저장소만으로 생성한 `Vaultfall.rbxlx`를 Roblox Studio에서 열어 자체 포함 빌드를 정본으로 테스트합니다.

1. 최신 `main`에서 `Vaultfall.rbxlx`를 빌드하거나 성공한 `Vaultfall CI` 아티팩트를 사용합니다.
2. Roblox Studio에서 Play로 1인 전체 런을 먼저 수행합니다.
3. 이어서 2~4인 Server/Player 테스트로 참가자 사망, 이탈, 추출, 스케일링을 확인합니다.
4. Output의 런타임 오류와 실제 화면/사운드/조작 문제를 기록합니다.
5. 선택적으로 외부 비주얼 에셋을 설치한 뒤 자체 포함 버전과 비교합니다. 외부 에셋이 없다는 이유만으로 테스트를 막지 않습니다.

정적 CI 성공은 Luau lint와 Rojo Place 생성 성공을 의미할 뿐, Roblox Studio 런타임 성공을 보장하지 않습니다. 최종 릴리스 판정 전에는 반드시 실제 Studio 플레이테스트가 필요합니다.

## 정본

- `default.project.json`: Rojo 구조
- `src/ReplicatedStorage`: Config / Arsenal / Loot 등 공유 데이터
- `src/ServerScriptService`: 서버 권한 전투, Run, Objective, Progression, World 서비스
- `src/StarterPlayer/StarterPlayerScripts`: 입력, HUD, 1인칭 무기/손, 적/전투 FX, 오디오
- `tools/INSTALL_VISUAL_ASSETS.server.lua`: 선택적 외부 시각 에셋 설치기
- `ASSET_SOURCES.md`: 외부 에셋 출처 및 처리 정책
- `docs/TEST_CHECKLIST.md`: 현재 12섹터 전체 플레이테스트 체크리스트
