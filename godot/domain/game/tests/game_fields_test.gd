extends TestCase
## Not in the Dart tests: what lib/domain/game/game.dart answers that the
## Dart tests read through the actions and the factory only. The bases a
## player captured, the factions, the difficulty, the Léviathan a new game
## keeps, and what the port answers where Dart's `!` throws.

const Type := TransitionBaseType.Value


func test_a_new_game_keeps_the_leviathan_and_plays_in_normal_without_faction() -> void:
	var game := Game.single_player(Player.new("A", "a"))
	assert_true(game.leviathan_return.is_available())
	assert_eq(game.difficulty(), Difficulty.Value.NORMAL)
	assert_eq(game.factions(), [] as Array[Faction])
	assert_null(game.replay)


func test_takes_the_status_the_journal_and_the_difficulty() -> void:
	var p := Player.new("A", "a")
	var journal := ReplayJournal.new(3, "A")
	var game := Game.new("a", {"a": p}, 4, null, {}, GameStatus.Value.VICTORY, journal, Difficulty.Value.HARD)
	assert_eq([game.turn, game.status, game.difficulty()], [4, GameStatus.Value.VICTORY, Difficulty.Value.HARD])
	assert_true(game.replay == journal)
	assert_eq(Game.single_player(p, Difficulty.Value.EASY).saved_difficulty, Difficulty.Value.EASY)


func test_the_factions_are_those_of_the_personalities_in_their_order() -> void:
	var game := Game.single_player(Player.new("A", "a"))
	game.saved_factions = [FactionPersonality.Value.KRAKEN_FAITHFUL, FactionPersonality.Value.PEARL_ORDER]
	var ids: Array = game.factions().map(func(f: Faction) -> String: return f.id())
	assert_eq(ids, ["faction-krakenFaithful", "faction-pearlOrder"])


func test_the_captured_bases_of_a_player_on_every_level() -> void:
	var game := Game.single_player(Player.new("A", "a"))
	game.levels = {
		1: _map([_post(Type.FAILLE, "b"), _post(Type.FAILLE, "a")]),
		2: _map([_post(Type.CHEMINEE, "a"), _post(Type.FAILLE, "a")]),
	}
	assert_eq(game.captured_base_types_of("a"), {Type.FAILLE: true, Type.CHEMINEE: true})
	assert_eq(game.captured_base_types_of("c"), {} as Dictionary[Type, bool])


func test_the_current_map_is_level_1() -> void:
	var game := Game.single_player(Player.new("A", "a"))
	var first := MapSamples.plain_map(2, 2)
	game.levels = {2: MapSamples.plain_map(2, 2), 1: first}
	assert_true(game.current_map() == first)
	assert_true(game.map_for_level(1) == first)


## Dart throws on a missing human or level 1: an error, and null.
func test_a_missing_human_or_level_1_logs_an_error() -> void:
	var game := Game.new("ghost", {})
	expect_error("Game.human_player: no player ghost")
	assert_null(game.human_player())
	expect_error("Game.current_map: no level 1")
	assert_null(game.current_map())


func _post(type: Type, captured_by: String) -> MapCell:
	var base := TransitionBase.new(type, "Faille", captured_by)
	return MapCell.new(TerrainType.Value.PLAIN, CellContentType.Value.TRANSITION_BASE, null, null, base)


func _map(cells: Array[MapCell]) -> GameMap:
	return GameMap.new(cells.size(), 1, cells, 0)
