extends TestCase
## Not in the Dart files: the samples the tests of the actions build.


func test_a_stocked_player_holds_only_the_stocks_and_buildings_given() -> void:
	var recruited: Array[UnitType.Value] = [UnitType.Value.SCOUT]
	var player := ActionSamples.stocked(
		ActionSamples.amounts(1, 2, 3, 4, 5), {BuildingType.Value.BARRACKS: 2}, recruited
	)
	assert_eq([player.id, player.name], ["test", "Test"])
	assert_eq(player.resources.keys(), ResourceType.Value.values())
	assert_eq(player.resources[ResourceType.Value.PEARL].amount, 5)
	assert_eq(player.buildings.keys(), [BuildingType.Value.BARRACKS])
	assert_eq(player.recruited_unit_types, recruited)


func test_the_explore_game_sees_around_its_base_with_its_scouts() -> void:
	var game := ActionSamples.explore_game(2)
	var player := game.human_player()
	assert_eq([player.base_x, player.base_y, player.id], [3, 3, "test-uuid"])
	assert_eq(player.revealed_cells_on_level(1).size(), 9)
	assert_eq(player.unit_counts_on_level(1), {UnitType.Value.SCOUT: 2})
	assert_eq(player.units_on_level(1).size(), UnitType.Value.size())
	assert_eq([game.levels[1].width, game.levels[1].map_seed], [7, 42])


func test_the_collect_and_fight_games_hold_their_cell_at_1_1() -> void:
	var collect := ActionSamples.collect_game(CellContentType.Value.RUINS, null, "x")
	assert_eq(collect.levels[1].cell_at(1, 1).content, CellContentType.Value.RUINS)
	assert_eq(collect.levels[1].cell_at(1, 1).collected_by, "x")
	assert_eq(collect.human_player().revealed_cells_on_level(1).size(), 25)
	var fight := ActionSamples.fight_game(MonsterDifficulty.Value.HARD, 4, {UnitType.Value.SCOUT: 2}, 3)
	var cell := fight.levels[1].cell_at(1, 1)
	assert_eq([cell.content, cell.lair.difficulty, cell.lair.unit_count], [CellContentType.Value.MONSTER_LAIR, MonsterDifficulty.Value.HARD, 4])
	assert_eq(fight.human_player().unit_counts_on_level(1), {UnitType.Value.SCOUT: 2})
	assert_eq(fight.human_player().tech_branches[TechBranch.Value.MILITARY].research_level, 3)
	assert_null(ActionSamples.fight_map(MonsterDifficulty.Value.EASY, 1, null, false).cell_at(1, 1).lair)


func test_the_game_of_a_player_alone_starts_at_the_turn_given() -> void:
	var player := GameSamples.player("p")
	var game := ActionSamples.game_of(player, 7)
	assert_eq([game.human_player_id, game.players.keys(), game.turn], ["p", ["p"], 7])
