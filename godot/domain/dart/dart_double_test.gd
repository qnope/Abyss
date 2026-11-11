extends TestCase
## DartDouble writes a double as the Dart VM does. No vector holds it yet:
## each answer below is what Dart 3.13 printed for the double of those bits
## (`dart run`).


func test_writes_a_double_as_its_to_string() -> void:
	var written := {
		"0000000000000000": "0.0", "8000000000000000": "-0.0", "3ff0000000000000": "1.0",
		"3ff8000000000000": "1.5", "3fd3333333333334": "0.30000000000000004",
		"3fd5555555555555": "0.3333333333333333", "3fe5555555555555": "0.6666666666666666",
		"4059000000000000": "100.0", "444b1ae4d6e2ef50": "1e+21",
		"4415af1d78b58c40": "100000000000000000000.0", "441ac53a7e04bcda": "123456789012345680000.0",
		"3eb0c6f7a0b5ed8d": "0.000001", "3e7ad7f29abcaf48": "1e-7", "3e8421f5f40d8376": "1.5e-7",
		"3f201f31f46ed246": "0.000123", "4028b33333333333": "12.35", "3fee666666666666": "0.95",
		"3ff3333333333333": "1.2", "c004000000000000": "-2.5", "7ff0000000000000": "Infinity",
		"fff0000000000000": "-Infinity", "7ff8000000000000": "NaN",
		"7fefffffffffffff": "1.7976931348623157e+308", "0000000000000001": "5e-324",
		"4340000000000000": "9007199254740992.0", "430c6bf526340002": "1000000000000000.2",
		"3feccccccccccccd": "0.9", "3ff199999999999a": "1.1", "be7ad7f29abcaf48": "-1e-7",
		"444b1ae4d6e2ef4f": "999999999999999900000.0", "3ee4f8b588e368f1": "0.00001",
		"0010000000000000": "2.2250738585072014e-308", "4020000000000000": "8.0",
	}
	for bits: String in written:
		assert_eq(DartDouble.text_of(VectorValues.float_of(bits)), written[bits], bits)


func test_rounds_an_exact_half_away_from_zero_as_text_as_fixed() -> void:
	var written := [
		["3fd0000000000000", 1, "0.3"], ["4029000000000000", 0, "13"],
		["4028800000000000", 1, "12.3"], ["4000000000000000", 1, "2.0"],
		["3fa999999999999a", 1, "0.1"], ["3fc3333333333333", 1, "0.1"],
		["3ff0147ae147ae14", 2, "1.00"], ["bfa47ae147ae147b", 1, "-0.0"],
		["8000000000000000", 1, "-0.0"], ["4058fccccccccccd", 1, "100.0"],
		["3fe0000000000000", 0, "1"], ["3ff8000000000000", 0, "2"], ["4004000000000000", 0, "3"],
		["4415af1d78b58c40", 1, "100000000000000000000.0"], ["4041800000000000", 1, "35.0"],
		["4042c00000000000", 1, "37.5"], ["0000000000000000", 0, "0"],
		["bfe0000000000000", 0, "-1"], ["bff4000000000000", 1, "-1.3"],
		["405edd2f1a9fbe77", 2, "123.46"], ["3fd5555555555555", 1, "0.3"],
		["3fe5555555555555", 0, "1"], ["3fdccccccccccccd", 1, "0.5"],
		["4050aaaaaaaaaaab", 0, "67"], ["3ddb7cdfd9d7bdbb", 1, "0.0"],
		["4330000000000002", 0, "4503599627370498"], ["4023fd70a3d70a3d", 2, "9.99"],
		["444b1ae4d6e2ef50", 1, "1e+21"], ["4450ab6b74cb909e", 2, "1.23e+21"],
		["441ac53a7e04bcda", 0, "123456789012345683968"], ["3fefffffffffffff", 0, "1"],
		["0000000000000001", 3, "0.000"], ["7ff8000000000000", 2, "NaN"],
	]
	for case: Array in written:
		var bits: String = case[0]
		var digits: int = case[1]
		var x := VectorValues.float_of(bits)
		assert_eq(DartDouble.text_as_fixed(x, digits), case[2], "%s %d" % [bits, digits])


func test_refuses_digits_out_of_0_to_20_where_dart_throws() -> void:
	expect_error("21 fraction digits")
	assert_eq(DartDouble.text_as_fixed(1.0, 21), "")
	expect_error("-1 fraction digits")
	assert_eq(DartDouble.text_as_fixed(1.0, -1), "")
