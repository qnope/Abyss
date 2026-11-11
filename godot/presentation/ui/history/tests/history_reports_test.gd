extends UiTestCase
## The reports a history entry reopens, rebuilt from what the entry stored
## (test/presentation/widgets/history/history_*_launcher_test.dart).

var _reports := HistoryReports.new()


func _page(entry: HistoryEntry) -> ModalPanel:
	var page := _reports.page_for(entry)
	if page != null:
		modals().open(page)
	return page


func test_a_combat_reopens_its_fight_summary() -> void:
	var entry := HistorySamples.combat_entry(true)
	var page := _page(entry) as FightSummaryPage
	assert_not_null(page)
	assert_eq(page.result.victory, true)
	assert_eq(page.result.fight, entry.fight_result)
	assert_eq(page.lair, entry.lair)
	assert_eq(Vector2i(page.target_x, page.target_y), Vector2i(entry.target_x, entry.target_y))
	assert_no_raw_keys()


func test_a_raid_reopens_its_report_from_the_fields_it_stored() -> void:
	var entry := HistorySamples.raid_entry(false)
	entry.rampart_level = 3
	entry.pillaged = {ResourceType.Value.ALGAE: 40} as Dictionary[ResourceType.Value, int]
	var report := (_page(entry) as RaidReportPage).report
	assert_eq([report.turn, report.victory, report.wave, report.fight, report.rampart_level],
		[entry.turn, false, entry.wave, entry.fight_result, 3])
	assert_eq(report.pillaged, entry.pillaged)
	assert_false(report.surprise)
	assert_no_raw_keys()


func test_a_school_of_predators_reopens_under_its_own_name() -> void:
	var page := _page(HistorySamples.raid_entry(true, true)) as RaidReportPage
	assert_true(page.report.surprise)
	assert_true(page.report.victory)


func test_a_kraken_wave_reopens_its_report() -> void:
	var entry := HistorySamples.volcano_entry(false)
	var report := (_page(entry) as VolcanoReportPage).report
	assert_eq([report.turn, report.victory, report.wave, report.fight, report.kernel_level],
		[20, false, entry.wave, entry.fight_result, 2])
	assert_no_raw_keys()


func test_the_other_entries_have_no_report_yet() -> void:
	assert_null(_reports.page_for(HistorySamples.capture_entry("Abysse")))
	assert_null(_reports.page_for(HistorySamples.base_assault_entry(true, false)), "the assault summary comes with the factions")
	assert_null(_reports.page_for(BuildingEntry.new(1, BuildingType.Value.ALGAE_FARM, 2)))
