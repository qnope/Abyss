extends VectorTestCase
## DartMath divides and rounds as Dart does where GDScript does not: the
## sections intDivision, divisionByZero, rounding, notFinite, quotient and
## pow of reference/vectors/dart_math.json, and the costs of buildings.json.

const MAX := 9223372036854775807
const MIN := -9223372036854775807 - 1

var _vectors := VectorFile.new("dart_math")


func test_divides_whole_numbers_as_dart() -> void:
	var cases := _vectors.cases("intDivision")
	assert_eq(cases.size(), 19 * 14, "dividends times divisors")
	for case: Dictionary in cases:
		var a: int = case["a"]
		var b: int = case["b"]
		var out: Dictionary = case["out"]
		assert_same(DartMath.trunc_div(a, b), out["truncDiv"], "%d ~/ %d" % [a, b])
		assert_same(DartMath.modulo(a, b), out["modulo"], "%d %% %d" % [a, b])


func test_a_modulo_is_never_negative() -> void:
	assert_eq(DartMath.modulo(-7, 3), 2)
	assert_eq(DartMath.modulo(-7, -3), 2)
	assert_eq(DartMath.modulo(7, -3), 1)
	assert_eq(DartMath.modulo(-7, MIN), MAX - 6)
	assert_eq(DartMath.modulo(MIN, MAX), MAX - 1)


func test_divides_the_smallest_number_by_minus_one_where_godot_crashes() -> void:
	assert_eq(DartMath.trunc_div(MIN, -1), MIN)
	assert_eq(DartMath.modulo(MIN, -1), 0)
	assert_eq(DartMath.trunc_div(MAX, -1), -MAX)


func test_refuses_to_divide_by_zero() -> void:
	for case: Dictionary in _vectors.cases("divisionByZero"):
		var a: int = case["a"]
		assert_eq(case["truncDivThrows"], true)
		expect_error("DartMath.trunc_div(%d, 0)" % a)
		assert_eq(DartMath.trunc_div(a, 0), 0)
		assert_eq(case["moduloThrows"], true)
		expect_error("DartMath.modulo(%d, 0)" % a)
		assert_eq(DartMath.modulo(a, 0), 0)


func test_a_quotient_of_whole_numbers_is_a_float() -> void:
	for case: Dictionary in _vectors.cases("quotient"):
		var a: int = case["a"]
		var b: int = case["b"]
		var out: Dictionary = case["out"]
		var what := "%d / %d" % [a, b]
		var quotient := DartMath.quotient(a, b)
		assert_same(quotient, out["quotient"], what)
		if out["round"] != null:
			assert_same(DartMath.round(quotient), out["round"], what)
			assert_same(DartMath.floor(quotient), out["floor"], what)
			assert_same(DartMath.ceil(quotient), out["ceil"], what)
		else:
			assert_false(is_finite(quotient), what)


func test_rounds_as_dart_and_stops_at_64_bits() -> void:
	var cases := _vectors.cases("rounding")
	assert_eq(cases.size(), 60)
	for case: Dictionary in cases:
		var x: float = case["x"]
		var out: Dictionary = case["out"]
		var what := VectorValues.bits_of(x)
		assert_same(DartMath.round(x), out["round"], what)
		assert_same(DartMath.floor(x), out["floor"], what)
		assert_same(DartMath.ceil(x), out["ceil"], what)
		assert_same(DartMath.truncate(x), out["truncate"], what)
		assert_same(DartMath.to_int(x), out["toInt"], what)


func test_refuses_to_round_what_is_not_finite() -> void:
	var cases := _vectors.cases("notFinite")
	assert_eq(cases.size(), 3)
	for case: Dictionary in cases:
		var x: float = case["x"]
		assert_eq(case["throws"], true)
		for rounding: Callable in [
			DartMath.round, DartMath.floor, DartMath.ceil, DartMath.truncate, DartMath.to_int,
		]:
			expect_error("DartMath: %s has no whole number" % x)
			assert_eq(rounding.call(x), 0)


func test_raises_whole_numbers_as_dart_pow_wrapping() -> void:
	var raised := 0
	for case: Dictionary in _vectors.cases("pow"):
		if case["base"] is int and case["exponent"] is int and case["exponent"] >= 0:
			var base: int = case["base"]
			var exponent: int = case["exponent"]
			assert_same(DartMath.int_pow(base, exponent), case["out"], str(case))
			raised += 1
	assert_eq(raised, 7)


func test_refuses_a_negative_exponent_which_gives_dart_a_double() -> void:
	expect_error("DartMath.int_pow(2, -1)")
	assert_eq(DartMath.int_pow(2, -1), 0)


func test_grows_a_cost_by_8_fifths_a_level_without_pow() -> void:
	var cases := VectorFile.new("buildings").cases("exponentialCost")
	assert_eq(cases.size(), 90)
	for case: Dictionary in cases:
		var step: int = case["step"]
		var bases: Dictionary = case["base"]
		var grown := {}
		for resource: String in bases:
			var base: int = bases[resource]
			grown[resource] = DartMath.round_times_power(base, 8, 5, step)
		assert_same(grown, case["out"], str(case))


func test_rounds_a_power_half_away_from_zero_on_both_sides() -> void:
	assert_eq(DartMath.round_times_power(1, 3, 2, 1), 2)
	assert_eq(DartMath.round_times_power(-1, 3, 2, 1), -2)
	assert_eq(DartMath.round_times_power(-60, 8, 5, 2), -154)
	assert_eq(DartMath.round_times_power(7, 8, 5, 0), 7)
	assert_eq(DartMath.round_times_power(0, 8, 5, 9), 0)


func test_says_when_a_cost_leaves_what_floats_and_whole_numbers_agree_on() -> void:
	assert_eq(DartMath.round_times_power(3000000, 8, 5, 9), 206158430)
	expect_error("DartMath.round_times_power(250, 8, 5, 14)")
	assert_eq(DartMath.round_times_power(250, 8, 5, 14), 180144)
	expect_error("DartMath.round_times_power(-250, 8, 5, 14)")
	assert_eq(DartMath.round_times_power(-250, 8, 5, 14), -180144)
