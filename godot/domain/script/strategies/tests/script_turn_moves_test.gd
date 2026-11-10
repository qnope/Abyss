extends TestCase
## Not in the Dart files: the common moves of the strategies, the best
## defender the barracks trains, a share of the recruits, the buildings
## raised round after round, and the economy strategy that does nothing
## else.

const BARRACKS := BuildingType.Value.BARRACKS
const HARPOONIST := UnitType.Value.HARPOONIST


func _turn(levels: Dictionary[BuildingType.Value, int], algae := 1000) -> ScriptTurn:
	var player := ActionSamples.stocked(ActionSamples.amounts(algae, 1000, 1000, 1000, 0), levels)
	return ScriptSamples.turn(ActionSamples.game_of(player))


func test_the_best_defender_follows_the_barracks() -> void:
	assert_null(ScriptTurnMoves.best_defender(_turn({BARRACKS: 0})))
	assert_eq(ScriptTurnMoves.best_defender(_turn({BARRACKS: 1})), HARPOONIST)
	assert_eq(ScriptTurnMoves.best_defender(_turn({BARRACKS: 2})), HARPOONIST)
	assert_eq(ScriptTurnMoves.best_defender(_turn({BARRACKS: 3})), UnitType.Value.GUARDIAN)


func test_a_share_of_the_affordable_recruits_joins() -> void:
	var turn := _turn({BARRACKS: 1}, 150)
	assert_eq(ScriptTurnMoves.recruit_share(turn, HARPOONIST, 0.5), 5)
	assert_eq(turn.player.units_on_level(1)[HARPOONIST].count, 5)
	assert_eq(ScriptTurnMoves.recruit_share(turn, HARPOONIST, 0.5), 0, "once a turn")


func test_a_share_rounding_down_to_nothing_recruits_nothing() -> void:
	var turn := _turn({BARRACKS: 1}, 15)
	assert_eq(ScriptTurnMoves.recruit_share(turn, HARPOONIST, 0.9), 0)
	assert_eq(ScriptTurnMoves.recruit_share(_turn({BARRACKS: 0}), HARPOONIST, 1.0), 0)


func test_the_buildings_go_up_round_after_round_until_none_can() -> void:
	var levels: Dictionary[BuildingType.Value, int] = {
		BuildingType.Value.HEADQUARTERS: 10, BuildingType.Value.ALGAE_FARM: 0,
		BuildingType.Value.SOLAR_PANEL: 0,
	}
	var turn := _turn(levels, 100000)
	var order: Array[BuildingType.Value] = [BuildingType.Value.ALGAE_FARM, BuildingType.Value.SOLAR_PANEL]
	ScriptTurnMoves.upgrade_in_order(turn, order)
	var buildings := turn.player.buildings
	assert_eq(buildings[BuildingType.Value.ALGAE_FARM].level, 2, "three sites at level 10")
	assert_eq(buildings[BuildingType.Value.SOLAR_PANEL].level, 1)


func test_the_economy_strategy_grows_and_trains_nobody() -> void:
	var game := GameFactory.new_single_player("human", 3)
	var player := game.human_player()
	player.resources[ResourceType.Value.CORAL].amount = 1000
	player.resources[ResourceType.Value.ORE].amount = 1000
	EconomyStrategy.new().play_turn(ScriptSamples.turn(game))
	assert_eq(Building.level_in(player.buildings, BuildingType.Value.HEADQUARTERS), 1)
	assert_eq(player.units_on_level(1)[HARPOONIST].count, 0)
