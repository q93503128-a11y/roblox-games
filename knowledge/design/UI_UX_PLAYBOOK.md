# UI / UX Playbook

> 검증 기준일: 2026-09-03

공식 참고:

- Roblox UI/UX design: https://create.roblox.com/docs/production/game-design/ui-ux-design
- UI overview: https://create.roblox.com/docs/ui
- Position and size: https://create.roblox.com/docs/ui/position-and-size
- List/flex layouts: https://create.roblox.com/docs/ui/list-flex-layouts
- UI animation: https://create.roblox.com/docs/ui/animation
- 9-slice: https://create.roblox.com/docs/ui/9-slice
- Adaptive design: https://create.roblox.com/docs/production/publishing/adaptive-design
- Accessibility: https://create.roblox.com/docs/production/publishing/accessibility

## 1. UI는 장식이 아니라 정보 구조

Roblox 공식 UI/UX 문서는 좋은 UI의 핵심으로 다음을 강조한다.

- Prioritization
- Attention
- Visual Language
- Conventions
- Consistency

즉 "그라데이션을 예쁘게 넣기"보다 **지금 플레이어에게 무엇이 가장 중요한지**가 먼저다.

## 2. 화면마다 질문

```text
플레이어가 지금 무엇을 하고 있는가?
가장 중요한 정보는 무엇인가?
어떤 결정을 내려야 하는가?
그 결정을 위해 어떤 정보가 필요한가?
얼마나 자주 이 기능을 쓰는가?
```

이 답에 따라 UI visibility와 hierarchy를 바꾼다.

## 3. HUD 원칙

HUD에 항상 필요한 것만 남긴다.

### combat game

- HP/resource
- current ability/cooldown
- immediate objective
- 중요한 status

### simulator

- 주요 currency
- 현재 action/progress
- 가장 빈번한 upgrade/navigation

### RPG

- HP/resource
- hotbar
- quest/objective
- contextual target info

inventory, codex, settings, full stats 같은 정보는 보통 상시 HUD에 둘 필요가 없다.

## 4. Visual hierarchy

중요도 표현 도구:

- size
- contrast
- color
- spacing
- proximity
- motion

중요한 버튼 하나를 크게 만드는 대신 **모든 버튼을 크게/밝게/움직이게 만들면 hierarchy가 사라진다.**

## 5. 디자인 시스템

프로젝트마다 최소 token을 정의한다.

```text
Color.Primary
Color.Secondary
Color.Success
Color.Warning
Color.Danger
Color.Background
Color.Panel
Color.TextPrimary
Color.TextSecondary

Radius.Small / Medium / Large
Spacing.4 / 8 / 12 / 16 / 24 / 32
Font.Title / Heading / Body / Caption
Stroke.Default
Shadow.Default
Motion.Fast / Normal / Slow
```

UI component마다 임의 색/CornerRadius/Stroke를 고르지 않는다.

## 6. Visual language

동일한 의미는 동일한 시각 규칙.

예:

- HP = 항상 같은 색 family
- locked = 동일 lock icon + muted state
- unaffordable = 동일 warning/error treatment
- selected = 동일 border/highlight
- rarity = 프로젝트 전체에서 같은 색/테두리/효과

일관성은 플레이어가 UI를 "읽는 법"을 학습하게 한다.

## 7. Roblox convention 활용

사용자가 이미 아는 문법을 재사용한다.

- `X` = close
- 회색/낮은 contrast = disabled
- lock = locked
- `E` proximity prompt = world interaction
- hover/pressed state = interactive

특별한 이유가 없다면 convention을 깨지 않는다.

## 8. Contextual UI

항상 버튼 15개를 띄우지 않는다.

예:

```text
평상시: HP + hotbar + objective
상점 접근: shop prompt
전투: target health + combat resources
상호작용: contextual prompt
```

필요할 때 나타나고 필요 없으면 사라지는 UI가 모바일에서 특히 중요.

## 9. Responsive UI

Roblox는 desktop/mobile/tablet/console을 모두 고려해야 한다.

우선:

- scale과 constraints 이해
- anchor point 일관성
- automatic size/layout 활용
- UIListLayout/flex/grid 활용
- text wrapping/AutomaticSize 확인
- safe area 고려
- device emulator로 반복 검사

단순히 모든 Offset을 Scale로 바꾸는 것은 responsive design이 아니다.

## 10. Touch target

모바일에서 작은 아이콘은 예뻐도 사용할 수 없으면 실패다.

검사:

- 엄지로 누를 수 있는가
- 인접 버튼 오입력이 없는가
- 화면 가장자리에 너무 붙지 않았는가
- 전투 중 누를 수 있는가
- 텍스트가 버튼보다 작은 장식처럼 보이지 않는가

정확한 pixel 기준은 최신 Roblox adaptive/accessibility 가이드와 실제 기기 테스트를 따른다.

## 11. 입력 장치별 표현

키보드 `E`, 게임패드 `X`, 모바일 tap이 모두 같은 기능이라면 UI text를 하드코딩하지 않는다.

가능하면 Input Action System과 플랫폼/입력 context를 사용한다.

공식: https://create.roblox.com/docs/input/input-action-system

## 12. 메뉴 flow

좋은 flow:

```text
HUD
→ Inventory
→ Item detail
→ Equip
→ 즉시 결과 확인
```

나쁜 flow:

```text
HUD
→ Menu
→ Category
→ Inventory
→ Item
→ More
→ Confirm
→ 뒤로 5번
```

자주 하는 행동은 단계 수를 줄인다.

## 13. Shop UI

수익화 UI도 gameplay UI의 일부다.

원칙:

- 무엇을 사는지 명확
- 가격 명확
- 효과/기간 명확
- 이미 소유한 상태 명확
- 구매 실패/성공 명확
- 실수 click을 유도하지 않음
- 가짜 scarcity / deceptive button 금지

value presentation은 가능하지만 혼란을 유도해서 conversion을 만드는 방식은 피한다.

## 14. Inventory

필요 요소:

- category/filter
- search가 필요한 규모인지
- current equipped 명확
- rarity/stat comparison
- sort
- empty state
- controller navigation

아이템 20개인데 MMO식 필터 10개를 만들지 않는다.

## 15. 애니메이션

UI motion은 목적이 있어야 한다.

### 좋은 용도

- state change 설명
- panel origin/destination 표현
- reward emphasis
- attention guide
- button feedback

### 나쁜 용도

- 모든 panel이 1초씩 날아옴
- 버튼 hover마다 과한 scale
- gameplay 중 UI 전체 shake
- 중요한 정보가 animation 종료 전까지 안 보임

빠른 interaction은 빠르게. 보상/큰 milestone만 더 풍부하게.

## 16. 텍스트

- 긴 문단보다 짧은 label
- gameplay 중 읽을 문장은 특히 짧게
- font legibility 우선
- outline/stroke를 과도하게 쓰지 않음
- 밝은 배경/어두운 배경 양쪽 contrast 확인
- localization 시 문자열 길이 증가 고려

## 17. 9-slice

둥근 panel, frame, button image를 크기마다 새 asset으로 만들지 않고 9-slice를 활용해 border distortion을 방지한다.

## 18. 3D UI

BillboardGui/SurfaceGui는 world와 함께 읽혀야 한다.

주의:

- 멀리서 너무 큰 nameplate
- 모든 NPC/몹이 screen space를 가림
- depth/occlusion 무시
- 작은 모바일 화면에서 겹침

중요 target만 강조하고 거리 기반 표시를 고려.

## 19. Accessibility

최소 점검:

- 색만으로 상태 구분하지 않기
- 충분한 contrast
- text readability
- motion이 과하지 않음
- controller navigation
- 작은 touch target 피하기
- 중요한 sound cue에는 시각 feedback도 고려

공식 accessibility guidelines를 출시 전에 체크한다.

## 20. Reference audit

UI를 만들기 전 같은 장르 게임 3~5개를 캡처/관찰하고 표로 정리한다.

```text
HUD density
menu entry point
shop card size
inventory cell
rarity language
font hierarchy
modal width
close button
mobile layout
animation speed
```

"그대로 복제"가 아니라 **장르 convention을 추출**한다.

## 21. 품질 실패 신호

- 버튼마다 스타일이 다름
- 아무 이유 없이 neon gradient
- 모든 정보가 같은 크기
- desktop에서만 맞음
- UI가 world보다 화면을 더 많이 차지
- 닫기/뒤로가기 방식이 메뉴마다 다름
- 텍스트가 잘림
- scroll area가 안 보임
- pressed/disabled 상태 없음
- default Roblox look과 custom UI가 어색하게 혼재

## 22. UI 개발 순서

```text
player task
→ information hierarchy
→ wireframe
→ flow
→ reference comparison
→ component system
→ visual pass
→ motion
→ mobile/gamepad
→ playtest
→ analytics/experiment
```

처음부터 색과 decoration을 만드는 순서를 금지한다.
