extends CodecTestCase
## PlayerCodec and GameCodec: a player and everything it holds, a game and
## its levels, written and read back, every map in its order.

const Unit := UnitType.Value


static func _player() -> Player:
	var player := Player.with_base("Nemo", 4, 5, 20, 20, HUMAN)
	player.resources[ResourceType.Value.PEARL].amount = 42
	player.buildings.erase(BuildingType.Value.HEADQUARTERS)
	player.buildings[BuildingType.Value.HEADQUARTERS] = Building.new(BuildingType.Value.HEADQUARTERS, 4)
	RaidSamples.set_units(player, Unit.GUARDIAN, 3, 2)
	RaidSamples.set_units(player, Unit.SCOUT, 1)
	player.add_revealed_cell(2, GridPosition.new(9, 9))
	player.recruited_unit_types = [Unit.SCOUT, Unit.GUARDIAN]
	player.pending_explorations = [ExplorationOrder.new(GridPosition.new(1, 2), 2)]
	player.pending_reinforcements = [ReinforcementOrder.new(1, 2, {Unit.SCOUT: 1}, 3, GridPosition.new(0, 0))]
	player.add_history_entry(ExploreEntry.new(1, 2, 3))
	player.add_history_entry(HistorySamples.raid_entry(true))
	player.saved_fallen = true
	player.saved_intel["faction-b"] = BaseIntel.new(3, 2, 1, {Unit.SCOUT: 2}, {})
	player.saved_intel["faction-a"] = BaseIntel.new(4, 2, 1, {}, {ResourceType.Value.ORE: 3})
	return player


func test_a_player_keeps_everything_it_holds_in_its_order() -> void:
	var player := _player()
	var read: Player = assert_round_trip(PlayerSnapshots.player(), PlayerCodec.player, PlayerCodec.read_player, player)
	assert_eq(read.buildings.keys(), player.buildings.keys())
	assert_eq(read.units_per_level.keys(), player.units_per_level.keys())
	assert_eq(read.saved_intel.keys(), ["faction-b", "faction-a"])
	assert_true(read.has_fallen())
	assert_round_trip(PlayerSnapshots.player(), PlayerCodec.player, PlayerCodec.read_player, Player.new("A", HUMAN))


func test_a_map_of_the_player_keyed_by_an_unknown_name_is_a_problem() -> void:
	var text := JSON.stringify(PlayerCodec.player(_player()), "", false)
	assert_eq(problem_of(PlayerCodec.read_player, text.replace("\"pearl\":{", "\"pearls\":{")),
		"resources: \"pearls\" is no %s" % "|".join(DartEnum.names(ResourceType.Value)))
	assert_eq(problem_of(PlayerCodec.read_player, text.replace("\"revealedCellsPerLevel\":{\"1\"", "\"revealedCellsPerLevel\":{\"a\"")),
		"revealedCellsPerLevel: \"a\" is not a whole number")


func test_a_game_keeps_its_players_in_order_its_levels_and_its_dates() -> void:
	var factions: Array[FactionPersonality.Value] = [
		FactionPersonality.Value.PEARL_ORDER, FactionPersonality.Value.MAGMA_SMITHS]
	var game := GameFactory.new_game("Nemo", 7, Difficulty.Value.HARD, false, 0, factions, HUMAN)
	game.turn = 5
	game.status = GameStatus.Value.FREE_PLAY
	game.created_at = DateSamples.at(2026, 3, 15, 14, 30)
	game.saved_last_played_at = DateSamples.at(2026, 4, 1, 8, 5)
	game.replay = ReplayJournal.new(7, "Nemo")
	game.levels[2] = MapSamples.plain_map(2, 2, 9)
	var text := JSON.stringify(GameCodec.game(game), "", false)
	var r := SaveReader.new()
	var read := GameCodec.read_game(r, JSON.parse_string(text))
	assert_eq(r.problem, "")
	assert_eq(GameSnapshot.texts(read), GameSnapshot.texts(game))
	assert_eq(read.players.keys(), game.players.keys())
	assert_eq(read.levels.keys(), game.levels.keys())
	assert_eq([read.created_at, read.saved_last_played_at], [game.created_at, game.saved_last_played_at])
	assert_eq(read.saved_factions, game.saved_factions)


func test_a_game_never_saved_nor_journaled_comes_back_so() -> void:
	var game := Game.single_player(Player.new("A", HUMAN))
	game.leviathan_return = null
	var r := SaveReader.new()
	var read := GameCodec.read_game(r, JSON.parse_string(JSON.stringify(GameCodec.game(game), "", false)))
	assert_eq(r.problem, "")
	assert_null(read.saved_last_played_at)
	assert_null(read.replay)
	assert_null(read.leviathan_return)
	assert_eq(read.last_played_at(), game.created_at)
	assert_eq(GameSnapshot.texts(read), GameSnapshot.texts(game))


func test_a_level_or_a_player_of_the_wrong_type_is_a_problem() -> void:
	var text := JSON.stringify(GameCodec.game(Game.single_player(Player.new("A", HUMAN))), "", false)
	assert_eq(problem_of(GameCodec.read_game, text.replace("\"levels\":{}", "\"levels\":{\"one\":{}}")),
		"levels: \"one\" is not a whole number")
	assert_eq(problem_of(GameCodec.read_game, text.replace("\"players\":{\"h\":{", "\"players\":{\"h\":7,\"x\":{")),
		"Player is not an object")
