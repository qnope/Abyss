extends TestCase
## A generated level and its bases. Dart has no test file for
## map_generation_result.dart: not in a Dart file, then.


func test_without_bases_the_one_base_is_the_base_of_the_map() -> void:
	var result := MapGenerationResult.new(MapSamples.plain_map(4, 4), 2, 3)
	assert_eq(GridPosition.keys(result.bases), [Vector2i(2, 3)])
	assert_eq([result.base_x, result.base_y], [2, 3])
	assert_eq(result.map.width, 4)


func test_keeps_the_bases_it_is_given_in_their_order() -> void:
	var bases: Array[GridPosition] = [GridPosition.new(2, 3), GridPosition.new(0, 1)]
	var result := MapGenerationResult.new(MapSamples.plain_map(4, 4), 2, 3, bases)
	assert_eq(result.bases, bases)


func test_two_results_without_bases_share_none() -> void:
	var first := MapGenerationResult.new(MapSamples.plain_map(4, 4), 2, 3)
	var second := MapGenerationResult.new(MapSamples.plain_map(4, 4), 1, 1)
	first.bases.append(GridPosition.new(0, 0))
	assert_eq(GridPosition.keys(second.bases), [Vector2i(1, 1)])
