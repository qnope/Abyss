extends TestCase
## test/domain/map/content_placer_test.dart: the treasures, the ruins and
## the lairs scattered on a new map.

const WIDTH := 20
const HEIGHT := 20
const BASE_X := 10
const BASE_Y := 10
const EMPTY := CellContentType.Value.EMPTY
const LAIR := CellContentType.Value.MONSTER_LAIR
## The generic monsters a lair of each difficulty stands for, fewest and most.
const RANGES: Dictionary[MonsterDifficulty.Value, Vector2i] = {
	MonsterDifficulty.Value.EASY: Vector2i(20, 50),
	MonsterDifficulty.Value.MEDIUM: Vector2i(60, 100),
	MonsterDifficulty.Value.HARD: Vector2i(120, 200),
}


func test_content_placer_base_zone_cells_have_empty_content() -> void:
	var cells := _generate(42)
	for dy: int in range(-2, 3):
		for dx: int in range(-2, 3):
			var x := BASE_X + dx
			var y := BASE_Y + dy
			assert_eq(cells[y * WIDTH + x].content, EMPTY, "Base zone cell (%d,%d)" % [x, y])


func test_content_placer_monster_lair_count_is_between_5_and_10() -> void:
	for seed_of_map: int in 20:
		var count := MapSamples.indices_of(_generate(seed_of_map), LAIR).size()
		assert_true(count >= 5 and count <= 10, "seed=%d: %d lairs" % [seed_of_map, count])


func test_content_placer_each_placed_lair_has_a_valid_unit_count() -> void:
	for seed_of_map: int in 20:
		var cells := _generate(seed_of_map)
		var lairs := MapSamples.indices_of(cells, LAIR)
		assert_false(lairs.is_empty(), "seed=%d" % seed_of_map)
		for index: int in lairs:
			_assert_lair_unit_count_in_range(cells[index], seed_of_map)


## A small map, so that the main roll loop almost never places the 5 lairs
## required and empty cells have to be promoted.
func test_content_placer_forced_placement_still_yields_a_valid_monster_lair() -> void:
	var saw_forced := false
	for seed_of_map: int in 30:
		var cells := MapSamples.plain_cells(8 * 8)
		ContentPlacer.place(cells, 8, 8, 4, 4, DartRandom.new(seed_of_map))
		var lairs := MapSamples.indices_of(cells, LAIR)
		assert_true(lairs.size() >= 5, "seed=%d" % seed_of_map)
		for index: int in lairs:
			_assert_lair_unit_count_in_range(cells[index], seed_of_map)
		var natural_max := DartMath.trunc_div(8 * 8, 10)
		if lairs.size() > natural_max:
			saw_forced = true
	assert_true(saw_forced, "expected at least one seed to exercise forced placement")


func test_content_placer_reserved_indices_have_no_content_placed() -> void:
	var reserved: Dictionary[int, bool] = {50: true, 100: true, 200: true}
	for seed_of_map: int in 20:
		var random := DartRandom.new(seed_of_map)
		var cells := TerrainGenerator.generate(WIDTH, HEIGHT, random, BASE_X, BASE_Y)
		ContentPlacer.place(cells, WIDTH, HEIGHT, BASE_X, BASE_Y, random, reserved)
		for idx: int in reserved:
			assert_eq(cells[idx].content, EMPTY, "seed=%d idx=%d" % [seed_of_map, idx])


func test_content_placer_same_seed_produces_same_content() -> void:
	var a := _generate(99)
	var b := _generate(99)
	assert_eq(MapSamples.contents(a), MapSamples.contents(b))
	assert_eq(_lairs(a), _lairs(b))


func test_content_placer_never_sinks_a_wreck_only_random_events_do() -> void:
	for seed_of_map: int in 30:
		var contents := MapSamples.contents(_generate(seed_of_map))
		assert_false(contents.has(CellContentType.Value.WRECK), "seed=%d" % seed_of_map)


func _generate(seed_of_map: int) -> Array[MapCell]:
	var random := DartRandom.new(seed_of_map)
	var cells := TerrainGenerator.generate(WIDTH, HEIGHT, random, BASE_X, BASE_Y)
	ContentPlacer.place(cells, WIDTH, HEIGHT, BASE_X, BASE_Y, random)
	return cells


## The difficulty and the size of the lair of each cell, null without one.
func _lairs(cells: Array[MapCell]) -> Array:
	return cells.map(func(cell: MapCell) -> Variant:
		return null if cell.lair == null else [cell.lair.difficulty, cell.lair.unit_count])


func _assert_lair_unit_count_in_range(cell: MapCell, seed_of_map: int) -> void:
	assert_not_null(cell.lair, "seed=%d" % seed_of_map)
	var lair := cell.lair
	var bounds := RANGES[lair.difficulty]
	var fewest := MonsterUnitStats.count_for(lair.family, bounds.x)
	var most := MonsterUnitStats.count_for(lair.family, bounds.y)
	assert_true(
		lair.unit_count >= fewest and lair.unit_count <= most,
		"seed=%d: %d monsters" % [seed_of_map, lair.unit_count],
	)
