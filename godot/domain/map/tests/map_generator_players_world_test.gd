extends TestCase
## test/domain/map/map_generator_players_test.dart, group
## 'WorldGenerator.generate': the three levels of a world, generated at once.

const Content := CellContentType.Value


func test_world_generator_generate_builds_the_three_levels_of_the_same_size() -> void:
	var world := WorldGenerator.generate(8, 4)
	assert_eq(world.keys(), [1, 2, 3])
	for r: MapGenerationResult in world.values():
		assert_eq(r.map.width, 26)


func test_world_generator_generate_levels_2_and_3_carry_the_passages_of_the_level_above() -> void:
	var world := WorldGenerator.generate(8, 7)
	for level: int in [2, 3]:
		var passages := MapSamples.passages_of(world[level - 1].map)
		assert_false(passages.is_empty())
		for key: Vector2i in passages:
			var cell := world[level].map.cell_at(key.x, key.y)
			assert_eq(cell.content, Content.PASSAGE)
			assert_eq(cell.passage_name, passages[key])
	assert_eq(world[3].map.cell_at(16, 16).content, Content.VOLCANIC_KERNEL)


func test_world_generator_generate_is_deterministic_and_keeps_level_1_as_generate_gives() -> void:
	var a := WorldGenerator.generate(8, 4)
	var b := WorldGenerator.generate(8, 4)
	for level: int in [1, 2, 3]:
		assert_eq(MapSamples.fingerprint(a[level].map), MapSamples.fingerprint(b[level].map))
	var l1 := MapGenerator.generate(8, 1, {}, 4)
	assert_eq(MapSamples.fingerprint(a[1].map), MapSamples.fingerprint(l1.map))


## Not in the Dart file: levels 2 and 3 are seeded with a draw of
## `Random(seed + level)`, so level 3 of a world and level 2 of the next
## get the same seed, and not the same map.
func test_levels_2_and_3_get_a_seed_drawn_from_the_seed_of_the_world_and_their_level() -> void:
	var world := WorldGenerator.generate(0)
	var next := WorldGenerator.generate(1)
	assert_eq(world[1].map.map_seed, 0)
	assert_eq(world[2].map.map_seed, DartRandom.new(2).next_int(0x7FFFFFFF))
	assert_eq(world[3].map.map_seed, DartRandom.new(3).next_int(0x7FFFFFFF))
	assert_eq(next[2].map.map_seed, world[3].map.map_seed)
	assert_ne(MapSamples.fingerprint(next[2].map), MapSamples.fingerprint(world[3].map))


## Not in the Dart file: Dart throws an ArgumentError at the first level;
## the port logs its error and gives a world without any level.
func test_rejects_a_player_count_off_the_1_to_11_range() -> void:
	expect_error("MapLayout: playerCount 12 must be 1 to 11")
	assert_eq(WorldGenerator.generate(8, 12).size(), 0)
