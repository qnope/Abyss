extends TestCase
## test/domain/history/entries/building_entry_test.dart: the line of a
## building raised. Its checks of the subtitle ('preserves optional
## subtitle' is nothing else) never come: the port drops the field, which
## only kept the layout of old saves.


func test_building_entry_exposes_category_building_building_type_and_level() -> void:
	var entry := BuildingEntry.new(3, BuildingType.Value.BARRACKS, 2)
	assert_eq(entry.turn, 3)
	assert_eq(entry.category, HistoryEntryCategory.Value.BUILDING)
	assert_eq(entry.building_type, BuildingType.Value.BARRACKS)
	assert_eq(entry.new_level, 2)


## Not in the Dart file: an entry is a HistoryEntry, read by its turn and
## its category whatever its class.
func test_is_a_history_entry() -> void:
	var entry: HistoryEntry = BuildingEntry.new(10, BuildingType.Value.LABORATORY, 5)
	assert_eq([entry.turn, entry.category], [10, HistoryEntryCategory.Value.BUILDING])
