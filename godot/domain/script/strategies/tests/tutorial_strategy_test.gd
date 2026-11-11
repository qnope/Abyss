extends TestCase
## test/domain/script/strategies/tutorial_strategy_test.dart: its tests play
## whole turns through EndTurnAction, and its last one reads ScriptLibrary:
## they wait for `turn` and the runners of `script` (domain/README.md, "Left
## for a later lot"). Meanwhile, not in the Dart file: one turn of the
## strategy, its steps without an end of turn.


static func _game() -> Game:
	return GameFactory.new_single_player("p", 5, Difficulty.Value.NORMAL, true)


static func _turn(game: Game, log_: Array[ScriptLogEntry]) -> ScriptTurn:
	return ScriptTurn.new(game, DartRandom.new(1, false), log_)


func test_it_plays_the_first_step_of_the_guide() -> void:
	var game := _game()
	var log_: Array[ScriptLogEntry] = []

	TutorialStrategy.new().play_turn(_turn(game, log_))

	assert_true(log_.size() > 0, "the step played its actions")
	assert_true(log_.all(func(e: ScriptLogEntry) -> bool: return e.success))


func test_it_recruits_against_a_raid_announced_during_the_tutorial() -> void:
	var game := _game()
	var player := game.human_player()
	player.buildings[BuildingType.Value.BARRACKS].level = 1
	for r: GameResource in player.resources.values():
		r.amount = 5000
	player.raid_state.announce(MonsterLair.new(MonsterDifficulty.Value.EASY, 4), game.turn + 2)

	TutorialStrategy.new().play_turn(_turn(game, []))

	assert_true(player.units_on_level(1)[UnitType.Value.HARPOONIST].count > 0)


func test_it_plays_like_the_careful_script_once_the_first_raid_is_fought() -> void:
	var tutorial := _game()
	var conquest := _game()
	tutorial.human_player().raid_state.raids_repelled = 1
	conquest.human_player().raid_state.raids_repelled = 1
	var played: Array[ScriptLogEntry] = []
	var expected: Array[ScriptLogEntry] = []

	TutorialStrategy.new().play_turn(_turn(tutorial, played))
	ConquestStrategy.new().play_turn(_turn(conquest, expected))

	assert_eq(TutorialStrategy.new().name(), "tutorial")
	assert_eq(played.map(func(e: ScriptLogEntry) -> String: return e.description),
		expected.map(func(e: ScriptLogEntry) -> String: return e.description))
