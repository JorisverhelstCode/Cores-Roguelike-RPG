# Aftermath

Aftermath is a work-in-progress roguelike RPG prototype built in Godot.

The game starts on an overworld map with fog of war. The player begins in Glory, explores locations, enters town and event popups, and fights tactical card-based battles on a hex grid.

## Current Features

- Overworld movement with keyboard and click-to-travel controls
- Fog of war and location discovery
- Town and event popup screens
- Inventory screen with equipment, stats, loose items, and deck view
- Equipment-driven deck construction
- Hex-based combat
- Initiative turns
- Card play with Core and Energy costs
- Discard-to-gain-energy flow
- Blocking phase with normal and magic block values
- Combat log with hoverable card previews
- Catalogue, settings, menu, save prompt, and chronicle screens

## Requirements

- Godot 4.6 or newer

## Running the Project

1. Open Godot.
2. Import or open this folder as a Godot project.
3. Run `scenes/Main.tscn`.

From command line:

```powershell
godot --path .
```

## Exporting Builds

Export presets are included for:

- Windows
- Linux
- Web

See [BUILD_AND_RELEASE.md](BUILD_AND_RELEASE.md) for release steps.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
