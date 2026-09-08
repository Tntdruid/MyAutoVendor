# MyAutoVendor

MyAutoVendor is a lightweight World of Warcraft addon for automatically managing vendor sales and protected items. It helps you keep valuable gear, consumables, and quest items while selling junk efficiently.

## Why use it?

If you want a fast, low-maintenance vendor helper, MyAutoVendor keeps the process simple:

- auto-sell junk and low-level gear
- keep important items automatically
- manage custom per-character rules
- add global or local sell/keep entries with a simple UI
- avoid repeatedly micromanaging vendor trash in your bags

## Features

- Auto-sell based on item-level rules
- Keep consumables, quest items, and profession mats
- Protect specific named items from being sold
- Per-character configuration for item-level thresholds
- Global sell and keep lists for shared rules
- Minimap button to open the addon UI
- Easy drag-and-drop item management
- Right-click remove support in the item list

## Installation

1. Clone or download this repository.
2. Copy the `MyAutoVendor` folder into your WoW `Interface/AddOns` directory.
3. Restart World of Warcraft.
4. Type `/reload` in-game.

Example install path:

- `World of Warcraft/Interface/AddOns/MyAutoVendor`

## Commands

- `/mav ui` — open the addon UI
- `/mav undo` — undo the last removal

## Project structure

- `Core.lua` — merchant handling, sell logic, keep logic, and state management
- `UI.lua` — main addon interface and list management
- `Settings.lua` — per-character item-level and keep settings
- `TabTooltips.lua` — tooltip help for the UI tabs
- `MyAutoVendor.toc` — addon metadata and load order

## Notes

This addon uses Ace3 and LibStub. It is intended for classic or retail-style WoW environments that support standard addon APIs.

## Changelog

### v1.0.1

- Fixed automatic selling of low-level weapons below the configured item-level threshold

### v1.0.0

- Initial release
- Auto-sell and auto-keep logic
- Character-specific item-level settings
- UI for managing keep and sell lists
- Global sell/keep lists

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
