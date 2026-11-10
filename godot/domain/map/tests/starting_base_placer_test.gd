extends TestCase
## Where the other players start. Dart has no test file for
## starting_base_placer.dart: its bases are held by
## map_generator_players_test.dart and by the section startingBases of the
## vectors. Not in a Dart file, then.


func test_a_lone_player_keeps_its_base_and_draws_nothing() -> void:
	var random := DartRandom.new(3)
	var first := GridPosition.new(9, 11)
	var bases := StartingBasePlacer.place(20, first, 1, random)
	assert_eq(bases, [first])
	assert_eq(random.next_int(1000), DartRandom.new(3).next_int(1000))


func test_each_base_is_drawn_among_the_cells_farthest_from_the_others() -> void:
	for seed_of_map: int in 20:
		var bases := StartingBasePlacer.place(
			26, GridPosition.new(13, 12), 6, DartRandom.new(seed_of_map)
		)
		assert_eq(bases.size(), 6)
		var keys := GridPosition.keys(bases)
		for index: int in keys.size():
			var cell := keys[index]
			if index > 0:
				assert_ne(cell, Vector2i(13, 13), "the centre is never taken")
				assert_true(cell.x >= 2 and cell.x < 24 and cell.y >= 2 and cell.y < 24, str(cell))
			for other: int in index:
				var apart := MapSamples.chebyshev(cell.x, cell.y, keys[other].x, keys[other].y)
				assert_true(apart >= 5, "%s and %s" % [cell, keys[other]])


func test_one_draw_per_base_after_the_first() -> void:
	var random := DartRandom.new(8)
	StartingBasePlacer.place(20, GridPosition.new(10, 10), 3, random)
	var twin := DartRandom.new(8)
	twin.next_int(7)
	twin.next_int(7)
	# Whatever the bound, a draw below 2^32 moves the generator once.
	assert_eq(random.next_int(64), twin.next_int(64))


## Dart throws on a map with no cell inside its margins: the port logs an
## error and places no more base.
func test_a_map_too_small_for_a_second_base_places_none() -> void:
	expect_error("StartingBasePlacer.place: no cell for a base on a map of 4")
	var bases := StartingBasePlacer.place(4, GridPosition.new(1, 1), 2, DartRandom.new(1))
	assert_eq(bases.size(), 1)
	assert_eq(StartingBasePlacer.place(4, GridPosition.new(1, 1), 1, DartRandom.new(1)).size(), 1)
