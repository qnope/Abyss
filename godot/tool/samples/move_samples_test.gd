extends TestCase
## Not in the Dart files: the samples of the actions that move units from
## one level to another.


func test_the_descend_game_holds_a_faille_and_the_scouts() -> void:
	var game := MoveSamples.descend_game(null, 2, 4)
	var player := game.human_player()
	var base := game.levels[1].cell_at(5, 5).transition_base
	assert_eq([base.type, base.captured_by], [TransitionBaseType.Value.FAILLE, null])
	assert_eq(Building.level_in(player.buildings, BuildingType.Value.DESCENT_MODULE), 2)
	assert_eq(player.unit_counts_on_level(1), {UnitType.Value.SCOUT: 4})
	assert_null(MoveSamples.descend_game("test", 1, 10, CellContentType.Value.EMPTY).levels[1].cell_at(5, 5).transition_base)


func test_the_reinforcement_game_may_lack_the_level_below() -> void:
	var game := MoveSamples.reinforcement_game(2, "x", false)
	assert_eq(game.levels.keys(), [1])
	assert_eq(game.levels[1].cell_at(2, 2).transition_base.captured_by, "x")
	assert_null(MoveSamples.reinforcement_map().cell_at(2, 2).transition_base)


func test_the_volcano_game_holds_the_kernel_captured_or_not() -> void:
	var player := Player.new("Test", "p1")
	assert_true(MoveSamples.volcano_game(player).is_volcanic_kernel_captured_by("p1"))
	assert_false(MoveSamples.volcano_game(player, false).is_volcanic_kernel_captured_by("p1"))
