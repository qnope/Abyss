extends TestCase
## test/domain/faction/faction_standing_test.dart: what the human knows of
## each player of the ranking.


func test_a_solo_game_has_no_ranking() -> void:
	assert_eq(FactionStanding.ranking(_game(0)).size(), 0)


func test_the_ranking_lists_the_human_and_every_faction() -> void:
	var game := _game(3)
	var ranking := FactionStanding.ranking(game)
	assert_eq(ranking.size(), 4)
	var humans: Array[String] = []
	var personalities: Array = []
	for standing: FactionStanding in ranking:
		if standing.is_human():
			humans.append(standing.name)
		else:
			personalities.append(standing.personality)
	assert_eq(humans, ["Nemo"] as Array[String])
	var expected: Array = []
	for faction: Faction in game.factions():
		expected.append(faction.personality)
	assert_eq(personalities, expected)


func test_a_fresh_player_is_at_level_one_without_kernel() -> void:
	var standing := FactionStanding.of(_game(2), _game(2).human_player())
	assert_eq(standing.deepest_level, 1)
	assert_false(standing.holds_kernel)
	assert_eq(standing.headquarters_level, 0)
	assert_false(standing.has_fallen)


func test_depth_follows_the_captured_posts_and_the_kernel() -> void:
	var game := _game(2)
	var faction := game.players[game.factions()[0].id()]
	_base_on_level(game, 1).captured_by = faction.id
	assert_eq(FactionStanding.of(game, faction).deepest_level, 2)
	var cells := game.levels[3].cells
	var i := -1
	for index: int in cells.size():
		if i < 0 and DartEnum.name_of(CellContentType.Value, cells[index].content) == "volcanicKernel":
			i = index
	cells[i] = cells[i].copy_with({"collected_by": faction.id})
	var standing := FactionStanding.of(game, faction)
	assert_eq(standing.deepest_level, 3)
	assert_true(standing.holds_kernel)


func test_the_most_advanced_come_first_and_the_fallen_last() -> void:
	var game := _game(3)
	var first := game.players[game.factions()[1].id()]
	first.buildings[BuildingType.Value.HEADQUARTERS].level = 4
	game.players[game.factions()[0].id()].saved_fallen = true
	var ranking := FactionStanding.ranking(game)
	assert_eq(ranking[0].personality, game.factions()[1].personality)
	assert_eq(ranking[-1].personality, game.factions()[0].personality)
	assert_true(ranking[-1].has_fallen)


func test_a_faction_is_discovered_once_the_human_has_seen_its_base() -> void:
	var game := _game(2)
	var faction := game.players[game.factions()[0].id()]
	assert_true(FactionStanding.of(game, game.human_player()).discovered)
	assert_false(FactionStanding.of(game, faction).discovered)
	game.human_player().add_revealed_cell(1, GridPosition.new(faction.base_x, faction.base_y))
	assert_true(FactionStanding.of(game, faction).discovered)


## Not in the Dart file: equal scores keep the playing order, the human
## first, and a faction whose player is missing is left out.
func test_equal_scores_keep_the_playing_order_and_a_missing_player_is_left_out() -> void:
	var game := _game(3)
	assert_eq(_names(game), ["Nemo", "anglerCult", "pyrosomeHive", "currentNomads"])
	game.players.erase(game.factions()[2].id())
	assert_eq(_names(game), ["Nemo", "anglerCult", "pyrosomeHive"])


## Not in the Dart file: a post one level down outranks ten levels of
## headquarters, as the Dart ranking printed it.
func test_a_post_below_outranks_the_headquarters() -> void:
	var game := _game(3)
	_base_on_level(game, 1).captured_by = game.factions()[0].id()
	game.players[game.factions()[1].id()].buildings[BuildingType.Value.HEADQUARTERS].level = 10
	assert_eq(_names(game), ["anglerCult", "pyrosomeHive", "Nemo", "currentNomads"])


## The human's name, then the Dart name of each personality, in the order of
## the ranking.
func _names(game: Game) -> Array:
	var names: Array = []
	for standing: FactionStanding in FactionStanding.ranking(game):
		if standing.is_human():
			names.append(standing.name)
			continue
		var personality: int = standing.personality
		names.append(DartEnum.name_of(FactionPersonality.Value, personality))
	return names


func _game(factions: int) -> Game:
	return GameFactory.new_game("Nemo", 7, Difficulty.Value.NORMAL, false, factions)


## `_baseOnLevel`: the first transition base of `level`.
func _base_on_level(game: Game, level: int) -> TransitionBase:
	for cell: MapCell in game.levels[level].cells:
		if cell.transition_base != null:
			return cell.transition_base
	return null
