extends TestCase
## The values of a vector file read back exactly: a JSON number is a whole
## number, "d:" the bits of a float, "i:" a whole number no float holds.

const MAX := 9223372036854775807
const MIN := -9223372036854775807 - 1


func test_a_json_number_is_an_int() -> void:
	assert_eq(VectorValues.decode(5.0), 5)
	assert_eq(VectorValues.decode(-3.0), -3)
	assert_eq(VectorValues.decode(4294967296.0), 4294967296)
	assert_eq(VectorValues.decode(9007199254740992.0), 9007199254740992)
	assert_eq(VectorValues.decode(-9007199254740992.0), -9007199254740992)


func test_a_fraction_or_a_number_no_float_holds_is_refused() -> void:
	expect_error("1.5 is not a whole number")
	assert_null(VectorValues.decode(1.5))
	expect_error("is beyond 2^53")
	assert_null(VectorValues.decode(9007199254740994.0))


func test_an_i_text_is_a_64_bit_int() -> void:
	assert_eq(VectorValues.decode("i:9223372036854775807"), MAX)
	assert_eq(VectorValues.decode("i:-9223372036854775808"), MIN)
	assert_eq(VectorValues.decode("i:9007199254740993"), 9007199254740993)


func test_a_d_text_is_the_float_of_those_bits() -> void:
	assert_eq(VectorValues.decode("d:3ff8000000000000"), 1.5)
	assert_eq(VectorValues.decode("d:c004000000000000"), -2.5)
	assert_eq(VectorValues.decode("d:7ff0000000000000"), INF)
	assert_eq(VectorValues.decode("d:fff0000000000000"), -INF)
	assert_eq(VectorValues.decode("d:3fb999999999999a"), 0.1)
	var nan: float = VectorValues.decode("d:7ff8000000000000")
	assert_true(is_nan(nan))


func test_a_zero_keeps_its_sign() -> void:
	var negative: float = VectorValues.decode("d:8000000000000000")
	var positive: float = VectorValues.decode("d:0000000000000000")
	assert_eq(1.0 / negative, -INF)
	assert_eq(1.0 / positive, INF)


func test_a_malformed_number_text_is_refused() -> void:
	expect_error('"d:3ff8" is not the 16 hex digits of a float')
	assert_null(VectorValues.decode("d:3ff8"))
	expect_error('"d:3ff80000000000zz" is not the 16 hex digits of a float')
	assert_null(VectorValues.decode("d:3ff80000000000zz"))
	expect_error('"i:12a" is not a whole number')
	assert_null(VectorValues.decode("i:12a"))


func test_other_values_are_kept() -> void:
	assert_eq(VectorValues.decode("double"), "double")
	assert_eq(VectorValues.decode(true), true)
	assert_null(VectorValues.decode(null))


func test_lists_and_maps_are_decoded_through() -> void:
	var raw: Variant = JSON.parse_string(
		'{"army": [["scout", 2], ["guard", "i:-9223372036854775808"]], "out": ["d:3ff8000000000000", null]}'
	)
	assert_eq(
		VectorValues.decode(raw),
		{"army": [["scout", 2], ["guard", MIN]], "out": [1.5, null]}
	)


func test_bits_of_a_float() -> void:
	assert_eq(VectorValues.bits_of(1.5), "3ff8000000000000")
	assert_eq(VectorValues.bits_of(0.1), "3fb999999999999a")
	assert_eq(VectorValues.bits_of(-INF), "fff0000000000000")
	assert_eq(VectorValues.bits_of(VectorValues.float_of("8000000000000000")), "8000000000000000")
	assert_eq(VectorValues.bits_of(VectorValues.float_of("00000000000007e8")), "00000000000007e8")


func test_every_nan_has_the_same_bits() -> void:
	assert_eq(VectorValues.bits_of(NAN), "7ff8000000000000")
	assert_eq(VectorValues.bits_of(VectorValues.float_of("fff8000000000001")), "7ff8000000000000")


func test_encode_writes_floats_as_their_bits_and_keeps_the_rest() -> void:
	assert_eq(VectorValues.encode(1.5), "d:3ff8000000000000")
	assert_eq(VectorValues.encode(NAN), "d:7ff8000000000000")
	assert_eq(VectorValues.encode(7), 7)
	assert_eq(VectorValues.encode(MIN), MIN)
	assert_eq(
		VectorValues.encode({"out": [1, 1.0, "x", null, [false, -2.5]]}),
		{"out": [1, "d:3ff0000000000000", "x", null, [false, "d:c004000000000000"]]}
	)


func test_encoded_values_tell_an_int_from_a_float_and_a_zero_from_the_other() -> void:
	assert_ne(VectorValues.encode(1), VectorValues.encode(1.0))
	assert_ne(
		VectorValues.encode(VectorValues.float_of("8000000000000000")),
		VectorValues.encode(VectorValues.float_of("0000000000000000"))
	)
	assert_eq(VectorValues.encode([NAN]), VectorValues.encode([VectorValues.float_of("fff8000000000001")]))
