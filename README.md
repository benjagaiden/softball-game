# Retro softball game prototype
# This project is meant to be opened in Godot 4.1.
# Controls:
#   Space: swing
#   Enter: new pitch cycle
#
# The prototype focuses on the full loop of:
# - pitch
# - hit timing
# - field result
# - run progression
# - crowd and teammate reactions

This project is a Godot 4.1 prototype for a retro 32-bit softball game with a playful tone: chants, crowd chatter, and the kind of parent commentary that makes the stands memorable.

## Core idea

The game starts from the key flow you highlighted as the most important:
- pitch -> hit -> field -> run bases -> defend
- staged in a top-down/isometric-inspired feel
- designed for a short 3-inning experience
- built for a goofy, fun sportsmanship-first tone

## Included prototype systems

- Pitch type cycle and timing window
- balls/strikes/outs tracking
- base progression and inning flow
- simple scoreboard + HUD
- crowd, teammate, and parent commentary system
- lightweight field layout for a softball diamond

## Controls

- Space: swing
- Enter: cycle to the next pitch / reset timing window

## Next steps

We will build on this prototype by adding:
- more realistic fielding AI
- base-running logic with visual runner movement
- better scoreboard and inning transitions
- player roster and team identity
- a longer, more polished commentary system

## Godot setup

Open the repository in Godot 4.1 and run the main scene:

- `res://scenes/Main.tscn`
