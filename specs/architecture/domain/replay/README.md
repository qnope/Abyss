# Replay Module

`lib/domain/replay/`

Records every move of a game so that it can be exported as a file and played again headless, turn for turn, with `bin/simulate.dart`. The history shown to the player is not enough for that: it keeps only the last 100 entries and leaves out the map seed, the units sent on a descent and the dice.

## Files

| File | Description |
|------|-------------|
| `seeded_random.dart` | `SeededRandom`: a `Random` that remembers its seed. The game screen gives a fresh one to every action that rolls dice and to every end of turn |
| `replay_journal.dart` | `ReplayJournal` (Hive `typeId` 45, `Game` field 6): map seed, player name, actions per turn as JSON, end-of-turn seeds, and whether every die was seeded |
| `action_encoder.dart` | `Action` → the JSON `ActionCodec` reads, with the `seed` of its `SeededRandom` |
| `replay_export.dart` | `Game` → JSON scenario and file name (`replay-<player>-tour-<n>.json`) |

`GameFactory` starts the journal with the map seed; `ActionExecutor` records every successful action of the human player before it advances the turn. Games saved before the journal existed have no journal and cannot be exported.

## Exported file

A scenario of the script module with a few more fields:

```json
{
  "name": "replay-qnope-tour-42",
  "player": "qnope",
  "mapSeed": 1234,
  "lastTurn": 42,
  "exact": true,
  "status": "playing",
  "turns": {"1": [{"do": "fight", "x": 3, "y": 4, "units": {"harpoonist": 5}, "seed": 987}]},
  "endTurnSeeds": {"1": 555}
}
```

`ScenarioParser` reads `player` (so cheat codes apply as in the game), `mapSeed`, `lastTurn` (the replay stops there, before ending that turn) and `endTurnSeeds` (raid dice). An action's `seed` replaces the runner's generator for that action only. `exact` is false when some die was rolled without a recorded seed; the replay then may differ on those fights.

## UI

"Exporter la partie" in the settings dialog and on the defeat screen opens `ReplayExportDialog`, which shares the file (`share_plus`: share sheet on iOS and Android, download on the web) or copies it to the clipboard.
