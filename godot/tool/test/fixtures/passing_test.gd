extends TestCase
## A fixture whose three tests pass.


func test_adds() -> void:
	assert_eq(2 + 2, 4)


func test_compares_arrays() -> void:
	assert_eq([1, {"a": [2]}], [1, {"a": [2]}])


func test_finds_an_item() -> void:
	assert_has(["coral", "ore"], "ore")
