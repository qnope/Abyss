extends VectorTestCase
## DartNum picks between an int and a float the operand Dart picks: the
## sections minMax and clamp of reference/vectors/dart_math.json, and the
## order of `compareTo` as the SDK's double.dart and integers.dart give it.

const MAX := 9223372036854775807
const MIN := -9223372036854775807 - 1
const BEYOND_EXACT := 9007199254740993

var _vectors := VectorFile.new("dart_math")
var _negative_zero := VectorValues.float_of("8000000000000000")
var _zero := VectorValues.float_of("0000000000000000")


func test_min_and_max_return_the_operand_dart_returns() -> void:
	var cases := _vectors.cases("minMax")
	assert_eq(cases.size(), 16)
	for case: Dictionary in cases:
		var out: Dictionary = case["out"]
		var what := str(VectorValues.encode([case["a"], case["b"]]))
		assert_same(DartNum.min(case["a"], case["b"]), out["min"], "min " + what)
		assert_same(DartNum.max(case["a"], case["b"]), out["max"], "max " + what)


func test_a_nan_wins_on_either_side() -> void:
	assert_same(DartNum.min(1, NAN), NAN)
	assert_same(DartNum.max(1, NAN), NAN)
	assert_same(DartNum.min(1.5, NAN), NAN)
	assert_same(DartNum.max(NAN, 1.5), NAN)
	assert_same(DartNum.min(_zero, NAN), NAN)
	assert_same(DartNum.max(_zero, NAN), NAN)


func test_clamp_returns_the_operand_dart_returns() -> void:
	var cases := _vectors.cases("clamp")
	assert_eq(cases.size(), 14)
	for case: Dictionary in cases:
		var what := str(VectorValues.encode([case["x"], case["low"], case["high"]]))
		if case.has("throws"):
			expect_error("DartNum.clamp(5, 10, 0)")
			assert_same(DartNum.clamp(case["x"], case["low"], case["high"]), 0, what)
		else:
			assert_same(DartNum.clamp(case["x"], case["low"], case["high"]), case["out"], what)


func test_clamp_refuses_bounds_out_of_order_whatever_their_type() -> void:
	expect_error("DartNum.clamp(0.5, 1.0, 0)")
	assert_same(DartNum.clamp(0.5, 1.0, 0), 0)


func test_clamp_between_floats_and_with_a_nan() -> void:
	assert_same(DartNum.clamp(5, 0.5, 1.5), 1.5)
	assert_same(DartNum.clamp(-5, 0.5, 1.5), 0.5)
	assert_same(DartNum.clamp(2.5, 0, 2), 2)
	assert_same(DartNum.clamp(1, NAN, NAN), NAN)
	assert_same(DartNum.clamp(NAN, 0, 1), 1)
	assert_same(DartNum.clamp(_zero, _negative_zero, 1), _zero)


func test_compares_whole_numbers() -> void:
	assert_eq(DartNum.compare_to(1, 2), -1)
	assert_eq(DartNum.compare_to(2, 1), 1)
	assert_eq(DartNum.compare_to(MIN, MIN), 0)


func test_orders_floats_from_minus_infinity_to_nan() -> void:
	# The SDK: NaN > Infinity > ... > 0.0 > -0.0 > ... > -Infinity.
	var ordered: Array[float] = [-INF, -1.5, _negative_zero, _zero, 0.25, INF, NAN]
	for i: int in ordered.size():
		for j: int in ordered.size():
			var what := "%s to %s" % [ordered[i], ordered[j]]
			assert_eq(DartNum.compare_to(ordered[i], ordered[j]), signi(i - j), what)


func test_compares_a_whole_number_with_a_float() -> void:
	assert_eq(DartNum.compare_to(1, 1.0), 0)
	assert_eq(DartNum.compare_to(1.0, 1), 0)
	assert_eq(DartNum.compare_to(1, 1.5), -1)
	assert_eq(DartNum.compare_to(1.5, 1), 1)
	assert_eq(DartNum.compare_to(0, _negative_zero), 1)
	assert_eq(DartNum.compare_to(_negative_zero, 0), -1)
	assert_eq(DartNum.compare_to(0, _zero), 0)
	assert_eq(DartNum.compare_to(5, NAN), -1)
	assert_eq(DartNum.compare_to(NAN, 5), 1)
	assert_eq(DartNum.compare_to(5, INF), -1)
	assert_eq(DartNum.compare_to(5, -INF), 1)


func test_compares_beyond_what_a_float_holds_as_whole_numbers() -> void:
	var rounded := float(BEYOND_EXACT)
	assert_eq(rounded, 9007199254740992.0)
	assert_eq(DartNum.compare_to(BEYOND_EXACT, rounded), 1)
	assert_eq(DartNum.compare_to(rounded, BEYOND_EXACT), -1)
	assert_eq(DartNum.compare_to(-BEYOND_EXACT, -rounded), -1)
	assert_eq(DartNum.compare_to(MAX, 9223372036854775808.0), -1)
	assert_eq(DartNum.compare_to(9223372036854775808.0, MAX), 1)
	assert_eq(DartNum.compare_to(MIN, -9223372036854775808.0), 0)
	assert_eq(DartNum.compare_to(-9223372036854775808.0, MIN), 0)
	assert_eq(DartNum.compare_to(MIN, -1e19), 1)
