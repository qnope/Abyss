extends TestCase
## test/domain/history/entries/event_entry_test.dart: the line of a random
## event played out. 'leaves its wording to the presentation' never comes:
## the port drops the subtitle, always null.


func _entry(
	type := RandomEventType.Value.CARAVAN, accepted := false, defaulted := false
) -> EventEntry:
	return EventEntry.new(9, type, accepted, defaulted)


func test_is_an_event_of_its_turn() -> void:
	var entry := _entry()
	assert_eq(entry.turn, 9)
	assert_eq(entry.category, HistoryEntryCategory.Value.EVENT)


func test_records_which_choice_the_player_made() -> void:
	var entry := _entry(RandomEventType.Value.CARAVAN, true)
	assert_eq(entry.type, RandomEventType.Value.CARAVAN)
	assert_true(entry.accepted)
	assert_false(entry.defaulted)
	assert_true(_entry(RandomEventType.Value.CARAVAN, false, true).defaulted)
