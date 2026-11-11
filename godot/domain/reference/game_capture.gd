class_name GameCapture
extends ActionExecutor
## lib/domain/reference/game_capture.dart: an executor that keeps the game
## it plays, which ScriptRunner builds and does not hand back.

var _game: Game


## The game played. Where Dart throws while no action was executed, logs
## an error and gives null.
func game() -> Game:
	if _game == null:
		push_error("No action was executed: no game to read")
	return _game


func execute(action: Action, game_: Game, player: Player) -> ActionResult:
	if _game == null:
		_game = game_
		on_start(game_)
	return super.execute(action, game_, player)


## Called once, before the first action of the game.
func on_start(_game_: Game) -> void:
	pass
