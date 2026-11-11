extends HistorySheetCase
## test/presentation/widgets/history/history_sheet_test.dart: the log of the
## player, newest first, filtered by category.


func test_an_empty_history_shows_the_empty_text() -> void:
	var sheet := HistorySheet.new([] as Array[HistoryEntry], modals())
	mount(sheet)
	assert_true(sheet.cards.is_empty())
	assert_true(sheet.empty_box.visible)
	assert_eq(sheet.empty_label.text, "Aucune action enregistrée pour l'instant.")


func test_the_cards_come_newest_first() -> void:
	var sheet := _sheet()
	assert_eq(_turns(sheet), [5, 2, 1] as Array[int])
	assert_false(sheet.empty_box.visible)
	assert_eq(sheet.list.get_child(sheet.list.get_child_count() - 1), sheet.cards[2])


func test_the_entries_are_kept_as_they_were_given() -> void:
	var entries := _entries()
	_sheet(entries)
	assert_eq(entries[0].turn, 1, "reading it does not reverse the player's history")


func test_changing_the_filter_narrows_the_list() -> void:
	var sheet := _sheet()
	assert_eq(sheet.cards.size(), 3)
	press("Combats")
	assert_eq(sheet.cards.size(), 1)
	assert_true(sheet.cards[0].entry is CombatEntry)
	press("Construction")
	assert_eq(_turns(sheet), [1] as Array[int])
	press("Tous")
	assert_eq(sheet.cards.size(), 3)


func test_a_filter_that_keeps_nothing_says_so() -> void:
	var sheet := _sheet()
	press("Événements")
	assert_true(sheet.cards.is_empty())
	assert_true(sheet.empty_box.visible)
	assert_eq(sheet.empty_label.text, "Aucune action pour ce filtre.")


func test_reopening_the_sheet_resets_the_filter_to_all() -> void:
	var first := _sheet()
	press("Combats")
	assert_eq(first.cards.size(), 1)
	first.close()
	var second := _sheet()
	assert_eq(second.chips.current, HistoryFilter.Value.ALL)
	assert_eq(second.cards.size(), 3)


func test_a_card_that_is_freed_by_the_filter_leaves_the_list() -> void:
	var sheet := _sheet()
	var before := sheet.list.get_child_count()
	press("Combats")
	assert_eq(sheet.list.get_child_count(), before - 2)


func test_follows_the_language() -> void:
	var sheet := _sheet()
	press("Événements")
	use_language("en")
	assert_eq(sheet.empty_label.text, "No action for this filter.")
	assert_not_null(find_text("Events", sheet))
	use_language("es")
	assert_no_raw_keys(sheet)
	assert_eq(sheet.cards.size(), 0)
	press("Todos")
	assert_no_raw_keys(sheet)
