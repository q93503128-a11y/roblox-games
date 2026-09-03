# Studio Setup

## Option A — Rojo

1. Install Rojo.
2. Open a blank Roblox Studio place.
3. Start Rojo from this folder.
4. Connect Studio to the project.
5. Sync.
6. Publish the experience.
7. Create Game Passes and Developer Products.
8. Replace the placeholder IDs in `MonetizationConfig.lua`.

## Option B — manual import

Create the following structure:

ReplicatedStorage
- Shared
  - GameConfig
  - EconomyConfig
  - MonetizationConfig

ServerScriptService
- Services
  - RemoteService
  - PlayerDataService
  - PassService
  - PurchaseService
  - EconomyService
- ServerBootstrap

StarterPlayer
- StarterPlayerScripts
  - ClientBootstrap

Paste each matching source file into a ModuleScript / Script / LocalScript.

## Studio testing

For DataStore testing:
Game Settings -> Security -> Enable Studio Access to API Services.

Do not enable it on an unrelated production universe.

## Purchases

Product/pass IDs remain `0` until you create the real monetization items.

A zero ID intentionally causes the client to warn instead of opening a purchase prompt.
