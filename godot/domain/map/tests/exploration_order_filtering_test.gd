extends TestCase
## test/domain/map/exploration_order_filtering_test.dart: the scouts sent,
## read level by level.


func test_filtering_explorations_by_level_returns_only_matching_level() -> void:
	var explorations: Array[ExplorationOrder] = [
		ExplorationOrder.new(GridPosition.new(0, 0), 1),
		ExplorationOrder.new(GridPosition.new(1, 1), 2),
		ExplorationOrder.new(GridPosition.new(2, 2), 1),
		ExplorationOrder.new(GridPosition.new(3, 3), 3),
	]

	var level1 := _targets_on(explorations, 1)
	assert_eq(level1, [Vector2i(0, 0), Vector2i(2, 2)])

	var level2 := _targets_on(explorations, 2)
	assert_eq(level2, [Vector2i(1, 1)])


## Not in the Dart file: a scout is sent on level 1 unless told, and what it
## found is told by an ExplorationResult, notable or not.
func test_a_scout_explores_level_1_unless_told_and_tells_what_it_found() -> void:
	assert_eq(ExplorationOrder.new(GridPosition.new(4, 5)).level, 1)
	var target := GridPosition.new(4, 5)
	var nothing := ExplorationResult.new(target, 9)
	assert_eq(nothing.target, target)
	assert_eq(nothing.new_cells_revealed, 9)
	assert_eq(nothing.notable_content, [])
	var notable: Array[CellContentType.Value] = [
		CellContentType.Value.RUINS, CellContentType.Value.MONSTER_LAIR,
	]
	assert_eq(ExplorationResult.new(target, 3, notable).notable_content, notable)
	nothing.notable_content.append(CellContentType.Value.RUINS)
	assert_eq(ExplorationResult.new(target, 1).notable_content, [], "a list of its own")


## The keys of the targets of the orders of a level, in their order.
func _targets_on(explorations: Array[ExplorationOrder], level: int) -> Array[Vector2i]:
	var targets: Array[Vector2i] = []
	for order: ExplorationOrder in explorations:
		if order.level == level:
			targets.append(order.target.key())
	return targets
