# Visual Quality Pipeline

> verified: 2026-09-03

목표: Roblox에서 "기능은 있지만 싸구려처럼 보이는" 결과를 방지한다. Visual quality는 마지막 polish 단계가 아니라 blockout부터 관리한다.

## 1. Art direction before asset collection

프로젝트 시작 시 한 페이지 art bible을 만든다.

필수:
- 3~5 reference screenshots
- shape language
- palette
- material language
- lighting mood
- character/world scale
- VFX brightness/shape
- UI visual language
- 금지 스타일

예:
```text
Shapes: chunky, rounded silhouettes
Environment: stylized, medium saturation
Lighting: warm key + cool ambient, readable shadows
VFX: 0.2~0.6 s bursts, thin additive accents
Forbidden: neon everywhere, random realism, flat gray blocks as final assets
```

## 2. Visual hierarchy

한 화면에서 중요도 순서가 보여야 한다.

Gameplay scene:
1. player / immediate hazard
2. target/enemy/goal
3. interactable/reward
4. path/landmark
5. decoration

배경 detail이 gameplay보다 더 밝고 contrast가 높으면 나쁜 art direction일 수 있다.

## 3. Authored blockout

초기 맵도 random parts scatter보다 **의도된 path와 landmark**를 먼저 만든다.

Blockout에서 측정:
- main route
- side route
- landmark visibility
- enemy encounter spacing
- combat area dimensions
- traversal time
- camera occlusion

좋은 blockout은 회색이어도 플레이 방향을 이해할 수 있다.

## 4. Modular environment

모듈 kit:
- wall segments
- corners
- doors/windows
- floors
- roofs
- rocks/foliage clusters
- path pieces
- props

그 후 variation:
- scale 제한
- rotation
- material/palette variants
- decals/props

완전 random placement는 art direction이 아니라 noise가 되기 쉽다.

## 5. Scale discipline

Studio viewport에 항상 avatar scale reference를 둔다.

Check:
- door/ceiling height
- stair height
- weapon size
- enemy silhouette
- path width
- interact distance
- UI world billboard size

실제 gameplay camera에서 screenshot으로 검수한다.

## 6. Lighting

먼저 gameplay readability, 그 다음 mood.

순서:
1. ClockTime/key direction
2. Environment/Ambient
3. atmosphere/fog only if needed
4. local lights
5. color grading/post effects

Post effect를 여러 개 겹쳐 "예쁘게" 만들지 않는다. flashing/contrast loss/overexposure를 device에서 확인한다.

## 7. Materials

- hero surface에는 필요한 detail
- background에는 simpler material
- 반복 텍스처 scale 통일
- transparent materials는 overdraw 비용 고려
- neon은 accent, 기본 재질이 아님

Material Generator / MaterialVariant는 빠른 iteration에 사용 가능:
https://create.roblox.com/docs/studio/material-generator

## 8. Weapon art

무기는 character와 함께 가장 자주 보는 hero asset이다.

Acceptance:
- third-person silhouette에서 즉시 category 인식
- grip 위치 자연스러움
- idle/equip/attack orientation 정상
- trail/VFX attachment 명확
- collision gameplay와 visual mesh 분리 가능
- 너무 얇아 모바일에서 사라지지 않음

primitive neon bar는 blockout으로만 허용.

## 9. Enemy art

Enemy visual은 attack readability와 연결한다.

- weak point / attack limb 명확
- wind-up 때 silhouette 변화
- hit reaction readable
- body parts는 Model lifecycle로 묶임
- accessories/eyes/VFX가 PivotTo/animation에서 분리되지 않음

## 10. Animation pipeline

상태:
- idle
- locomotion
- anticipation
- active hit
- recovery
- hurt
- death

액션 animation에서 gameplay timestamp를 문서화한다.

예:
```text
0.00 input
0.00-0.16 anticipation
0.17 hit opens
0.22 hit closes
0.23-0.42 recovery
```

Animation과 hitbox가 따로 노는 것을 방지한다.

## 11. VFX pipeline

VFX는 공격을 숨기는 것이 아니라 설명해야 한다.

Layer:
- anticipation cue
- hit flash
- directional trail
- impact burst
- lingering state only if gameplay relevant

Check:
- enemy telegraph와 player VFX 색 구분
- giant opaque particles 금지
- camera 가까이에서 screen fill 제한
- mobile particle count/profile
- `Enabled`/lifetime cleanup

## 12. Sound

전투/상호작용에서 sound hierarchy:
1. danger/telegraph
2. hit/confirm
3. reward
4. movement
5. ambience

동시에 모두 큰 소리로 재생하지 않는다.

Variation:
- pitch/rate small variation
- multiple impact samples
- distance rolloff

## 13. Camera

카메라는 art/전투 시스템이다.

검수:
- base FOV
- distance
- collision
- lock/target behavior
- shake amplitude/frequency
- zoom/FOV kick
- motion sickness risk

Camera shake는 짧고 목적이 있어야 한다. 매 공격에 과도한 shake는 피로를 준다.

## 14. Screenshot review gate

Vertical Slice에서 최소 screenshot:
- spawn wide shot
- core loop scene
- combat anticipation
- combat hit
- reward state
- menu/HUD
- low-end mobile emulator

각 screenshot에서 질문:
- 어디를 봐야 하는지 1초 안에 알 수 있나?
- project style이 일관적인가?
- placeholder가 보이나?
- clipping/z-fighting/seam이 있나?
- UI가 world를 과도하게 가리나?

## 15. AI / procedural art

Roblox current AI/procedural tools는 iteration 가속에 사용한다.
- generated mesh/material
- ProceduralModel
- Assistant/MCP

하지만 생성 결과는 자동 S-tier가 아니다. Creator Store asset과 동일한 art/performance inspection을 통과해야 한다.

Official overview:
https://create.roblox.com/docs/art/overview-studio
https://create.roblox.com/docs/parts/procedural-models

## 16. Production art done definition

- [ ] placeholder tag가 player-facing hero area에 없음
- [ ] reference board와 silhouette/palette 일치
- [ ] 움직이는 model integrity 정상
- [ ] lighting/device exposure 검증
- [ ] no obvious z-fighting
- [ ] collisions 플레이를 방해하지 않음
- [ ] VFX가 hit/telegraph를 읽기 쉽게 함
- [ ] mobile render/perf check
- [ ] source records complete
