extends TestCase
## The replay of a reference game (ReferenceReplay), on the short games:
## `idle-normal`, whose journal holds no move, and `economy-hard`, 27 turns
## of moves, go through the states Dart went through, every section of
## every turn, and end with its result, journal and coverage. The other
## games take minutes: `tool/godot_reference.sh` replays them all
## (tool/replay/README.md). A replay that differs names where.


func test_replays_a_game_without_moves_as_dart_did() -> void:
	var replay := ReferenceReplay.new(CommittedGame.named("idle-normal"))
	assert_eq(replay.differences(), PackedStringArray())
	assert_eq(replay.recorder.turns.size(), 48)
	assert_eq(replay.game.status, GameStatus.Value.DEFEAT)


func test_replays_a_game_with_moves_as_dart_did() -> void:
	var replay := ReferenceReplay.new(CommittedGame.named("economy-hard"))
	assert_eq(replay.differences(), PackedStringArray())
	assert_eq(replay.recorder.turns.size(), 27)
	assert_true(replay.recorder.actions[ActionType.Value.UPGRADE_BUILDING] > 10)


func test_names_the_first_turn_that_differs_the_missing_turns_and_the_rest() -> void:
	var replay := ReferenceReplay.new(CommittedGame.named("idle-normal"))
	var json := _idle_normal()
	json["turns"][4]["digests"][3] = "0".repeat(64)
	json["turns"][4]["digests"][1] = "0".repeat(64)
	json["turns"][9]["digests"][1] = "0".repeat(64)
	assert_eq(_against(replay, json), PackedStringArray(["turn 5 started as turn 5, differing in: events, game"]))

	json = _idle_normal()
	var turns: Array = json["turns"]
	turns.pop_back()
	json["final"][19] = "0".repeat(64)
	assert_eq(_against(replay, json), PackedStringArray([
		"48 turns started, 47 in the file", "when it stopped, differing in: worksite",
	]))

	json = _idle_normal()
	json["result"]["turn"] = 47
	json["journal"]["status"] = "playing"
	json["coverage"]["actions"]["endTurn"] = 1
	json["coverage"]["events"]["storm"] = 9
	json["coverage"]["milestones"]["raidsLost"] = 0
	var found := _against(replay, json)
	assert_eq(Array(found).map(func(line: String) -> String: return line.get_slice(":", 0)), [
		"result", "journal", "actions", "events", "milestones",
	])
	assert_eq(found[0], "result: [\"defeat\",48]")


func _idle_normal() -> Dictionary:
	return CommittedGame.named("idle-normal").json.duplicate(true)


func _against(replay: ReferenceReplay, json: Dictionary) -> PackedStringArray:
	return replay.differences(CommittedGame.new("changed", JSON.stringify(json, "", false)))
