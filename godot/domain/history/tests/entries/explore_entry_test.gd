extends TestCase
## test/domain/history/entries/explore_entry_test.dart: the line of an
## exploration ordered.


func test_explore_entry_keeps_the_target_coordinates() -> void:
	var entry := ExploreEntry.new(6, 5, 7)
	assert_eq(entry.category, HistoryEntryCategory.Value.EXPLORE)
	assert_eq(entry.target_x, 5)
	assert_eq(entry.target_y, 7)


func test_explore_entry_accepts_zero_coordinates() -> void:
	var entry := ExploreEntry.new(1, 0, 0)
	assert_eq(entry.target_x, 0)
	assert_eq(entry.target_y, 0)
	assert_eq(entry.turn, 1)
