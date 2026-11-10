extends TestCase
## Not in the Dart files: what a turn logs, its refusals once the game is
## over, the victory an action brings, a turn played for another player,
## and the defaults of a GameScript.

const HQ := BuildingType.Value.HEADQUARTERS


func test_a_turn_logs_each_action_it_performs_with_its_outcome() -> void:
	var log_: Array[ScriptLogEntry] = []
	var game := GameSamples.two_players()
	game.turn = 4
	var turn := ScriptSamples.turn(game, null, 1, log_)
	assert_eq(turn.number(), 4)
	assert_true(turn.perform(UpgradeBuildingAction.new(HQ)).is_success)
	assert_false(turn.try_perform(RecruitUnitAction.new(UnitType.Value.SCOUT, 1)))
	assert_false(turn.perform(RecruitUnitAction.new(UnitType.Value.SCOUT, 1)).is_success)
	assert_eq(log_.size(), 2)
	assert_eq(str(log_[0]), "T4 ✓ Ameliorer BuildingType.headquarters")
	assert_eq(log_[1].reason, ActionFailure.Value.UNIT_LOCKED)
	assert_eq(str(log_[1]), "T4 ✗ Recruter 1 UnitType.scout (unitLocked)")
	assert_eq(str(ScriptLogEntry.new(2, "x", false)), "T2 ✗ x (null)")


func test_once_the_game_is_over_nothing_is_allowed_nor_logged() -> void:
	var log_: Array[ScriptLogEntry] = []
	var game := GameSamples.two_players()
	game.status = GameStatus.Value.DEFEAT
	var turn := ScriptSamples.turn(game, null, 1, log_)
	assert_true(turn.is_over())
	assert_false(turn.allows(UpgradeBuildingAction.new(HQ)))
	assert_eq(turn.perform(UpgradeBuildingAction.new(HQ)).reason, ActionFailure.Value.GAME_OVER)
	assert_true(log_.is_empty())
	assert_eq(Building.level_in(game.human_player().buildings, HQ), 0)


func test_an_action_that_tames_the_volcano_wins_the_game() -> void:
	var game := GameSamples.two_players()
	var turn := ScriptSamples.turn(game)
	assert_true(turn.perform(UpgradeBuildingAction.new(HQ)).is_success)
	assert_eq(game.status, GameStatus.Value.PLAYING)
	var buildings := game.human_player().buildings
	buildings[BuildingType.Value.VOLCANIC_KERNEL].level = 10
	buildings[HQ].level = 10
	assert_true(turn.perform(UpgradeBuildingAction.new(BuildingType.Value.ALGAE_FARM)).is_success)
	assert_eq(game.status, GameStatus.Value.VICTORY)


func test_the_same_turn_played_for_another_player_shares_its_dice_and_log() -> void:
	var log_: Array[ScriptLogEntry] = []
	var game := GameSamples.two_players()
	var turn := ScriptSamples.turn(game, null, 1, log_)
	var rival := AssaultSamples.rival_of(game)
	var other := turn.as_player(rival)
	assert_true(other.player == rival)
	assert_true(other.random() == turn.random())
	other.perform(UpgradeBuildingAction.new(HQ))
	assert_eq(log_.size(), 1)
	assert_eq(Building.level_in(rival.buildings, HQ), 1)


func test_a_script_keeps_the_defaults_of_a_game_script() -> void:
	var script := IdleScript.new()
	var game := GameSamples.two_players()
	script.play_turn(ScriptSamples.turn(game))
	assert_eq(script.name(), "idle")
	assert_eq(script.player_name(), "idle")
	assert_null(script.map_seed())
	assert_null(script.difficulty())
	assert_true(script.factions().is_empty())
	assert_true(script.factions_play())
	assert_null(script.last_turn())
	assert_null(script.end_turn_random(3))
	assert_eq(EconomyStrategy.new().name(), "economy")
