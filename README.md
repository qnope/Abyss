# ABYSSES

[![CI](https://github.com/qnope/Abyss/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/qnope/Abyss/actions/workflows/ci.yml)
[![Deploy](https://github.com/qnope/Abyss/actions/workflows/deploy.yml/badge.svg?branch=main)](https://github.com/qnope/Abyss/actions/workflows/deploy.yml)

A deep-sea turn-based strategy game in real 3D, built with Godot (typed
GDScript) for the web, Android and iOS.

Play it in the browser: https://qnope.github.io/Abyss/

See `PRD.md` for the full game design. The game lives in `godot/`; each of its
layers has a README saying what it is and what it may depend on.

The game was first written with Flutter. It was replaced by the Godot version
once the Godot one played the same game (the rules are checked against games
the Flutter version played, kept in `reference/`) and ran well on a phone. The
last commit that holds the Flutter version is the parent of the one that
removed it: `git log --diff-filter=D -- lib/domain` finds it.

## Continuous integration

Two GitHub Actions workflows live in `.github/workflows/`.

**CI** (`ci.yml`) runs on every pull request and every push to `main`:

| Job | What it does |
|---|---|
| Models | tests the Blender scripts of the 3D models (`tool/models/`) |
| Godot Test | the translations are up to date, the Python tools' tests, the suite with its line coverage (100 % required) |
| Godot Reference | replays the reference games and the simulations (`reference/`) |
| Godot Web | exports the web build |
| Godot Android | exports the APK |
| Godot iOS | exports the Xcode project and builds it unsigned |

**Deploy** (`deploy.yml`) runs on every push to `main`: it tests the game,
exports the web build and publishes it to GitHub Pages, at the root of the
site. The old address `/Abyss/godot/` redirects to it.

### Working on the game

- Tests: `tool/godot_test.sh` (paths restrict it); coverage:
  `COVERAGE_MIN=100 python3 tool/godot_coverage.py`.
- Texts: the three languages are written in `tool/l10n/app_*.arb`;
  `python3 tool/arb_to_po.py` writes the `.po` files Godot loads.
- Web export: `.github/scripts/godot_export.sh Web build/web/index.html`.
- More in `CLAUDE.md`, and the README of each folder of `godot/`.
