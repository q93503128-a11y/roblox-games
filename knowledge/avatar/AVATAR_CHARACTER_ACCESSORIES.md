# Avatar, Character, Accessories, and Custom Rig Strategy

> verified: 2026-09-03

Official:
- Avatar overview: https://create.roblox.com/docs/avatar
- Rigid accessories: https://create.roblox.com/docs/avatar/rigid-accessories
- Layered accessories: https://create.roblox.com/docs/avatar/layered-accessories
- Avatar resources: https://create.roblox.com/docs/avatar/resources

## 1. Choose avatar strategy first

### User avatar
Pros:
- personal identity
- existing cosmetics
- social familiarity

Costs:
- body/scale variation
- accessory interference
- weapon socket differences
- silhouette less controlled

### Custom character
Pros:
- fixed combat silhouette
- exact rig/animation
- strong game identity

Costs:
- avatar expression reduced
- custom rig/art pipeline
- cosmetics need separate design

### Hybrid
User head/accessories + controlled body, or game outfit over avatar. Test technical/policy behavior explicitly.

## 2. Rig contract

Document:
- R6/R15/custom
- root
- humanoid usage
- Animator
- attachment/socket names
- scale policy
- hitbox policy

Gameplay code should not assume arbitrary avatar accessory geometry is damage hitbox.

## 3. Humanoid vs custom controller

Humanoid provides a large amount of built-in character behavior. Replace it only when game requirements justify ownership of movement/state/camera complexity.

Custom controller must re-solve:
- locomotion
- slopes/steps
- jump/fall
- seats
- death
- replication
- mobile/gamepad
- networking/security

## 4. Rigid accessories

Rigid accessory structure:
- mesh/texture
- attachment

Attachments determine consistent body placement. For game weapons/cosmetics, use named sockets rather than random CFrame offsets per avatar.

## 5. Layered accessories

Layered clothing depends on:
- mesh/textures
- rigging armature
- cage meshes
- attachments

It deforms to avatar body. Test multiple bodies and animations if supporting user avatars.

## 6. Accessory Fitting Tool

Use Studio fitting tools for avatar-facing assets. Preview against body/animation combinations instead of checking one mannequin only.

## 7. Gameplay weapon vs Marketplace accessory

A combat weapon held by character does not automatically need to be a Marketplace avatar accessory. Separate:
- gameplay model
- cosmetic accessory
- marketplace item

Each has different ownership/attachment/policy needs.

## 8. Character collision

Do not use every visible limb/accessory as physical collision.
Define:
- root/capsule-style gameplay collision
- damage hurtboxes
- cosmetic no-collision accessories

This improves predictability and avoids hats/wings snagging.

## 9. Animation compatibility

Test:
- idle/run/jump
- attack
- weapon equip
- emotes if supported
- scaled avatars
- layered clothing

Hero combat animation may require controlled rig proportions.

## 10. Avatar appearance load

When loading user avatar description/appearance:
- failure/timeouts considered
- respawn lifecycle
- asset permissions
- performance with many accessories

Do not block core server boot on optional cosmetic loading.

## 11. Cosmetic performance

Large social lobbies can contain many unique avatar assets.
Budget:
- particles
- lights
- high complexity accessories
- layered items

If game adds custom aura/cosmetic effects, LOD them.

## 12. Marketplace vs Creator Store

Marketplace = user avatar items.
Creator Store = development assets (models/images/plugins/etc.).
Do not confuse usage/licensing/commerce paths.

## 13. Marketplace publishing

If selling avatar items, current technical specifications, moderation, creator eligibility, fees, and category policy must be re-checked immediately before submission. These requirements change over time.

## 14. Character security

Client controls movement under traditional network ownership assumptions. Competitive games need server movement/combat sanity validation or current server-authority approach.

Never trust client:
- humanoid health changes
- equipped valuable item ownership
- damage
- movement-derived reward without validation

## 15. Character lifecycle

Every system must handle:
```text
PlayerAdded
→ CharacterAdded
→ Humanoid/rig ready
→ death
→ CharacterRemoving
→ respawn
→ PlayerRemoving
```

Connections/effects/tools from old character must be cleaned.

## 16. Acceptance

- [ ] avatar strategy documented
- [ ] rig/socket contract
- [ ] supported body variants tested
- [ ] accessories do not affect gameplay collision unexpectedly
- [ ] weapon remains attached through animation
- [ ] death/respawn cleanup
- [ ] cosmetic load failure safe
- [ ] multiplayer avatar performance checked
