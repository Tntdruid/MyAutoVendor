# MyAutoVendor

MyAutoVendor is a lightweight World of Warcraft classic-style vendor addon designed to automatically keep or sell items depending on your rules.

It supports:

- automatic vendor selling
- automatic keep rules
- per-character item-level rules
- global sell/keep lists
- minimap button
- simple UI for managing item lists

## Features

- Auto-sell low-level gear based on your configured minimum item level
- Keep consumables, quest items, profession mats, and gear as needed
- Manage per-character settings
- Use global sell and keep lists for shared rules
- Drag items into the addon UI to add them to a list
- Right-click rows in the UI to remove items quickly

## Installation

1. Download or clone this repository.
2. Copy the folder into your WoW Interface/AddOns directory.
3. Restart World of Warcraft.
4. Type `/reload` in-game.

Example path:

- `World of Warcraft/Interface/AddOns/MyAutoVendor`

## Commands

- `/mav ui` – open the addon UI
- `/mav undo` – undo the last removal

## Files

- `Core.lua` – main logic for keep/sell behavior and merchant handling
- `UI.lua` – addon interface and list management
- `Settings.lua` – settings window for auto-keep rules
- `TabTooltips.lua` – tooltip descriptions for tabs
- `MyAutoVendor.toc` – addon load order and metadata

## Notes

This addon is intended for WoW environments using LibStub, Ace3, and standard retail/classic-style addon APIs.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
