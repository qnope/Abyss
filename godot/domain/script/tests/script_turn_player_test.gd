extends TestCase
## test/domain/script/script_turn_player_test.dart: a turn plays the human
## unless it is given another player.


func _levels(player: Player) -> Dictionary[BuildingType.Value, int]:
	var levels: Dictionary[BuildingType.Value, int] = {}
	for type: BuildingType.Value in player.buildings:
		levels[type] = player.buildings[type].level
	return levels


func _stocks(player: Player) -> Dictionary[ResourceType.Value, int]:
	var stocks: Dictionary[ResourceType.Value, int] = {}
	for type: ResourceType.Value in player.resources:
		stocks[type] = player.resources[type].amount
	return stocks


func test_a_turn_plays_the_human_player_unless_told_otherwise() -> void:
	var game := GameSamples.two_players()
	var turn := ScriptTurn.new(game, DartRandom.new(1, false), [])
	assert_true(turn.player == game.human_player())


func test_a_turn_given_another_player_acts_for_that_player_only() -> void:
	var game := GameSamples.two_players()
	var human := game.human_player()
	var rival := AssaultSamples.rival_of(game)
	var human_levels := _levels(human)
	var human_stocks := _stocks(human)
	var rival_levels := _levels(rival)
	var rival_stocks := _stocks(rival)
	var turn := ScriptTurn.new(game, DartRandom.new(1, false), [], rival)

	assert_true(turn.player == rival)
	assert_true(turn.perform(UpgradeBuildingAction.new(BuildingType.Value.HEADQUARTERS)).is_success)
	EconomyStrategy.new().play_turn(turn)

	assert_ne(_levels(rival), rival_levels)
	assert_ne(_stocks(rival), rival_stocks)
	assert_eq(_levels(human), human_levels)
	assert_eq(_stocks(human), human_stocks)
