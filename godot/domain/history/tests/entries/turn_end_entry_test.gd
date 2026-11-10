extends TestCase
## test/domain/history/entries/turn_end_entry_test.dart: the line of a turn
## resolved. Its check of the subtitle never comes (the port drops the
## field); its group TurnEndEntryFactory waits for the `turn` module, whose
## TurnResult the factory reads.


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
