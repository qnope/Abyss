extends UiTestCase
## test/presentation/widgets/history/history_sheet_test.dart: the log of the
## player, newest first, filtered by category, and the reports its cards
## reopen.


## A hook for the reports: opens a plain page for the combats, as the lot that
## builds the fight summary will.
class FakeReports:
	extends HistoryReports

	var asked: Array[HistoryEntry] = []
	var page: ModalPanel

	func page_for(entry: HistoryEntry) -> ModalPanel:
		asked.append(entry)
		return page if entry is CombatEntry else null


func _entries() -> Array[HistoryEntry]:
	return [
		BuildingEntry.new(1, BuildingType.Value.ALGAE_FARM, 2),
		ResearchEntry.new(2, TechBranch.Value.MILITARY, false, 1),
		HistorySamples.combat_entry(true),
	]


## The sheet of [param entries] (the sample ones when none), on the window or,
## when [param on_modals], opened on the modals.
func _sheet(entries: Array[HistoryEntry] = [], reports := HistoryReports.new(), on_modals := false) -> HistorySheet:
	var sheet := HistorySheet.new(entries if not entries.is_empty() else _entries(), modals(), reports)
	if on_modals:
		modals().open(sheet)
		return sheet
	return mount(sheet) as HistorySheet


func _turns(sheet: HistorySheet) -> Array[int]:
	var turns: Array[int] = []
	for card in sheet.cards:
		turns.append(card.entry.turn)
	return turns


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


func test_a_touch_on_a_card_without_a_report_does_nothing() -> void:
	var sheet := _sheet()
	press(sheet.cards[0].tap_button)
	assert_null(current_modal(), "no report page exists yet")
	press("Construction")
	assert_null(sheet.cards[0].tap_button, "a building has nothing to reopen")


func test_a_touch_on_a_card_opens_the_report_the_hook_gives() -> void:
	var reports := FakeReports.new()
	reports.page = ModalPanel.new()
	var sheet := _sheet([], reports, true)
	press(sheet.cards[0].tap_button)
	assert_eq(reports.asked, [sheet.cards[0].entry] as Array[HistoryEntry])
	assert_eq(current_modal(), reports.page)
	assert_eq(modals().depth(), 2, "over the history")
	reports.page.close()
	assert_eq(current_modal(), sheet, "back to the history")


func test_a_touch_on_a_card_whose_report_is_none_opens_nothing() -> void:
	var reports := FakeReports.new()
	var sheet := _sheet([HistorySamples.raid_entry(true)], reports, true)
	press(sheet.cards[0].tap_button)
	assert_eq(reports.asked.size(), 1)
	assert_eq(current_modal(), sheet)


func test_is_a_bottom_sheet_eighty_percent_high() -> void:
	var sheet := _sheet()
	assert_eq(sheet.placement, ModalPanel.Placement.BOTTOM)
	assert_eq(sheet.theme_type_variation, &"BottomSheetPanel")
	sheet.fit(Vector2(390.0, 800.0))
	assert_eq(sheet.custom_minimum_size, Vector2(390.0, 640.0))


func test_dragging_the_handle_down_far_enough_closes_it() -> void:
	var sheet := _sheet()
	var closed := []
	sheet.closed.connect(closed.append)
	sheet.handle.pulled.emit(BottomSheet.DISMISS_PULL - 1.0)
	assert_eq(closed, [])
	sheet.handle.pulled.emit(BottomSheet.DISMISS_PULL)
	assert_eq(closed, [null])


func test_a_sheet_that_cannot_be_dismissed_stays_when_dragged() -> void:
	var sheet := _sheet()
	sheet.dismissible = false
	sheet.handle.pulled.emit(500.0)
	assert_false(sheet.is_closed())


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
