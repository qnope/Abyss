class_name FactionTurns
extends RefCounted
## lib/domain/faction/faction_turns.dart: plays the turn of every faction,
## one after the other in the order of Game.factions, through the regular
## ActionExecutor so the actions are journalled for the replay.
##
## The end of the human's turn calls it before the resolution. A replay does
## not: the journal already holds what the brains did.


## `executor` null is a new ActionExecutor.
static func play_all(game: Game, executor: ActionExecutor = null) -> void:
	var run := executor if executor != null else ActionExecutor.new()
	var map: GameMap = game.levels.get(1)
	var map_seed := map.map_seed if map != null else 0
	var factions := game.factions()
	for i: int in factions.size():
		if game.status != GameStatus.Value.PLAYING:
			return
		var player: Player = game.players.get(factions[i].id())
		if player == null or player.has_fallen():
			continue
		FactionBrain.new(factions[i].personality).play_turn(
			FactionTurn.new(game, player, run, DartRandom.new(_seed_of(map_seed, game.turn, i), false))
		)


## The dice of one faction on one turn; the same game always gives the same
## numbers, whatever the platform.
static func _seed_of(map_seed: int, turn: int, index: int) -> int:
	return (map_seed * 31 + turn * 1009 + index * 7919) & 0x7FFFFFFF
