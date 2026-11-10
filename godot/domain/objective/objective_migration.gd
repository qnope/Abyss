class_name ObjectiveMigration
extends RefCounted
## lib/domain/objective/objective_migration.dart: brings the games saved
## before the objectives to the objectives: what was already met counts as
## completed, without its reward, and the tutorial and the tips stay off.
##
## No Godot save is that old and a new Player always holds a state, so
## `state_of` is `saved_objective_state` in a live game; the rules read it
## through here, as Dart's do (the resolver, the attack validator).


## The state of `player` in `game` had it been saved before the objectives.
## Pure: `game` is left as is.
static func legacy_state(game: Game, player: Player) -> ObjectiveState:
	var completed: Array[ObjectiveId.Value] = []
	for objective: Objective in ObjectiveCatalog.all():
		if objective.is_done(game, player):
			completed.append(objective.id)
	return ObjectiveState.new(completed)


## The objectives of `player`, filled with legacy_state when it was saved
## before them.
static func state_of(game: Game, player: Player) -> ObjectiveState:
	if player.saved_objective_state == null:
		player.saved_objective_state = legacy_state(game, player)
	return player.saved_objective_state


## Gives every player of `game` saved before the objectives its
## legacy_state; applied when a game is loaded.
static func migrate(game: Game) -> void:
	for player: Player in game.players.values():
		state_of(game, player)
