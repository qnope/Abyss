extends VectorTestCase
## DartSort.sort leaves a list in the order Dart's List.sort leaves it, ties
## included, with the same comparisons: every case of
## reference/vectors/dart_sort.json.

const MAX := 9223372036854775807
const MIN := -9223372036854775807 - 1

var _vectors := VectorFile.new("dart_sort")
var _comparisons: int = 0


func test_orders_ties_as_dart_with_as_many_comparisons() -> void:
	var cases := _vectors.cases("sort")
	assert_eq(cases.size(), 608)
	var longest := 0
	for case: Dictionary in cases:
		var keys := _ints(case, "keys")
		var descending: bool = case["descending"]
		var what := "%s %s, %d keys" % [case["pattern"], case.get("seed"), keys.size()]
		assert_same(_sorted_indices(keys, descending), case["out"], what)
		assert_same(_comparisons, case["comparisons"], what)
		longest = maxi(longest, keys.size())
	assert_eq(longest, 500)


func test_sorts_whole_numbers_as_dart_without_comparator() -> void:
	for case: Dictionary in _vectors.cases("natural"):
		var values := _ints(case, "values")
		DartSort.sort(values, DartSort.compare_ints)
		assert_same(values, _ints(case, "out"), str(case["pattern"]))


func test_godot_sorts_whole_numbers_alike_since_equal_ones_cannot_be_told() -> void:
	for case: Dictionary in _vectors.cases("natural"):
		var values := _ints(case, "values")
		values.sort()
		assert_same(values, _ints(case, "out"), str(case["pattern"]))


func test_keeps_the_order_of_equal_elements_up_to_33() -> void:
	var posts: Array = []
	for index: int in 33:
		posts.append({"level": index % 3, "name": "post %d" % index})
	var expected: Array = []
	for level: int in 3:
		expected.append_array(posts.filter(func(post: Dictionary) -> bool: return post["level"] == level))
	DartSort.sort(posts, _by_level)
	assert_eq(posts, expected)


func test_does_not_keep_it_beyond_33_as_dart_does_not() -> void:
	var equal: Array[int] = []
	equal.resize(34)
	var order := _sorted_indices(equal, false)
	assert_ne(order, range(34))
	order.sort()
	assert_eq(order, range(34))


func test_sorts_a_typed_list_in_place() -> void:
	var levels: Array[int] = [3, 1, 2]
	DartSort.sort(levels, DartSort.compare_ints)
	assert_eq(levels, [1, 2, 3] as Array[int])


func test_leaves_an_empty_list_and_a_single_element_alone() -> void:
	var nothing: Array = []
	var alone: Array = ["kernel"]
	DartSort.sort(nothing, _by_level)
	DartSort.sort(alone, _by_level)
	assert_eq(nothing, [])
	assert_eq(alone, ["kernel"])
	assert_eq(_comparisons, 0)


func test_compares_whole_numbers_as_dart_compare_to() -> void:
	assert_eq(DartSort.compare_ints(1, 2), -1)
	assert_eq(DartSort.compare_ints(2, 1), 1)
	assert_eq(DartSort.compare_ints(7, 7), 0)
	assert_eq(DartSort.compare_ints(MIN, MAX), -1)
	assert_eq(DartSort.compare_ints(MAX, MIN), 1)


func test_follows_the_sdk_even_where_a_comparator_changes_its_mind() -> void:
	# The SDK's last loop has a branch no honest comparator reaches (see
	# reference/vectors/README.md). This one tells the truth 68 times, then
	# the opposite: the order below is what the SDK's statements give, by
	# the specification test/tool/vectors/spec/dart_sort_spec.dart.
	var keys: Array[int] = [
		1, 0, 0, 1, 0, 2, 1, 1, 1, 1, 0, 0, 0, 2, 2, 2, 0, 2, 1, 2, 0, 2, 2, 0, 0, 2, 1,
		0, 2, 0, 0, 1, 0, 0,
	]
	var order := range(keys.size())
	DartSort.sort(order, func(a: int, b: int) -> int:
		_comparisons += 1
		var honest := DartSort.compare_ints(keys[a], keys[b])
		return honest if _comparisons <= 68 else -honest)
	assert_eq(order, [
		16, 1, 2, 4, 11, 10, 12, 26, 20, 9, 3, 0, 6, 7, 18, 8, 29, 27, 24, 23, 33, 19, 22,
		17, 5, 25, 15, 14, 28, 13, 21, 31, 32, 30,
	])
	assert_eq(_comparisons, 147)


## The indices of the keys as DartSort orders them, counting in _comparisons
## the calls of the comparator.
func _sorted_indices(keys: Array[int], descending: bool) -> Array:
	var order := range(keys.size())
	_comparisons = 0
	DartSort.sort(order, func(a: int, b: int) -> int:
		_comparisons += 1
		if descending:
			return DartSort.compare_ints(keys[b], keys[a])
		return DartSort.compare_ints(keys[a], keys[b]))
	return order


func _by_level(a: Dictionary, b: Dictionary) -> int:
	_comparisons += 1
	var level_a: int = a["level"]
	var level_b: int = b["level"]
	return DartSort.compare_ints(level_a, level_b)


func _ints(case: Dictionary, key: String) -> Array[int]:
	var values: Array = case[key]
	var typed: Array[int] = []
	typed.assign(values)
	return typed
