# Roblox Tycoon Game

A Roblox tycoon game framework featuring persistent player data, in-game purchases, and modular tycoon components.

## Features

- **Player Management**
  - Persistent player data using `DataStoreService`.
  - Automatic creation of leaderstats.
  - Session handling via `sessionData`.
  - Multiplier system and unlockable tycoon upgrades.
  
- **Gamepasses & Developer Products**
  - Supports Roblox Gamepasses and Developer Products.
  - Handles in-game purchases with `PromptGamePassPurchase` and `ProcessReceipt`.
  
- **Tycoon System**
  - Individual tycoon spawns per player.
  - Unlockable and upgradeable components.
  - Modular component system (`Upgrader`, `Despawn`, `Kill`, etc.).
  - Automatic event subscription via `BindableEvent` topics.

  - **CollectionService Tags**
  - This project uses Roblox's `CollectionService` to tag objects (e.g., Gamepass buttons, tycoon components).
  - Tags allow automatic module attachment and event handling for new objects added during runtime.
  
- **Data Safety**
  - `Reconcile` ensures new fields are safely added to old player data.
  - Session data automatically saved when players leave or the server shuts down.
  - Functions for clearing unlocks or resetting player tycoon data.

## Folder Structure

- **ServerScriptService**
  - `PlayerManager.lua` — Handles player sessions, data, and gamepasses
  - **Tycoon/**
    - `Tycoon.lua` — Main Tycoon class
    - **Components/** — Component modules (Upgrader, Despawn, Kill, etc.)
    - `PlayerHandler.lua` — Optional player utility module
  - `ProductHandler.lua` — Handles developer products

- **LocalScripts**
  - `PlayerMonetization.lua` — Handles Gamepass/DevProduct UI prompts

- **ModuleScripts**
  - `Gamepasses.lua` — Gamepass effects mapped by ID
