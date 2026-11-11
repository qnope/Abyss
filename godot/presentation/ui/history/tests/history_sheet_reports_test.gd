extends HistorySheetCase
## history_sheet_test.dart: the reports the cards reopen, and the sheet that
## the handle pulls down.


func test_a_touch_on_a_combat_reopens_its_fight_summary() -> void:
	var sheet := _sheet([], HistoryReports.new(), true)
	press(sheet.cards[0].tap_button)
	var page := current_modal() as FightSummaryPage
	assert_not_null(page)
	assert_true(page.result.victory)
	assert_no_raw_keys()
	page.close()
	press("Construction")
	assert_null(sheet.cards[0].tap_button, "a building has nothing to reopen")


func test_a_touch_on_an_assault_reopens_its_summary_for_either_side() -> void:
	for defending: bool in [false, true]:
		var sheet := _sheet([HistorySamples.base_assault_entry(true, defending)], HistoryReports.new(), true)
		press(sheet.cards[0].tap_button)
		var page := current_modal() as BaseAssaultSummaryPage
		assert_not_null(page)
		assert_eq(page.entry.defending, defending)
		page.close()
		sheet.close()


func test_a_touch_on_a_capture_opens_nothing() -> void:
	var sheet := _sheet([HistorySamples.capture_entry("Abysse")], HistoryReports.new(), true)
	press(sheet.cards[0].tap_button)
	assert_eq(current_modal(), sheet, "no report behind a capture")


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
