# Script Module

`lib/domain/script/`

Plays whole games without the UI, to balance the game on tens or hundreds of games. A script only acts through the regular `Action` + `ActionExecutor` pipeline, so a scripted game follows exactly the rules of a game played on screen.

## Files

| File | Description |
|------|-------------|
| `game_script.dart` | `GameScript`: plays one turn through a `ScriptTurn` |
| `script_turn.dart` | What a script sees and does during a turn (`perform`, `tryPerform`, `allows`) |
| `script_runner.dart` | Plays one game from a seed until defeat, victory or the turn limit |
| `script_run_report.dart` | How one game ended (status, raids, noise, buildings, units, action log, milestones) |
| `script_milestones.dart` | First turn the Faille, the Cheminée and the kernel were taken, and every raid fought |
| `batch_runner.dart` / `batch_report.dart` | Same script on many seeds, with survival rate, averages and milestones reached |
| `timeline_script.dart` | Scenario written in advance: actions per turn, plus a fallback script |
| `action_spec.dart` / `action_codec.dart` | JSON action → `Action` built with the game's seeded `Random` |
| `scenario_parser.dart` | JSON scenario file → `TimelineScript` |
| `script_library.dart` | Built-in scripts by name: `idle`, `economy`, `balanced`, `conquest`, `rush` |
| `strategies/` | Built-in strategies and the moves they are made of |

## Strategies

| Name | Plays | Expected (step 6 calibration) |
|------|-------|-------------------------------|
| `idle` | Nothing | Falls between turns 40 and 50 |
| `economy` | Production buildings only, never a defender | Falls before turn 40 |
| `balanced` | Production, barracks, Citadel, Military research, a share of each turn in Gardiens and Harponneurs | Holds at least 50 turns, then falls |
| `conquest` | A careful whole game: holds every announced raid, clears the lairs it surely beats, explores, takes a Faille, a Cheminée and the volcanic kernel, then raises the kernel to level 10 | Wins about 15 % of the games |
| `rush` | `conquest` without recruiting for raids | Never wins |

`conquest` is made of moves in `strategies/`: `growth_moves` (buildings with an energy guard, research plan), `recruit_moves` (unit mixes, top-ups), `battle_moves` (raid defence, lairs), `explore_moves` (frontier scouting, treasures), `expedition_moves` and `conquest_moves` (assaults and descents). It sizes every fight with `ArmyPlanner`, which replays the fight a few times with the real `FightEngine` and its own seeded `Random`, so planning never changes the game's dice.

## Reproducibility

One seed drives everything: `ScriptRunner` draws the map seed from it and hands the same `Random` to `EndTurnAction` (raids), to every action that rolls dice, and to `DescendAction` (maps of deeper levels). The same script and seed always replay the same game.

A replay exported from the game (see `../replay/README.md`) pins its own map seed, player, end-of-turn seeds and per-action seeds instead, and stops on its `lastTurn`:

```
dart run bin/simulate.dart --scenario replay-qnope-tour-42.json --games 1 --verbose
```

## Command line

Pure Dart, no Flutter UI: it runs with the Dart SDK shipped with Flutter after `flutter pub get`.

```
dart run bin/simulate.dart --strategy balanced --games 100
dart run bin/simulate.dart --strategy conquest --games 100 --turns 150
dart run bin/simulate.dart --scenario scenarios/rush-caserne.json --verbose
dart run bin/simulate.dart --strategy economy --games 50 --turns 80 --json
```

## Scenario format

```json
{
  "name": "rush-caserne",
  "otherwise": "economy",
  "turns": {
    "1": [{"do": "upgrade", "building": "headquarters"}],
    "5": [{"do": "recruit", "unit": "harpoonist", "count": 6}]
  }
}
```

Verbs: `upgrade` (building), `unlock` / `research` (branch), `recruit` (unit, count), `explore` / `collect` (x, y), `fight` / `attackBase` / `attackKernel` (x, y, units), `descend` / `reinforce` (x, y, units). `level` defaults to 1. Turns left out are played by the `otherwise` strategy, if any.
