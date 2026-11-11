# tool/simulate

The simulator of `bin/simulate.dart`, played by the Godot port of the rules:
the same scripted games, headless, for the same seeds, and the same text to
the byte. Test infrastructure, not game code, left out of exports and of
the coverage.

    tool/godot_simulate.sh --strategy balanced --games 100
    tool/godot_simulate.sh --strategy conquest --turns 100 --difficulty hard --json
    tool/godot_simulate.sh --replay scenarios/replays/victoire-tour-85.json --new-map --army 1.2

## Options

Those of `bin/simulate.dart`, read as its `_parse` reads them (each
`--key` takes the next argument as its value unless that one starts with
`--`; anything else is left out), with the same defaults:

| Option | Meaning |
| --- | --- |
| `--strategy <name>` | built-in strategy or human plan of `ScriptLibrary` (`balanced` by default; `plan85-late`...) |
| `--scenario <file>` | JSON scenario or exported replay (`ScenarioParser`) |
| `--games <n>` | games, seeds seed..seed+n-1 (20) |
| `--seed <n>` | first seed (1) |
| `--turns <n>` | turn limit per game (60) |
| `--difficulty <d>` | `easy`, `normal` or `hard` |
| `--verbose` | a line per game, then the action log of the first |
| `--json` | the whole batch as JSON, as `JsonEncoder.withIndent('  ')` |
| `--replay <file>` | an exported replay to vary (`PlanScript`), with `--new-map`, `--new-dice`, `--army <f>`, `--jitter <n>`, `--stretch <f>`, `--patience <n>`, `--defends` |
| `--workers <n>` | read and left out (below) |

`--scenario` and `--replay` name files from the current folder, or are
absolute.

## How it runs

`tool/godot_simulate.sh` refreshes the class cache as `tool/godot_test.sh`
does and runs `simulate.gd`, a `SceneTree` script:

    godot --headless --path godot --script res://tool/simulate/simulate.gd -- [option ...]

Godot works in the project's folder, so the script reads the files from
`ABYSS_CWD` (the folder the shell was called from), and it starts its
standard output with its banner, so it writes the text to the file
`ABYSS_SIMULATE_OUT`, which the shell then prints. `Simulation` does the
work: it builds the script of each seed as Dart does, plays the batch with
`BatchRunner` and writes it with `BatchSummary` or `DartJson`.

Where Dart throws (an unknown strategy, a file that is not there, a value
that is not a number), the simulator prints the error on the standard error
and exits with 1, where Dart exits with 255. The message is Godot's own.

## Differences

- **One game at a time.** Dart plays the games on `--workers` isolates (one
  per core by default); Godot plays them one after the other
  (`GameWorkers`). The runs come back in seed order either way, so the
  batch is the same; it only takes longer, the more so as the Godot rules
  are about ten times slower than the Dart VM (a 100-turn `conquest` game
  takes some 10 s).
- **Decimals.** `--army` and `--stretch` are read with `String.to_float`,
  which gives Dart's double up to 15 significant digits
  (`domain/dart/README.md`); a longer text may land one bit away.

## Checked against Dart

`reference/simulations/` holds what Dart prints for a few option sets, and
`tool/simulations.py --engine godot` plays them with `tool/godot_simulate.sh`
(`reference/simulations/README.md`); `tests/simulation_test.gd` plays two in
the unit tests.
