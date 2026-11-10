extends TestCase
## test/domain/history/history_constants_test.dart: how long the history of
## a player gets.


func test_history_constants_k_history_max_entries_equals_100() -> void:
	assert_eq(HistoryConstants.K_HISTORY_MAX_ENTRIES, 100)
