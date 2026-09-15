# BQ Sqwad Game — Game Design Foundation

## Core identity

**Game:** BQ Sqwad Game
**Universe:** Landly City
**Studio:** BQ Sqwad Technologies

This is an original BQ Sqwad universe. It is not a Call of Duty clone. The design target is a distinct combination of cinematic action, exploration, squad gameplay, character abilities, missions, and an expandable online world.

## First playable loop

1. Enter the game.
2. Authenticate or continue into a local prototype account.
3. Enter Landly City.
4. Spawn as Ziking.
5. Explore the first district.
6. Visit BQ Sqwad HQ.
7. Receive a mission.
8. Travel to the mission zone.
9. Encounter an enemy.
10. Complete the objective.
11. Receive XP/rewards.
12. Save progression.

## Long-term pillars

- Landly City open-world exploration
- Distinct BQ Sqwad character abilities
- Story missions and cinematic events
- Squad-based online gameplay
- Vehicles and traversal
- Player progression and customization
- Expanding districts and future cities
- NPC and enemy AI
- Competitive and cooperative game modes

## Architecture rule

Gameplay that requires real-time synchronization should eventually be authoritative on a multiplayer game server. Firebase is for identity and persistent application data, not the simulation authority for combat or player movement.

## First character

Ziking is the first production target. Other BQ Sqwad characters will be added through a data-driven character system rather than hard-coding every character into the player controller.
