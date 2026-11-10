extends TestCase
## test/domain/game/player_test.dart, its groups 'Player.withBase reveal
## seeding' and 'Player isolation'.


func test_player_with_base_reveal_seeding_revealed_cells_match_reveal_area_calculator_output_5x5() -> void:
	var p := Player.with_base("A", 10, 10, 20, 20)
	var expected := _set_of(RevealAreaCalculator.cells_to_reveal(10, 10, 5, 20, 20))
	assert_eq(p.revealed_cells(), expected)
	assert_eq(p.revealed_cells().size(), 25)
	assert_eq(p.base_x, 10)
	assert_eq(p.base_y, 10)
	# Strict centering: 2 cells in each cardinal direction from the base.
	for d: int in range(1, 3):
		assert_has(p.revealed_cells(), Vector2i(10 - d, 10))
		assert_has(p.revealed_cells(), Vector2i(10 + d, 10))
		assert_has(p.revealed_cells(), Vector2i(10, 10 - d))
		assert_has(p.revealed_cells(), Vector2i(10, 10 + d))


func test_player_with_base_reveal_seeding_base_near_edge_truncates_naturally_without_shifting() -> void:
	var p := Player.with_base("A", 1, 1, 20, 20)
	var expected: Dictionary[Vector2i, bool] = {}
	for y: int in range(0, 4):
		for x: int in range(0, 4):
			expected[Vector2i(x, y)] = true
	assert_eq(p.revealed_cells(), expected)
	assert_eq(p.revealed_cells().size(), 16)


func test_player_isolation_two_players_mutate_independently() -> void:
	var a := Player.new("A", "a", 5, 5)
	var b := Player.new("B", "b", 5, 5)
	a.resources[ResourceType.Value.ALGAE].amount = 999
	assert_ne(b.resources[ResourceType.Value.ALGAE].amount, 999)
	assert_eq(a.resources[ResourceType.Value.ALGAE].amount, 999)


## Not in the Dart file: the id a player draws is a version 4 UUID, as the
## `uuid` package writes it.
func test_a_drawn_id_is_a_uuid_of_version_4() -> void:
	var pattern := RegEx.create_from_string(
		"^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$"
	)
	for _player: int in 50:
		assert_not_null(pattern.search(Player.new("A").id))


## Not in the Dart file: a cell is revealed once, in the order revealed.
func test_add_revealed_cell_adds_a_cell_once_per_level() -> void:
	var p := Player.new("A")
	assert_true(p.add_revealed_cell(2, GridPosition.new(3, 4)))
	assert_false(p.add_revealed_cell(2, GridPosition.new(3, 4)))
	assert_true(p.add_revealed_cell(2, GridPosition.new(1, 1)))
	assert_eq(GridPosition.keys(p.revealed_cells_on_level(2)), [Vector2i(3, 4), Vector2i(1, 1)])
	assert_eq(p.revealed_cells_set_on_level(2), {Vector2i(3, 4): true, Vector2i(1, 1): true})
	assert_eq(p.revealed_cells_on_level(1).size(), 0)


## Not in the Dart file: the headquarters lowered never go below level 1.
func test_lower_headquarters_stops_at_level_1() -> void:
	var p := Player.new("A")
	p.buildings[BuildingType.Value.HEADQUARTERS].level = 5
	assert_eq(p.lower_headquarters(2), 3)
	assert_eq(p.lower_headquarters(9), 1)
	assert_eq(p.buildings[BuildingType.Value.HEADQUARTERS].level, 1)


## Not in the Dart file: a building is degraded when the headquarters lack
## what it needs; a base stands, a scout's report is kept.
func test_reads_the_degradation_the_fall_and_the_intel() -> void:
	var p := Player.new("A")
	p.buildings[BuildingType.Value.HEADQUARTERS].level = 1
	p.buildings[BuildingType.Value.LABORATORY].level = 1
	assert_false(p.is_degraded(BuildingType.Value.ALGAE_FARM))
	assert_true(p.is_degraded(BuildingType.Value.LABORATORY))
	assert_false(p.has_fallen())
	p.saved_fallen = true
	assert_true(p.has_fallen())
	assert_eq(p.intel(), {} as Dictionary[String, BaseIntel])
	p.intel()["b"] = BaseIntel.new(3, 1, 0, {}, {})
	assert_eq(p.saved_intel.keys(), ["b"])


func _set_of(positions: Array[GridPosition]) -> Dictionary[Vector2i, bool]:
	var cells: Dictionary[Vector2i, bool] = {}
	for key: Vector2i in GridPosition.keys(positions):
		cells[key] = true
	return cells
