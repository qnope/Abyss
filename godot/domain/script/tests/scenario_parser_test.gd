extends TestCase
## test/domain/script/scenario_parser_test.dart. Where Dart throws a
## FormatException, the port logs an error and gives null.


func test_reads_the_name_the_timeline_and_the_fallback_strategy() -> void:
	var script := ScenarioParser.parse("""
		{
			"name": "rush",
			"otherwise": "economy",
			"turns": {
				"1": [{"do": "upgrade", "building": "headquarters"}],
				"2": []
			}
		}
	""")

	assert_eq(script.name(), "rush")
	assert_eq(script.turns.keys(), [1, 2])
	assert_eq(script.turns[1].size(), 1)
	assert_true(script.otherwise is EconomyStrategy)


func test_plays_a_scenario_end_to_end() -> void:
	var script := ScenarioParser.parse('{"turns": {"1": [{"do": "upgrade", "building": "headquarters"}]}}')

	var report := ScriptRunner.new(2).run(script, 3)

	assert_eq(report.script_name, "scenario")
	assert_eq(report.buildings[BuildingType.Value.HEADQUARTERS], 1)


func test_pins_the_difficulty_it_names_by_its_dart_name() -> void:
	assert_eq(ScenarioParser.parse('{"difficulty": "hard"}').difficulty(), Difficulty.Value.HARD)
	assert_null(ScenarioParser.parse("{}").difficulty())
	expect_error("Difficulté inconnue : nightmare")
	assert_null(ScenarioParser.parse('{"difficulty": "nightmare"}'))


func test_rejects_a_malformed_scenario() -> void:
	expect_error("Un scénario est un objet JSON")
	assert_null(ScenarioParser.parse("[]"))
	expect_error("Numéro de tour invalide : zero")
	assert_null(ScenarioParser.parse('{"turns": {"zero": []}}'))
	expect_error("Stratégie inconnue : magic")
	assert_null(ScenarioParser.parse('{"otherwise": "magic"}'))


## Not in the Dart file: what an exported replay adds, and the other
## malformed scenarios.
func test_reads_what_an_exported_replay_pins() -> void:
	var script := ScenarioParser.parse("""{"player": "Nemo", "mapSeed": 12, "lastTurn": 9,
		"factions": ["magmaSmiths"], "endTurnSeeds": {"2": 77},
		"turns": {"3": [{"do": "upgrade", "building": "headquarters", "player": "faction-magmaSmiths"}]}}""")

	assert_eq([script.player_name(), script.map_seed(), script.last_turn()], ["Nemo", 12, 9])
	assert_eq(script.factions(), [FactionPersonality.Value.MAGMA_SMITHS] as Array[FactionPersonality.Value])
	assert_eq(script.end_turn_seeds, {2: 77} as Dictionary[int, int])
	assert_eq(script.actors, {3: ["faction-magmaSmiths"]} as Dictionary[int, Array])
	assert_null(script.otherwise)


func test_rejects_the_other_malformed_scenarios() -> void:
	for wrong: Array in [
		['{"turns": []}', "\"turns\" doit être un objet"],
		['{"turns": {"1": {}}}', "Chaque tour est une liste d'actions"],
		['{"turns": {"0": []}}', "Numéro de tour invalide : 0"],
		['{"factions": "magmaSmiths"}', "\"factions\" doit être une liste"],
		['{"factions": ["pirates"]}', "Faction inconnue : pirates"],
		['{"endTurnSeeds": [1]}', "\"endTurnSeeds\" doit être un objet"],
		['{"endTurnSeeds": {"x": 1}}', "Numéro de tour invalide : x"],
		['{"turns": {"1": [{"do": "dance"}]}}', "dance"],
	]:
		var source: String = wrong[0]
		var text: String = wrong[1]
		expect_error(text)
		assert_null(ScenarioParser.parse(source), source)
