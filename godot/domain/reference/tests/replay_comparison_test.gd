extends TestCase
## Not in the Dart files: replay_comparison.dart is tested through the
## exporter (`reference_exporter_failures_test.dart`), which is not ported.

var names := SnapshotSections.names()


func _row(changed: Array[String] = []) -> PackedStringArray:
	var row := PackedStringArray()
	for name: String in names:
		row.append("x" if changed.has(name) else "a")
	return row


func test_the_same_digests_are_the_same_state() -> void:
	assert_true(ReplayComparison.same("at the start", _row(), _row()))
	assert_eq(ReplayComparison.differing(_row(), _row()), PackedStringArray())


func test_names_the_sections_that_differ_in_their_order() -> void:
	var changed: Array[String] = ["units", "fog"]
	assert_eq(ReplayComparison.differing(_row(), _row(changed)), PackedStringArray(["fog", "units"]))
	expect_error("The replay differs at the start of turn 3: fog, units")
	assert_false(ReplayComparison.same("at the start of turn 3", _row(), _row(changed)))


func test_stops_on_the_first_turn_that_started_differently() -> void:
	var played: Array[ReplayComparison.Turn] = [ReplayComparison.Turn.new(1, _row()), ReplayComparison.Turn.new(2, _row())]
	var replayed: Array[ReplayComparison.Turn] = [
		ReplayComparison.Turn.new(1, _row()), ReplayComparison.Turn.new(2, _row(["map2"] as Array[String])),
	]
	assert_true(ReplayComparison.same_turns(played, played))
	expect_error("at the start of turn 2: map2")
	assert_false(ReplayComparison.same_turns(played, replayed))


func test_a_replay_that_started_another_number_of_turns_differs() -> void:
	var played: Array[ReplayComparison.Turn] = [ReplayComparison.Turn.new(1, _row())]
	expect_error("The replay differs: 0 turns started, 1 in the game")
	assert_false(ReplayComparison.same_turns(played, []))
