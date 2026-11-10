class_name GameFactory
extends RefCounted
## lib/domain/game/game_factory.dart: builds a fresh game: the generated
## levels and the players standing on their bases.


## A single-player game: a generated first level and the player on its
## base. `map_seed` (an int) makes it reproducible, null draws one.
## `tutorial` has the guide lead the player through the first chapter, with
## the tip cards. `human_id` (a String) names the player, null draws an id.
static func new_single_player(
	player_name: String,
	map_seed: Variant = null,
	difficulty := Difficulty.Value.NORMAL,
	tutorial := false,
	human_id: Variant = null,
) -> Game:
	var seed_: int = map_seed if map_seed != null else DartRandom.unseeded().next_int(0x7FFFFFFF)
	var generation := MapGenerator.generate(seed_)
	var player := Player.with_base(
		player_name,
		generation.base_x,
		generation.base_y,
		generation.map.width,
		generation.map.height,
		human_id,
	)
	player.saved_objective_state = ObjectiveState.new([], tutorial, tutorial)
	var game := Game.single_player(player, difficulty)
	game.levels = {1: generation.map}
	game.replay = ReplayJournal.new(seed_, player_name)
	return game


## A game against factions: `faction_count` (1 to 10) drawn from the
## catalogue with the map seed, or the `personalities` given (an
## `Array[FactionPersonality.Value]`, or null to draw). Each faction is a
## player on a base of its own, with a fog of its own, and the three levels
## are generated at once so that everybody descends in the same world.
## Without faction it is new_single_player.
##
## A faction breaks a tie between two bases by their ids, so only a given
## `human_id` makes a game against factions the same every time. A count
## or a number of players Dart throws for logs an error and gives null.
static func new_game(
	player_name: String,
	map_seed: Variant = null,
	difficulty := Difficulty.Value.NORMAL,
	tutorial := false,
	faction_count := 0,
	personalities: Variant = null,
	human_id: Variant = null,
) -> Game:
	var seed_: int = map_seed if map_seed != null else DartRandom.unseeded().next_int(0x7FFFFFFF)
	var drawn: Array[FactionPersonality.Value] = []
	if personalities != null:
		drawn = personalities
	elif faction_count != 0:
		drawn = FactionCatalogue.draw(faction_count, seed_)
		if drawn.is_empty():
			return null
	if drawn.is_empty() and faction_count == 0:
		return new_single_player(player_name, seed_, difficulty, tutorial, human_id)
	var world := WorldGenerator.generate(seed_, drawn.size() + 1)
	if world.is_empty():
		return null
	var first: MapGenerationResult = world[1]
	var human := _player_on(first, 0, player_name, human_id)
	human.saved_objective_state = ObjectiveState.new([], tutorial, tutorial)
	var game := Game.single_player(human, difficulty)
	for i: int in drawn.size():
		var faction := Faction.new(drawn[i])
		game.players[faction.id()] = _player_on(first, i + 1, faction.name(), faction.id())
	var levels: Dictionary[int, GameMap] = {}
	for level: int in world:
		levels[level] = world[level].map
	game.levels = levels
	game.saved_factions = drawn
	game.replay = ReplayJournal.new(seed_, player_name)
	return game


static func _player_on(level: MapGenerationResult, base: int, name: String, id: Variant) -> Player:
	var at: GridPosition = level.bases[base]
	return Player.with_base(name, at.x, at.y, level.map.width, level.map.height, id)
