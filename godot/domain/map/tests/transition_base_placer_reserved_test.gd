extends TestCase
## test/domain/map/transition_base_placer_reserved_test.dart: the cells no
## post may take.

const WIDTH := 20
const HEIGHT := 20


func test_reserved_indices_reserved_indices_are_never_chosen_for_placement() -> void:
	# First run without reservation to find where failles land.
	var baseline := _placed(1, 99, {})
	var baseline_positions: Dictionary[int, bool] = {}
	for index: int in MapSamples.transition_base_indices(baseline):
		baseline_positions[index] = true
	assert_eq(baseline_positions.size(), 4)

	# Re-run with those positions reserved.
	var new_positions := MapSamples.transition_base_indices(_placed(1, 99, baseline_positions))
	assert_eq(new_positions.size(), 4)
	for index: int in new_positions:
		assert_false(baseline_positions.has(index), "No post should land on %d" % index)


## Not in the Dart file: a post with no cell left is not placed, and draws
## no die; the others still are.
func test_a_post_without_any_cell_left_is_not_placed() -> void:
	var top_left: Dictionary[int, bool] = {}
	var everything: Dictionary[int, bool] = {}
	for index: int in WIDTH * HEIGHT:
		everything[index] = true
		if index % WIDTH < 10 and index < 10 * WIDTH:
			top_left[index] = true
	var names: Array = []
	var cells := _placed(1, 99, top_left)
	for index: int in MapSamples.transition_base_indices(cells):
		names.append(cells[index].transition_base.name)
	names.sort()
	assert_eq(names, ["faille:1", "faille:2", "faille:3"])
	var random := DartRandom.new(5)
	var none := MapSamples.plain_cells(WIDTH * HEIGHT)
	TransitionBasePlacer.place(none, WIDTH, HEIGHT, 10, 10, 2, random, everything)
	assert_eq(MapSamples.transition_base_indices(none), [])
	assert_eq(random.next_int(1000), DartRandom.new(5).next_int(1000), "no die drawn")


func _placed(level: int, seed_of_map: int, reserved: Dictionary[int, bool]) -> Array[MapCell]:
	var cells := MapSamples.plain_cells(WIDTH * HEIGHT)
	TransitionBasePlacer.place(
		cells, WIDTH, HEIGHT, 10, 10, level, DartRandom.new(seed_of_map), reserved
	)
	return cells
