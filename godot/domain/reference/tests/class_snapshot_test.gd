extends TestCase
## test/domain/reference/class_snapshot_test.dart.

var ids := PlayerIds.new("1f0e")


class Point:
	extends RefCounted
	var x: int
	var saved_y: Variant
	var owner: String

	func _init(x_: int, saved_y_: Variant, owner_: String) -> void:
		x = x_
		saved_y = saved_y_
		owner = owner_


func _points() -> ClassSnapshot:
	return ClassSnapshot.new("_Point", {
		"x": func(p: Point, _ids: PlayerIds) -> Variant: return p.x,
		"savedY": func(p: Point, _ids: PlayerIds) -> Variant: return 0 if p.saved_y == null else p.saved_y,
		"owner": func(p: Point, i: PlayerIds) -> Variant: return i.of(p.owner),
	}, {"savedY": "y"})


func test_the_human_id_is_written_human_the_others_as_they_are() -> void:
	assert_eq(ids.of("1f0e"), "human")
	assert_eq(ids.of("faction-pearlOrder"), "faction-pearlOrder")
	assert_null(ids.or_null(null))
	assert_eq(ids.or_null("1f0e"), "human")


func test_writes_every_field_under_its_dart_name_unless_renamed() -> void:
	assert_eq(_points().of(Point.new(3, null, "1f0e"), ids), {"x": 3, "y": 0, "owner": "human"})
	assert_eq(_points().key_of("savedY"), "y")
	assert_eq(_points().key_of("x"), "x")


func test_or_null_and_list_of_follow_the_values() -> void:
	assert_null(_points().or_null(null, ids))
	assert_not_null(_points().or_null(Point.new(1, 2, "f"), ids))
	assert_eq(_points().list_of([Point.new(1, 2, "f"), Point.new(3, 4, "g")], ids), [
		{"x": 1, "y": 2, "owner": "f"},
		{"x": 3, "y": 4, "owner": "g"},
	])


func test_only_keeps_the_fields_named_by_their_dart_name() -> void:
	assert_eq(_points().only(Point.new(1, 2, "f"), ids, {"savedY": true}), {"y": 2})


func test_a_map_is_the_list_of_its_pairs_in_its_own_order() -> void:
	var units := {UnitType.Value.GUARDIAN: 2, UnitType.Value.SCOUT: 1}
	assert_eq(SnapshotValues.counts(units, UnitType.Value), [["guardian", 2], ["scout", 1]])
	var same := func(v: Variant) -> Variant: return v
	assert_eq(SnapshotValues.pairs({2: "b", 1: "a"}, same, same), [[2, "b"], [1, "a"]])
	assert_eq(SnapshotValues.names([UnitType.Value.SCOUT], UnitType.Value), ["scout"])


func test_a_decoded_json_object_keeps_the_order_of_its_keys() -> void:
	var decoded := {"do": "fight", "units": {"scout": 1, "guardian": 2}, "path": [{"x": 1}, 2]}
	assert_eq(SnapshotValues.ordered(decoded), [
		["do", "fight"],
		["units", [["scout", 1], ["guardian", 2]]],
		["path", [[["x", 1]], 2]],
	])


## Not in the Dart file: the names of the fields, and an enum that may be
## null.
func test_lists_the_fields_written_and_names_an_enum_or_null() -> void:
	assert_eq(_points().field_names(), ["x", "savedY", "owner"] as Array[String])
	assert_eq(_points().omitted, {} as Dictionary[String, String])
	assert_null(SnapshotValues.name_or_null(UnitType.Value, null))
	assert_eq(SnapshotValues.name_or_null(UnitType.Value, UnitType.Value.DOME_BREAKER), "domeBreaker")
