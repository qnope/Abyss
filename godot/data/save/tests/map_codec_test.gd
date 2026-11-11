extends CodecTestCase
## MapCodec and OrderCodec: the maps, their cells, and the orders that move
## on them, written and read back.

const Family := MonsterFamily.Value


func test_a_lair_with_or_without_its_families() -> void:
	assert_round_trip(MapSnapshots.lair(), MapCodec.lair, MapCodec.read_lair,
		MonsterLair.new(MonsterDifficulty.Value.MEDIUM, 6))
	assert_round_trip(MapSnapshots.lair(), MapCodec.lair, MapCodec.read_lair,
		MonsterLair.new(MonsterDifficulty.Value.HARD, 6, Family.HUNTER, Family.SWARM, 3))


func test_a_post_captured_or_not() -> void:
	var post := TransitionBase.new(TransitionBaseType.Value.FAILLE, "Faille Nord")
	assert_round_trip(MapSnapshots.transition_base(), MapCodec.transition_base, MapCodec.read_transition_base, post)
	post.captured_by = "h"
	assert_round_trip(MapSnapshots.transition_base(), MapCodec.transition_base, MapCodec.read_transition_base, post)


func test_an_empty_cell_and_a_cell_holding_everything() -> void:
	assert_round_trip(MapSnapshots.cell(), MapCodec.cell, MapCodec.read_cell, MapCell.new(TerrainType.Value.PLAIN))
	var full := MapCell.new(
		TerrainType.Value.PLAIN, CellContentType.Value.MONSTER_LAIR,
		MonsterLair.new(MonsterDifficulty.Value.EASY, 2, Family.KRAKEN), "h",
		TransitionBase.new(TransitionBaseType.Value.CHEMINEE, "Cheminée", "f"), "Passage",
	)
	assert_round_trip(MapSnapshots.cell(), MapCodec.cell, MapCodec.read_cell, full)


func test_a_map_keeps_its_cells_in_row_order_and_its_seed() -> void:
	var map := MapSamples.plain_map(3, 2, 77)
	map.cells[4] = MapCell.new(TerrainType.Value.PLAIN, CellContentType.Value.RUINS)
	var read: GameMap = assert_round_trip(MapSnapshots.game_map(), MapCodec.game_map, MapCodec.read_game_map, map)
	assert_eq(read.cells.size(), 6)


func test_positions_and_the_orders_on_their_way() -> void:
	assert_round_trip(MapSnapshots.position(), MapCodec.position, MapCodec.read_position, GridPosition.new(-1, 4))
	assert_round_trip(MapSnapshots.exploration(), OrderCodec.exploration, OrderCodec.read_exploration,
		ExplorationOrder.new(GridPosition.new(2, 3), 2))
	var units: Dictionary[UnitType.Value, int] = {UnitType.Value.GUARDIAN: 4, UnitType.Value.SCOUT: 1}
	assert_round_trip(MapSnapshots.reinforcement(), OrderCodec.reinforcement, OrderCodec.read_reinforcement,
		ReinforcementOrder.new(1, 2, units, 7, GridPosition.new(5, 5)))


func test_a_nullable_object_of_the_wrong_type_is_a_problem() -> void:
	var cell := JSON.stringify(MapCodec.cell(MapCell.new(TerrainType.Value.PLAIN)), "", false)
	assert_eq(problem_of(MapCodec.read_cell, cell.replace("\"lair\":null", "\"lair\":3")), "MonsterLair is not an object")
	assert_eq(problem_of(MapCodec.read_cell, cell.replace("\"transitionBase\":null", "\"transitionBase\":[]")),
		"transitionBase is not an object")
