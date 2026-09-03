# World Art, Animation & Audio

> 검증 기준일: 2026-09-03

공식 참고:

- Environment: https://create.roblox.com/docs/environment
- Lighting: https://create.roblox.com/docs/environment/lighting
- Materials: https://create.roblox.com/docs/parts/materials
- Terrain: https://create.roblox.com/docs/parts/terrain
- Animation: https://create.roblox.com/docs/animation
- Characters: https://create.roblox.com/docs/characters
- Effects: https://create.roblox.com/docs/effects
- Audio: https://create.roblox.com/docs/audio
- Importer: https://create.roblox.com/docs/studio/importer

## 1. 아트 방향은 에셋보다 먼저

프로젝트 시작 시 먼저 정의한다.

```text
shape language:
color palette:
material family:
lighting mood:
character proportions:
VFX density:
UI visual language:
reference games:
performance target:
```

좋은 에셋 여러 개를 섞는 것만으로 좋은 게임이 되지 않는다. **같은 시각 문법**이 중요하다.

## 2. Roblox에서 읽히는 월드

플레이어가 빠르게 이동하고 카메라가 멀리 떨어지는 장르가 많다. 작은 디테일보다는 다음이 먼저 읽혀야 한다.

- 실루엣
- 큰 색 덩어리
- landmark
- 길/목표 방향
- 안전/위험 구역
- 상호작용 가능한 오브젝트

원칙:

- 주요 경로는 배경과 대비
- 지역마다 기억 가능한 landmark 최소 1개
- 반복 prop은 variation을 주되 theme는 유지
- 장식이 navigation을 가리지 않음
- 플레이 공간과 장식 공간을 구분

## 3. Greybox → Art Pass

맵 제작 순서:

```text
metric/scale 테스트
→ greybox
→ 이동/카메라/전투 테스트
→ landmark와 composition
→ kit/asset 선택
→ material/color pass
→ lighting
→ clutter/foliage
→ VFX/audio
→ optimization
```

처음부터 나무·집·바위를 예쁘게 배치하면 동선이 틀렸을 때 수정 비용이 커진다.

## 4. 스케일 기준

캐릭터 크기와 실제 WalkSpeed/JumpPower로 직접 걸어본다.

검사:

- 문 폭/높이
- 계단
- 코너 회전
- 복도 폭
- 카메라 충돌
- 점프 가능한 턱
- 전투 arena 크기
- 몬스터와 플레이어 사이 spacing

실제 Playtest 없이 숫자만 보고 scale을 결정하지 않는다.

## 5. Lighting

조명은 예쁨뿐 아니라 gameplay readability를 만든다.

### 우선순위

1. 플레이어/적/목표가 보이는가
2. 지역 mood가 구분되는가
3. UI와 대비가 깨지지 않는가
4. 모바일/낮은 quality에서도 읽히는가
5. post effect가 gameplay를 방해하지 않는가

주의:

- Bloom/ColorCorrection/Atmosphere를 여러 개 겹쳐 과노출
- transparent surface가 중첩되어 flicker/z-fighting처럼 보임
- 지역별 lighting transition이 너무 급함
- 낮은 graphics quality에서 핵심 정보가 사라짐

## 6. Z-fighting 예방

같은 평면 또는 거의 같은 깊이의 표면을 겹치지 않는다.

예:

- 바닥 위에 0.01 stud짜리 다른 바닥을 완전히 포개지 않음
- decal/texture로 해결 가능한 장식을 얇은 part로 중첩하지 않음
- runtime world와 edit-time safety geometry가 중복 생성되지 않도록 함

화면 번쩍임이 보이면 먼저 겹친 geometry와 post-processing을 확인한다.

## 7. Materials

- 장르에 맞는 material family를 제한
- 비슷한 표면마다 서로 다른 texture를 무작정 쓰지 않음
- 반복 texture scale 확인
- PBR/SurfaceAppearance는 실제 효과가 보이는 자산에 집중
- 작은 prop에 과도한 texture memory를 쓰지 않음

## 8. Terrain vs Parts/Meshes

Terrain 적합:

- 자연 지형
- 넓은 산/계곡/강
- 유기적인 지면

Parts/Meshes 적합:

- 건축
- 정밀 collision
- 반복 modular kit
- 명확한 silhouette

혼합이 보통 가장 실용적이다.

## 9. Modular environment kit

좋은 kit는 다음이 있다.

```text
floor
wall
corner
pillar
door/window
stairs
roof
trim
large landmark
small props
```

grid와 pivot을 통일하면 배치 속도와 일관성이 크게 올라간다.

## 10. 캐릭터/몹 모델

### 하나의 model/rig로 움직인다

몸통만 CFrame 변경하고 눈/장식은 world position에 남겨두는 식의 구조를 금지한다.

사용:

- Model:PivotTo
- PrimaryPart
- WeldConstraint
- Motor6D
- Attachments
- Bones/rigging

### silhouette 우선

적은 멀리서도 종류가 구분되어야 한다.

차별화:

- 키
- 너비
- 머리/무기
- 이동 자세
- 색 accent
- animation cadence

HP만 다른 같은 구체 20종은 콘텐츠가 아니다.

## 11. 애니메이션 원칙

좋은 combat animation은 다음을 전달한다.

```text
anticipation → action → impact → recovery
```

### 공격

- startup이 읽힘
- hit frame과 실제 판정이 일치
- recovery가 전투 리듬을 만든다
- combo 단계마다 silhouette 차이

### 적 공격

- telegraph가 충분히 명확
- 공격 방향/범위가 animation/VFX와 일치
- 강한 공격일수록 anticipation이 커짐

### 이동

- acceleration/stop과 animation이 어색하게 따로 놀지 않음
- sprint/strafe/jump/fall/land transition 확인

## 12. Animation marker

타격 판정/VFX/audio를 animation timing과 맞추려면 marker/event를 활용한다.

단, 보안상 최종 피해량은 서버 authoritative logic과 정합되어야 한다.

## 13. VFX hierarchy

VFX는 중요도 계층을 가진다.

### Tier 1 — 반복 행동

- 작은 hit spark
- 짧은 trail
- subtle sound

### Tier 2 — skill

- 명확한 shape/color
- 범위/방향 표현

### Tier 3 — ultimate/boss/milestone

- 더 큰 screen/world response
- 카메라/음향/lighting 조합 가능

매 기본 공격을 ultimate처럼 만들지 않는다.

## 14. VFX와 판정 일치

보이는 범위와 실제 hitbox가 크게 다르면 불공정하게 느껴진다.

검사:

- beam/trail 끝
- AoE radius
- projectile size
- ground telegraph
- boss cone/line

presentation과 gameplay bounds를 함께 튜닝한다.

## 15. Particle/Beam/Trail 선택

- ParticleEmitter: 폭발, 먼지, 마법 입자
- Beam: 연결, 레이저, arc, ribbon
- Trail: 빠른 무기/투사체 이동 궤적
- Highlight: 목표/상호작용 강조

필요한 effect type을 사용하고 particle만으로 모든 것을 해결하지 않는다.

## 16. Camera as art

카메라가 게임의 시각 품질 절반을 좌우할 수 있다.

검사:

- 기본 거리
- FOV
- 실내 충돌
- sprint FOV 변화
- lock-on
- boss framing
- hit shake
- mobile thumb input

camera shake는 작은 반복 공격에는 최소, 큰 impact에만 강하게.

## 17. Audio hierarchy

소리도 정보 계층.

### 항상 잘 들려야 함

- 플레이어 피격
- 중요한 enemy telegraph
- 성공/실패
- UI confirmation

### 덜 중요

- ambient clutter
- 작은 decorative loop

여러 효과음이 동시에 최대 volume으로 경쟁하지 않게 mix를 설계한다.

## 18. 2D vs 3D audio

2D:

- UI
- music
- global notification

3D:

- enemy
- weapon/world interaction
- ambience source

거리 attenuation과 rolloff를 실제 gameplay 거리에서 테스트.

## 19. Sound variation

같은 swing/hit sound를 1개만 반복하면 빠르게 인공적으로 들린다.

가능하면 작은 variation:

- pitch
- multiple samples
- material-specific impact
- intensity tier

단, 랜덤 pitch가 장르 정체성을 깨지 않게 범위를 제한.

## 20. Art QA checklist

- [ ] 첫 스폰에서 어디로 갈지 보임
- [ ] landmark가 있음
- [ ] 모든 적 silhouette 구분
- [ ] 무기 grip/orientation 정상
- [ ] rig 장식이 몸과 함께 이동
- [ ] z-fighting 없음
- [ ] 카메라 clipping 없음
- [ ] VFX와 hitbox 정합
- [ ] 중요한 audio cue가 묻히지 않음
- [ ] 낮은 graphics quality 테스트
- [ ] 모바일 화면에서 readability 유지
- [ ] Streaming 시 pop-in이 gameplay를 깨지 않음
