@abstract
class_name Action
extends RefCounted
## lib/domain/action/action.dart: what a player does during a turn. Each
## action checks itself (`validate`) and plays itself (`execute`, which
## validates again); ActionExecutor runs one and notes what it left.
##
## Dart's abstract getters `type` and `description` are abstract methods;
## `makeHistoryEntry` and `noiseMade` keep their default.


@abstract func type() -> ActionType.Value


## The line a script log writes for the action.
@abstract func description() -> String


@abstract func validate(game: Game, player: Player) -> ActionResult


@abstract func execute(game: Game, player: Player) -> ActionResult


## The entry the player's history keeps of the action once it succeeded,
## or null.
func make_history_entry(_game: Game, _player: Player, _result: ActionResult, _turn: int) -> HistoryEntry:
	return null


## Noise this action made once executed successfully; it fills the player's
## raid gauge (see `NoiseRules`).
func noise_made(_player: Player) -> int:
	return 0
