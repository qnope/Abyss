extends VectorTestCase
## DartRandom.shuffle orders a list as Dart's List.shuffle(random) does, with
## the same draws: every case of reference/vectors/dart_shuffle.json.

const POW32 := 4294967296

var _vectors := VectorFile.new("dart_shuffle")


func test_shuffles_as_dart_and_leaves_the_generator_where_dart_does() -> void:
	var cases := _vectors.cases("shuffle")
	assert_eq(cases.size(), 18 * 7, "lengths times seeds")
	for case: Dictionary in cases:
		var random := _seeded(case)
		var list := _counting(case)
		DartRandom.shuffle(list, random)
		assert_same(list, case["out"], _inputs(case))
		assert_same(random.next_int(POW32), case["next"], _inputs(case))


func test_shuffles_two_lists_in_a_row_on_one_generator() -> void:
	for case: Dictionary in _vectors.cases("twice"):
		var random := _seeded(case)
		var first := _counting(case)
		var second := _counting(case)
		DartRandom.shuffle(first, random)
		DartRandom.shuffle(second, random)
		assert_same([first, second], case["out"], _inputs(case))


func test_draws_nothing_for_a_list_of_no_more_than_one_element() -> void:
	for length: int in 2:
		var random := DartRandom.new(42)
		DartRandom.shuffle(range(length), random)
		assert_eq(random.next_int(POW32), DartRandom.new(42).next_int(POW32))


func test_shuffles_a_typed_list_in_place() -> void:
	var names: Array[String] = ["scout", "harpoonist", "guardian", "dome breaker"]
	var numbers := range(4)
	DartRandom.shuffle(names, DartRandom.new(7))
	DartRandom.shuffle(numbers, DartRandom.new(7))
	var expected: Array[String] = []
	for index: int in numbers:
		expected.append(["scout", "harpoonist", "guardian", "dome breaker"][index])
	assert_eq(names, expected)
	assert_ne(numbers, range(4))


func _seeded(case: Dictionary) -> DartRandom:
	var seed_of_case: int = case["seed"]
	return DartRandom.new(seed_of_case)


## 0 to length - 1, as List.generate(length, (i) => i).
func _counting(case: Dictionary) -> Array:
	var length: int = case["length"]
	return range(length)


func _inputs(case: Dictionary) -> String:
	return "seed %s, length %s" % [case["seed"], case["length"]]
