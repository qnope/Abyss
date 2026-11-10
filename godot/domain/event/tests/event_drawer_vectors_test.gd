extends VectorTestCase
## Not in the Dart files: the sections drawTurns and pick of
## reference/vectors/events.json, every case, through EventDrawer.


func test_draws_the_turns_of_the_draws_as_dart_does() -> void:
	var cases := VectorFile.new("events").cases("drawTurns")
	assert_eq(cases.size(), 49)
	for case: Dictionary in cases:
		var turn: int = case["turn"]
		var seed_value: int = case["seed"]
		var out := [
			EventDrawer.first_draw_turn(turn, DartRandom.new(seed_value)),
			EventDrawer.next_draw_turn(turn, DartRandom.new(seed_value)),
		]
		assert_same(out, case["out"], str(case))


func test_picks_the_event_as_dart_does_and_rolls_only_then() -> void:
	var cases := VectorFile.new("events").cases("pick")
	assert_eq(cases.size(), 192)
	for case: Dictionary in cases:
		var seed_value: int = case["seed"]
		var ended_turn: int = case["endedTurn"]
		var random := DartRandom.new(seed_value)
		var picked: Variant = EventDrawer.pick(
			random,
			ended_turn,
			EventInputs.event_or_null(case["lastDrawn"]),
			EventInputs.events(case["excluded"]),
		)
		var out: Variant = VectorInputs.name_or_null(RandomEventType.Value, picked)
		assert_same([out, random.next_int(1000)], [case["out"], case["next"]], str(case))
