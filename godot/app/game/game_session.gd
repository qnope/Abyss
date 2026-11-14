class_name GameSession
extends RefCounted
## The game being played and where it is saved: it owns the [Game], the
## [GameRepository] and the [GameActions] through which the player changes
## the game. Each time the game changes it tells [signal changed] at once, so
## that the screen redraws in the frame of the action, and saves the game on
## the next frame ([NextFrame]), once for all the changes of a frame:
## Flutter's `onChanged` and `repository.save`, without the UI depending on
## `data/`, and without the save holding back the frame the player waits for.
##
## No change is lost on the ways out: [method save] and [method flush] write
## at once (the player quits, the app closes or goes behind another), and
## [method close] writes the save that waits before the session saves nothing
## more, so that a game left, then deleted, is never written back.

## The game changed: redraw. Its save waits for the next frame.
signal changed

var game: Game
var repository: GameRepository
var actions: GameActions
var _next_frame: NextFrame


## The save of a change waits for [param next_frame], the scene tree's
## unless a test gives its own.
func _init(game_: Game, repository_: GameRepository, next_frame := NextFrame.new()) -> void:
	game = game_
	repository = repository_
	actions = GameActions.new(game)
	actions.acted.connect(_on_acted)
	_next_frame = next_frame
	_next_frame.came.connect(save)


## Saves the game at once where it was saved before, or in a file of its own:
## no save waits any more.
func save() -> Error:
	_next_frame.cancel()
	return save_game(repository, game)


## Whether a change waits for the next frame to be saved.
func is_save_waiting() -> bool:
	return _next_frame.is_waiting()


## Writes the save that waits, if any, at once: the next frame may never come.
func flush() -> void:
	if is_save_waiting():
		save()


## The game is left: the save that waits is written, and no change is saved
## nor told from now on.
func close() -> void:
	flush()
	actions.acted.disconnect(_on_acted)


## Saves [param game] in [param repository]. A save that fails is warned of
## and the player goes on: the game is still in memory, and the next change
## saves it again.
static func save_game(repository_: GameRepository, game_: Game) -> Error:
	var error := repository_.save(game_)
	if error != OK:
		push_warning("The game of %s could not be saved: %s" % [
			game_.human_player().name, error_string(error)])
	return error


## The save is asked for before the change is told: a listener that saves or
## closes the session finds it waiting.
func _on_acted(_result: Variant) -> void:
	_next_frame.wait()
	changed.emit()
