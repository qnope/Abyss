extends TestCase
## TestValues compares values exactly, deep through arrays and dictionaries.


func test_equal_is_exact_on_types() -> void:
	assert_true(TestValues.equal(1, 1))
	assert_false(TestValues.equal(1, 1.0))
	assert_false(TestValues.equal("1", 1))
	assert_false(TestValues.equal(null, 0))


func test_equal_reads_a_string_name_as_its_text() -> void:
	assert_true(TestValues.equal(&"Title", "Title"))


func test_equal_goes_deep_through_arrays_and_dictionaries() -> void:
	assert_true(TestValues.equal([1, {"a": [2.0]}], [1, {"a": [2.0]}]))
	assert_false(TestValues.equal([1, {"a": [2.0]}], [1, {"a": [2]}]))
	assert_false(TestValues.equal([1], [1, 2]))
	assert_false(TestValues.equal({"a": 1}, {"b": 1}))


func test_equal_ignores_the_element_type_of_an_array() -> void:
	var typed: Array[int] = [1, 2]
	assert_true(TestValues.equal(typed, [1, 2]))


func test_describe_quotes_strings_inside_containers() -> void:
	assert_eq(TestValues.describe(["a", 1, {"k": &"n"}]), '["a", 1, {"k": &"n"}]')
	assert_eq(TestValues.describe(null), "null")
	assert_eq(TestValues.describe(2.0), "2.0")


func test_contains_looks_into_strings_arrays_dictionaries_and_packed_arrays() -> void:
	assert_true(TestValues.contains("deep sea", "sea"))
	assert_true(TestValues.contains([1, [2]], [2]))
	assert_true(TestValues.contains({"key": 1}, "key"))
	assert_true(TestValues.contains(PackedStringArray(["a"]), "a"))
	assert_false(TestValues.contains([1.0], 1))
	assert_false(TestValues.contains(12, 1))
