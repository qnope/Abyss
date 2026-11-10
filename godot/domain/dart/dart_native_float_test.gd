extends VectorTestCase
## What GDScript does as Dart with floats, so that a ported rule writes it
## as it is: literals, `+ - * /`, and rounding inside 64 bits, held against
## reference/vectors/dart_math.json. The last tests say where it parts; what
## it gives from 2^63 up, or for a shift of 64, depends on the processor.

const TWO_POW_63 := 9223372036854775808.0

## Every float literal and constant expression of lib/domain, as GDScript
## writes it: `1 / 3` is 0 here, a float needs `1.0 / 3.0`.
const LITERALS := {
	"0.04": 0.04, "0.05": 0.05, "0.06": 0.06, "0.08": 0.08, "0.1": 0.1, "0.12": 0.12,
	"0.125": 0.125, "0.15": 0.15, "0.2": 0.2, "0.225": 0.225, "0.25": 0.25, "0.3": 0.3,
	"0.5": 0.5, "0.50": 0.50, "0.60": 0.60, "0.625": 0.625, "0.65": 0.65, "0.7": 0.7,
	"0.75": 0.75, "0.8": 0.8, "0.80": 0.80, "0.85": 0.85, "0.9": 0.9, "0.90": 0.90,
	"0.95": 0.95, "1.0": 1.0, "1.1": 1.1, "1.2": 1.2, "1.6": 1.6, "2.0": 2.0,
	"1 / 3": 1.0 / 3.0,
	"0.60 + (0.80 - 0.60) * (1 / 3)": 0.60 + (0.80 - 0.60) * (1.0 / 3.0),
	"0.80 + (0.90 - 0.80) * (1 / 3)": 0.80 + (0.90 - 0.80) * (1.0 / 3.0),
	"0.5 / 2": 0.5 / 2, "0.85 - 0.125": 0.85 - 0.125, "0.8 - 0.125": 0.8 - 0.125,
	"0.75 - 0.125": 0.75 - 0.125, "0.7 - 0.125": 0.7 - 0.125,
}

var _vectors := VectorFile.new("dart_math")


func test_literals_and_float_arithmetic_give_the_bits_of_dart() -> void:
	var cases := _vectors.cases("literals")
	assert_eq(cases.size(), LITERALS.size())
	for case: Dictionary in cases:
		var text: String = case["text"]
		assert_has(LITERALS, text)
		assert_same(LITERALS.get(text), case["out"], text)


func test_rounding_is_alike_inside_64_bits() -> void:
	var inside := 0
	for case: Dictionary in _vectors.cases("rounding"):
		var x: float = case["x"]
		var out: Dictionary = case["out"]
		if absf(x) < TWO_POW_63:
			var what := VectorValues.bits_of(x)
			assert_same(roundi(x), out["round"], what)
			assert_same(floori(x), out["floor"], what)
			assert_same(ceili(x), out["ceil"], what)
			assert_same(int(x), out["truncate"], what)
			assert_same(int(x), out["toInt"], what)
			inside += 1
	assert_eq(inside, 55)


func test_a_quotient_of_floats_rounds_alike() -> void:
	for case: Dictionary in _vectors.cases("quotient"):
		var a: int = case["a"]
		var b: int = case["b"]
		var out: Dictionary = case["out"]
		var quotient := float(a) / float(b)
		assert_same(quotient, out["quotient"], "%d / %d" % [a, b])
		if out["round"] != null:
			assert_same(roundi(quotient), out["round"], "%d / %d" % [a, b])
			assert_same(floori(quotient), out["floor"], "%d / %d" % [a, b])
			assert_same(ceili(quotient), out["ceil"], "%d / %d" % [a, b])


func test_pow_is_alike_where_a_float_holds_the_result() -> void:
	# The rest of the section, between whole numbers, is DartMath.int_pow.
	# Elsewhere the last bit of pow is the C library's: a rule never calls it.
	var raised := 0
	for case: Dictionary in _vectors.cases("pow"):
		if case["out"] is float:
			var base: float = case["base"]
			var exponent: float = case["exponent"]
			assert_same(pow(base, exponent), case["out"], str(VectorValues.encode(case)))
			raised += 1
	assert_eq(raised, 8)


func test_a_division_of_whole_numbers_is_not_dart_division() -> void:
	var seven := 7
	var two := 2
	@warning_ignore("integer_division")
	var whole := seven / two
	assert_eq(whole, 3)
	assert_eq(DartMath.quotient(seven, two), 3.5)


func test_minf_and_maxf_ignore_the_sign_of_a_zero() -> void:
	var negative := VectorValues.float_of("8000000000000000")
	var positive := VectorValues.float_of("0000000000000000")
	assert_same(maxf(negative, positive), positive)
	assert_same(maxf(positive, negative), negative)
	assert_same(DartNum.max(positive, negative), positive)
	assert_same(minf(negative, positive), positive)
	assert_same(DartNum.min(negative, positive), negative)
