extends VectorTestCase
## DartRandom draws what the Dart VM's Random(seed) draws, to the last bit:
## every case of reference/vectors/dart_random.json.

const POW32 := 4294967296
## The only seed Dart's mix turns into 0, see tool/vectors/language.
const MIXED_TO_ZERO := 9223367638806167551

var _vectors := VectorFile.new("dart_random")


func test_draws_the_whole_numbers_of_dart() -> void:
	var cases := _vectors.cases("nextInt")
	assert_eq(cases.size(), 35 * 37, "seeds times bounds")
	for case: Dictionary in cases:
		var random := _seeded(case)
		var bound: int = case["max"]
		var drawn: Array = []
		for _draw: int in 6:
			drawn.append(random.next_int(bound))
		assert_same(drawn, case["out"], _inputs(case))


func test_draws_the_doubles_of_dart_bit_for_bit() -> void:
	for case: Dictionary in _vectors.cases("nextDouble"):
		var random := _seeded(case)
		var drawn: Array = []
		for _draw: int in 12:
			drawn.append(random.next_double())
		assert_same(drawn, case["out"], _inputs(case))


func test_draws_the_booleans_of_dart() -> void:
	for case: Dictionary in _vectors.cases("nextBool"):
		var random := _seeded(case)
		var drawn: Array = []
		for _draw: int in 40:
			drawn.append(random.next_bool())
		assert_same(drawn, case["out"], _inputs(case))


func test_mixes_the_three_draws_on_one_state() -> void:
	for case: Dictionary in _vectors.cases("mixed"):
		assert_same(_called(_seeded(case), case), case["out"], _inputs(case))


func test_stays_in_step_after_many_draws() -> void:
	for case: Dictionary in _vectors.cases("afterMany"):
		var random := _seeded(case)
		var skip: int = case["skip"]
		var bound: int = case["max"]
		for _draw: int in skip:
			random.next_int(POW32)
		var drawn: Array = []
		for _draw: int in 6:
			drawn.append(random.next_int(bound))
		assert_same(drawn, case["out"], _inputs(case))


func test_replaces_the_seed_that_mixes_to_zero() -> void:
	var seeds := {}
	for case: Dictionary in _vectors.cases("nextDouble"):
		seeds[case["seed"]] = true
	assert_has(seeds, MIXED_TO_ZERO)
	assert_ne(DartRandom.new(MIXED_TO_ZERO).next_int(POW32), 0)


func test_refuses_a_bound_out_of_range_without_drawing() -> void:
	var cases := _vectors.cases("refused")
	assert_eq(cases.size(), 4)
	for case: Dictionary in cases:
		assert_eq(case["throws"], true)
		var bound: int = case["max"]
		var random := _seeded(case)
		expect_error("DartRandom.next_int(%d)" % bound)
		assert_eq(random.next_int(bound), DartRandom.REFUSED, _inputs(case))
		assert_eq(random.next_int(POW32), _seeded(case).next_int(POW32), "nothing was drawn")


func test_a_refused_draw_is_no_draw_anyone_could_use() -> void:
	assert_eq(DartRandom.REFUSED, -1)


func test_takes_the_largest_bound_and_the_smallest() -> void:
	var random := DartRandom.new(1)
	assert_eq(random.next_int(1), 0)
	var drawn := random.next_int(POW32)
	assert_true(drawn >= 0 and drawn < POW32, str(drawn))


func test_remembers_its_seed_as_seeded_random() -> void:
	var cases := _vectors.cases("seededRandom")
	assert_eq(cases.size(), 5)
	for case: Dictionary in cases:
		var random := _seeded(case)
		assert_same(random.initial_seed, case["keptSeed"], _inputs(case))
		assert_same(_called(random, case), case["out"], _inputs(case))
		assert_same(random.initial_seed, case["keptSeed"], "after the draws")


func test_two_generators_of_one_seed_draw_the_same() -> void:
	var first := DartRandom.new(20261110)
	var second := DartRandom.new(20261110)
	for _draw: int in 50:
		assert_eq(first.next_int(1000), second.next_int(1000))


func _seeded(case: Dictionary) -> DartRandom:
	var seed_of_case: int = case["seed"]
	return DartRandom.new(seed_of_case)


## One call per entry of "calls": next_int for a number, else next_double
## for "double" and next_bool for "bool".
func _called(random: DartRandom, case: Dictionary) -> Array:
	var calls: Array = case["calls"]
	var drawn: Array = []
	for call: Variant in calls:
		if call is int:
			var bound: int = call
			drawn.append(random.next_int(bound))
		elif call == "double":
			drawn.append(random.next_double())
		else:
			drawn.append(random.next_bool())
	return drawn


func _inputs(case: Dictionary) -> String:
	return "seed %s, max %s" % [case["seed"], case.get("max", "-")]
