extends TestCase
## A test driven by vectors compares what the port answers with the file to
## the last bit, checked on a probe instance.

const NEGATIVE_ZERO := "8000000000000000"

var _probe: VectorTestCase


func before_each() -> void:
	_probe = VectorTestCase.new()


func test_the_same_values_pass() -> void:
	_probe.assert_same(3, 3)
	_probe.assert_same([1.5, {"out": NAN}], [1.5, {"out": NAN}])
	_probe.assert_same(
		VectorValues.float_of(NEGATIVE_ZERO), VectorValues.float_of(NEGATIVE_ZERO)
	)
	assert_eq(_probe.failures(), PackedStringArray())


func test_an_int_is_not_a_float() -> void:
	_probe.assert_same(1.0, 1, "max")
	assert_eq(
		_probe.failures(), PackedStringArray(['max: expected 1, got "d:3ff0000000000000"'])
	)


func test_a_zero_is_not_the_other() -> void:
	_probe.assert_same([VectorValues.float_of(NEGATIVE_ZERO)], [0.0])
	assert_eq(
		_probe.failures(),
		PackedStringArray(['expected ["d:0000000000000000"], got ["d:8000000000000000"]'])
	)


func test_the_last_bit_counts() -> void:
	_probe.assert_same(0.1 + 0.2, 0.3)
	assert_eq(
		_probe.failures(),
		PackedStringArray(['expected "d:3fd3333333333333", got "d:3fd3333333333334"'])
	)
