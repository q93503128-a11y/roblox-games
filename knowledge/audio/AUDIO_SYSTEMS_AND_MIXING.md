# Audio Systems and Mixing

> verified: 2026-09-03

Official current audio docs:
- https://create.roblox.com/docs/audio
- https://create.roblox.com/docs/audio/effects
- legacy/current Sound overview: https://create.roblox.com/docs/sound

Roblox has both traditional Sound/SoundGroup workflows and newer Audio object graph systems. Choose one intentionally and verify current support before architecture migration.

## 1. Audio hierarchy

Mix by category instead of individual sound chaos.

Example buses/groups:
- Master
- Music
- Ambience
- Gameplay
  - Player
  - Enemy
- UI
- Voice/Social if applicable

Settings can independently control major categories.

## 2. Priority

Player가 반드시 들어야 하는 순서:
1. lethal danger / telegraph
2. input/hit confirmation
3. reward/important state
4. movement
5. ambience/decorative

모든 sound를 같은 loudness로 만들지 않는다.

## 3. 2D vs 3D

2D/non-positional:
- UI
- music
- global notification

3D/positional:
- enemy
- footsteps
- world machine
- environmental source

Sound object parent/location 또는 newer AudioEmitter/Listener graph에 따라 behavior가 달라진다.

## 4. Combat layering

Strong hit example:
- weapon whoosh
- contact transient
- material/body impact
- target reaction
- optional low-end accent

모든 layer를 크게 하지 않는다. 작은 hit과 heavy hit의 spectral/duration 차이를 만든다.

## 5. Variation

반복 sound fatigue 감소:
- sample variants
- tiny playback speed/pitch variation where appropriate
- volume variation 제한
- cooldown to prevent spam

발소리 1개를 초당 여러 번 똑같이 반복하지 않는다.

## 6. Spatial rolloff

3D sound range는 gameplay readability와 world scale에 맞춘다.

문제:
- 모든 combat 소리가 map 전체에서 들림
- 바로 옆 enemy가 너무 작음
- ambience source가 sudden hard cutoff

거리별 test.

## 7. Occlusion/reverb/effects

Current audio/dynamic effects include equalizer/compressor/reverb families.

Use:
- indoor reverb
- underwater/behind-wall coloration if system supports it
- master compression carefully

Effect 자체가 gameplay cue를 흐리지 않게.

## 8. Music states

Music을 한 loop로만 생각하지 않는다.

State 후보:
- hub
- exploration
- combat
- boss
- victory
- danger

Transition:
- crossfade
- bar/phrase-aware if implementation supports
- death/menu interruption

Music은 중요한 enemy telegraph를 덮지 않게 mix.

## 9. UI sounds

필수 후보:
- hover/selection only if not annoying
- confirm
- error
- purchase/reward
- menu open/close

모든 tiny hover에서 sound를 내면 fatigue.

## 10. Voice / TTS / STT

Current Roblox Audio system includes current-generation objects such as AudioPlayer/Emitter/Listener and docs describe TTS/STT objects. Voice/speech features는 privacy/policy/eligibility와 current docs를 별도 확인하고 도입한다.

## 11. Asset rights

Creator Store/free-to-use audio라도 source/usage를 project asset manifest에 기록.

External music/SFX는 라이선스와 Roblox upload permissions를 확인.

## 12. Performance

- simultaneous sounds
- many 3D emitters
- long ambience assets
- effect graph complexity
를 worst-case로 profile.

Far/inactive source 재생을 줄인다.

## 13. Audio settings

Recommended player controls:
- Master
- Music
- SFX

게임 성격에 따라:
- ambient
- voice
- hit sound
등 optional.

Settings persist if project has profiles.

## 14. Reference analysis

레퍼런스에서:
- impact timing
- transient duration
- music transition
- danger cue lead time
- UI confirmation loudness
를 기록.

Sound file 자체를 복제하지 않고 **mixing grammar**를 배운다.

## 15. Acceptance

- [ ] danger audible over music
- [ ] repeated attacks not clipping/fatiguing
- [ ] distance rolloff sane
- [ ] settings work
- [ ] UI confirmation distinct from error
- [ ] multiple players worst-case mix
- [ ] no unauthorized audio source
