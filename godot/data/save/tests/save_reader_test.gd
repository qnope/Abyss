extends TestCase
## SaveReader: each value read as written, and what is wrong noted once,
## the first problem kept, a default in place of the value.

const Unit := UnitType.Value

var r := SaveReader.new()


func test_reads_each_value_as_written() -> void:
	var m := {"o": {"a": 1}, "l": [1], "i": 3.0, "b": true, "t": "x", "e": "domeBreaker"}
	assert_eq(r.object_at(m, "o"), {"a": 1})
	assert_eq(r.list_at(m, "l"), [1])
	assert_eq(r.int_at(m, "i"), 3)
	assert_eq(typeof(r.int_at(m, "i")), TYPE_INT)
	assert_eq(r.whole(-7, "n"), -7)
	assert_true(r.bool_at(m, "b"))
	assert_eq(r.text_at(m, "t"), "x")
	assert_eq(r.enum_at(m, "e", Unit), Unit.DOME_BREAKER)
	assert_eq(r.enum_at(m, "e", Unit), Unit.DOME_BREAKER, "the second time, from the names kept")
	assert_true(r.ok())


func test_reads_null_or_a_value_where_null_is_allowed() -> void:
	var m := {"o": {}, "i": 2.0, "t": "x", "e": "domeBreaker"}
	assert_null(r.object_or_null_at({"o": null}, "o"))
	assert_null(r.int_or_null_at({"i": null}, "i"))
	assert_null(r.text_or_null_at({"t": null}, "t"))
	assert_null(r.enum_or_null_at({"e": null}, "e", Unit))
	assert_eq(r.object_or_null_at(m, "o"), {})
	assert_eq(r.int_or_null_at(m, "i"), 2)
	assert_eq(r.text_or_null_at(m, "t"), "x")
	assert_eq(r.enum_or_null_at(m, "e", Unit), Unit.DOME_BREAKER)
	assert_true(r.ok())


func test_a_missing_field_is_a_problem_and_reads_as_a_default() -> void:
	assert_eq(r.int_at({}, "turn"), 0)
	assert_eq(r.problem, "turn is missing")
	assert_false(r.ok())


func test_keeps_the_first_problem_only() -> void:
	r.text_at({}, "name")
	r.int_at({}, "turn")
	assert_eq(r.problem, "name is missing")


func test_a_value_of_the_wrong_type_is_a_problem() -> void:
	assert_eq(_problem(func(x: SaveReader) -> void: x.object([], "o")), "o is not an object")
	assert_eq(_problem(func(x: SaveReader) -> void: x.list({}, "l")), "l is not a list")
	assert_eq(_problem(func(x: SaveReader) -> void: x.whole("1", "i")), "i is not a whole number")
	assert_eq(_problem(func(x: SaveReader) -> void: x.boolean(1.0, "b")), "b is not true or false")
	assert_eq(_problem(func(x: SaveReader) -> void: x.text(1.0, "t")), "t is not a text")
	assert_eq(_problem(func(x: SaveReader) -> void: x.whole(null, "i")), "i is not a whole number")


func test_a_number_is_whole_and_held_exactly_or_it_is_a_problem() -> void:
	assert_eq(_problem(func(x: SaveReader) -> void: x.whole(1.5, "turn")), "turn is not a whole number")
	assert_eq(_problem(func(x: SaveReader) -> void: x.whole(1e20, "seed")), "seed is not a whole number")
	assert_eq(r.whole(9007199254740992.0, "n"), 9007199254740992)
	assert_eq(r.whole(-9007199254740992.0, "n"), -9007199254740992)
	assert_true(r.ok())


func test_an_unknown_enum_name_is_a_problem() -> void:
	assert_eq(r.enum_value("kraken", CombatSide.Value, "side"), 0)
	assert_eq(r.problem, "side: \"kraken\" is no player|monster")
	assert_eq(_problem(func(x: SaveReader) -> void: x.enum_value(1.0, CombatSide.Value, "side")),
		"side: 1.0 is no player|monster")


func test_notes_what_a_codec_finds_wrong() -> void:
	r.fail("the human player x is not among the players")
	r.fail("later")
	assert_eq(r.problem, "the human player x is not among the players")


static func _problem(read: Callable) -> String:
	var reader := SaveReader.new()
	read.call(reader)
	return reader.problem
