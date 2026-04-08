# ABYSSES

A deep-sea turn-based strategy game built with Flutter.

See `ABYSS.md` for the full game design.

## Migration

After the `game-player-decoupling` refactor (2026-04), pre-existing Hive saves
are incompatible and will be deleted automatically on first launch. This is
intentional while the game is in development: `GameRepository.initialize` wraps
the box open in a `try/catch` that deletes the box on any decode failure, so
players on older saves will simply start with a clean slate the next time they
launch the app.
