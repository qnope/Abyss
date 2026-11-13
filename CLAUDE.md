# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**ABYSSES** is a free, single-player, turn-based strategy game set in the deep sea, inspired by titles like Travian, OGame, and Clash of Clans — but without the real-time waiting. Each turn, the player performs their actions (build, research, move units, fight) and then presses the "next turn" button to advance the world.

The player develops a base, gathers resources, trains an army, researches technologies, explores a fog-of-war world, interacts with rival entities, and progresses through successive zones toward an end-game objective.

The full product vision and the incremental development stages are described in `PRD.md`. Each stage is meant to ship a fully playable version of the game, building on the previous one.

## Godot
The game is written with Godot in `godot/`, in real 3D. It replaced the Flutter version (`lib/`, `test/`), which is gone: its last commit is the parent of the one that removed it, and `reference/` keeps what it computed.

### Tech
1. Godot 4.7.2, pinned in `godot/GODOT_VERSION` (the SHA-512 of its downloads in `.github/scripts/godot_sha512sums.txt`). `tool/install_godot_dev.sh` installs it with the web, Android and iOS export templates.
2. Typed GDScript only: untyped declarations and unsafe accesses, calls and casts are errors (`project.godot`).
3. JSON saves in `user://`, not Hive.

### Rules
1. The same 5 layers, each with a README saying what it may depend on: `domain/` (pure `RefCounted` rules, no node), `data/` (saves), `presentation/ui/` (2D `Control` scenes), `presentation/world/` (3D scenes), `app/` (startup, navigation).
2. Always run `tool/godot_test.sh` (every `*_test.gd` in one headless process; paths restrict it, as in `tool/godot_test.sh godot/domain`), `tool/godot_coverage.py` (line coverage, `COVERAGE_MIN=100` in CI), `tool/godot_reference.sh` and `python3 tool/simulations.py` after a change of `godot/domain` (the 19 reference games and the long cases replayed, `godot/tool/replay/README.md`; the simulator against the output the Flutter version printed, `godot/tool/simulate/README.md`) and, after changing a Python tool, `python3 -m unittest discover -s tool -p '*_test.py'`. Runner: `godot/tool/test/README.md`; coverage: `tool/gdscript_coverage/README.md`.
3. Exports: `.github/scripts/godot_export.sh Web build/web/index.html` (also `Android build/android/abysses.apk`, `iOS build/ios/abysses.ipa`), presets in `godot/export_presets.cfg`. The web export is single-threaded, for Safari iOS and GitHub Pages (deployed at `/Abyss/`, where `/Abyss/godot/` redirects). The iOS export writes an Xcode project and needs an App Store team ID in the preset; CI puts a placeholder and builds it unsigned.
4. Test files share a process: a class with static state (a cache, a registry) exposes `static func debug_reset() -> void` and is listed in `godot/tool/test/process_resets.gd`.
5. The UI uses the theme of `godot/presentation/ui/theme/` through `theme_type_variation` and the `AbyssColors`, `AbyssMotion`... constants: no hard-coded colour, font or style.
6. Files under 150 lines, components reusable, objects complete once `_init` returns (no `initialize()`).
7. 3D models: one Blender Python script each in `tool/models/catalog/`, with its budget (triangles, materials, texture size); `tool/models/build.py [names]` regenerates `godot/assets/models/*.glb`, never edited by hand, `tool/models/preview.sh <name>` renders it for review, and its tests run with Python 3.13 and `bpy==5.2.3` (`tool/models/README.md`).
8. Review the startup scene's look with `tool/scene_capture.sh [out dir]`: phone-sized renders of four views under xvfb (Compatibility), with each view's draw calls and primitives (`godot/tool/scene/README.md`); never commit renders. Measure it on a device with `?bench=1` in the web page's address (`godot/app/README.md`).
9. `godot/domain` was ported from the Flutter rules to give the same game, to the last die, and is checked against `reference/` (games, vectors and simulations are frozen: the Flutter version that wrote them is gone, so a change of rules changes them by hand, in the same commit, and says why; a test extends `VectorTestCase`, `godot/tool/reference/README.md`). A ported rule never uses `randi`, `randf`, `Array.shuffle`, `Array.sort`/`sort_custom` with a comparator that can tie, `%` on an int that can be negative, `/` between two ints, `pow` nor `**`: it uses `DartRandom`, `DartSort`, `DartMath`, `DartBits` and `DartNum` (`godot/domain/dart/README.md`). A rule is written as the "Porting conventions" of `godot/domain/README.md` say (same file and class names as the Dart ones, enums by their Dart names, maps in the Dart order), and every section of a vector file is held by a test or listed pending in `godot/tool/reference/vector_registry.gd`.
10. The texts are written in `tool/l10n/app_{fr,en,es}.arb`; `python3 tool/arb_to_po.py` writes the `.po` files Godot loads (CI checks they are up to date).
