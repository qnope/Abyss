extends TestCase
## A fixture with one passing test and two failing ones.


func test_passes() -> void:
	assert_true(true)


func test_adds_wrongly() -> void:
	assert_eq(2 + 3, 4, "the sum")


func test_fails_twice() -> void:
	assert_null(1)
	fail("on purpose")
