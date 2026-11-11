extends TestCase
## test/domain/replay/replay_export_test.dart. 'replays an ongoing game turn
## for turn' and 'replays fights, raids and descents with the same dice' play
## the export through `ScenarioParser` and `ScriptRunner`: they wait for the
## runners of `script`.


func test_a_new_game_keeps_a_journal_with_its_map_seed() -> void:
	var game := GameFactory.new_single_player("Nemo", 42)

	assert_true(ReplayExport.can_export(game))
	var json := ReplayExport.to_json(game)
	assert_eq(json["mapSeed"], 42)
	assert_eq(json["player"], "Nemo")
	assert_eq(json["lastTurn"], 1)
	assert_eq(json["exact"], true)


func test_a_game_saved_before_the_journal_cannot_be_exported() -> void:
	var game := GameFactory.new_single_player("Nemo")
	game.replay = null

	assert_false(ReplayExport.can_export(game))


func test_a_game_saved_before_the_leviathan_return_is_not_exact() -> void:
	var game := GameFactory.new_single_player("Nemo")
	game.leviathan_return = null

	assert_true(game.replay.exact)
	assert_false(ReplayExport.is_exact(game))
	assert_eq(ReplayExport.to_json(game)["exact"], false)


func test_names_the_file_after_the_player_and_the_turn() -> void:
	var game := GameFactory.new_single_player("Le Nautile")

	assert_eq(ReplayExport.file_name(game), "replay-Le_Nautile-tour-1.json")


## Not in the Dart file: a game without journal is named after "partie",
## and every character but letters, digits, `_` and `-` becomes `_`.
func test_names_a_file_without_journal_after_partie() -> void:
	var game := GameFactory.new_single_player("é-è_x 9!")
	assert_eq(ReplayExport.file_name(game), "replay-_-__x_9_-tour-1.json")
	game.replay = null
	game.turn = 7
	assert_eq(ReplayExport.file_name(game), "replay-partie-tour-7.json")


## Not in the Dart file: the whole scenario, its keys in the Dart order, its
## turns and seeds sorted, as Dart's `JsonEncoder.withIndent('  ')` writes
## it (printed by a scratch Dart script).
func test_writes_the_scenario_as_dart_does() -> void:
	var game := GameFactory.new_game("Nemo", 42, Difficulty.Value.HARD, false, 1)
	game.replay.actions[3] = ['{"do":"spy","target":"human","player":"x"}'] as Array[String]
	game.replay.actions[1] = ['{"do":"upgrade","building":"algaeFarm"}'] as Array[String]
	game.replay.end_turn_seeds[2] = 5
	game.replay.end_turn_seeds[1] = 4
	game.turn = 3

	assert_eq(ReplayExport.to_text(game), "\n".join([
		'{', '  "name": "replay-Nemo-tour-3",', '  "player": "Nemo",', '  "players": [', '    {',
		'      "id": "%s",' % game.human_player_id, '      "name": "Nemo"', '    },', '    {',
		'      "id": "faction-krakenFaithful",', '      "name": "Les Fidèles du Kraken"',
		'    }', '  ],', '  "factions": [', '    "krakenFaithful"', '  ],', '  "mapSeed": 42,',
		'  "difficulty": "hard",', '  "lastTurn": 3,', '  "exact": true,', '  "status": "playing",',
		'  "turns": {', '    "1": [', '      {', '        "do": "upgrade",', '        "building": "algaeFarm"',
		'      }', '    ],', '    "3": [', '      {', '        "do": "spy",', '        "target": "human",',
		'        "player": "x"', '      }', '    ]', '  },', '  "endTurnSeeds": {', '    "1": 4,', '    "2": 5',
		'  }', '}',
	]))
