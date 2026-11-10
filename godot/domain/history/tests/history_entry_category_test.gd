extends TestCase
## test/domain/history/history_entry_category_test.dart: what a line of the
## history tells of.

const Category := HistoryEntryCategory.Value


func test_history_entry_category_enum_has_exactly_14_values() -> void:
	assert_eq(Category.size(), 14)


func test_history_entry_category_all_expected_categories_exist() -> void:
	for category: Category in [
		Category.COMBAT, Category.BUILDING, Category.RESEARCH, Category.RECRUIT,
		Category.EXPLORE, Category.COLLECT, Category.TURN_END, Category.CAPTURE,
		Category.DESCENT, Category.REINFORCEMENT, Category.EVENT,
	]:
		assert_has(Category.values(), category)


func test_history_entry_category_all_categories_are_distinct() -> void:
	var different: Dictionary[Category, bool] = {}
	for category: Category in Category.values():
		different[category] = true
	assert_eq(different.size(), Category.size())


## Not in the Dart file: the names the snapshots write, which tell an entry
## from the others.
func test_has_the_values_of_dart_in_its_order() -> void:
	assert_eq(
		DartEnum.names(Category),
		PackedStringArray([
			"combat", "building", "research", "recruit", "explore", "collect", "turnEnd",
			"capture", "descent", "reinforcement", "raid", "volcano", "event", "assault",
		]),
	)
