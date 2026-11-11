extends TestCase
## test/domain/script/among_factions_test.dart.


func test_plays_the_script_it_wraps_against_the_given_factions() -> void:
	var factions: Array[FactionPersonality.Value] = [
		FactionPersonality.Value.PEARL_ORDER, FactionPersonality.Value.ANGLER_CULT,
	]
	var script := AmongFactions.new(ConquestStrategy.new(), factions)

	assert_eq(script.factions().size(), 2)
	assert_eq(script.name(), "conquest+2")
	assert_true(script.factions_play())


func test_draws_the_factions_from_the_catalogue_without_duplicates() -> void:
	var script := AmongFactions.drawn(IdleScript.new(), 5, 3)

	var distinct := {}
	for f: FactionPersonality.Value in script.factions():
		distinct[f] = true
	assert_eq(distinct.size(), 5)


func test_no_faction_at_all_is_the_solo_game() -> void:
	assert_eq(AmongFactions.drawn(IdleScript.new(), 0).factions().size(), 0)


func test_a_game_against_factions_runs_and_the_report_says_who_won() -> void:
	var report := ScriptRunner.new(10).run(AmongFactions.drawn(ConquestStrategy.new(), 3, 1), 1)

	assert_eq(report.turns_played, 10)
	assert_false(report.faction_won)


## Not in the Dart file: every other trait is the inner script's.
func test_keeps_the_traits_of_the_inner_script() -> void:
	var script := AmongFactions.drawn(PlanScript.from_replay(
		DartJson.encode({"player": "Nemo", "mapSeed": 9, "turns": {}, "endTurnSeeds": {"2": 4}}),
		ReplayVariant.new(),
	), 1)

	assert_eq(script.player_name(), "Nemo")
	assert_eq(script.map_seed(), 9)
	assert_null(script.difficulty())
	assert_null(script.last_turn())
	assert_eq(script.end_turn_random(2).initial_seed, 4)
