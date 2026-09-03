# Vaultfall first full-play test checklist

이 문서는 사용자 첫 플레이테스트 때 순서대로 확인할 항목입니다. 코드/에셋 설치 전 중간 플레이테스트를 요구하지 않습니다.

## A. Studio 준비
- [ ] `ServerStorage/VaultfallAssets` 존재
- [ ] DungeonKit / WeaponPack / MonsterPack / NaturePack 중 설치 성공 개수 확인
- [ ] Output에 `Vaultfall Installer` 실패가 있다면 해당 Creator Store 모델을 계정에 추가했는지 확인
- [ ] Rojo가 `projects/vaultfall/default.project.json`을 기준으로 연결됨
- [ ] Play 실행 후 Output에 `[Vaultfall] server boot complete` 표시
- [ ] DataStore API가 꺼져 있어도 게임이 세션 폴백으로 시작됨

## B. 허브
- [ ] 플레이어가 HubSpawn에서 생성
- [ ] `ENTER VAULT` 프롬프트가 보임
- [ ] Attack / Health 영구 강화 제단 프롬프트가 보임
- [ ] Essence가 부족할 때 강화를 구매하지 못하고 필요한 Essence 메시지가 표시
- [ ] 외부 NaturePack이 있으면 허브 모서리에 환경 장식이 일부 사용됨

## C. 원정 시작
- [ ] Enter Vault 사용 시 최대 4명이 Room 1으로 이동
- [ ] HUD가 `ROOM 1 / 8`로 전환
- [ ] 시작 무기가 Worn Blade로 표시
- [ ] Room 1 출구가 적을 모두 잡기 전에는 막혀 있음
- [ ] 원정 중 두 번째 Enter 요청이 새 원정을 중복 생성하지 않음

## D. 전투 입력
- [ ] 좌클릭 기본 공격
- [ ] E 강공격
- [ ] Q 대시
- [ ] R 회전 공격
- [ ] 공격을 연타해도 서버 쿨다운보다 빨리 피해가 적용되지 않음
- [ ] 벽을 향해 Q를 사용해도 벽 너머로 대시하지 않음
- [ ] 치명타 시 CRIT 피해 피드백 표시
- [ ] 적 사망 시 Essence 증가

## E. 적 동작
- [ ] Shade가 플레이어에게 접근 후 근접 공격
- [ ] Archer가 원거리 구체 공격
- [ ] Brute가 느리지만 강한 근접 공격
- [ ] Elite 방에서 Elite + 일반 적 조합 생성
- [ ] Boss 방에서 VaultWarden 생성
- [ ] VaultWarden이 주기적으로 확장 원형 장판을 예고 후 피해
- [ ] 파티 인원이 많을수록 적 체력/수량이 증가
- [ ] MonsterPack 설치 시 적이 가져온 모델 외형을 사용하거나, 사용할 수 없는 경우 폴백 외형으로 정상 동작

## F. 방 진행
- [ ] Combat 방 전멸 시 출구 해제
- [ ] Treasure 방은 전투 없이 강화된 드롭 제안
- [ ] Elite 방은 일반 방보다 강한 적/드롭
- [ ] Shrine 방에서 생명력 회복
- [ ] DeepCombat 방 적 구성이 일반 방보다 많고 강함
- [ ] 이전 방을 클리어하지 않은 상태에서 다음 방으로 진행 불가
- [ ] 8번 Boss 처치 전 완료 처리되지 않음

## G. 장비 드롭
- [ ] 방 클리어 후 중앙 LootOffer 표시
- [ ] 현재 무기와 새 무기의 이름/Power/희귀도 비교 가능
- [ ] EQUIP 선택 시 HUD 무기 정보 즉시 변경
- [ ] SKIP 선택 시 기존 무기 유지
- [ ] 같은 제안을 두 번 Claim하여 중복 처리할 수 없음
- [ ] 깊은 방일수록 평균 Power가 올라가는지 체감 확인

## H. 사망/협동
- [ ] 한 명이 죽어도 다른 파티원이 살아 있으면 원정 계속
- [ ] 죽은 플레이어가 적 AI 대상에서 제외
- [ ] 전원 사망하면 RUN FAILED
- [ ] 실패 후 적이 정리되고 허브 상태로 복귀
- [ ] 서버를 나간 파티원이 생겨도 남은 인원 상태가 깨지지 않음

## I. 보스 완료 및 영구 성장
- [ ] VaultWarden 처치 시 VAULT CLEARED 메시지
- [ ] Completion Essence 지급
- [ ] Runs +1
- [ ] 2회 완료마다 Power Rank +1
- [ ] 완료 후 허브 복귀
- [ ] 허브 Attack 강화 구매 후 다음 원정 피해 증가
- [ ] Health 강화 구매 후 재생성 시 MaxHealth 증가

## J. 저장
- [ ] Studio API 사용 가능 환경에서 Essence/Runs/Rank/강화 저장
- [ ] 재접속 후 저장값 복구
- [ ] 원정 중 임시 무기는 영구 저장되지 않고 새 원정에서 Worn Blade로 초기화
- [ ] DataStore 오류가 발생해도 서버 전체가 중단되지 않음

## 첫 테스트 후 기록할 것
1. 가장 먼저 재미가 끊긴 방 번호
2. 공격 손맛: 너무 느림 / 적당 / 너무 빠름
3. 적 체력: 종이 / 적당 / 피통돼지
4. 대시 거리 체감
5. 방 크기와 적 밀도
6. 외부 DungeonKit 장식이 실제로 어울리는지
7. MonsterPack 비율/크기 오류 여부
8. HUD에서 거슬리는 부분만 스크린샷
9. 발생 오류 전체 Output
10. 계속 키우고 싶은지, 바로 폐기해야 할지 한 줄 평가
