# Crazy Farm Workspace Instructions

## Build and Run
- Use Godot 4.6.
- Run the project from the editor with `F5` (main scene: `scenes/main.tscn`).
- There is no automated test suite in this repo. Do not invent test commands.
- For exports, use the Godot editor export pipeline.

## Architecture
- Use the component-driven architecture already in place.
- Keep entity scripts in `scripts/core/` thin and orchestration-focused.
- Put reusable behavior in `scripts/component/` and wire components through exported references in scenes.
- Keep gameplay and visual config in stat resources under `scripts/resources/` and `resource/`.
- Prefer signal-driven communication between components/systems over tightly coupled direct calls.

## Core Conventions
- Follow existing naming patterns:
  - Files use `snake_case.gd`.
  - Scripts declare `class_name` in `PascalCase`.
  - Components end with `Component`.
- Follow the setup pattern used by core actors:
  - Components receive dependencies via `setup(...)` from parent `_ready()`.
  - Guard optional exported components with `if component != null:` checks.
- Keep player architecture aligned with the current component split:
  - Input, movement, animation, pickup/inventory/shop/placement/throw should stay in dedicated components.
  - `Player` remains an orchestrator layer.

## Project Pitfalls
- Missing exported node/resource references can silently disable behavior. Validate scene wiring before changing logic.
- Animation names can vary in case. Preserve existing fallback behavior when touching animation playback.
- Movement is manual `CharacterBody2D` velocity + `move_and_slide()` style flow, not rigid-body-driven.
- Economy pacing depends on `GameManager` debt growth and tick/debt intervals; preserve game-speed scaling semantics.

## Key Files
- `scripts/core/player.gd`: player orchestration pattern.
- `scripts/core/game_manager.gd`: tick and debt systems.
- `scripts/component/producer_component.gd`: timer-driven production pattern.
- `scripts/component/inventory_component.gd`: inventory and signal usage.
- `scripts/resources/player_stat.gd`: resource + signal pattern.

## Existing Docs
- See `CLAUDE.md` for project overview, high-level architecture, scene layout, and autoload context.
