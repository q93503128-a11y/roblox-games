# BREACH PROTOCOL / Vaultfall 첫 전체 플레이테스트 체크리스트

이 문서는 최신 12섹터 자체 포함 빌드를 Roblox Studio에서 처음부터 끝까지 검증할 때 사용하는 체크리스트입니다. 외부 Creator Store 에셋 설치는 필수 선행 조건이 아닙니다.

## A. 빌드 / Studio 시작
- [ ] 최신 `main`에서 `rojo build projects/vaultfall/default.project.json --output Vaultfall.rbxlx` 성공
- [ ] 또는 최신 `Vaultfall CI`의 `vaultfall-rbxlx` 아티팩트 사용
- [ ] Studio Play 후 Output에 `[Vaultfall] server boot complete; world ready` 표시
- [ ] 외부 `ServerStorage/VaultfallAssets`가 없어도 Safehouse / 무기 / 적 / 전투방이 정상 표시
- [ ] DataStore API가 꺼져 있어도 세션 폴백으로 월드와 플레이가 시작됨
- [ ] 시작 직후 빈 하늘, 낙하, 무한 로딩, 카메라 고정, 입력 불능이 없음

## B. Safehouse
- [ ] 플레이어가 바닥이 있는 Safehouse 스폰 위치에 생성
- [ ] 출격 인터랙션이 바로 식별됨
- [ ] 영구 성장 / Mastery / Career / Contract 관련 인터랙션이 서로 겹치지 않음
- [ ] 넓은 빈 바닥 + 텍스트 패드만 있는 형태가 아니라 구조물 / 랜드마크 / 조명 / 장식이 공간을 구분
- [ ] 모바일 화면에서도 핵심 인터랙션이 HUD에 가려지지 않음
- [ ] 외부 에셋을 설치하지 않아도 첫 인상이 명백한 placeholder 수준으로 무너지지 않음

## C. 원정 시작 / 파티
- [ ] 출격 시 Room 1으로 정상 이동
- [ ] HUD가 `1 / 12` 구조와 현재 섹터 타입을 올바르게 표시
- [ ] 시작 무기가 PX-9 Service Carbine으로 표시
- [ ] 서버에 여러 명이 있을 때 최대 4명까지만 원정 참가
- [ ] 원정 중 중복 출격 요청으로 두 번째 Run이 생성되지 않음
- [ ] 2~4인 테스트에서 인원 증가에 따라 적 수 / 체력 / 압박이 증가

## D. 4종 무기 / 1인칭 표현
- [ ] Carbine / SMG / Shotgun / Rail Rifle이 서로 다른 실루엣으로 즉시 구분
- [ ] 총이 화면에서 사라지거나 카메라 뒤 / 몸 안으로 심하게 클리핑하지 않음
- [ ] 좌클릭 발사
- [ ] R 재장전
- [ ] Q 대시
- [ ] 발사 중 서버 FireInterval보다 빠른 피해 적용이 없음
- [ ] 탄약 0에서 발사가 되지 않고 재장전이 정상 작동
- [ ] 무기 교체 시 탄창 / Combat HUD가 새 무기에 맞게 갱신
- [ ] 걷기 / idle / recoil / reload / swap에서 손과 총기 디테일이 분리되어 떠다니지 않음
- [ ] Shotgun은 펌프 / 쉘 장전 느낌, Rail Rifle은 중량감 있는 별도 동작이 보임
- [ ] 모바일 입력으로 발사 / 재장전 / 대시가 가능

## E. 오디오 / 피드백
- [ ] 전투 시작 시 CombatAudio가 사라지거나 중복 생성되지 않음
- [ ] Carbine / SMG / Shotgun / Rail Rifle 발사음이 서로 구분됨
- [ ] 재장전 / 대시 / 일반 Hit / Crit / Kill 확인음이 재생
- [ ] Safehouse와 Sector ambience가 동시에 과도하게 겹치지 않음
- [ ] 강한 발사 시 ambience ducking이 작동하되 배경음이 영구적으로 줄어들지 않음
- [ ] 보스 / HVT / Extraction 경고가 전투음에 완전히 묻히지 않음

## F. 적 / HVT / 보스 가독성
- [ ] Shade / Archer / Brute가 실루엣과 행동으로 구분
- [ ] Elite가 일반 적보다 위협적으로 보임
- [ ] Huntsman / Bulwark / Reaper가 서로 다른 장식과 전투 패턴으로 구분
- [ ] HVT Highlight / threat plate가 과도한 화면 번짐 없이 식별에 도움
- [ ] Vault Warden이 일반 Elite와 혼동되지 않을 정도로 크기 / 코어 / 스파인 / 연출이 다름
- [ ] 적 사망 연출 뒤 히트박스 / AI가 남지 않음

## G. 보스 패턴
- [ ] Vault Warden 체력에 따라 3페이즈가 체감됨
- [ ] 원형 충격파 예고 후 실제 피해 범위가 시각 범위와 크게 어긋나지 않음
- [ ] 직선 Lane 공격이 충분히 먼저 보임
- [ ] 교차 Sweep이 피할 수 없는 즉사 패턴이 아님
- [ ] 표적 Barrage 위치가 플레이어를 따라 무한 추적하지 않고 예고 위치에 떨어짐
- [ ] 페이즈가 올라갈수록 빈도 / 조합이 강해지지만 패턴 판독은 가능

## H. 섹터 진행 / 목표
- [ ] 12개 섹터 경로가 순서대로 진행
- [ ] Combat / Treasure / Elite / Shrine / DeepCombat / Boss의 역할 차이가 체감됨
- [ ] Uplink 3개 상호작용 정상
- [ ] Holdout 타이머가 멈추거나 중복 진행하지 않음
- [ ] Recovery 목표 아이템을 모두 확보 가능
- [ ] Sabotage 노드 2개를 모두 처리 가능
- [ ] 적을 먼저 전멸시킨 경우에도 남은 Objective를 완료하면 방이 열림
- [ ] Objective를 먼저 완료한 경우 남은 적을 잡으면 방이 열림
- [ ] Objective 완료 시 8% 회복 + `OBJECTIVE PROTOCOL` Augment 제안이 정상 발생
- [ ] 같은 방의 일반 보상과 Objective 보상이 의도치 않게 무한 중복되지 않음

## I. Loot / Augment / Optional Op / HVT
- [ ] 방 클리어 후 Loot Offer에서 현재 무기와 새 무기 비교 가능
- [ ] EQUIP 시 즉시 새 무기 / 탄약 / 프레젠테이션으로 전환
- [ ] SKIP 시 기존 무기 유지
- [ ] 같은 Loot Offer를 두 번 Claim할 수 없음
- [ ] 일반 Augment 보상은 같은 방에서 중복 스팸되지 않음
- [ ] HVT / Optional Op 보너스가 일반 Augment와 겹쳐도 사라지지 않고 큐에 보존
- [ ] 현재 Augment를 선택한 뒤 대기 중이던 프리미엄 보상이 다음 선택으로 열림
- [ ] HVT / Optional Op를 수행한 보상이 단순 Notice만 뜨고 증발하지 않음

## J. Extraction / 위험-보상
- [ ] 4 / 7 / 9 / 11섹터 클리어 후 Extraction Window 표시
- [ ] 현재 미확보 Essence / 깊이 보너스 / 총 확보 예정량이 HUD와 Notice에서 일치
- [ ] Extraction Prompt를 홀드하면 해당 플레이어만 Safehouse로 복귀
- [ ] 추출한 플레이어의 Essence가 실제 Profile에 반영
- [ ] 다른 생존 파티원은 계속 깊게 진행 가능
- [ ] 다음 방 진입 시 이전 Extraction Beacon과 상태가 정리
- [ ] 모두 추출하면 Run이 깨끗하게 종료되고 Safehouse 상태로 돌아감

## K. 사망 / 탈락 / 이탈
- [ ] 한 명이 죽어도 생존 파티원이 있으면 원정 계속
- [ ] 죽은 플레이어가 적 AI 대상으로 남지 않음
- [ ] 죽은 플레이어가 Roblox 자동 리스폰 후 다시 발사 / 재장전 / 대시할 수 없음
- [ ] 자동 리스폰된 탈락자는 Safehouse로 이동하고 stale Run HUD가 정리됨
- [ ] 전원 사망하면 `BREACH FAILED`
- [ ] 실패 후 적 / Objective / Extraction Beacon이 정리
- [ ] 파티원이 서버를 나가도 남은 인원의 Run 상태가 깨지지 않음
- [ ] 마지막 생존자가 나가면 Run이 정상 실패 / 정리

## L. 완료 / 영구 성장
- [ ] Vault Warden 처치 후 Boss 방이 완료 처리
- [ ] 미확보 Essence가 전액 은행 처리
- [ ] Completion / Runs / Power Rank 진행이 정상 반영
- [ ] 완료 후 Safehouse 복귀
- [ ] 영구 공격 / 체력 성장 효과가 다음 Run에 반영
- [ ] Mastery / Career / Contract 진행 수치가 의도한 이벤트에서만 증가

## M. 저장 / 재접속
- [ ] Studio API 사용 가능 환경에서 Essence / Runs / Rank / 영구 성장 저장
- [ ] 재접속 후 저장값 복구
- [ ] 원정 중 임시 무기와 Augment가 영구 저장되지 않음
- [ ] DataStore 오류가 발생해도 게임 월드 / Run 시작이 중단되지 않음

## N. 최종 체감 기록
1. 가장 먼저 재미가 끊긴 섹터 번호
2. 4종 무기 중 가장 좋은 것 / 가장 약한 것
3. 발사 손맛: 가벼움 / 적당 / 과함
4. 적 체력: 너무 약함 / 적당 / 피통 과다
5. Safehouse 첫인상과 가장 허전한 구역
6. 반복적으로 보이는 전투방 장식 / 구조
7. 가장 알아보기 어려운 적 또는 보스 패턴
8. Extraction을 실제로 고민하게 되는지
9. 모바일에서 가장 불편한 입력 / HUD
10. Output의 Error / Warning 전체
11. 문제 장면 스크린샷
12. 현재 상태에서 계속 키울 가치가 있는지 한 줄 평가

> CI의 Selene / Rojo 성공은 정적 빌드 검증입니다. 이 체크리스트를 실제 Roblox Studio에서 통과하기 전에는 런타임 완성으로 간주하지 않습니다.
