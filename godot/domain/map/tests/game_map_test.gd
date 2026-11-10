extends TestCase
## test/domain/map/game_map_test.dart: the grid of one level.

const PLAIN := TerrainType.Value.PLAIN
const RUINS := CellContentType.Value.RUINS
const LAIR := CellContentType.Value.MONSTER_LAIR


func test_construction_constructs_without_base_coordinates() -> void:
	var map := _make_map()
	assert_eq(map.width, 20)
	assert_eq(map.height, 20)
	assert_eq(map.cells.size(), 400)
	assert_eq(map.map_seed, 42)


func test_cell_at_set_cell_cell_at_retrieves_the_correct_cell() -> void:
	var map := _make_map()
	map.cells[5 * 20 + 3] = MapCell.new(PLAIN, RUINS)
	assert_eq(map.cell_at(3, 5).content, RUINS)


func test_cell_at_set_cell_set_cell_overwrites_the_correct_cell() -> void:
	var map := _make_map()
	map.set_cell(7, 12, MapCell.new(PLAIN, LAIR))
	assert_eq(map.cell_at(7, 12).content, LAIR)
	assert_eq(map.cells[12 * 20 + 7].content, LAIR)


func test_cell_at_set_cell_cell_at_handles_corners() -> void:
	var map := _make_map()
	map.set_cell(0, 0, MapCell.new(PLAIN, RUINS))
	map.set_cell(19, 19, MapCell.new(PLAIN, CellContentType.Value.EMPTY))
	assert_eq(map.cell_at(0, 0).content, RUINS)
	assert_eq(map.cell_at(19, 19).content, CellContentType.Value.EMPTY)


func _make_map() -> GameMap:
	return GameMap.new(20, 20, MapSamples.plain_cells(400), 42)
