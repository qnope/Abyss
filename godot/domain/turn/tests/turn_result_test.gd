extends TestCase
## test/domain/turn/turn_result_test.dart: what the end of a turn did to a
## stock (TurnResourceChange) and to the game (TurnResult).


func test_turn_resource_change_consumed_defaults_to_0() -> void:
	var change := TurnResourceChange.new(ResourceType.Value.ALGAE, 50, false, 100, 150)
	assert_eq(change.consumed, 0)


func test_turn_resource_change_consumed_stores_given_value() -> void:
	var change := TurnResourceChange.new(ResourceType.Value.ALGAE, 50, false, 100, 138, 12)
	assert_eq(change.consumed, 12)


## Not in the Dart file: every field as given.
func test_keeps_every_field() -> void:
	var change := TurnResourceChange.new(ResourceType.Value.ENERGY, 5, true, 50, 50, 3)
	assert_eq(change.type, ResourceType.Value.ENERGY)
	assert_eq(change.produced, 5)
	assert_true(change.was_capped)
	assert_eq([change.before_amount, change.after_amount], [50, 50])


func test_turn_result_deactivated_buildings_defaults_to_empty() -> void:
	var result := TurnResult.new([], 1, 2, false)
	assert_true(result.deactivated_buildings.is_empty())


func test_turn_result_lost_units_defaults_to_empty() -> void:
	var result := TurnResult.new([], 1, 2, false)
	assert_true(result.lost_units.is_empty())


func test_turn_result_stores_deactivated_buildings() -> void:
	var result := TurnResult.new([], 1, 2, false, [BuildingType.Value.ORE_EXTRACTOR])
	assert_eq(result.deactivated_buildings.size(), 1)


func test_turn_result_stores_lost_units() -> void:
	var result := TurnResult.new([], 1, 2, false, [], {UnitType.Value.SCOUT: 5})
	assert_eq(result.lost_units[UnitType.Value.SCOUT], 5)


## Not in the Dart file: what a TurnResult holds when nothing else is given.
func test_turn_result_defaults_to_nothing_else() -> void:
	var result := TurnResult.new([], 1, 2, true)
	assert_eq([result.previous_turn, result.new_turn, result.had_recruited_units], [1, 2, true])
	assert_eq([result.explorations, result.arrived_reinforcements, result.objectives], [[], [], []])
	assert_eq([result.temporary_objectives, result.attacks], [[], []])
	for value: Variant in [
		result.raid, result.announced_raid, result.announced_raid_turn, result.volcano,
		result.announced_wave, result.event, result.defaulted_event, result.predators,
		result.leviathan, result.announced_leviathan,
	]:
		assert_null(value)
