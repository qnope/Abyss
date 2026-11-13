extends TestCase
## The game a bench on the map measures: three levels, the same each time, a
## part of each seen.


func test_gives_the_map_of_each_level_with_some_of_it_seen() -> void:
	for level: int in [1, 2, 3]:
		var state := BenchGame.map_of(level)
		assert_eq(state.level, level)
		assert_true(state.revealed.size() > 0, "level %d has something seen" % level)
		assert_true(state.revealed.size() < state.map.width * state.map.height, "and something in the fog")


func test_is_the_same_game_each_time() -> void:
	var one := BenchGame.map_of(1)
	var two := BenchGame.map_of(1)
	assert_eq(one.revealed.keys(), two.revealed.keys())
	assert_eq(one.base, two.base)


func test_stays_within_the_levels_there_are() -> void:
	assert_eq(BenchGame.map_of(9).level, 3)
	assert_eq(BenchGame.map_of(0).level, 1)
