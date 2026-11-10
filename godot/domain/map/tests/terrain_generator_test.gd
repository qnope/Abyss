extends TestCase
## test/domain/map/terrain_generator_test.dart: the ground of a new map.

const WIDTH := 20
const HEIGHT := 20


func test_terrain_generator_all_cells_are_plain() -> void:
	for cell: MapCell in _generate(42):
		assert_eq(cell.terrain, TerrainType.Value.PLAIN)


func test_terrain_generator_generates_correct_number_of_cells() -> void:
	assert_eq(_generate(42).size(), WIDTH * HEIGHT)


## Not in the Dart file: each cell is its own, bare, and no die is drawn.
func test_every_cell_is_a_bare_cell_of_its_own_and_the_dice_are_left_alone() -> void:
	var random := DartRandom.new(42)
	var cells := TerrainGenerator.generate(3, 2, random, 1, 1)
	assert_eq(cells.size(), 6)
	assert_ne(cells[0], cells[1])
	assert_eq(MapSamples.contents(cells).count(CellContentType.Value.EMPTY), 6)
	assert_eq(random.next_int(1000), DartRandom.new(42).next_int(1000))


func _generate(seed_of_map: int) -> Array[MapCell]:
	return TerrainGenerator.generate(WIDTH, HEIGHT, DartRandom.new(seed_of_map), 10, 10)
