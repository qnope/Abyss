# tool/replay

The full replay of the reference games, outside the unit tests: test
infrastructure, not game code, left out of exports and of the coverage.

    tool/godot_reference.sh                          # the 19 games
    tool/godot_reference.sh conquest-normal rush-easy

Each game of `reference/games/` (`reference/README.md`) is replayed as Dart's
`ReferenceExporter` replays it: its journal read by `ScenarioParser`, played
by `ScriptRunner` with the human id, turn limit, difficulty and seed of its
source, through a `ReferenceRecorder` (`ReferenceReplay`,
`tool/reference/`). The game then has to match the file in full: the
digests of the 20 sections at the start of every turn and when it stopped,
its result, its journal, and its coverage (the actions by type, the events
drawn, the milestones).

`tool/godot_reference.sh` refreshes the class cache as `tool/godot_test.sh`
does, then runs each game in a Godot process of its own,
`GODOT_REFERENCE_JOBS` at once (the number of cores by default), the
longest first, and prints for each its turns, its time and `ok`, or
`FAILED` and what differs, the first turn that started differently naming
its sections:

    conquest-normal: 90 turns, 5495 ms, ok
    every-research-option-b: 111 turns, 9356 ms, FAILED
      turn 31 started as turn 31, differing in: history, journal, units

It exits with 1 when a game differs, and kills a game still going after
`GODOT_TEST_TIMEOUT` seconds (600 by default). One process can also run
games itself, one after the other (`--list` lists them all, the longest
first):

    godot --headless --path godot --script res://tool/replay/run_references.gd -- [game ...]

Beside the games, it plays the **long cases** of `LongCases`: Dart tests of
whole games too long for the unit tests, each a function giving what it
found wrong (`CaseChecks`, an `expect` per line):

| Case | Dart |
| --- | --- |
| `faction-play-3`, `faction-play-10` | '$count factions play 60 turns and every one of them grows' of `faction_play_test.dart` |
| `faction-research-play` | `faction_research_play_test.dart` |
| `faction-attack-play` | `faction_attack_play_test.dart`, its four tests of `playIdleFactionGame(3, 100)` on one game |
| `calibration` | the three games of `calibration_test.dart`: the plan `plan85` wins or falls by seed and difficulty (`ScriptCases`) |
| `careful-script` | 'the careful script loses most games' of `strategies_test.dart` |
| `script-performance` | `script_runner_performance_test.dart`: a conquest of 100 turns within 120 s, ten times what Godot takes (Dart's budget is 8 s, ten times its own) |

To find what went wrong, dump the turn on the Dart side
(`dart run bin/export_reference.dart --reference reference/games/x.json
--dump-turn N --trace-turn N-1`) and compare it with
`GameSnapshot.texts` of the Godot replay at that turn
(`ReferenceRecorder` takes `dump_turn` and `trace_turn` too).

The digests take most of the time: the history of a game against ten
factions writes megabytes at every turn. The 19 games and 4 cases take
about 6.5 min of processor, 1 min 45 s on 4 cores, the longest
(`conquest-normal-10-factions`) 88 s. The unit tests keep the fast checks:
the start of every game (`domain/reference/tests/reference_games_test.gd`),
`idle-normal` and `economy-hard` in full (`tool/reference/
reference_replay_test.gd`), and every move of every journal through the
codec (`domain/replay/tests/reference_journal_test.gd`).
