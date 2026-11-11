extends TestCase
## test/domain/resource/consumption_integration_test.dart: the energy and
## the algae spent over ends of turn, and the buildings shut down.

const B := BuildingType.Value
const ENERGY := ResourceType.Value.ENERGY
const ALGAE := ResourceType.Value.ALGAE


static func _game(buildings: Variant = null, resources: Variant = null, units_per_level: Variant = null) -> Game:
	return Game.single_player(Player.new("Test", null, 0, 0, resources, buildings, null, units_per_level))


static func _b(levels: Dictionary[BuildingType.Value, int]) -> Dictionary[BuildingType.Value, Building]:
	return DomainSamples.buildings(levels)


## The default stocks, with `energy` of `max_storage`.
static func _energy(amount: int, max_storage: int) -> Dictionary[ResourceType.Value, GameResource]:
	var resources := PlayerDefaults.resources()
	resources[ENERGY] = GameResource.new(ENERGY, amount, max_storage)
	return resources


func test_full_consumption_scenario_over_multiple_turns() -> void:
	# Energy: prod=19, cons=21 => net -2/turn
	# Algae: prod=50, cons=10 (scouts) => net +40/turn
	var units: Dictionary[UnitType.Value, Unit] = PlayerDefaults.units_per_level()[1]
	units[UnitType.Value.SCOUT] = Unit.new(UnitType.Value.SCOUT, 10)
	var per_level: Dictionary[int, Dictionary] = {1: units}
	var game := _game(
		_b({B.HEADQUARTERS: 1, B.ALGAE_FARM: 1, B.SOLAR_PANEL: 1, B.BARRACKS: 5}), _energy(40, 2000), per_level
	)
	var player := game.human_player()
	# Keep random events out too: a cold current would cut the algae.
	player.event_state.schedule(1000)
	var resolver := TurnResolver.new()

	# Turn 1: energy 40->38, algae 100->140
	var result := resolver.resolve(game)
	assert_eq(player.resources[ENERGY].amount, 38)
	assert_eq(player.resources[ALGAE].amount, 140)
	assert_true(result.deactivated_buildings.is_empty())

	# Turns 2-20: energy drains by 2 each turn
	for i: int in 19:
		# Keep raids out of this energy scenario: a pillage would drain it.
		player.raid_state.noise = 0
		result = resolver.resolve(game)
		assert_true(result.deactivated_buildings.is_empty(), str(i))
	assert_eq(player.resources[ENERGY].amount, 0)
	assert_eq(player.resources[ALGAE].amount, 900)

	# Turn 21: stock=0, available=19 < consumption=21 => deactivation
	result = resolver.resolve(game)
	assert_false(result.deactivated_buildings.is_empty())
	assert_has(result.deactivated_buildings, B.ALGAE_FARM)
	# Deactivated buildings produce nothing
	assert_eq(player.resources[ENERGY].amount, 0)
	assert_eq(player.resources[ALGAE].amount, 890)


func test_no_consumption_with_empty_game() -> void:
	var game := _game()
	var player := game.human_player()
	var energy_before := player.resources[ENERGY].amount
	var algae_before := player.resources[ALGAE].amount

	var result := TurnResolver.new().resolve(game)

	assert_true(result.deactivated_buildings.is_empty())
	assert_true(result.lost_units.is_empty())
	assert_true(result.changes.is_empty())
	assert_eq(player.resources[ENERGY].amount, energy_before)
	assert_eq(player.resources[ALGAE].amount, algae_before)


func test_consumption_below_production_fills_the_stock() -> void:
	# SolarPanel lvl 2 produces 59, total consumption = 54
	# HQ(18)+SolarPanel(2)+Barracks(18)+AlgaeFarm(10)+OreExtractor(6)
	var game := _game(_b({
		B.SOLAR_PANEL: 2, B.HEADQUARTERS: 6, B.BARRACKS: 6, B.ALGAE_FARM: 5, B.ORE_EXTRACTOR: 2,
	}))
	var player := game.human_player()
	var energy_before := player.resources[ENERGY].amount
	var result := TurnResolver.new().resolve(game)

	assert_true(result.deactivated_buildings.is_empty())
	assert_eq(player.resources[ENERGY].amount, energy_before + 5)


func test_deactivation_restores_next_turn_when_conditions_improve() -> void:
	var game := _game(
		_b({B.HEADQUARTERS: 3, B.ALGAE_FARM: 1, B.SOLAR_PANEL: 1, B.ORE_EXTRACTOR: 2}), _energy(0, 1000)
	)
	var player := game.human_player()
	var resolver := TurnResolver.new()

	# Consumption=18 equals production+stock=18 => no deactivation
	var result := resolver.resolve(game)
	assert_true(result.deactivated_buildings.is_empty())

	# Add barracks: consumption=21 > available=18 => deactivation
	player.buildings[B.BARRACKS] = Building.new(B.BARRACKS, 1)
	result = resolver.resolve(game)
	assert_false(result.deactivated_buildings.is_empty())

	# Upgrade solar panel lvl 3: prod=114 >> consumption=23
	player.buildings[B.SOLAR_PANEL] = Building.new(B.SOLAR_PANEL, 3)
	result = resolver.resolve(game)
	assert_true(result.deactivated_buildings.is_empty())
