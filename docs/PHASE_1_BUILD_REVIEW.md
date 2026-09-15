# Phase 1 — Landly City Build & Review

## Current build

The repository now contains the first playable Godot foundation using Godot 4.7.2 stable.

### Implemented
- Godot project configuration
- Landly City prototype scene
- Procedurally assembled prototype district
- Roads and ground collision
- Placeholder buildings
- BQ Sqwad HQ placeholder
- Ziking prototype player
- Third-person camera rig
- Basic movement and jump
- Basic lighting/environment
- Input actions for keyboard movement

## Reference integration rule

The uploaded Landly City references remain source material. They are not automatically treated as final game assets. Before replacing a placeholder, review:

1. Architectural shape and proportions
2. Materials and surface language
3. Street relationship and scale
4. Lighting/time-of-day characteristics
5. Repeated visual motifs
6. BQ Sqwad branding spelling: **BQ Sqwad**
7. Whether the reference should inspire one asset or a reusable asset family

## Review loop

Build → inspect in-engine → identify visual/gameplay problems → correct → rebuild → repeat.

Do not claim a reference was visually analyzed when only its filename or repository metadata is available. Binary reference files should be visually inspected before detailed reproduction decisions are made.

## Next production pass

- Replace placeholder district geometry with reviewed Landly City references and original variations.
- Add modular building pieces and street props.
- Establish a consistent district scale.
- Add navigation/interaction foundations.
- Add a proper HUD and mission prototype.
- Profile performance before increasing world density.
