extends VectorTestCase
## What GDScript does as Dart between whole numbers, so that a ported rule
## writes it as it is: each operator below gives what the Dart VM gave in
## reference/vectors/dart_math.json. Where one parts from Dart, the last
## tests say so, and DartMath, DartBits or DartNum has the Dart one.

const MAX := 9223372036854775807
const MIN := -9223372036854775807 - 1

var _vectors := VectorFile.new("dart_math")


func test_sums_products_and_bitwise_operators_wrap_to_64_bits_alike() -> void:
	for case: Dictionary in _vectors.cases("bits"):
		var a: int = case["a"]
		var b: int = case["b"]
		var out: Dictionary = case["out"]
		var what := "%d and %d" % [a, b]
		assert_same(a + b, out["add"], what)
		assert_same(a - b, out["sub"], what)
		assert_same(a * b, out["mul"], what)
		assert_same(a & b, out["and"], what)
		assert_same(a | b, out["or"], what)
		assert_same(a ^ b, out["xor"], what)
		assert_same(-a, out["neg"], what)
		assert_same(~a, out["not"], what)
		assert_same(a & -a, out["lowestBit"], what)


func test_shifts_from_0_to_63_are_alike() -> void:
	for case: Dictionary in _vectors.cases("bits"):
		var a: int = case["a"]
		var out: Dictionary = case["out"]
		var shift: int = out["shift"]
		assert_true(shift >= 0 and shift <= 63)
		assert_same(a << shift, out["shl"], "%d << %d" % [a, shift])
		assert_same(a >> shift, out["shr"], "%d >> %d" % [a, shift])


func test_absi_is_dart_abs_and_the_smallest_int_its_own() -> void:
	for case: Dictionary in _vectors.cases("abs"):
		var a: int = case["a"]
		assert_same(absi(a), case["out"], str(a))
	assert_eq(absi(MIN), MIN)


func test_percent_is_dart_remainder() -> void:
	for case: Dictionary in _vectors.cases("intDivision"):
		var a: int = case["a"]
		var b: int = case["b"]
		var out: Dictionary = case["out"]
		assert_same(a % b, out["remainder"], "%d rem %d" % [a, b])


func test_a_division_of_whole_numbers_is_dart_truncating_one() -> void:
	# The same number as `~/`; a rule still writes DartMath.trunc_div, which
	# cannot be read as Dart's `/` and does not crash on MIN / -1.
	for case: Dictionary in _vectors.cases("intDivision"):
		var a: int = case["a"]
		var b: int = case["b"]
		var out: Dictionary = case["out"]
		@warning_ignore("integer_division")
		assert_same(a / b, out["truncDiv"], "%d ~/ %d" % [a, b])


func test_mini_maxi_and_clampi_are_dart_between_whole_numbers() -> void:
	var compared := 0
	for case: Dictionary in _vectors.cases("minMax"):
		if case["a"] is int and case["b"] is int:
			var a: int = case["a"]
			var b: int = case["b"]
			var out: Dictionary = case["out"]
			assert_same(mini(a, b), out["min"], "min %d %d" % [a, b])
			assert_same(maxi(a, b), out["max"], "max %d %d" % [a, b])
			compared += 1
	assert_eq(compared, 4)
	var clamped := 0
	for case: Dictionary in _vectors.cases("clamp"):
		if case["x"] is int and case["low"] is int and case["high"] is int and case.has("out"):
			var x: int = case["x"]
			var low: int = case["low"]
			var high: int = case["high"]
			assert_same(clampi(x, low, high), case["out"], str(case))
			clamped += 1
	assert_eq(clamped, 9)


func test_percent_is_not_dart_percent_below_zero() -> void:
	var parted := 0
	for case: Dictionary in _vectors.cases("intDivision"):
		var a: int = case["a"]
		var b: int = case["b"]
		var out: Dictionary = case["out"]
		if a % b != out["modulo"]:
			assert_true(a < 0, "%d %% %d" % [a, b])
			parted += 1
		if b > 0:
			assert_same(posmod(a, b), out["modulo"], "posmod(%d, %d)" % [a, b])
	assert_eq(parted, 96)
	assert_eq(-7 % 3, -1)
	assert_eq(posmod(-7, -3), -1)
	assert_eq(DartMath.modulo(-7, -3), 2)


func test_clampi_does_not_refuse_bounds_out_of_order() -> void:
	expect_error("DartNum.clamp(5, 10, 0)")
	assert_eq(DartNum.clamp(5, 10, 0), 0)
	assert_eq(clampi(5, 10, 0), 10)
