extends TestCase
## test/domain/map/map_generator_test.dart: a generated level.

const Content := CellContentType.Value


func test_generate_returns_a_20x20_map_with_matching_cells_length() -> void:
	var result := MapGenerator.generate(42)
	assert_eq(result.map.width, 20)
	assert_eq(result.map.height, 20)
	assert_eq(result.map.cells.size(), 400)


func test_generate_base_x_base_y_are_inside_map_bounds() -> void:
	var result := MapGenerator.generate(42)
	assert_true(result.base_x >= 0 and result.base_x < result.map.width)
	assert_true(result.base_y >= 0 and result.base_y < result.map.height)


func test_generate_base_cell_content_is_empty() -> void:
	var result := MapGenerator.generate(42)
	assert_eq(result.map.cell_at(result.base_x, result.base_y).content, Content.EMPTY)


func test_generate_seed_is_stored_on_the_generated_map() -> void:
	assert_eq(MapGenerator.generate(123).map.map_seed, 123)


func test_generate_same_seed_produces_identical_maps_deterministic() -> void:
	var a := MapGenerator.generate(99)
	var b := MapGenerator.generate(99)
	assert_eq([a.base_x, a.base_y, a.map.map_seed], [b.base_x, b.base_y, b.map.map_seed])
	assert_eq(MapSamples.fingerprint(a.map), MapSamples.fingerprint(b.map))


func test_generate_every_cell_is_well_formed_no_fog_of_war_residue() -> void:
	for cell: MapCell in MapGenerator.generate(42).map.cells:
		assert_eq(cell.terrain, TerrainType.Value.PLAIN)
		assert_has(Content.values(), cell.content)
		assert_null(cell.collected_by)


func test_generate_level_1_map_has_4_failles() -> void:
	var cells := MapGenerator.generate(42, 1).map.cells
	var bases := MapSamples.transition_base_indices(cells)
	assert_eq(bases.size(), 4)
	for index: int in bases:
		assert_eq(cells[index].transition_base.type, TransitionBaseType.Value.FAILLE)


func test_generate_level_2_map_has_3_cheminees() -> void:
	var cells := MapGenerator.generate(42, 2).map.cells
	var bases := MapSamples.transition_base_indices(cells)
	assert_eq(bases.size(), 3)
	for index: int in bases:
		assert_eq(cells[index].transition_base.type, TransitionBaseType.Value.CHEMINEE)


func test_generate_level_3_map_has_no_transition_bases() -> void:
	var cells := MapGenerator.generate(42, 3).map.cells
	assert_eq(MapSamples.transition_base_indices(cells), [])


func test_generate_level_3_has_exactly_one_volcanic_kernel_at_center() -> void:
	var cells := MapGenerator.generate(42, 3).map.cells
	assert_eq(MapSamples.indices_of(cells, Content.VOLCANIC_KERNEL), [10 * 20 + 10])


func test_generate_level_1_has_no_volcanic_kernel() -> void:
	var cells := MapGenerator.generate(42, 1).map.cells
	assert_eq(MapSamples.indices_of(cells, Content.VOLCANIC_KERNEL), [])


func test_generate_level_2_has_no_volcanic_kernel() -> void:
	var cells := MapGenerator.generate(42, 2).map.cells
	assert_eq(MapSamples.indices_of(cells, Content.VOLCANIC_KERNEL), [])


func test_generate_base_cell_never_has_transition_base() -> void:
	for level: int in [1, 2]:
		var result := MapGenerator.generate(42, level)
		var base := result.map.cell_at(result.base_x, result.base_y)
		assert_ne(base.content, Content.TRANSITION_BASE, "level=%d" % level)


## Not in the Dart file: without a seed, the map draws one below 2^31 and
## remembers it, so that the same map can be generated again.
func test_a_map_without_a_seed_draws_one_and_remembers_it() -> void:
	var drawn := MapGenerator.generate()
	var seed_drawn := drawn.map.map_seed
	assert_true(seed_drawn >= 0 and seed_drawn < 0x7FFFFFFF, str(seed_drawn))
	var again := MapGenerator.generate(seed_drawn)
	assert_eq(MapSamples.fingerprint(drawn.map), MapSamples.fingerprint(again.map))
	var world := WorldGenerator.generate()
	var world_again := WorldGenerator.generate(world[1].map.map_seed)
	for level: int in [1, 2, 3]:
		assert_eq(
			MapSamples.fingerprint(world[level].map), MapSamples.fingerprint(world_again[level].map)
		)
