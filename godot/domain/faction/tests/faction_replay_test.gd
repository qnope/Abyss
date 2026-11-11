extends TestCase
## test/domain/faction/faction_replay_test.dart.


func test_a_replay_never_asks_a_brain_the_journal_alone_gives_the_game() -> void:
	var live := FactionGames.play(3, 25)
	var json := ReplayExport.to_json(live)
	var spy := LiveGames.SpyExecutor.new()

	var script := ScenarioParser.parse(DartJson.encode(json))
	ScriptRunner.new(500, Difficulty.Value.NORMAL, null, spy).run(script, 1)
	var replayed := spy.game

	var factions: Array = json["factions"]
	assert_eq(factions.size(), 3)
	assert_false(script.factions_play())
	assert_eq(replayed.turn, live.turn)
	assert_eq(_everyone(replayed), _everyone(live))
	assert_eq(replayed.replay.actions, live.replay.actions, "a brain called again would journal more actions")


func test_a_timeline_replays_factions_without_brains_by_default() -> void:
	var script := TimelineScript.new("t", {})
	assert_false(script.factions_play())


func test_a_strategy_lets_the_brains_play() -> void:
	assert_true(BalancedStrategy.new().factions_play())


func test_the_end_of_turn_without_the_switch_plays_no_brain() -> void:
	var game := FactionGames.play(2, 1)
	var before := game.replay.actions_of(1).size()
	EndTurnAction.new(DartRandom.new(1, false), false).execute(game, game.human_player())

	assert_eq(game.replay.actions_of(1).size(), before)


## `everyone`: the snapshots of the human and of every faction.
static func _everyone(game: Game) -> Dictionary:
	var all := {"human": LiveGames.snapshot_of(game)}
	for f: Faction in game.factions():
		all[f.id()] = LiveGames.snapshot_of(game, game.players[f.id()])
	return all
