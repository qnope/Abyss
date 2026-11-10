extends TestCase
## Not in the Dart files: lib/domain/history/entries/reinforcement_entry.dart
## has no test of its own. The line of reinforcements sent down.


func test_keeps_the_level_and_the_units_sent() -> void:
	var entry := ReinforcementEntry.new(21, 3, 4)
	assert_eq(entry.turn, 21)
	assert_eq(entry.category, HistoryEntryCategory.Value.REINFORCEMENT)
	assert_eq(entry.target_level, 3)
	assert_eq(entry.unit_count, 4)
