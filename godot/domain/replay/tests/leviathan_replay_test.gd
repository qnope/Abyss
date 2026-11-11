extends TestCase
## test/domain/replay/leviathan_replay_test.dart.


func test_the_guardians_coming_back_replay_with_the_same_dice() -> void:
	var live := LiveGames.play_live_game(ConquestStrategy.new(), 40, 25)
	var spy := LiveGames.SpyExecutor.new()
	var runner := ScriptRunner.new(500, Difficulty.Value.NORMAL, null, spy)
	runner.run(ScenarioParser.parse(ReplayExport.to_text(live)), 12345)
	var replayed := spy.game

	assert_true(live.leviathan_return.over)
	var strikes := _strikes(live)
	var again := _strikes(replayed)
	assert_eq(strikes.size(), 1)
	assert_eq(again.size(), 1)
	assert_eq(again[0].turn, strikes[0].turn)
	assert_eq(again[0].victory, strikes[0].victory)
	assert_eq(again[0].dead, strikes[0].dead)
	assert_eq(again[0].fight_result.turn_count, strikes[0].fight_result.turn_count)
	assert_eq(LiveGames.snapshot_of(replayed), LiveGames.snapshot_of(live))


static func _strikes(game: Game) -> Array[BaseAssaultEntry]:
	var strikes: Array[BaseAssaultEntry] = []
	for e: HistoryEntry in game.human_player().history_entries:
		if e is BaseAssaultEntry and (e as BaseAssaultEntry).opponent_name == LeviathanForce.ATTACKER_NAME:
			strikes.append(e as BaseAssaultEntry)
	return strikes
