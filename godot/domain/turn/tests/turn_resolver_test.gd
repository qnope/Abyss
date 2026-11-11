extends TestCase
## test/domain/turn/turn_resolver_test.dart: the production, the turn, the
## storage, the energy, the algae and the players of an end of turn.

const Type := BuildingType.Value
const ALGAE := ResourceType.Value.ALGAE
const ENERGY := ResourceType.Value.ENERGY
const SCOUT := UnitType.Value.SCOUT


static func _player(
	id := "human",
	building_levels: Dictionary[BuildingType.Value, int] = {},
	resource_amounts: Dictionary[ResourceType.Value, int] = {},
	unit_counts: Dictionary[UnitType.Value, int] = {},
) -> Player:
	var p := Player.new(id, id, 5, 5)
	for type: BuildingType.Value in building_levels:
		p.buildings[type] = Building.new(type, building_levels[type])
	for type: ResourceType.Value in resource_amounts:
		p.resources[type].amount = resource_amounts[type]
	for type: UnitType.Value in unit_counts:
		p.units_on_level(1)[type] = Unit.new(type, unit_counts[type])
	return p


## A game where the objectives `p` already meets were completed earlier, so
## a turn shows its production alone, without their rewards.
static func _single_game(p: Player, turn := 1) -> Game:
	var game := Game.single_player(p)
	game.turn = turn
	p.saved_objective_state = ObjectiveMigration.legacy_state(game, p)
	return game


static func _change(result: TurnResult, type: ResourceType.Value) -> TurnResourceChange:
	for c: TurnResourceChange in result.changes:
		if c.type == type:
			return c
	return null


static func _level_2(p: Player, scouts: int) -> void:
	var units: Dictionary[UnitType.Value, Unit] = {}
	for t: UnitType.Value in UnitType.Value.values():
		units[t] = Unit.new(t)
	p.units_per_level[2] = units
	p.units_on_level(2)[SCOUT].count = scouts


func test_production_single_building_produces_and_reports_change() -> void:
	var p := _player("human", {Type.ALGAE_FARM: 2})
	var before := p.resources[ALGAE].amount
	var result := TurnResolver.new().resolve(_single_game(p))
	assert_eq(p.resources[ALGAE].amount, before + 140)
	assert_eq(_change(result, ALGAE).produced, 140)


func test_production_game_turn_increments_exactly_once_per_resolve() -> void:
	var game := _single_game(_player(), 5)
	var result := TurnResolver.new().resolve(game)
	assert_eq(game.turn, 6)
	assert_eq(result.previous_turn, 5)
	assert_eq(result.new_turn, 6)


func test_production_result_reads_from_human_player_and_clears_recruited_unit_types() -> void:
	var p := _player()
	p.recruited_unit_types.append_array([SCOUT, UnitType.Value.HARPOONIST])
	var result := TurnResolver.new().resolve(_single_game(p))
	assert_true(result.had_recruited_units)
	assert_true(p.recruited_unit_types.is_empty())


func test_storage_production_capped_at_max_storage() -> void:
	var p := _player("human", {Type.ALGAE_FARM: 1})
	p.resources[ALGAE] = GameResource.new(ALGAE, 498, 500)
	var c := _change(TurnResolver.new().resolve(_single_game(p)), ALGAE)
	assert_eq(c.before_amount, 498)
	assert_eq(c.after_amount, 500)
	assert_true(c.was_capped)


func test_energy_buildings_consume_energy_from_production() -> void:
	var p := _player("human", {Type.SOLAR_PANEL: 2, Type.ALGAE_FARM: 1})
	var before := p.resources[ENERGY].amount
	var result := TurnResolver.new().resolve(_single_game(p))
	assert_eq(p.resources[ENERGY].amount, before + 55)
	var c := _change(result, ENERGY)
	assert_eq(c.produced, 59)
	assert_eq(c.consumed, 4)


func test_energy_insufficient_energy_deactivates_buildings() -> void:
	var p := _player("human", {Type.HEADQUARTERS: 1, Type.ORE_EXTRACTOR: 3}, {ENERGY: 3})
	var ore_before := p.resources[ResourceType.Value.ORE].amount
	var result := TurnResolver.new().resolve(_single_game(p))
	assert_has(result.deactivated_buildings, Type.ORE_EXTRACTOR)
	# Only the HQ's flat income comes in.
	assert_eq(p.resources[ResourceType.Value.ORE].amount, ore_before + 10)


func test_algae_unit_losses_applied_when_algae_insufficient() -> void:
	var p := _player("human", {}, {ALGAE: 5}, {SCOUT: 100})
	var result := TurnResolver.new().resolve(_single_game(p))
	assert_true(result.lost_units[SCOUT] > 0)
	assert_true(p.units_on_level(1)[SCOUT].count < 100)


func test_algae_units_on_level_2_still_consume_algae() -> void:
	var p := _player("human", {}, {ALGAE: 0}, {SCOUT: 10})
	_level_2(p, 10)
	var result := TurnResolver.new().resolve(_single_game(p))
	# Both levels should lose units
	assert_true(result.lost_units[SCOUT] > 0)
	assert_true(p.units_on_level(1)[SCOUT].count < 10)
	assert_true(p.units_on_level(2)[SCOUT].count < 10)


func test_algae_moving_units_to_level_2_does_not_reduce_algae_consumption() -> void:
	var p_a := _player("human", {}, {ALGAE: 1000}, {SCOUT: 20})
	var consumed_a := _change(TurnResolver.new().resolve(_single_game(p_a)), ALGAE).consumed
	var p_b := _player("human", {}, {ALGAE: 1000}, {SCOUT: 10})
	_level_2(p_b, 10)
	var consumed_b := _change(TurnResolver.new().resolve(_single_game(p_b)), ALGAE).consumed
	assert_eq(consumed_a, consumed_b)


func test_multi_player_resolve_mutates_each_player_independently() -> void:
	var alice := _player("alice", {Type.ALGAE_FARM: 1})
	var bob := _player("bob")
	var game := Game.new(alice.id, {alice.id: alice, bob.id: bob})
	var bob_algae_before := bob.resources[ALGAE].amount
	TurnResolver.new().resolve(game)
	# Alice gains 50 algae from her farm; Bob's unchanged.
	assert_eq(alice.resources[ALGAE].amount, 150)
	assert_eq(bob.resources[ALGAE].amount, bob_algae_before)
	# Turn incremented exactly once for the shared game.
	assert_eq(game.turn, 2)
