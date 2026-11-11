extends TestCase
## test/domain/script/script_runner_faction_win_test.dart.

const RIVAL_ID := "faction-magmaSmiths"


func test_in_a_live_game_a_faction_tames_the_volcano_while_the_turn_ends_and_the_turn_ends_all_the_same() -> void:
	var game := _game_before_the_rival_wins()

	ActionExecutor.new().execute(EndTurnAction.new(DartRandom.new(7)), game, game.human_player())

	assert_eq(VictoryChecker.winner_of(game).id, RIVAL_ID)
	assert_true(game.replay.actions_of(1).any(func(a: Dictionary) -> bool:
		return a.get("building") == "volcanicKernel"))
	assert_eq(game.status, GameStatus.Value.DEFEAT)
	assert_eq(game.turn, 2)
	assert_true(_ended_turn_one(game))


func test_its_replay_which_plays_the_move_of_the_faction_before_ending_the_turn_ends_that_turn_too() -> void:
	var game := _game_before_the_rival_wins()

	ScriptRunner.new().run_on(game, _replay({1: 7}), DartRandom.new(1, false), 1)

	assert_eq(game.status, GameStatus.Value.DEFEAT)
	assert_eq(game.turn, 2)
	assert_true(_ended_turn_one(game))
	assert_eq(game.replay.end_turn_seeds, {1: 7})


func test_a_timeline_that_recorded_no_end_for_that_turn_stops_there() -> void:
	var game := _game_before_the_rival_wins()

	ScriptRunner.new().run_on(game, _replay({}), DartRandom.new(1, false), 1)

	assert_eq(game.status, GameStatus.Value.DEFEAT)
	assert_eq(game.turn, 1)
	assert_false(_ended_turn_one(game))


func test_a_game_the_human_wins_still_stops_on_the_winning_move() -> void:
	var game := _game_before_the_rival_wins()
	var human := game.human_player()
	var rival: Player = game.players[RIVAL_ID]
	_hold_kernel(game, human.id)
	for type: BuildingType.Value in [BuildingType.Value.HEADQUARTERS, BuildingType.Value.VOLCANIC_KERNEL]:
		human.buildings[type].level = rival.buildings[type].level
	for resource: GameResource in human.resources.values():
		resource.amount = resource.max_storage
	var turns: Dictionary[int, Array] = {1: [_last_level]}
	var seeds: Dictionary[int, int] = {1: 7}

	ScriptRunner.new().run_on(
		game, TimelineScript.new("replay", turns, null, null, null, null, null, [], seeds),
		DartRandom.new(1, false), 1,
	)

	assert_eq(game.status, GameStatus.Value.VICTORY)
	assert_eq(game.turn, 1)


## A game where the faction holds the kernel at level 9 and can pay for the
## last level: its next upgrade tames the volcano.
static func _game_before_the_rival_wins() -> Game:
	var factions: Array[FactionPersonality.Value] = [FactionPersonality.Value.MAGMA_SMITHS]
	var game := GameFactory.new_game("Nemo", 5, Difficulty.Value.NORMAL, false, 0, factions)
	var rival: Player = game.players[RIVAL_ID]
	_hold_kernel(game, RIVAL_ID)
	rival.buildings[BuildingType.Value.HEADQUARTERS].level = 10
	rival.buildings[BuildingType.Value.VOLCANIC_KERNEL].level = 9
	for resource: GameResource in rival.resources.values():
		resource.amount = resource.max_storage
	return game


static func _hold_kernel(game: Game, holder: String) -> void:
	var deep: GameMap = game.levels[3]
	for i: int in deep.cells.size():
		if deep.cells[i].content == CellContentType.Value.VOLCANIC_KERNEL:
			deep.cells[i] = deep.cells[i].copy_with({"collected_by": holder})
			return


static func _last_level(_r: DartRandom) -> Action:
	return UpgradeBuildingAction.new(BuildingType.Value.VOLCANIC_KERNEL)


static func _replay(end_turn_seeds: Dictionary[int, int]) -> TimelineScript:
	var turns: Dictionary[int, Array] = {1: [_last_level]}
	var actors: Dictionary[int, Array] = {1: [RIVAL_ID]}
	return TimelineScript.new("replay", turns, null, null, null, null, 2, [], end_turn_seeds, actors)


static func _ended_turn_one(game: Game) -> bool:
	return game.human_player().history_entries.any(func(e: HistoryEntry) -> bool:
		return e is TurnEndEntry and e.turn == 1)
