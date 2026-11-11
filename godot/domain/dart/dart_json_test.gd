extends TestCase
## DartJson writes JSON as the Dart VM's `dart:convert` does. No vector holds
## it yet: each text below is what Dart 3.13 wrote for the same value
## (`dart run`).


func test_writes_on_one_line_as_json_encode() -> void:
	var value := {"a": [1, 2.0, {}], "b": "\b\f\r"}

	assert_eq(DartJson.encode(value), "{\"a\":[1,2.0,{}],\"b\":\"\\b\\f\\r\"}")


func test_indents_as_json_encoder_with_indent_keeping_the_key_order() -> void:
	var value := {
		"a": 1, "b": [], "c": {}, "d": [1, 2.5, null, true, "x\"\\\n\t\u0001\u001f/é"],
		"e": {"z": 0.0, "y": -3}, "f": 0.1 + 0.2,
	}

	assert_eq(DartJson.encode(value, "  "), "\n".join([
		"{",
		"  \"a\": 1,",
		"  \"b\": [],",
		"  \"c\": {},",
		"  \"d\": [",
		"    1,",
		"    2.5,",
		"    null,",
		"    true,",
		"    \"x\\\"\\\\\\n\\t\\u0001\\u001f/é\"",
		"  ],",
		"  \"e\": {",
		"    \"z\": 0.0,",
		"    \"y\": -3",
		"  },",
		"  \"f\": 0.30000000000000004",
		"}",
	]))


func test_refuses_what_dart_cannot_encode() -> void:
	expect_error("NaN has no JSON form")
	assert_eq(DartJson.encode([NAN]), "")
	expect_error("Infinity has no JSON form")
	assert_eq(DartJson.encode({"a": INF}), "")
	expect_error("a key must be a String, not int")
	assert_eq(DartJson.encode({1: 2}), "")
	expect_error("Vector2i has no JSON form")
	assert_eq(DartJson.encode([Vector2i.ZERO]), "")
