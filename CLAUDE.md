# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Crazy Farm is a Godot 4.6 2D game. The project uses Forward Plus rendering and Jolt Physics.

## Running the Project

To run the project, open it in Godot 4.6 and press F5 or use "Run Project" from the menu. The main scene is `scenes/main.tscn`.

## Architecture

### Script Structure

- **scripts/core/**: Core game logic
  - `game_manager.gd`: Autoload singleton that manages the game tick system
  - `player.gd`: Player character controller (CharacterBody2D)

- **scripts/resources/**: Resource definitions
  - `player_stat.gd`: Player stats resource (name, speed, balance)

### Key Systems

**Tick System**: The GameManager implements a tick-based system using the `_process(delta)` loop. It accumulates time and emits a `tick` signal at a configurable rate (default: 0.1s). Connect to this signal for gameplay logic that should run on fixed intervals rather than per-frame.

**Player Controller**: The `player.gd` script handles movement via WASD (using ui_left, ui_right, ui_up, ui_down input actions). Movement is handled in `_process()` and applies velocity to the CharacterBody2D based on the player's `speed` stat from the PlayerStat resource.

**PlayerStats Resource**: Data-only resource containing `name`, `speed`, and `balance` properties. Balance can be modified via `add_balance()` and `subtract_balance()` methods.

### Scene Organization

- `scenes/main.tscn`: Main game scene that instantiates the player
- `scenes/Entity/player.tscn`: Player character with AnimatedSprite2D and CollisionShape2D

### Character Animation

Player uses SpriteFrames with two animations:
- `idle`: 4 frames, speed 6.0
- `move`: 6 frames, speed 10.0

Sprite sheets are located in `assets/characters/2/`.

## Autoloads

- **GameManager**: Singleton accessible globally. Emits `tick` signal at configurable intervals for game logic synchronization.
