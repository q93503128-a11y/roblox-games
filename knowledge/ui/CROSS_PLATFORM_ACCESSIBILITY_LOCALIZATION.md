# Cross-Platform UI, Accessibility, and Localization

> verified: 2026-09-03

Roblox UI는 "PC에서 예쁘다"가 완료 조건이 아니다. 화면 크기, 방향, 입력 장치가 바뀌어도 core action을 수행할 수 있어야 한다.

Official:
- Adaptive design: https://create.roblox.com/docs/production/publishing/adaptive-design
- Input Action System: https://create.roblox.com/docs/input/input-action-system
- Localization: https://create.roblox.com/docs/production/localization

## 1. Adaptive design principles

Roblox 공식 adaptive design의 핵심:
- input fluidity
- responsive layout
- dynamic sizing
- legibility / visual clarity

Device category만 보지 말고 현재 screen + input capability를 본다.

## 2. UI hierarchy

화면을 세 층으로 생각한다.

### Persistent HUD
항상 보여야 하는 최소 정보.
예: HP, core resource, objective.

### Context UI
상황에 따라 등장.
예: interact prompt, enemy boss bar, skill hint.

### Full-screen surfaces
inventory/shop/settings/quests.

모든 정보를 Persistent HUD에 박지 않는다.

## 3. Responsive layout

우선 사용:
- UIListLayout
- UIGridLayout
- UIPadding
- UISizeConstraint
- UIAspectRatioConstraint
- AnchorPoint
- scale/offset을 역할에 맞게 조합

금지:
- 한 해상도에서 pixel coordinate를 맞춘 뒤 완료
- TextScaled만 켜서 typography problem을 숨김

## 4. Mobile thumb zones

핵심 combat buttons가:
- device/system UI와 겹치지 않음
- 오른손/왼손 movement 영역을 방해하지 않음
- 손가락으로 world target을 가리지 않음

Device Emulator와 실제 touch behavior를 확인한다.

## 5. Gamepad

모든 full-screen menu:
- focus navigation 경로
- selection highlight
- back/cancel
- shoulder/tab navigation
- modal focus trapping
을 확인한다.

마우스 hover만으로 정보를 제공하지 않는다.

## 6. Input prompt

`Press E` 고정 문자열보다 action/binding 기반 prompt를 선호한다.

입력이 바뀌면:
- keyboard glyph/text
- gamepad icon
- touch button
이 전환 가능해야 한다.

## 7. Typography

- title / section / body / caption 최소 hierarchy
- 중요한 숫자와 unit 분리
- outline/stroke를 남용하지 않음
- 배경 contrast 확보
- 긴 번역 문장에도 layout 유지

UI가 읽히지 않으면 art quality가 아니라 usability failure다.

## 8. Color

색만으로 state를 구분하지 않는다.

예:
- red + icon + label for danger
- rarity: color + frame shape/icon/name
- success/failure: color + text/symbol

color vision variation을 고려한다.

## 9. Motion

좋은 UI motion:
- hierarchy 설명
- action result confirm
- state transition

나쁜 motion:
- 모든 hover마다 큰 bounce
- 반복 flashing
- menu open마다 긴 cinematic

motion duration은 빠르게 느껴져야 하고 repeated action을 방해하지 않는다.

## 10. Safe areas / reserved UI

Roblox topbar/system overlays/device cutouts를 고려한다. 중요 버튼/label을 edge에 무작정 붙이지 않는다.

## 11. Localization

Automatic translation과 localization table 기능을 활용할 수 있지만:
- player-facing string을 여러 script에 하드코딩하지 않음
- formatting placeholder를 안전하게 사용
- icon/number/date/currency context 고려
- product/name/sign처럼 번역하면 안 되는 항목은 AutoLocalize policy 확인

번역 언어는 문장 길이가 크게 달라질 수 있다. English/Korean만 보고 width를 고정하지 않는다.

## 12. UI design system

프로젝트마다 최소 token을 정한다.

```text
spacing: 4 / 8 / 12 / 16 / 24 / 32
corner: small / medium / pill
text: display / title / body / caption
surface: base / raised / modal
semantic: success / warning / danger / info
motion: fast / normal / emphasis
```

Screen마다 새 style을 즉흥적으로 만들지 않는다.

## 13. Component states

모든 interactive component에서:
- default
- hover (if pointer)
- pressed
- selected
- disabled
- loading
- error
를 고려한다.

Purchase button은 network request 중 duplicate press를 막는 loading/disabled state가 필요하다.

## 14. UI architecture

Domain state와 presentation을 분리한다.

예:
```text
Inventory state → ViewModel/selector → Inventory UI
```

UI button에서 inventory authoritative table을 직접 변경하지 않는다.

## 15. Performance

- 매 frame 전체 UI tree 재계산 금지
- invisible screen의 expensive animation/effects 중지
- viewport frames/blur/gradients를 무분별하게 늘리지 않음
- huge rich text/animated gradients를 profile

## 16. Test matrix

최소 viewport:
- small phone portrait/landscape if game supports
- common modern phone
- tablet
- 720p desktop/laptop
- 1080p desktop
- console/TV distance + gamepad

모든 장치에서 동일 pixel layout일 필요는 없다. 동일 **기능과 hierarchy**가 유지돼야 한다.

## 17. UI acceptance

- [ ] primary action 1초 내 찾기 가능
- [ ] mobile touch 가능
- [ ] gamepad focus 가능
- [ ] keyboard prompt current binding과 맞음
- [ ] no clipping at min viewport
- [ ] text translated-length tolerance
- [ ] modal back/cancel 동작
- [ ] loading/error/disabled state 있음
- [ ] no accidental double purchase
- [ ] world readability를 과도하게 가리지 않음
