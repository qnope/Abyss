extends TestCase
## test/domain/script/strategies/tutorial_strategy_test.dart: the strategy
## of the tutorial, through whole turns. Its last test, 'is a strategy of the
## library', reads ScriptLibrary and waits for the runners of `script`.

const HARPOONIST := UnitType.Value.HARPOONIST


static func _game() -> Game:
	return GameFactory.new_single_player("p", 5, Difficulty.Value.NORMAL, true)


## Plays `turns` turns of `game` with `script`; returns the log.
static func _play(script: GameScript, game: Game, turns: int) -> Array[ScriptLogEntry]:
	var random := DartRandom.new(1, false)
	var log_: Array[ScriptLogEntry] = []
	for _i: int in turns:
		script.play_turn(ScriptTurn.new(game, random, log_))
		ActionExecutor.new().execute(EndTurnAction.new(random), game, game.human_player())
	return log_


func test_reaches_the_objectives_of_the_first_chapter_one_after_the_other() -> void:
	var game := _game()

	_play(TutorialStrategy.new(), game, 12)

	var completed := game.human_player().saved_objective_state.completed
	var expected: Array[ObjectiveId.Value] = []
	for objective: Objective in InstallationObjectives.installation_objectives().slice(0, 9):
		expected.append(objective.id)
	assert_eq(completed.slice(0, 9), expected)


func test_builds_nothing_the_tutorial_does_not_ask_for() -> void:
	var game := _game()

	_play(TutorialStrategy.new(), game, 9)

	var buildings := game.human_player().buildings
	assert_eq(buildings[BuildingType.Value.CORAL_CITADEL].level, 0)
	assert_true(buildings[BuildingType.Value.HEADQUARTERS].level <= 2)
	assert_true(buildings[BuildingType.Value.ALGAE_FARM].level <= 1)


func test_recruits_defenders_for_a_raid_announced_during_the_tutorial() -> void:
	var game := _game()
	_play(TutorialStrategy.new(), game, 7)
	var player := game.human_player()
	assert_eq(player.buildings[BuildingType.Value.BARRACKS].level, 1)
	player.raid_state.announce(RaidWaveFactory.from_total_noise(40, DartRandom.new(1, false)), game.turn + 2)

	_play(TutorialStrategy.new(), game, 1)

	assert_true(player.units_on_level(1)[HARPOONIST].count > 0)


func test_recruits_the_harpoonists_the_guide_advises_for_the_first_raid() -> void:
	var game := _game()
	_play(TutorialStrategy.new(), game, 7)
	var player := game.human_player()
	var wave := RaidWaveFactory.from_total_noise(40, DartRandom.new(3, false))
	player.raid_state.announce(wave, game.turn + 2)

	_play(TutorialStrategy.new(), game, 1)

	var needed: int = RaidDefenceAdvisor.harpoonists_for(player, wave)
	assert_true(needed > 0)
	assert_eq(player.units_on_level(1)[HARPOONIST].count, needed)


func test_still_recruits_defenders_when_no_advice_can_hold_the_raid() -> void:
	var game := _game()
	_play(TutorialStrategy.new(), game, 7)
	var player := game.human_player()
	var wave := MonsterLair.new(MonsterDifficulty.Value.HARD, 40, MonsterFamily.Value.COLOSSUS)
	player.raid_state.announce(wave, game.turn + 2)
	assert_null(RaidDefenceAdvisor.harpoonists_for(player, wave))
	var before := player.units_on_level(1)[HARPOONIST].count

	_play(TutorialStrategy.new(), game, 1)

	assert_true(player.units_on_level(1)[HARPOONIST].count > before)


func test_plays_like_the_careful_script_once_the_first_raid_is_fought() -> void:
	var tutorial := _game()
	tutorial.human_player().raid_state.raids_repelled = 1
	var conquest := _game()
	conquest.human_player().raid_state.raids_repelled = 1

	var played := _play(TutorialStrategy.new(), tutorial, 6)
	var expected := _play(ConquestStrategy.new(), conquest, 6)

	var described := func(e: ScriptLogEntry) -> String: return e.description
	assert_eq(played.map(described), expected.map(described))


## Not in the Dart file: the name the library would list it under.
func test_is_named_tutorial() -> void:
	assert_eq(TutorialStrategy.new().name(), "tutorial")
