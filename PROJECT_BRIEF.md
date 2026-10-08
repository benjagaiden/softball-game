# Softball Game Project Brief

This document captures the current direction of the softball game prototype and the key decisions we've discussed so far. It is intended to give the project context a clean, durable summary in the repo and in any Copilot Space or project workspace that references it.

## Project overview

This is a Godot 4.1 retro softball game prototype built around a lighthearted, playful tone. The current iteration focuses on the core batting loop:

- pitch
- swing timing
- field result
- base progression
- inning flow
- crowd / teammate / parent commentary

The project is intentionally structured as a quick, fun prototype rather than a full simulation. The tone is a goofy, small-town sports vibe with crowd chatter, teammate encouragement, and parent commentary.

## Current state

The repository already includes:

- a basic field layout with mound, bases, and batter/pitcher elements
- a pitch cycle with timing window and swing meter
- balls/strikes/outs tracking
- inning progression and score updates
- commentary system with crowd, teammate, and parent lines
- a main Godot scene and script-driven gameplay loop

Key implementation files:

- `README.md` — project overview and controls
- `scenes/Main.tscn` — main scene entry point
- `scripts/Game.gd` — core gameplay loop, field state, scoring, and inning logic
- `scripts/CommentaryManager.gd` — randomized crowd / team / parent lines

## Core gameplay concept

The core gameplay loop is:

- pitch -> hit -> field result -> run progression -> defend

The prototype is designed for:

- short 3-inning play sessions
- a top-down / isometric-inspired visual feel
- a sportsmanship-first, fun tone
- retro 32-bit style presentation

## Controls

- Space: swing
- Enter: advance to the next pitch / reset timing window

## Design direction and decisions

From the work so far, we have converged on this direction:

1. Keep the prototype lightweight and readable.
2. Prioritize fun and atmosphere over realism.
3. Use commentary as a major part of the experience.
4. Make the game feel arcade-like rather than simulation-heavy.
5. Build toward a small but memorable game loop instead of a full sports engine.

## Near-term improvements to explore

The next steps identified in the repo are still relevant and likely to be the main focus:

- more realistic fielding AI
- base-running logic with visual runner movement
- better scoreboard and inning transitions
- player roster and team identity
- a longer, more polished commentary system

## Notes for future work

This project is not intended to be a full baseball sim. It is best viewed as a fun prototype with enough structure to support later iterations. The commentary system and arcade timing loop are especially strong as differentiators and are likely the best features to continue building around.

## Helpful repo link

- GitHub: https://github.com/benjagaiden/softball-game

## Summary

The project is a playful retro softball prototype with a strong arcade feel, a distinctive crowd commentary system, and a clear path for future expansion into a richer game experience.
