extends TestCase
## test/domain/map/transition_base_placer_test.dart: the Failles of level 1
## and the Cheminées of level 2.

const WIDTH := 20
const HEIGHT := 20
const BASE_X := 10
const BASE_Y := 10
const FAILLE := TransitionBaseType.Value.FAILLE
const CHEMINEE := TransitionBaseType.Value.CHEMINEE


func test_level_1_places_exactly_4_failles() -> void:
	for seed_of_map: int in 20:
		var cells := _placed(1, seed_of_map)
		var indices := MapSamples.transition_base_indices(cells)
		assert_eq(indices.size(), 4, "seed=%d" % seed_of_map)
		for i: int in indices:
			assert_eq(cells[i].transition_base.type, FAILLE)


func test_level_1_failles_use_expected_names() -> void:
	assert_eq(_names(_placed(1, 42)), _codes(FAILLE))


func test_level_1_base_cell_never_has_a_transition_base() -> void:
	for seed_of_map: int in 20:
		var base := _placed(1, seed_of_map)[BASE_Y * WIDTH + BASE_X]
		assert_ne(base.content, CellContentType.Value.TRANSITION_BASE, "seed=%d" % seed_of_map)


func test_level_2_places_exactly_3_cheminees() -> void:
	for seed_of_map: int in 20:
		var cells := _placed(2, seed_of_map)
		var indices := MapSamples.transition_base_indices(cells)
		assert_eq(indices.size(), 3, "seed=%d" % seed_of_map)
		for i: int in indices:
			assert_eq(cells[i].transition_base.type, CHEMINEE)


func test_level_2_cheminees_use_expected_names() -> void:
	assert_eq(_names(_placed(2, 42)), _codes(CHEMINEE))


func test_level_3_and_more_places_nothing() -> void:
	for level: int in [3, 4, 5]:
		var random := DartRandom.new(42)
		var cells := MapSamples.plain_cells(WIDTH * HEIGHT)
		TransitionBasePlacer.place(cells, WIDTH, HEIGHT, BASE_X, BASE_Y, level, random)
		assert_eq(MapSamples.transition_base_indices(cells), [], "level=%d" % level)
		assert_eq(random.next_int(1000), DartRandom.new(42).next_int(1000), "no die drawn")


func test_determinism_same_seed_produces_same_placement() -> void:
	var a := _placed(1, 77)
	var b := _placed(1, 77)
	for i: int in a.size():
		assert_eq(a[i].content, b[i].content, "idx=%d" % i)
		var name_a: Variant = null if a[i].transition_base == null else a[i].transition_base.name
		var name_b: Variant = null if b[i].transition_base == null else b[i].transition_base.name
		assert_eq(name_a, name_b, "idx=%d" % i)


func _placed(level: int, seed_of_map: int) -> Array[MapCell]:
	var cells := MapSamples.plain_cells(WIDTH * HEIGHT)
	TransitionBasePlacer.place(
		cells, WIDTH, HEIGHT, BASE_X, BASE_Y, level, DartRandom.new(seed_of_map)
	)
	return cells


## The names of the posts placed, as a set.
func _names(cells: Array[MapCell]) -> Dictionary[String, bool]:
	var names: Dictionary[String, bool] = {}
	for i: int in MapSamples.transition_base_indices(cells):
		names[cells[i].transition_base.name] = true
	return names


## The codes of every name of the type, as a set.
func _codes(type: TransitionBaseType.Value) -> Dictionary[String, bool]:
	var codes: Dictionary[String, bool] = {}
	for name: TransitionBaseName in TransitionBaseName.all_of(type):
		codes[name.code()] = true
	return codes
