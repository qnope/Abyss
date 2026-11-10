extends VectorTestCase
## DartBits shifts and counts bits as Dart does: the section bits of
## reference/vectors/dart_math.json, and the shifts of 64 and more, where
## GDScript goes its own way.

const MAX := 9223372036854775807
const MIN := -9223372036854775807 - 1

var _vectors := VectorFile.new("dart_math")


func test_shifts_as_dart_from_0_to_63() -> void:
	var cases := _vectors.cases("bits")
	assert_eq(cases.size(), 26)
	for case: Dictionary in cases:
		var a: int = case["a"]
		var out: Dictionary = case["out"]
		var shift: int = out["shift"]
		var what := "%d by %d" % [a, shift]
		assert_same(DartBits.shl(a, shift), out["shl"], what)
		assert_same(DartBits.shr(a, shift), out["shr"], what)
		assert_same(DartBits.ushr(a, shift), out["ushr"], what)


func test_counts_the_bits_of_a_number_as_dart_bit_length() -> void:
	for case: Dictionary in _vectors.cases("bits"):
		var a: int = case["a"]
		var out: Dictionary = case["out"]
		assert_same(DartBits.bit_length(a), out["bitLength"], str(a))
	assert_eq(DartBits.bit_length(255), 8)
	assert_eq(DartBits.bit_length(256), 9)
	assert_eq(DartBits.bit_length(-256), 8)
	assert_eq(DartBits.bit_length(-257), 9)


func test_a_shift_of_64_or_more_leaves_no_bit_where_godot_wraps_it() -> void:
	assert_eq(DartBits.shl(1, 64), 0)
	assert_eq(DartBits.shl(-1, 65), 0)
	assert_eq(DartBits.shr(MAX, 64), 0)
	assert_eq(DartBits.shr(-1, 64), -1)
	assert_eq(DartBits.shr(MIN, 1000), -1)
	assert_eq(DartBits.ushr(-1, 64), 0)
	assert_eq(DartBits.ushr(MIN, 1000), 0)


func test_a_shift_of_0_keeps_the_number() -> void:
	for a: int in [0, 1, -1, MAX, MIN]:
		assert_eq(DartBits.shl(a, 0), a)
		assert_eq(DartBits.shr(a, 0), a)
		assert_eq(DartBits.ushr(a, 0), a)


func test_an_unsigned_shift_fills_with_zeros() -> void:
	assert_eq(DartBits.ushr(-1, 1), MAX)
	assert_eq(DartBits.ushr(MIN, 63), 1)
	assert_eq(DartBits.ushr(-1, 32), 0xFFFFFFFF)
	assert_eq(DartBits.shr(-1, 32), -1)


func test_refuses_a_negative_shift_as_dart_throws() -> void:
	expect_error("DartBits.shl(1, -1)")
	assert_eq(DartBits.shl(1, -1), 0)
	expect_error("DartBits.shr(8, -2)")
	assert_eq(DartBits.shr(8, -2), 0)
	expect_error("DartBits.ushr(-8, -3)")
	assert_eq(DartBits.ushr(-8, -3), 0)
