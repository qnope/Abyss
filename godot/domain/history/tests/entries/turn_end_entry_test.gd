extends TestCase
## test/domain/history/entries/turn_end_entry_test.dart: the line of a turn
## resolved, and the factory that builds it from a TurnResult. Its check
## of the subtitle never comes (the port drops the field).


func test_turn_end_entry_records_the_turn_that_ended() -> void:
	var entry := TurnEndEntry.new(12, [], [], {})
	assert_eq(entry.turn, 12)
	assert_eq(entry.category, HistoryEntryCategory.Value.TURN_END)


## Not in the Dart file: the changes, the buildings shut down and the units
## lost, as given and in their order.
func test_keeps_the_recap_of_the_turn() -> void:
	var changes: Array[TurnResourceChange] = [
		TurnResourceChange.new(ResourceType.Value.ALGAE, 30, false, 100, 120, 10),
		TurnResourceChange.new(ResourceType.Value.ENERGY, 5, true, 50, 50),
	]
	var entry := TurnEndEntry.new(
		5, changes, [BuildingType.Value.LABORATORY], {UnitType.Value.SCOUT: 2}
	)
	assert_eq(entry.changes.size(), 2)
	assert_eq(entry.changes[0].type, ResourceType.Value.ALGAE)
	assert_eq(entry.changes[0].after_amount, 120)
	assert_eq(entry.deactivated_buildings, [BuildingType.Value.LABORATORY])
	assert_eq(entry.lost_units[UnitType.Value.SCOUT], 2)


func test_factory_from_turn_result_copies_changes_deactivated_buildings_and_losses() -> void:
	var changes: Array[TurnResourceChange] = [
		TurnResourceChange.new(ResourceType.Value.ALGAE, 30, false, 100, 120, 10),
		TurnResourceChange.new(ResourceType.Value.ENERGY, 5, true, 50, 50),
	]
	var result := TurnResult.new(
		changes, 4, 5, false, [BuildingType.Value.LABORATORY], {UnitType.Value.SCOUT: 2}
	)

	var entry := TurnEndEntryFactory.new().from_turn_result(5, result)

	assert_eq(entry.turn, 5)
	assert_eq(entry.category, HistoryEntryCategory.Value.TURN_END)
	assert_eq(entry.changes.size(), 2)
	assert_eq(entry.changes[0].type, ResourceType.Value.ALGAE)
	assert_eq(entry.changes[0].after_amount, 120)
	assert_eq(entry.deactivated_buildings, [BuildingType.Value.LABORATORY])
	assert_eq(entry.lost_units[UnitType.Value.SCOUT], 2)


func test_factory_from_turn_result_handles_empty_deactivations_and_losses() -> void:
	var result := TurnResult.new([], 1, 2, true)

	var entry := TurnEndEntryFactory.new().from_turn_result(2, result)

	assert_eq(entry.turn, 2)
	assert_true(entry.changes.is_empty())
	assert_true(entry.deactivated_buildings.is_empty())
	assert_true(entry.lost_units.is_empty())


## Not in the Dart file: the entry holds read-only copies (Dart's
## `unmodifiable`), not the lists of the result.
func test_factory_copies_the_lists_read_only() -> void:
	var result := TurnResult.new([], 1, 2, true, [BuildingType.Value.LABORATORY], {UnitType.Value.SCOUT: 2})

	var entry := TurnEndEntryFactory.new().from_turn_result(2, result)

	result.deactivated_buildings.clear()
	result.lost_units.clear()
	assert_eq(entry.deactivated_buildings, [BuildingType.Value.LABORATORY])
	assert_eq(entry.lost_units, {UnitType.Value.SCOUT: 2})
	assert_true(entry.changes.is_read_only())
	assert_true(entry.deactivated_buildings.is_read_only())
	assert_true(entry.lost_units.is_read_only())
