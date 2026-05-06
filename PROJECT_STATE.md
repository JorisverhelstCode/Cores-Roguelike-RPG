# Aftermath Project State

This file is a compact handoff for continuing development in a fresh Codex thread.

## Project

- Godot project path: `D:\Games\Cores project\cores`
- Game name: **Aftermath**
- Repository: `JorisverhelstCode/Cores-Roguelike-RPG`
- Current active map asset: `res://assets/maps/Belland.png`
- Terrain mask asset: `res://assets/maps/Belland_terrain_mask.png`
- User-added data file: `res://assets/Book.xlsx`

## Current Gameplay Shape

- The run starts with Jiali in **Glory**.
- Title screen includes New Run, Continue Run, Catalogue, Settings, and Quit.
- In-game top-right controls include Menu, Chronicle, Inventory, and contextual town entry.
- Overworld has fog of war, a calendar measured in years and days, and zoom/pan controls.
- Overworld movement uses keyboard/WASD and terrain-aware rules from the terrain mask.
- Clicking a known location opens a travel prompt instead of immediately moving.
- Confirmed travel calculates a shortest route through passable terrain.
- Towns no longer auto-open on arrival. When the player is close enough, an `Enter [Town]` button appears.
- Events still auto-trigger when reached.

## Map And Terrain

Terrain mask color legend:

- `sea`: `#0F4D89`
- `river`: `#20A6E0`
- `plains`: `#8EB952`
- `desert`: `#DDBE70`
- `forest`: `#30682A`
- `rainforest`: `#144826`
- `mountain`: `#6C5F50`
- `tundra`: `#DCEDF2`

Current movement rules are intentionally loose:

- `sea` is blocked.
- `river`, `mountain`, `forest`, `rainforest`, `desert`, and `tundra` are passable but can have higher pathfinding cost.

## Main Code Files

- `scripts/Main.gd`: primary game state, UI, overworld travel, inventory, catalogue, towns/events, combat orchestration.
- `scripts/OverworldView.gd`: map rendering, fog display, location markers, zoom and pan interaction.
- `scripts/CombatView.gd`: combat board rendering and unit/hex click signals.
- `scripts/CardView.gd`: card layout and hover/draggable behavior.

## Recent Work Notable Details

- Overworld map zoom supports mouse wheel plus `+`, `-`, and `1x` buttons.
- Left mouse hold drags/pans the overworld map.
- Location markers and names scale with zoom; labels hide when too zoomed out.
- Player movement was smoothed to avoid snapping when held movement meets blocked terrain.
- Event view buttons were made larger, centered, and lower in the popup.
- In-game menu/prompt buttons were restyled toward the title-menu layout.
- `artifacts/` contains large temporary map-preview files and is ignored.

## Verification Habit

After code changes, run:

```powershell
godot --headless --path . --quit-after 1
```

Do not commit or push automatically unless the user explicitly asks.

## User Preferences

- Commit and push only when explicitly requested.
- Keep README maintained as the game progresses.
- Prefer standalone Godot app development, not browser game.
- Use full-screen startup with settings to change screen size.
- Use image/pictogram-driven UI where practical.
- Avoid automatic town entry; require explicit player action.
