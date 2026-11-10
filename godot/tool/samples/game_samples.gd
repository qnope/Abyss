class_name GameSamples
extends RefCounted
## Sample players and games for the tests of godot/domain: what the Dart
## tests write as `Player(id: 'h', name: ..., buildings: {...})` and
## `Game(humanPlayerId: human.id, players: {...})`, and the GDScript twin of
## test/helpers/two_player_game.dart.


## A player named after its id, with everything a new player holds.
static func player(id: String) -> Player:
	return Player.new(id, id)


## A player holding only the buildings given, at the levels given, in the
## order given.
static func player_with(id: String, levels: Dictionary[BuildingType.Value, int]) -> Player:
	return Player.new(id, id, 0, 0, null, DomainSamples.buildings(levels))


## A game whose human is the first of `players`, the others after it, in
## the order given.
static func game(players: Array[Player], status := GameStatus.Value.PLAYING) -> Game:
	var by_id: Dictionary[String, Player] = {}
	for each: Player in players:
		by_id[each.id] = each
	return Game.new(players[0].id, by_id, 1, {}, status)


## `TwoPlayerGame.create`: the single-player game of `map_seed`, its human
## named "human", and a rival named "rival" on a base half a map away.
static func two_players(map_seed := 3, rival_id: Variant = null) -> Game:
	var game := GameFactory.new_single_player("human", map_seed)
	var width := game.levels[1].width
	var height := game.levels[1].height
	var human := game.human_player()
	var rival := Player.with_base(
		"rival",
		(human.base_x + DartMath.trunc_div(width, 2)) % width,
		(human.base_y + DartMath.trunc_div(height, 2)) % height,
		width,
		height,
		rival_id,
	)
	game.players[rival.id] = rival
	return game
