# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**ABYSSES** is a free, single-player, turn-based strategy game set in the deep sea, inspired by titles like Travian, OGame, and Clash of Clans — but without the real-time waiting. Each turn, the player performs their actions (build, research, move units, fight) and then presses the "next turn" button to advance the world.

The player develops a base, gathers resources, trains an army, researches technologies, explores a fog-of-war world, interacts with rival entities, and progresses through successive zones toward an end-game objective.

The full product vision and the incremental development stages are described in `PRD.md`. Each stage is meant to ship a fully playable version of the game, building on the previous one.

## Tech
1. Dart
2. Flutter
3. Hive for saving
4. Should run on iOS, Android, Web.

## Rules
1. Always design component that are reusable
2. Never have object with `initialize()` function. Object should be constructed or not.
3. Always run `flutter analyze` and `tool/test.sh` to be sure everything is fine. `tool/test.sh` runs every test file in 4 bundled processes (minutes faster than plain `flutter test`, which still works for a single file: `flutter test test/some_test.dart`); it passes extra options to `flutter test`, as in `tool/test.sh --coverage`, and paths to restrict the files, as in `tool/test.sh test/domain`.
4. Always target under 150 lines of code by file.
5. Target architecture of 5 layers.
6. Theme is in `lib/presentation/theme/`. Always use it when creating UI component.
7. Test files share a process in the bundles, and `resetProcessState()` (`test/helpers/fresh_process.dart`) puts it back as at startup before each file. Any new process-wide state (a static cache, a static future, a registry) needs a `@visibleForTesting static void debugReset()` called from there, or a test may pass alone and fail in a bundle.

8. The Godot port is checked against `reference/`: games replayed turn by turn (`reference/README.md`) and vectors per module (`reference/vectors/README.md`). After a change of rules in `lib/domain`, run `dart run bin/export_reference.dart --update`, `dart run bin/export_vectors.dart` and `python3 tool/simulations.py --update`, commit what changed, and port the change to `godot/domain` if that module is already there. CI's `Reference` job runs both with `--check`.

## Godot
The game is being rewritten with Godot in `godot/`, for real 3D. Both versions coexist until the switch: the Flutter rules above still apply to `lib/` and `test/`, these to `godot/`.

### Tech
1. Godot 4.7.2, pinned in `godot/GODOT_VERSION` (the SHA-512 of its downloads in `.github/scripts/godot_sha512sums.txt`). `tool/install_godot_dev.sh` installs it with the web, Android and iOS export templates.
2. Typed GDScript only: untyped declarations and unsafe accesses, calls and casts are errors (`project.godot`).
3. JSON saves in `user://`, not Hive.

### Rules
1. The same 5 layers, each with a README saying what it may depend on: `domain/` (pure `RefCounted` rules, no node), `data/` (saves), `presentation/ui/` (2D `Control` scenes), `presentation/world/` (3D scenes), `app/` (startup, navigation).
2. Always run `tool/godot_test.sh` (every `*_test.gd` in one headless process; paths restrict it, as in `tool/godot_test.sh godot/domain`), `tool/godot_coverage.py` (line coverage, `COVERAGE_MIN=100` in CI), `tool/godot_reference.sh` and `python3 tool/simulations.py --engine godot` after a change of `godot/domain` (the 19 reference games and the long cases replayed, `godot/tool/replay/README.md`; the simulator against Dart's output, `godot/tool/simulate/README.md`) and, after changing a Python tool, `python3 -m unittest discover -s tool -p '*_test.py'`. Runner: `godot/tool/test/README.md`; coverage: `tool/gdscript_coverage/README.md`.
3. Exports: `.github/scripts/godot_export.sh Web build/web/index.html` (also `Android build/android/abysses.apk`, `iOS build/ios/abysses.ipa`), presets in `godot/export_presets.cfg`. The web export is single-threaded, for Safari iOS and GitHub Pages (deployed at `/Abyss/godot/`). The iOS export writes an Xcode project and needs an App Store team ID in the preset; CI puts a placeholder and builds it unsigned.
4. Test files share a process: a class with static state (a cache, a registry) exposes `static func debug_reset() -> void` and is listed in `godot/tool/test/process_resets.gd`.
5. The UI uses the theme of `godot/presentation/ui/theme/` through `theme_type_variation` and the `AbyssColors`, `AbyssMotion`... constants: no hard-coded colour, font or style.
6. Files under 150 lines, components reusable, objects complete once `_init` returns (no `initialize()`).
7. 3D models: one Blender Python script each in `tool/models/catalog/`, with its budget (triangles, materials, texture size); `tool/models/build.py [names]` regenerates `godot/assets/models/*.glb`, never edited by hand, `tool/models/preview.sh <name>` renders it for review, and its tests run with Python 3.13 and `bpy==5.2.3` (`tool/models/README.md`).
8. Review the startup scene's look with `tool/scene_capture.sh [out dir]`: phone-sized renders of four views under xvfb (Compatibility), with each view's draw calls and primitives (`godot/tool/scene/README.md`); never commit renders. Measure it on a device with `?bench=1` in the web page's address (`godot/app/README.md`).
9. `godot/domain` is ported from `lib/domain` to give the same game, to the last die, and checked against `reference/vectors/` (a test extends `VectorTestCase`, `godot/tool/reference/README.md`). A ported rule never uses `randi`, `randf`, `Array.shuffle`, `Array.sort`/`sort_custom` with a comparator that can tie, `%` on an int that can be negative, `/` between two ints, `pow` nor `**`: it uses `DartRandom`, `DartSort`, `DartMath`, `DartBits` and `DartNum` (`godot/domain/dart/README.md`). A Dart file is ported as the "Porting conventions" of `godot/domain/README.md` say (same file and class names, enums by their Dart names, maps in the Dart order, tests ported one for one), and every section of a vector file is held by a test or listed pending in `godot/tool/reference/vector_registry.gd`.
