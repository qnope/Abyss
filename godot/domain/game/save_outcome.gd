class_name SaveOutcome
extends RefCounted
## lib/domain/game/save_outcome.dart: how a saved game stands, as the save
## list groups it.

## FREE_PLAY: won, then played on, still in progress.
enum Value { IN_PROGRESS, FREE_PLAY, VICTORY, DEFEAT }

const _OF_STATUS: Dictionary[GameStatus.Value, Value] = {
	GameStatus.Value.PLAYING: Value.IN_PROGRESS,
	GameStatus.Value.FREE_PLAY: Value.FREE_PLAY,
	GameStatus.Value.VICTORY: Value.VICTORY,
	GameStatus.Value.DEFEAT: Value.DEFEAT,
}


static func of(status: GameStatus.Value) -> Value:
	return _OF_STATUS[status]


## Whether the game is over: it can no longer be continued.
static func is_finished(outcome: Value) -> bool:
	return outcome == Value.VICTORY or outcome == Value.DEFEAT


## Whether the game has been won, played on or not.
static func is_won(outcome: Value) -> bool:
	return outcome == Value.VICTORY or outcome == Value.FREE_PLAY
