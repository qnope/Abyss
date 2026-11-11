class_name GameSession
extends RefCounted
## The game being played and where it is saved: it owns the [Game], the
## [GameRepository] and the [GameActions] through which the player changes
## the game. Each time the game changes it saves it, then tells
## [signal changed] so that the screen redraws: Flutter's `onChanged` and
## `repository.save` in one, without the UI depending on `data/`.

## The game changed and has been saved (or could not be): redraw.
signal changed

var game: Game
var repository: GameRepository
var actions: GameActions


func _init(game_: Game, repository_: GameRepository) -> void:
	game = game_
	repository = repository_
	actions = GameActions.new(game)
	actions.acted.connect(_on_acted)


## Saves the game where it was saved before, or in a file of its own.
func save() -> Error:
	return save_game(repository, game)


## Saves [param game] in [param repository]. A save that fails is warned of
## and the player goes on: the game is still in memory, and the next change
## saves it again.
static func save_game(repository_: GameRepository, game_: Game) -> Error:
	var error := repository_.save(game_)
	if error != OK:
		push_warning("The game of %s could not be saved: %s" % [
			game_.human_player().name, error_string(error)])
	return error


func _on_acted(_result: Variant) -> void:
	save()
	changed.emit()
