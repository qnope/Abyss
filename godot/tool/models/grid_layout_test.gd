extends TestCase
## The layout of the review board's grid: variants that never repeat along a
## row or a column, quarter turns, and a ragged patch seen off the middle.

const GridLayout := preload("res://tool/models/grid_layout.gd")


func test_no_cell_has_the_variant_of_its_left_or_upper_neighbour() -> void:
	var variants := GridLayout.variants(10, 10, 3)
	assert_eq(variants.size(), 100)
	for y in 10:
		for x in 10:
			var here := variants[y * 10 + x]
			assert_true(here >= 0 and here < 3)
			if x > 0:
				assert_ne(here, variants[y * 10 + x - 1])
			if y > 0:
				assert_ne(here, variants[(y - 1) * 10 + x])


func test_every_variant_is_used() -> void:
	var used := {}
	for variant in GridLayout.variants(10, 10, 3):
		used[variant] = true
	assert_eq(used.size(), 3)


func test_two_variants_alternate_and_one_repeats() -> void:
	var two := GridLayout.variants(4, 1, 2)
	assert_ne(two[0], two[1])
	assert_eq(two[0], two[2])
	assert_eq(GridLayout.variants(3, 3, 1), PackedInt32Array([0, 0, 0, 0, 0, 0, 0, 0, 0]))


func test_the_same_seed_gives_the_same_board() -> void:
	assert_eq(GridLayout.variants(6, 6, 3), GridLayout.variants(6, 6, 3))
	assert_ne(GridLayout.variants(6, 6, 3, 1), GridLayout.variants(6, 6, 3, 2))


func test_the_turns_are_quarters_and_all_of_them_appear() -> void:
	var turns := GridLayout.turns(10, 10)
	assert_eq(turns.size(), 100)
	var used := {}
	for turn in turns:
		assert_true(turn >= 0 and turn < 4)
		used[turn] = true
	assert_eq(used.size(), 4)


func test_the_seen_patch_is_a_part_of_the_board_off_its_middle() -> void:
	var seen := 0
	for y in 10:
		for x in 10:
			if GridLayout.seen(x, y, 10):
				seen += 1
	assert_true(seen > 15 and seen < 50, "a patch, not all the board")
	assert_true(GridLayout.seen(4, 6, 10))
	assert_false(GridLayout.seen(0, 0, 10))
	assert_false(GridLayout.seen(9, 0, 10))
