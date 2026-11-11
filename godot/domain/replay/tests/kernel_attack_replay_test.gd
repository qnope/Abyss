extends TestCase
## test/domain/replay/kernel_attack_replay_test.dart.


func test_a_kernel_attack_in_the_journal_replays_to_the_same_state() -> void:
	var live := _scene()
	var result := ActionExecutor.new().execute(
		live.strike({UnitType.Value.HARPOONIST: 40}, 9), live.game, live.attacker()
	)
	assert_true(result.is_success)

	var json := ReplayExport.to_json(live.game)
	var turns: Dictionary = json["turns"]
	var written: Array[Dictionary] = turns["12"]
	assert_eq(written.size(), 1)
	var entry := written[0]
	assert_eq(entry["do"], "attackHeldKernel")
	assert_eq(entry["seed"], 9)
	assert_eq(entry["player"], live.attacker().id)
	assert_eq(json["exact"], true)

	var replayed := _scene()
	var action: Action = ActionCodec.decode(entry).call(DartRandom.new(1, false))
	ActionExecutor.new().execute(action, replayed.game, replayed.attacker())

	assert_eq(_state(replayed), _state(live))


static func _scene() -> KernelWar:
	var war := KernelWar.new(2)
	war.arm({UnitType.Value.HARPOONIST: 40})
	war.garrison({UnitType.Value.GUARDIAN: 6, UnitType.Value.HARPOONIST: 6})
	return war


static func _state(war: KernelWar) -> Dictionary:
	return {
		"attacker": LiveGames.snapshot_of(war.game, war.attacker()),
		"owner": LiveGames.snapshot_of(war.game, war.owner()),
		"holder": "attacker" if war.holder() == war.attacker().id else "owner",
		"kernel": war.kernel_of(war.owner()),
	}
