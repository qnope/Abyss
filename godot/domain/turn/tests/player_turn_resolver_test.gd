extends TestCase
## Not in the Dart files: the edges of PlayerTurnResolver that the tests of
## TurnResolver leave, the production on top (the pearl income), a stock
## the player lacks and a stock that cannot go below zero.

const ALGAE := ResourceType.Value.ALGAE
const PEARL := ResourceType.Value.PEARL


## A player whose farm makes algae.
static func _player() -> Player:
	var p := Player.new("Nemo", "human", 5, 5)
	p.buildings[BuildingType.Value.ALGAE_FARM] = Building.new(BuildingType.Value.ALGAE_FARM, 2)
	return p


static func _change(changes: Array[TurnResourceChange], type: ResourceType.Value) -> TurnResourceChange:
	for c: TurnResourceChange in changes:
		if c.type == type:
			return c
	return null


func test_the_extra_production_comes_on_top_of_the_buildings() -> void:
	var p := _player()
	var plain := PlayerTurnResolver.resolve(_player(), 4)
	var result := PlayerTurnResolver.resolve(p, 4, {PEARL: 3, ALGAE: 7})
	assert_null(_change(plain.changes, PEARL))
	assert_eq(_change(result.changes, PEARL).produced, 3)
	assert_eq(_change(result.changes, ALGAE).produced, _change(plain.changes, ALGAE).produced + 7)
	assert_eq([result.previous_turn, result.new_turn], [4, 4])


func test_a_stock_the_player_lacks_is_left_out() -> void:
	var p := _player()
	p.resources.erase(PEARL)
	var result := PlayerTurnResolver.resolve(p, 4, {PEARL: 3})
	assert_null(_change(result.changes, PEARL))
	assert_not_null(_change(result.changes, ALGAE))


func test_a_stock_never_goes_below_zero() -> void:
	var p := _player()
	p.resources[ALGAE].amount = 10
	var c := _change(PlayerTurnResolver.resolve(p, 4, {ALGAE: -1000}).changes, ALGAE)
	assert_eq([c.before_amount, c.after_amount, c.was_capped], [10, 0, false])
	assert_eq(p.resources[ALGAE].amount, 0)


func test_a_faction_produces_by_its_difficulty() -> void:
	var human := PlayerTurnResolver.resolve(_player(), 4, {}, Difficulty.Value.HARD)
	var faction := PlayerTurnResolver.resolve(_player(), 4, {}, Difficulty.Value.HARD, true)
	assert_ne(_change(human.changes, ALGAE).produced, _change(faction.changes, ALGAE).produced)


func test_the_worksite_of_the_turn_is_freed() -> void:
	var p := _player()
	p.worksite.upgrades = 1
	p.worksite.research = 1
	PlayerTurnResolver.resolve(p, 4)
	assert_eq([p.worksite.upgrades, p.worksite.research], [0, 0])


func test_the_buildings_shut_down_spend_no_energy() -> void:
	var p := Player.new("Nemo", "human", 5, 5)
	p.buildings[BuildingType.Value.SOLAR_PANEL] = Building.new(BuildingType.Value.SOLAR_PANEL, 1)
	p.buildings[BuildingType.Value.ALGAE_FARM] = Building.new(BuildingType.Value.ALGAE_FARM, 2)
	p.buildings[BuildingType.Value.ORE_EXTRACTOR] = Building.new(BuildingType.Value.ORE_EXTRACTOR, 5)
	p.resources[ResourceType.Value.ENERGY].amount = 0
	var result := PlayerTurnResolver.resolve(p, 4)
	var excluded: Dictionary[BuildingType.Value, bool] = {}
	for type: BuildingType.Value in result.deactivated_buildings:
		excluded[type] = true
	assert_true(excluded.has(BuildingType.Value.ORE_EXTRACTOR))
	var consumed := _change(result.changes, ResourceType.Value.ENERGY).consumed
	assert_true(consumed > 0)
	assert_eq(consumed, ConsumptionCalculator.total_building_consumption(p.buildings, excluded))
	assert_true(consumed < ConsumptionCalculator.total_building_consumption(p.buildings))


func test_a_stock_filled_to_the_brim_is_not_capped() -> void:
	var p := _player()
	p.resources[ALGAE] = GameResource.new(ALGAE, 500 - 140, 500)
	var c := _change(PlayerTurnResolver.resolve(p, 4).changes, ALGAE)
	assert_eq([c.produced, c.after_amount, c.was_capped], [140, 500, false])
