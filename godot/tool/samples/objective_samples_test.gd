extends TestCase
## The games and the progresses the tests of the objectives share.


func test_an_objective_game_is_a_new_player_on_a_plain_map_of_10() -> void:
	var game := ObjectiveSamples.objective_game()
	var player := game.human_player()
	assert_eq([player.name, player.base_x, player.base_y], ["Nemo", 5, 5])
	assert_eq(game.levels.keys(), [1])
	assert_eq([game.levels[1].width, game.levels[1].height], [10, 10])
	assert_eq(player.revealed_cells_on_level(1).size(), RevealAreaCalculator.around_base(5, 5, 10, 10).size())


func test_set_building_and_progress_read_the_human() -> void:
	var game := ObjectiveSamples.objective_game()
	ObjectiveSamples.set_building(game.human_player(), BuildingType.Value.HEADQUARTERS, 4)
	assert_eq(ObjectiveSamples.progress(game, ObjectiveId.Value.HQ_LEVEL_5), [4, 5, false])
	assert_eq(ObjectiveSamples.expected(5, 5), [5, 5, true])


func test_a_tip_applies_as_the_catalog_says() -> void:
	var game := ObjectiveSamples.objective_game()
	assert_false(ObjectiveSamples.applies(game, TipId.Value.RAID_REPORT))
	game.human_player().raid_state.record_outcome(true)
	assert_true(ObjectiveSamples.applies(game, TipId.Value.RAID_REPORT))
