extends TestCase
## Not in the Dart files: lib/domain/history/entries/descent_entry.dart has
## no test of its own. The line of a descent to a deeper level.


func test_keeps_the_level_reached_and_the_units_sent() -> void:
	var entry := DescentEntry.new(14, 2, 6)
	assert_eq(entry.turn, 14)
	assert_eq(entry.category, HistoryEntryCategory.Value.DESCENT)
	assert_eq(entry.target_level, 2)
	assert_eq(entry.unit_count, 6)
