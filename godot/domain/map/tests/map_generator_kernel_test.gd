extends TestCase
## test/domain/map/map_generator_kernel_test.dart: the volcano of level 3.

const KERNEL := CellContentType.Value.VOLCANIC_KERNEL
const PART := CellContentType.Value.VOLCANIC_KERNEL_PART


func test_level_3_keeps_its_kernel_and_the_base_stays_out_of_its_footprint() -> void:
	var nudged := 0
	for seed_of_map: int in 300:
		var result := MapGenerator.generate(seed_of_map, 3)
		assert_eq(result.map.cell_at(10, 10).content, KERNEL, "seed=%d" % seed_of_map)
		var on_footprint := (
			result.base_x >= 10 and result.base_x <= 11
			and result.base_y >= 10 and result.base_y <= 11
		)
		assert_false(on_footprint, "seed=%d" % seed_of_map)
		if result.base_x == 9 or result.base_y == 9:
			nudged += 1
	assert_true(nudged > 0)


func test_level_3_maps_carry_the_2x2_footprint_other_levels_none() -> void:
	for seed_of_map: int in 100:
		var map := MapGenerator.generate(seed_of_map, 3).map
		for cell: Vector2i in [Vector2i(11, 10), Vector2i(10, 11), Vector2i(11, 11)]:
			assert_eq(map.cell_at(cell.x, cell.y).content, PART, "seed=%d" % seed_of_map)
		for level: int in [1, 2]:
			var other := MapGenerator.generate(seed_of_map, level).map
			assert_eq(MapSamples.indices_of(other.cells, PART), [])
