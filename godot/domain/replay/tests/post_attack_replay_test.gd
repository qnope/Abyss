extends TestCase
## test/domain/replay/post_attack_replay_test.dart.


func test_a_post_attack_in_the_journal_replays_to_the_same_state() -> void:
	var live := _scene()
	var result := ActionExecutor.new().execute(
		live.strike({UnitType.Value.HARPOONIST: 30}, 9), live.game, live.attacker()
	)
	assert_true(result.is_success)

	var json := ReplayExport.to_json(live.game)
	var turns: Dictionary = json["turns"]
	var written: Array[Dictionary] = turns["12"]
	assert_eq(written.size(), 1)
	var entry := written[0]
	assert_eq(entry["do"], "attackPost")
	assert_eq(entry["seed"], 9)
	assert_eq(entry["player"], live.attacker().id)
	assert_eq(json["exact"], true)

	var replayed := _scene()
	var action: Action = ActionCodec.decode(entry).call(DartRandom.new(1, false))
	ActionExecutor.new().execute(action, replayed.game, replayed.attacker())

	assert_eq(_state(replayed), _state(live))


static func _scene() -> PostWar:
	var war := PostWar.new(TransitionBaseType.Value.FAILLE)
	war.arm(war.attacker(), {UnitType.Value.HARPOONIST: 30})
	war.put(war.owner(), 2, {UnitType.Value.GUARDIAN: 12, UnitType.Value.HARPOONIST: 12})
	return war


static func _state(war: PostWar) -> Dictionary:
	return {
		"attacker": LiveGames.snapshot_of(war.game, war.attacker()),
		"owner": LiveGames.snapshot_of(war.game, war.owner()),
		"holder": "attacker" if war.post.captured_by == war.attacker().id else "owner",
	}
