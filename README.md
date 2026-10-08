# ABYSSES

[![CI](https://github.com/qnope/Abyss/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/qnope/Abyss/actions/workflows/ci.yml)
[![Deploy](https://github.com/qnope/Abyss/actions/workflows/deploy.yml/badge.svg?branch=main)](https://github.com/qnope/Abyss/actions/workflows/deploy.yml)
[![Coverage](https://img.shields.io/endpoint?url=https://qnope.github.io/Abyss/coverage/badge.json)](https://qnope.github.io/Abyss/coverage/)

A deep-sea turn-based strategy game built with Flutter.

Play it in the browser: https://qnope.github.io/Abyss/

See `ABYSS.md` for the full game design.

## Continuous integration

Two GitHub Actions workflows live in `.github/workflows/`.

**CI** (`ci.yml`) runs on every pull request and every push to `main`:

| Job | What it does |
|---|---|
| Analyze | `flutter analyze --fatal-infos` |
| Test | `flutter test --coverage`, then reports the coverage |
| Build Web | `flutter build web`, uploaded as the `web-build` artifact |
| Build Android | `flutter build apk`, uploaded as the `android-apk` artifact |
| Build iOS | `flutter build ios --no-codesign`, uploaded as the `ios-build` artifact |

**Deploy** (`deploy.yml`) runs on every push to `main`: it analyzes, tests,
builds the web version and publishes it to GitHub Pages, together with the
coverage report.

### Code coverage

Generated `*.g.dart` files are left out of the numbers.

- **On a pull request**: a comment on the PR gives the total coverage, the
  coverage per layer and the least covered files. It is updated on each push.
- **On `main`**: the full HTML report is online at
  https://qnope.github.io/Abyss/coverage/ and the badge above shows the total.
- **On any CI run**: the same table is in the Test job's summary, and the
  `coverage` artifact holds `lcov.info` and the HTML report.
- **Locally**: `flutter test --coverage`, then
  `.github/scripts/coverage_summary.sh coverage/lcov.info`.

## Migration

After the `game-player-decoupling` refactor (2026-04), pre-existing Hive saves
are incompatible and will be deleted automatically on first launch. This is
intentional while the game is in development: `GameRepository.initialize` wraps
the box open in a `try/catch` that deletes the box on any decode failure, so
players on older saves will simply start with a clean slate the next time they
launch the app.
