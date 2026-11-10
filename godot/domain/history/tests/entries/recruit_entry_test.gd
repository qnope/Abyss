extends TestCase
## test/domain/history/entries/recruit_entry_test.dart: the line of a batch
## of units recruited. 'preserves subtitle when provided' never comes: the
## port drops the subtitle, which only kept the layout of old saves.


func test_recruit_entry_carries_the_unit_type_and_quantity() -> void:
	var entry := RecruitEntry.new(5, UnitType.Value.GUARDIAN, 10)
	assert_eq(entry.category, HistoryEntryCategory.Value.RECRUIT)
	assert_eq(entry.quantity, 10)
	assert_eq(entry.unit_type, UnitType.Value.GUARDIAN)
	assert_eq(entry.turn, 5)
