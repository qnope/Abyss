extends TestCase
## test/domain/game/game_factory_factions_test.dart. 'the human exploring
## does not reveal anything to a faction' waits for the actions (an
## exploration and an end of turn).

const Personality := FactionPersonality.Value
const HQ := BuildingType.Value.HEADQUARTERS


func test_a_game_without_faction_is_the_single_player_game_byte_for_byte() -> void:
	var solo := GameFactory.new_single_player("Nemo", 5)
	var none := _with_factions(0, 5)
	assert_eq(none.players.size(), 1)
	assert_eq(none.factions().size(), 0)
	assert_eq(none.levels.keys(), solo.levels.keys())
	assert_eq(MapSamples.fingerprint(none.levels[1]), MapSamples.fingerprint(solo.levels[1]))
	assert_eq(none.human_player().base_x, solo.human_player().base_x)
	assert_eq(none.human_player().base_y, solo.human_player().base_y)
	assert_eq(none.replay.map_seed, 5)


func test_each_faction_is_a_real_player_on_a_base_of_its_own() -> void:
	var game := _with_factions(3)
	var bases := MapGenerator.generate(11, 1, {}, 4).bases
	assert_eq(game.players.size(), 4)
	assert_eq(game.factions().size(), 3)
	assert_eq(game.human_player().base_x, bases[0].x)
	for i: int in 3:
		var faction: Faction = game.factions()[i]
		var player: Player = game.players[faction.id()]
		assert_eq(player.name, faction.name())
		assert_eq([player.base_x, player.base_y], [bases[i + 1].x, bases[i + 1].y])
		assert_eq(player.buildings[HQ].level, game.human_player().buildings[HQ].level)
		assert_has(player.revealed_cells(), Vector2i(player.base_x, player.base_y))


func test_the_levels_2_and_3_exist_from_the_start_on_a_bigger_map() -> void:
	var game := _with_factions(2)
	assert_eq(game.levels.keys(), [1, 2, 3])
	assert_eq(game.levels[1].width, 20)
	assert_eq(_with_factions(5).levels[1].width, 26)
	assert_eq(_with_factions(10).levels[1].width, 32)


func test_the_factions_are_drawn_from_the_catalogue_with_the_map_seed() -> void:
	var different: Dictionary[Personality, bool] = {}
	for faction: Faction in _with_factions(10).factions():
		different[faction.personality] = true
	assert_eq(different.size(), 10)
	assert_eq(_personalities(_with_factions(4)), FactionCatalogue.draw(4, 11))


func test_explicit_personalities_are_honoured() -> void:
	var chosen: Array[Personality] = [Personality.KRAKEN_FAITHFUL, Personality.PEARL_ORDER]
	var game := GameFactory.new_game("Nemo", 3, Difficulty.Value.NORMAL, false, 0, chosen)
	assert_eq(_personalities(game), chosen)


func test_the_difficulty_and_the_tutorial_choice_reach_a_faction_game() -> void:
	var game := GameFactory.new_game("Nemo", 3, Difficulty.Value.HARD, true, 2)
	assert_eq(game.difficulty(), Difficulty.Value.HARD)
	assert_true(game.human_player().saved_objective_state.tutorial_enabled)
	for faction: Faction in game.factions():
		assert_false(game.players[faction.id()].saved_objective_state.tutorial_enabled)


## Dart throws an ArgumentError: the port logs an error and gives no game.
func test_1_to_10_factions_only() -> void:
	expect_error("FactionCatalogue.draw: the count 11 must be 1 to 10")
	assert_null(_with_factions(11))
	expect_error("FactionCatalogue.draw: the count -1 must be 1 to 10")
	assert_null(_with_factions(-1))


## Not in the Dart file: eleven personalities given make a world Dart
## refuses to lay out.
func test_eleven_personalities_give_no_game() -> void:
	var chosen: Array[Personality] = []
	chosen.assign(Personality.values())
	chosen.append(Personality.PEARL_ORDER)
	expect_error("MapLayout: playerCount 12")
	assert_null(GameFactory.new_game("Nemo", 3, Difficulty.Value.NORMAL, false, 0, chosen))


## Not in the Dart file: no personality given and a count asked lay out a
## game of the human alone on the world of one player, as Dart does.
func test_no_personality_and_a_count_give_the_world_of_the_human_alone() -> void:
	var none: Array[Personality] = []
	var game := GameFactory.new_game("Nemo", 3, Difficulty.Value.NORMAL, false, 2, none)
	assert_eq(game.players.size(), 1)
	assert_eq(game.levels.keys(), [1, 2, 3])
	assert_eq(game.factions().size(), 0)


func _with_factions(count: int, seed_ := 11) -> Game:
	return GameFactory.new_game("Nemo", seed_, Difficulty.Value.NORMAL, false, count)


func _personalities(game: Game) -> Array[Personality]:
	var found: Array[Personality] = []
	for faction: Faction in game.factions():
		found.append(faction.personality)
	return found
