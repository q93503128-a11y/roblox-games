# Publishing, Marketplace, Policy, and Localization Safety

> verified: 2026-09-03
> Policy/eligibility details change frequently. Re-check official Roblox pages immediately before release or Marketplace submission.

Official:
- Marketplace overview: https://create.roblox.com/docs/marketplace
- Marketplace policy: https://create.roblox.com/docs/marketplace/marketplace-policy
- Localization: https://create.roblox.com/docs/production/localization
- Creator Docs policy/publishing index: https://create.roblox.com/docs/llms.txt

## 1. Marketplace != Creator Store

Marketplace:
- avatar items for users
- bodies/heads/clothing/accessories/animations
- user commerce

Creator Store:
- development assets
- models/images/plugins/etc.

Never treat them as the same licensing/publishing surface.

## 2. Release-time policy check

Before public release, re-check current:
- Community Standards
- experience/content maturity/age guidance
- monetization policy
- paid randomized items rules if applicable
- advertising/sponsored content rules
- music/audio rights
- intellectual property
- avatar Marketplace rules if selling items

Do not copy a 2024 checklist into a 2026+ release without revalidation.

## 3. Intellectual property

Safe default:
- own original work
- Roblox official reusable resources under their terms
- Creator Store assets used under current platform permissions
- external OSS/assets with explicit compatible license

Reject production reuse:
- decompiled locked place
- ripped commercial game asset
- unknown Discord dump
- "free" file with no rights/source

## 4. Marketplace avatar publishing

If selling avatar content, current Marketplace policy includes creator eligibility and technical/category requirements that can change.

Before submission:
- current creator eligibility
- category
- technical specs
- moderation rules
- fees/commissions
- intellectual property

Roblox automatically/moderately enforces category/technical constraints; do not design around bypassing moderation.

## 5. Avatar item separation

Avatar body submissions and accessories/clothing have distinct requirements. For example, Marketplace body rules can require accessories to be separate items. Always use current category-specific docs.

## 6. Experience metadata

Title/description/icon/thumbnail must accurately represent actual gameplay.
Do not:
- imply unavailable feature
- use misleading rare reward imagery
- copy another game's branding
- hide monetization nature

Metadata quality affects discovery and user trust.

## 7. Localization baseline

Roblox provides automatic localization/translation capabilities and users may have automatic translations enabled.

Project rules:
- player-facing strings centralized/localizable
- `AutoLocalize` policy explicit for proper nouns/signs
- manual translations override where maintained
- UI tolerates expansion
- number/date/currency context considered

## 8. Do not bake text into images unnecessarily

Text in texture/image:
- harder to localize
- inaccessible
- resolution issues

Use actual UI text unless graphic identity requires image text; provide localized variants when needed.

## 9. User-generated text/content

If game supports user text/content:
- use current Roblox filtering/moderation APIs
- never display raw unfiltered user text where filtering is required
- define report/block flows when platform/product scope needs them

Do not store/transmit user text to external systems casually.

## 10. Privacy/data minimization

Collect only game-relevant behavior.
Do not put in analytics/logs:
- passwords/tokens
- arbitrary chat text
- sensitive personal information

Follow platform requirements for user data removal/requests where applicable.

## 11. External web/API

If HttpService/external API is used:
- server only for secrets
- Secrets Store/current secure method
- allowlist expected endpoints in design
- timeout/retry
- data minimization
- failure fallback

No secret in LocalScript/ReplicatedStorage.

## 12. Commerce UX

Purchase prompt:
- exact item/value
- clear currency
- intentional action
- no fake countdown/stock
- no repeated harassment

Server grants reward only after authoritative purchase/receipt path.

## 13. Localization QA

At minimum test:
- English
- Korean/project primary language
- one expansion-heavy Latin language
- one CJK if relevant
- RTL if target audience/support demands

Focus:
- truncation
- line wrapping
- button width
- font support
- numeric formatting

## 14. Region/platform availability

Some commerce/social/policy features vary by region/account/platform. Never assume universal availability based on one test account.

## 15. Release checklist additions

- [ ] current policy rechecked
- [ ] metadata accurate
- [ ] all external assets sourced
- [ ] audio/music rights recorded
- [ ] user text filtering reviewed
- [ ] localization smoke
- [ ] supported platform settings accurate
- [ ] monetization UX transparent
- [ ] Marketplace item category/technical requirements current if applicable
