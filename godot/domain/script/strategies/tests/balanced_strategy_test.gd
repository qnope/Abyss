extends TestCase
## Not in the Dart files (strategies_test.dart plays whole games, which
## wait for `turn`): the options of the research plan, the farms that wait
## for the energy, and a turn of the balanced strategy.

const Branch := TechBranch.Value
const FARM := BuildingType.Value.ALGAE_FARM
const SOLAR := BuildingType.Value.SOLAR_PANEL
const HARPOONIST := UnitType.Value.HARPOONIST
const GUARDIAN := UnitType.Value.GUARDIAN


func _turn(levels: Dictionary[BuildingType.Value, int], energy := 0) -> ScriptTurn:
	var player := ActionSamples.stocked(ActionSamples.amounts(5000, 5000, 5000, energy, 0), levels)
	return ScriptSamples.turn(ActionSamples.game_of(player))


func test_the_choice_nodes_take_the_options_of_the_picks() -> void:
	var turn := _turn({BuildingType.Value.HEADQUARTERS: 1})
	var expected: Dictionary[Branch, Array] = {
		Branch.MILITARY: [TechOption.Value.A, TechOption.Value.B, TechOption.Value.A, TechOption.Value.A],
		Branch.EXPLORER: [TechOption.Value.A, TechOption.Value.B, TechOption.Value.A, TechOption.Value.B],
	}
	for branch: Branch in expected:
		var options: Array = expected[branch]
		for level: int in 4:
			turn.player.tech_branches[branch].research_level = level
			var next := GrowthMoves.research_next(turn, branch)
			assert_eq(next.option, options[level], "%d at %d" % [branch, level])
			assert_eq(next.branch, branch)


func test_a_farm_that_would_leave_the_base_short_waits_for_a_solar_panel() -> void:
	var turn := _turn({BuildingType.Value.HEADQUARTERS: 1, FARM: 1, SOLAR: 0})
	assert_true(GrowthMoves.energy_margin(turn) < 0)
	GrowthMoves.grow_in_order(turn, [FARM])
	assert_eq(turn.player.buildings[SOLAR].level, 1)
	assert_eq(turn.player.buildings[FARM].level, 1)


func test_with_energy_to_spare_the_farm_goes_up() -> void:
	var turn := _turn({BuildingType.Value.HEADQUARTERS: 3, FARM: 1, SOLAR: 3})
	GrowthMoves.grow_in_order(turn, [FARM, SOLAR])
	assert_eq(turn.player.buildings[FARM].level, 2)
	assert_eq(turn.player.buildings[SOLAR].level, 3)


func test_the_balanced_strategy_recruits_researches_then_builds() -> void:
	var levels: Dictionary[BuildingType.Value, int] = {
		BuildingType.Value.HEADQUARTERS: 3, BuildingType.Value.BARRACKS: 3,
		BuildingType.Value.LABORATORY: 1, SOLAR: 0,
	}
	var turn := _turn(levels, 1000)
	var strategy := BalancedStrategy.new()
	strategy.play_turn(turn)
	var units := turn.player.units_on_level(1)
	assert_eq(strategy.name(), "balanced")
	assert_true(units[GUARDIAN].count > 0)
	assert_true(units[HARPOONIST].count > 0)
	assert_eq(turn.player.tech_branches[Branch.MILITARY].research_level, 1)
	assert_eq(turn.player.buildings[SOLAR].level, 1)


func test_on_alert_the_harpoonists_alone_take_a_larger_share() -> void:
	var quiet := _turn({BuildingType.Value.HEADQUARTERS: 1, BuildingType.Value.BARRACKS: 1})
	var alert := _turn({BuildingType.Value.HEADQUARTERS: 1, BuildingType.Value.BARRACKS: 1})
	alert.player.raid_state.announce(MonsterLair.new(MonsterDifficulty.Value.EASY, 3), 4)
	BalancedStrategy.new().play_turn(quiet)
	BalancedStrategy.new(0.25, 0.5).play_turn(alert)
	var calm := quiet.player.units_on_level(1)[HARPOONIST].count
	assert_eq(calm, floori(100 * 0.25), "the barracks trains 100 at most")
	assert_eq(alert.player.units_on_level(1)[HARPOONIST].count, floori(100 * 0.5))
	assert_eq(quiet.player.units_on_level(1)[GUARDIAN].count, 0)
	var bare := _turn({BuildingType.Value.HEADQUARTERS: 1})
	BalancedStrategy.new().play_turn(bare)
	assert_eq(bare.player.units_on_level(1)[HARPOONIST].count, 0)
