extends TestCase
## Not in the Dart files (lib/domain/turn/turn_production.dart has no test
## of its own; the turn resolver's tests wait for `turn`): what a base makes
## and burns, shut buildings apart, scaled by the difficulty and the events.

const ALGAE := ResourceType.Value.ALGAE
const ENERGY := ResourceType.Value.ENERGY
const FARM := BuildingType.Value.ALGAE_FARM
const SOLAR := BuildingType.Value.SOLAR_PANEL


func _player(energy := 0) -> Player:
	var levels: Dictionary[BuildingType.Value, int] = {FARM: 3, SOLAR: 1}
	var player := Player.new("P", null, 0, 0, null, DomainSamples.base(4, levels))
	player.resources[ENERGY].amount = energy
	return player


func test_a_shut_building_makes_nothing_and_the_map_of_the_player_stays() -> void:
	var player := _player()
	var shut: Array[BuildingType.Value] = [FARM]
	var made := TurnProduction.of(player, 1, Difficulty.Value.NORMAL, shut)
	var full := TurnProduction.of(player, 1, Difficulty.Value.NORMAL)
	assert_false(ProductionCalculator.HEADQUARTERS_INCOME.has(ALGAE))
	assert_false(made.has(ALGAE))
	assert_true(full[ALGAE] > 0)
	assert_eq(player.buildings[FARM].level, 3)


func test_the_difficulty_and_the_faction_percent_scale_what_is_made() -> void:
	var player := _player()
	var raw := ProductionCalculator.from_buildings(player.buildings)[ALGAE]
	var hard := TurnProduction.of(player, 1, Difficulty.Value.HARD)
	var faction := TurnProduction.of(player, 1, Difficulty.Value.HARD, [], true)
	assert_eq(hard[ALGAE], DartMath.trunc_div(raw * Difficulty.resource_percent(Difficulty.Value.HARD), 100))
	assert_eq(faction[ALGAE], DartMath.trunc_div(raw * Difficulty.faction_percent(Difficulty.Value.HARD), 100))


func test_a_cold_current_cuts_the_farms_and_its_heating_burns_energy() -> void:
	var player := _player()
	var before := TurnProduction.of(player, 2, Difficulty.Value.NORMAL)[ALGAE]
	var burnt := TurnProduction.energy_consumption(player, 2)
	player.event_state.activate(RandomEventType.Value.COLD_CURRENT, 3)
	assert_true(TurnProduction.of(player, 2, Difficulty.Value.NORMAL)[ALGAE] < before)
	assert_eq(TurnProduction.energy_consumption(player, 2), burnt)
	player.event_state.heating = true
	assert_eq(TurnProduction.energy_consumption(player, 2), burnt + EventRules.HEATING_ENERGY_PER_TURN)
	var shut: Array[BuildingType.Value] = [FARM]
	var farm := ConsumptionCalculator.building_energy_consumption(FARM, 3)
	assert_eq(TurnProduction.energy_consumption(player, 2, shut), burnt - farm + EventRules.HEATING_ENERGY_PER_TURN)


func test_the_buildings_shut_for_lack_of_energy_pay_the_heating_first() -> void:
	var player := _player()
	var burnt := TurnProduction.energy_consumption(player, 1)
	var enough: Dictionary[ResourceType.Value, int] = {ENERGY: burnt}
	assert_true(TurnProduction.deactivated(player, enough, 1).is_empty())
	player.event_state.activate(RandomEventType.Value.COLD_CURRENT, 3)
	player.event_state.heating = true
	assert_false(TurnProduction.deactivated(player, enough, 1).is_empty())
	player.resources[ENERGY].amount = EventRules.HEATING_ENERGY_PER_TURN
	assert_true(TurnProduction.deactivated(player, enough, 1).is_empty(), "the stock pays")
	assert_false(TurnProduction.deactivated(_player(), {}, 1).is_empty())
