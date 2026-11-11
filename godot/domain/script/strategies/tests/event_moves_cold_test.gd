extends TestCase
## test/domain/script/strategies/event_moves_cold_test.dart: whether a
## script heats its farms through a cold current.

const HEATING := EventRules.HEATING_ENERGY_PER_TURN


## Turn of a cold current for a base whose farms make about 230 algae, fed
## to `guardians`, with `algae` in stock and Solar Panels at `solar`.
func _cold(guardians := 0, algae := 0, solar := 15) -> ScriptTurn:
	var player := EventSamples.producing_player()
	player.buildings[BuildingType.Value.SOLAR_PANEL].level = solar
	player.units_on_level(1)[UnitType.Value.GUARDIAN].count = guardians
	player.resources[ResourceType.Value.ALGAE].amount = algae
	return EventMoveSamples.choice_turn(player, RandomEventType.Value.COLD_CURRENT)


func _choice(turn: ScriptTurn) -> Variant:
	EventMoves.choose_event(turn, ArmyPlanner.new())
	return EventMoveSamples.choice_of(turn.player)


func test_the_farms_are_heated_when_the_cut_would_starve_the_units() -> void:
	var turn := _cold(70, 100)
	assert_true(RecruitMoves.algae_margin(turn) > 0)
	assert_true(GrowthMoves.energy_margin(turn) >= HEATING)
	assert_eq(_choice(turn), true)
	assert_true(turn.player.event_state.heating)


func test_endured_when_the_margin_stays_fine_under_the_cut_whatever_the_energy() -> void:
	var turn := _cold(0, 0, 25)
	assert_true(GrowthMoves.energy_margin(turn) > 10 * HEATING)
	assert_eq(_choice(turn), false)
	assert_false(turn.player.event_state.heating)


func test_endured_when_the_stock_feeds_the_units_through_the_three_turns() -> void:
	assert_eq(_choice(_cold(70, 400)), false)


func test_endured_when_the_energy_margin_cannot_pay_the_heating() -> void:
	var turn := _cold(70, 100, 1)
	assert_true(GrowthMoves.energy_margin(turn) < HEATING)
	assert_eq(_choice(turn), false)
