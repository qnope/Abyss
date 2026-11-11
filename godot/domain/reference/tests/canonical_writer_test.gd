extends TestCase
## test/domain/reference/canonical_writer_test.dart. A NUL is left out of
## the escapes tested: no Godot String holds one. The values Dart refuses
## are those GDScript has (an object, a vector, a StringName, a packed
## array); where Dart throws, the writer logs an error and gives "".


func test_null_booleans_and_integers_are_written_as_json_does() -> void:
	assert_eq(_write(null), "null")
	assert_eq(_write(true), "true")
	assert_eq(_write(false), "false")
	assert_eq(_write(0), "0")
	assert_eq(_write(-42), "-42")
	assert_eq(_write(9007199254740993), "9007199254740993")
	assert_eq(_write(-9223372036854775807 - 1), "-9223372036854775808")


func test_a_double_is_the_string_d_and_the_hex_of_its_ieee_754_bits() -> void:
	assert_eq(_write(1.0), '"d:3ff0000000000000"')
	assert_eq(_write(0.1), '"d:3fb999999999999a"')
	assert_eq(_write(-2.5), '"d:c004000000000000"')
	assert_eq(_write(VectorValues.float_of("0000000000000001")), '"d:0000000000000001"')


func test_negative_zero_keeps_its_sign() -> void:
	assert_eq(_write(0.0), '"d:0000000000000000"')
	assert_eq(_write(VectorValues.float_of("8000000000000000")), '"d:8000000000000000"')


func test_infinities_are_written() -> void:
	assert_eq(_write(INF), '"d:7ff0000000000000"')
	assert_eq(_write(-INF), '"d:fff0000000000000"')


func test_nan_fails_loudly_it_has_many_bit_patterns() -> void:
	expect_error("NaN")
	assert_eq(_write(NAN), "")
	expect_error("NaN")
	assert_eq(_write([1, NAN]), "")


func test_only_the_quote_the_backslash_and_control_characters_escape() -> void:
	assert_eq(_write("abc"), '"abc"')
	assert_eq(_write('a"b'), '"a\\"b"')
	assert_eq(_write("a\\b"), '"a\\\\b"')
	assert_eq(_write("a\nb\tc"), '"a\\u000ab\\u0009c"')
	assert_eq(_write("\u0001\u001f"), '"\\u0001\\u001f"')


func test_everything_else_is_raw_slash_del_accents_emoji() -> void:
	assert_eq(_write("a/b"), '"a/b"')
	assert_eq(_write("\u007f"), '"\u007f"')
	assert_eq(_write("Léviathan"), '"Léviathan"')
	assert_eq(_write("\U01F419"), '"\U01F419"')
	assert_eq(_write(" "), '" "')


func test_a_list_keeps_its_order_without_whitespace() -> void:
	assert_eq(_write([3, 1, 2]), "[3,1,2]")
	assert_eq(_write([]), "[]")
	assert_eq(_write([[], null]), "[[],null]")


func test_map_keys_are_sorted_whatever_the_order_they_were_added_in() -> void:
	assert_eq(_write({"b": 1, "a": 2, "c": {}}), '{"a":2,"b":1,"c":{}}')


func test_keys_are_sorted_by_utf_16_code_unit_not_by_letter() -> void:
	# "Z" (0x5a) < "a" (0x61) < "é" (0xe9) < the surrogates of an emoji
	# (0xd83d) < U+FFFF: a code point order would put the emoji last.
	var map := {"￿": 5, "\U01F419": 4, "é": 3, "a": 2, "Z": 1, "aa": 6, "": 0}
	assert_eq(_write(map), '{"":0,"Z":1,"a":2,"aa":6,"é":3,"\U01F419":4,"￿":5}')


func test_keys_are_escaped_like_any_string() -> void:
	assert_eq(_write({'a"b': 1}), '{"a\\"b":1}')


func test_nests() -> void:
	assert_eq(
		_write({"list": [{"y": 2, "x": 1}, "e"], "d": 0.5}),
		'{"d":"d:3fe0000000000000","list":[{"x":1,"y":2},"e"]}',
	)


func test_an_object_a_vector_a_string_name_a_map_with_other_keys() -> void:
	for value: Variant in [RefCounted.new(), Vector2i(1, 1), &"a", PackedStringArray(["a"])]:
		expect_error("not a canonical value")
		assert_eq(_write(value), "", str(value))
	expect_error("not a canonical key")
	assert_eq(_write({1: 1}), "")
	expect_error("not a canonical value")
	assert_eq(_write({"a": [Vector2i.ZERO]}), "")


## Not in the Dart file: the order of the keys, alone.
func test_compares_keys_by_utf_16_code_unit() -> void:
	assert_true(CanonicalKeys.compare("\U01F419", "￿") < 0)
	assert_true(CanonicalKeys.compare("￿", "\U01F419") > 0)
	assert_true(CanonicalKeys.compare("a", "aa") < 0)
	assert_true(CanonicalKeys.compare("ab", "a") > 0)
	assert_eq(CanonicalKeys.compare("é", "é"), 0)
	var keys: Array[String] = ["b", "a"]
	CanonicalKeys.sort(keys)
	assert_eq(keys, ["a", "b"] as Array[String])


func _write(value: Variant) -> String:
	return CanonicalWriter.write(value)
