extends TestCase
## test/domain/replay/replay_all_players_test.dart. Where Dart throws on
## an unknown player id, the replay logs the error and leaves the action out
## (TimelineScript).

const RIVAL_ID := LiveGames.RIVAL_ID


func test_a_solo_journal_records_no_player_key_and_no_header() -> void:
	var journal := ReplayJournal.new(1, "Nemo")
	journal.record(1, UpgradeBuildingAction.new(BuildingType.Value.ALGAE_FARM))

	assert_eq(journal.actions_of(1), [{"do": "upgrade", "building": "algaeFarm"}] as Array[Dictionary])


func test_a_solo_export_has_no_players_header() -> void:
	var game := GameSamples.two_players()
	for id: String in game.players.keys():
		if id != game.human_player_id:
			game.players.erase(id)

	assert_false(ReplayExport.to_json(game).has("players"))


func test_records_the_rival_actions_keyed_by_player_in_order_played() -> void:
	var game := LiveGames.play_two(6)
	var json := ReplayExport.to_json(game)

	assert_eq(json["players"], [
		{"id": game.human_player_id, "name": "human"},
		{"id": RIVAL_ID, "name": "rival"},
	])
	var turns: Dictionary = json["turns"]
	var turn1: Array[Dictionary] = turns["1"]
	var actors: Array = turn1.map(func(a: Dictionary) -> Variant: return a.get("player"))
	assert_has(actors, RIVAL_ID)
	assert_has(actors, null)
	var first_rival := actors.find_custom(func(a: Variant) -> bool: return a != null)
	var last_human := actors.rfind(null)
	assert_true(last_human < first_rival)


func test_replaying_an_export_gives_the_same_state_for_both_players() -> void:
	var live := LiveGames.play_two(12)
	var replayed := LiveGames.replay_on(ReplayExport.to_json(live))

	assert_eq(replayed.turn, live.turn)
	assert_eq(LiveGames.both(replayed), LiveGames.both(live))
	assert_true(replayed.players[RIVAL_ID].buildings[BuildingType.Value.HEADQUARTERS].level > 0)


func test_the_replay_never_calls_a_strategy_for_the_rival() -> void:
	var live := LiveGames.play_two(8)
	var spy := Spy.new()
	var fresh := GameSamples.two_players(3, RIVAL_ID)
	var script := ScenarioParser.parse(DartJson.encode(ReplayExport.to_json(live)))

	ScriptRunner.new(500).run_on(fresh, LiveGames.Fallback.new(script, spy), DartRandom.new(1, false), 1)

	assert_false(spy.players.has(RIVAL_ID))


func test_a_rejected_action_is_not_journalled() -> void:
	var game := GameSamples.two_players(3, RIVAL_ID)
	var result := ActionExecutor.new().execute(
		UpgradeBuildingAction.new(BuildingType.Value.VOLCANIC_KERNEL), game, game.players[RIVAL_ID]
	)

	assert_false(result.is_success)
	assert_eq(game.replay.actions_of(1), [] as Array[Dictionary])


func test_an_unknown_player_id_in_a_replay_is_a_clear_error() -> void:
	var json := ReplayExport.to_json(LiveGames.play_two(2))
	var fresh := GameSamples.two_players(3, "someone-else")
	var turns: Dictionary = json["turns"]
	for planned: Array in turns.values():
		for action: Dictionary in planned:
			if action.get("player") == RIVAL_ID:
				expect_error("Joueur inconnu dans le scénario : %s" % RIVAL_ID)
	assert_true(expected_errors().size() > 0)

	ScriptRunner.new(500).run_on(fresh, ScenarioParser.parse(DartJson.encode(json)), DartRandom.new(1, false), 1)


func test_a_journal_saved_before_players_existed_still_exports() -> void:
	var actions: Dictionary[int, Array] = {
		1: [JSON.stringify({"do": "upgrade", "building": "algaeFarm"}, "", false)] as Array[String],
	}
	var journal := ReplayJournal.new(3, "Nemo", actions)

	assert_eq(journal.actions_of(1), [{"do": "upgrade", "building": "algaeFarm"}] as Array[Dictionary])


## Not in the Dart file: the executor hands the journal the id of the human,
## so a rival spying on the human base names it `human`.
func test_a_rival_spying_on_the_human_names_its_target_human() -> void:
	var game := GameSamples.two_players(3, RIVAL_ID)
	var rival: Player = game.players[RIVAL_ID]
	var human := game.human_player()
	rival.add_revealed_cell(RaidBattle.BASE_LEVEL, GridPosition.new(human.base_x, human.base_y))
	rival.units_on_level(RaidBattle.BASE_LEVEL)[UnitType.Value.SCOUT].count = 1

	assert_true(ActionExecutor.new().execute(SpyBaseAction.new(human.id), game, rival).is_success)
	assert_eq(game.replay.actions_of(1), [{"do": "spy", "target": "human", "player": RIVAL_ID}] as Array[Dictionary])


## `Spy`: the players a script is asked to play for.
class Spy extends GameScript:
	var players: Array[String] = []

	func name() -> String:
		return "spy"

	func play_turn(turn: ScriptTurn) -> void:
		players.append(turn.player.id)
