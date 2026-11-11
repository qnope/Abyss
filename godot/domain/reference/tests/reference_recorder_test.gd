extends TestCase
## test/domain/reference/reference_recorder_test.dart, GameCapture's test
## with it.


## A digest that tells two texts apart well enough for a test.
static func _digest(text: String) -> String:
	return "%d:%d" % [text.length(), text.hash()]


func _play(turns: int, trace_turn: Variant = null, dump_turn: Variant = null) -> ReferenceRecorder:
	var recorder := ReferenceRecorder.new(_digest, trace_turn, dump_turn)
	ScriptRunner.new(turns, Difficulty.Value.NORMAL, null, recorder).run(SeededScript.new(BalancedStrategy.new(), 2, recorder), 2)
	return recorder


func test_a_capture_has_no_game_before_an_action_is_executed() -> void:
	expect_error("No action was executed: no game to read")
	assert_null(GameCapture.new().game())


func test_records_the_start_of_turn_1_then_the_state_after_each_end_of_turn() -> void:
	var recorder := ReferenceRecorder.new(_digest)
	ScriptRunner.new(3, Difficulty.Value.NORMAL, null, recorder).run(IdleScript.new(), 1)

	assert_eq(recorder.turns.map(func(t: ReplayComparison.Turn) -> int: return t.turn), [1, 2, 3, 4])
	assert_eq(recorder.game().turn, 4)
	assert_eq(recorder.turns[-1].digests, GameSnapshot.digests(recorder.game(), _digest))
	for t: ReplayComparison.Turn in recorder.turns:
		assert_eq(t.digests.size(), SnapshotSections.names().size())
	# An idle turn only moves the turn on: the maps stay as they are.
	var game := SnapshotSections.names().find("game")
	var map1 := SnapshotSections.names().find("map1")
	assert_ne(recorder.turns[0].digests[game], recorder.turns[1].digests[game])
	assert_eq(recorder.turns[0].digests[map1], recorder.turns[3].digests[map1])
	assert_eq(recorder.actions, {ActionType.Value.END_TURN: 3} as Dictionary[ActionType.Value, int])


func test_counts_the_successful_actions_by_type_and_the_events_drawn() -> void:
	var recorder := _play(30)

	assert_eq(recorder.actions[ActionType.Value.END_TURN], 30)
	assert_true(recorder.actions[ActionType.Value.UPGRADE_BUILDING] > 5)
	assert_true(recorder.actions.has(ActionType.Value.RECRUIT_UNIT))
	var drawn := 0
	for count: int in recorder.events.values():
		drawn += count
	assert_eq(drawn, recorder.game().human_player().event_state.events_seen)
	assert_false(recorder.events.is_empty())


func test_traces_the_digests_after_each_action_of_one_turn_only() -> void:
	var recorder := _play(8, 6)
	var in_turn := recorder.game().replay.actions_of(6).size()

	assert_true(in_turn > 0)
	assert_eq(recorder.traced.size(), in_turn)
	assert_ne(recorder.traced[-1], recorder.turns[5].digests)
	assert_eq(_play(8).traced.size(), 0)


func test_dumps_the_texts_of_the_turn_asked_as_it_starts() -> void:
	var recorder := _play(8, null, 5)
	var dump: Dictionary[String, String] = recorder.dump

	assert_eq(PackedStringArray(dump.keys()), PackedStringArray(SnapshotSections.names()))
	assert_true(dump["game"].contains("\"turn\":5"))
	var digests := PackedStringArray()
	for text: String in dump.values():
		digests.append(_digest(text))
	assert_eq(digests, recorder.turns[4].digests)
	assert_null(_play(3, null, 9).dump)
	var first: Dictionary[String, String] = _play(3, null, 1).dump
	assert_true(first["game"].contains("\"turn\":1"))


## Not in the Dart file: a refused action is neither counted nor traced.
func test_a_refused_action_is_neither_counted_nor_traced() -> void:
	var recorder := ReferenceRecorder.new(_digest, 1)
	var barracks := func(_random: DartRandom) -> Action: return UpgradeBuildingAction.new(BuildingType.Value.BARRACKS)
	ScriptRunner.new(1, Difficulty.Value.NORMAL, null, recorder).run(TimelineScript.new("too-soon", {1: [barracks]}), 1)

	assert_eq(recorder.actions, {ActionType.Value.END_TURN: 1} as Dictionary[ActionType.Value, int])
	assert_eq(recorder.traced.size(), 0)
