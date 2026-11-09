extends TestCase
## Each assertion of TestCase records a readable failure, checked on a probe
## instance so that this file's own tests stay green.

var _probe: TestCase


func before_each() -> void:
	_probe = TestCase.new()


func test_records_nothing_when_assertions_hold() -> void:
	_probe.assert_true(true)
	_probe.assert_false(false)
	_probe.assert_eq({"a": [1, 2]}, {"a": [1, 2]})
	_probe.assert_ne(1, 2)
	_probe.assert_almost_eq(0.1 + 0.2, 0.3, 0.0001)
	_probe.assert_null(null)
	_probe.assert_not_null(0)
	_probe.assert_has({"key": 1}, "key")
	assert_eq(_probe.failures(), PackedStringArray())


func test_assert_true_and_false() -> void:
	_probe.assert_true(false)
	_probe.assert_false(true, "flag")
	assert_eq(
		_probe.failures(),
		PackedStringArray(["expected true, got false", "flag: expected false, got true"])
	)


func test_assert_eq_shows_both_values() -> void:
	_probe.assert_eq("1", 1)
	_probe.assert_eq([1, [2]], [1, [3]], "rows")
	assert_eq(
		_probe.failures(),
		PackedStringArray(['expected 1, got "1"', "rows: expected [1, [3]], got [1, [2]]"])
	)


func test_assert_ne() -> void:
	_probe.assert_ne([1], [1])
	assert_eq(_probe.failures(), PackedStringArray(["expected anything but [1]"]))


func test_assert_almost_eq() -> void:
	_probe.assert_almost_eq(1.5, 1.0, 0.25)
	assert_eq(_probe.failures(), PackedStringArray(["expected 1.0 ± 0.25, got 1.5"]))


func test_assert_null_and_not_null() -> void:
	_probe.assert_null("x")
	_probe.assert_not_null(null)
	assert_eq(
		_probe.failures(),
		PackedStringArray(['expected null, got "x"', "expected a value, got null"])
	)


func test_assert_has() -> void:
	_probe.assert_has([1, 2], 3)
	assert_eq(_probe.failures(), PackedStringArray(["expected [1, 2] to contain 3"]))


func test_fail_records_its_message() -> void:
	_probe.fail("broken")
	assert_eq(_probe.failures(), PackedStringArray(["broken"]))
