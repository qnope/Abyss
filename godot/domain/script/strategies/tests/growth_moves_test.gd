extends TestCase
## test/domain/script/strategies/growth_moves_test.dart: the energy margin
## and a research plan of its own.

const Branch := TechBranch.Value
const PLAN: Array[Branch] = [Branch.EXPLORER, Branch.RESOURCES]


func _turn() -> ScriptTurn:
	return ScriptSamples.turn(GameFactory.new_single_player("p", 5))


func test_the_energy_margin_counts_the_heating_of_the_farms() -> void:
	var calm := _turn()
	var heated := _turn()
	heated.player.event_state.activate(RandomEventType.Value.COLD_CURRENT, heated.game.turn)
	heated.player.event_state.heating = true
	assert_eq(
		GrowthMoves.energy_margin(heated),
		GrowthMoves.energy_margin(calm) - EventRules.HEATING_ENERGY_PER_TURN,
	)


## `labTurn` of the group: the laboratory at 2, every stock empty.
func _lab_turn() -> ScriptTurn:
	var turn := _turn()
	turn.player.buildings[BuildingType.Value.LABORATORY].level = 2
	for r: GameResource in turn.player.resources.values():
		r.amount = 0
	return turn


func test_research_with_a_plan_of_its_own_skips_an_explorer_node_it_cannot_pay_and_goes_on() -> void:
	var turn := _lab_turn()
	turn.player.resources[ResourceType.Value.CORAL].amount = 1000
	turn.player.resources[ResourceType.Value.ALGAE].amount = 1000

	GrowthMoves.research(turn, PLAN)

	assert_false(turn.player.tech_branches[Branch.EXPLORER].unlocked)
	assert_eq(turn.player.tech_branches[Branch.RESOURCES].research_level, 1)


func test_research_with_a_plan_of_its_own_a_lab_too_low_still_stops_the_plan() -> void:
	var turn := _lab_turn()
	turn.player.buildings[BuildingType.Value.LABORATORY].level = 1
	for r: GameResource in turn.player.resources.values():
		r.amount = 1000
	var explorer := turn.player.tech_branches[Branch.EXPLORER]
	explorer.unlocked = true
	explorer.research_level = 1

	GrowthMoves.research(turn, [Branch.EXPLORER, Branch.EXPLORER, Branch.RESOURCES])

	assert_eq(explorer.research_level, 1)
	assert_false(turn.player.tech_branches[Branch.RESOURCES].unlocked)


func test_research_with_a_plan_of_its_own_the_default_plan_still_waits_for_what_it_cannot_pay() -> void:
	var turn := _lab_turn()
	turn.player.resources[ResourceType.Value.ORE].amount = 1000
	turn.player.resources[ResourceType.Value.ENERGY].amount = 1000

	GrowthMoves.research(turn)

	assert_false(turn.player.tech_branches[Branch.RESOURCES].unlocked)
	assert_false(turn.player.tech_branches[Branch.MILITARY].unlocked)
