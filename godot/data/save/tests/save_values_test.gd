extends TestCase
## SaveValues writes the shapes SaveCollections reads back, each map in
## the order it iterates.

const Unit := UnitType.Value

var r := SaveReader.new()


func test_writes_an_enum_by_its_dart_name_and_null_as_null() -> void:
	assert_eq(SaveValues.name(Unit, Unit.DOME_BREAKER), "domeBreaker")
	assert_eq(SaveValues.name_or_null(Unit, Unit.SCOUT), "scout")
	assert_null(SaveValues.name_or_null(Unit, null))
	assert_eq(SaveValues.names([Unit.GUARDIAN, Unit.SCOUT], Unit), ["guardian", "scout"])


func test_writes_a_count_by_enum_value_in_its_order_and_reads_it_back() -> void:
	var counts: Dictionary[UnitType.Value, int] = {Unit.GUARDIAN: 2, Unit.SCOUT: 5}
	var written := SaveValues.counts(counts, Unit)
	assert_eq(JSON.stringify(written, "", false), "{\"guardian\":2,\"scout\":5}")
	var read: Dictionary[UnitType.Value, int] = SaveCollections.counts_at(r, {"u": _parsed(written)}, "u", Unit)
	assert_eq(read, counts)
	assert_eq(read.keys(), counts.keys())
	assert_true(r.ok())


func test_writes_a_list_and_a_missing_object() -> void:
	assert_eq(SaveValues.list_of([1, 2], func(n: int) -> int: return n * 10), [10, 20])
	assert_null(SaveValues.or_null(null, MapCodec.position))
	assert_eq(SaveValues.or_null(GridPosition.new(1, 2), MapCodec.position), {"x": 1, "y": 2})


func test_writes_a_map_by_number_under_its_digits_and_reads_the_keys_back() -> void:
	var written := SaveValues.by_number({3: "c", 1: "a", -2: "b"}, func(v: String) -> String: return v + "!")
	assert_eq(JSON.stringify(written, "", false), "{\"3\":\"c!\",\"1\":\"a!\",\"-2\":\"b!\"}")
	for key: String in written:
		assert_eq(str(SaveCollections.number_key(r, key, "levels")), key)
	assert_true(r.ok())


func test_a_key_that_is_not_the_digits_of_a_whole_number_is_a_problem() -> void:
	for key: String in ["03", "+3", "3.0", "x", ""]:
		var reader := SaveReader.new()
		assert_eq(SaveCollections.number_key(reader, key, "levels"), 0)
		assert_eq(reader.problem, "levels: %s is not a whole number" % JSON.stringify(key), key)


func test_reads_lists_of_names_of_numbers_and_of_objects() -> void:
	var m: Dictionary = _parsed({"u": ["scout", "guardian"], "n": [3, 1], "p": [{"x": 1, "y": 2}]})
	var units: Array[UnitType.Value] = SaveCollections.names_at(r, m, "u", Unit)
	assert_eq(units, [Unit.SCOUT, Unit.GUARDIAN] as Array[UnitType.Value])
	var numbers: Array[int] = SaveCollections.ints_at(r, m, "n")
	assert_eq(numbers, [3, 1] as Array[int])
	var cells: Array = SaveCollections.list_of(r, m["p"], "p", MapCodec.read_position)
	assert_eq(cells.size(), 1)
	assert_true(r.ok())


func test_reads_turns_by_player_id() -> void:
	var m: Dictionary = _parsed({"t": {"b": 4, "a": 2}})
	var turns := SaveCollections.turns_by_id_at(r, m, "t")
	assert_eq(turns, {"b": 4, "a": 2} as Dictionary[String, int])
	assert_eq(turns.keys(), ["b", "a"])
	SaveCollections.turns_by_id_at(r, {"t": {1: 2}}, "t")
	assert_eq(r.problem, "t is not a text")


static func _parsed(value: Variant) -> Variant:
	return JSON.parse_string(JSON.stringify(value, "", false))
