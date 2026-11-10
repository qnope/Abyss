extends TestCase
## test/domain/map/exploration_resolver_level_test.dart: the research of the
## explorer widens the square a scout reveals.

const A := TechOption.Value.A
const B := TechOption.Value.B


func _revealed(size: int, explorer_level: int, options: Array[TechOption.Value] = [], unlocked := true) -> int:
	var half := DartMath.trunc_div(size, 2)
	var orders: Array[ExplorationOrder] = [ExplorationOrder.new(GridPosition.new(half, half))]
	var player := Player.new("Test", null, 5, 5, null, null, null, null, [], orders)
	var choices: Array[int] = []
	choices.assign(options)
	player.tech_branches[TechBranch.Value.EXPLORER] = TechBranchState.new(
		TechBranch.Value.EXPLORER, unlocked, explorer_level, choices
	)
	var game := Game.single_player(player)
	game.levels = {1: MapSamples.plain_map(size, size, 42)}
	return ExplorationResolver.resolve(game)[0].new_cells_revealed


func test_explorer_level_impact_level_0_reveals_3x3_area_9_cells() -> void:
	assert_eq(_revealed(10, 0), 9)


func test_explorer_level_impact_level_1_first_tier_reveals_5x5_area_25_cells() -> void:
	assert_eq(_revealed(10, 1), 25)


func test_explorer_level_impact_level_4_without_sonar_reveals_7x7_area_49_cells() -> void:
	assert_eq(_revealed(20, 4, [B, A]), 49)


func test_explorer_level_impact_level_4_with_sonar_profond_reveals_9x9_area_81_cells() -> void:
	assert_eq(_revealed(20, 4, [A, B]), 81)


func test_explorer_level_impact_a_locked_branch_reveals_3x3_whatever_its_level() -> void:
	assert_eq(_revealed(10, 5, [], false), 9)
