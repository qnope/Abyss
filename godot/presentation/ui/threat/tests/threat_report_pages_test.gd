extends UiTestCase
## The reports of a raid and of a kraken wave, opened after the summary
## (test/presentation/screens/game/raid/, game_screen_turn_flow_volcano_test.dart).

var _closed: Array = []


func _open(page: ThreatReportPage) -> ThreatReportPage:
	page.closed.connect(_closed.append)
	modals().open(page)
	return page


## The class of each card of [param page], top to bottom; a plain button has none.
func _kinds(page: ThreatReportPage) -> Array[StringName]:
	var found: Array[StringName] = []
	for card in page.body.get_children():
		var script: Script = card.get_script()
		found.append(&"" if script == null else script.get_global_name())
	return found


func test_a_raid_won_tells_the_loot_and_the_rampart() -> void:
	var report := ThreatSamples.raid_report(true, 2)
	var page := _open(RaidReportPage.new(report))
	assert_eq(page.title(), "Raid sur la base (tour 12)")
	assert_eq(_kinds(page), [&"FightResultBanner", &"MonsterPreview", &"ThreatInfoCard", &"FightUnitAccounting",
		&"FightKillCount", &"FightLootCard", &"FightTurnList", &""] as Array[StringName])
	assert_not_null(find_text("VICTOIRE", page))
	assert_not_null(find_text("Rempart de la Citadelle niv. 2", page))
	assert_not_null(find_text(RampartTexts.coral(2), page))
	assert_not_null(find_text("Butin", page))
	assert_null(find_text("Pillage", page))
	assert_not_null(find_text("Vos unités", page))
	assert_no_raw_keys(page)


func test_a_raid_lost_tells_the_pillage_and_has_no_units_to_count() -> void:
	var report := ThreatSamples.raid_report(false)
	var page := _open(RaidReportPage.new(report))
	assert_not_null(find_text("DÉFAITE", page))
	assert_not_null(find_text("Pillage", page))
	assert_null(find_text("Butin", page))
	assert_null(find_text("Vos unités", page))
	assert_null(find_text("Rempart de la Citadelle niv. 0", page))
	assert_eq(find_type("ThreatInfoCard", page).size(), 0)
	assert_no_raw_keys(page)


func test_a_school_of_predators_is_titled_as_such() -> void:
	var page := _open(RaidReportPage.new(ThreatSamples.raid_report(true, 0, true)))
	assert_eq(page.title(), "Banc de prédateurs (tour 12)")


func test_the_wave_is_shown_before_the_fight_it_started() -> void:
	var report := ThreatSamples.raid_report(true)
	var page := _open(RaidReportPage.new(report))
	var preview := find_type("MonsterPreview", page)[0] as MonsterPreview
	assert_eq(preview.lair, report.wave)
	var turns := find_type("FightTurnTile", page)
	assert_eq(turns.size(), report.fight.turn_summaries.size())


func test_back_to_the_base_closes_the_page_with_nothing() -> void:
	var page := _open(RaidReportPage.new(ThreatSamples.raid_report(false)))
	press("Retour à la base")
	assert_eq(_closed, [null])
	assert_true(page.is_closed())
	assert_null(current_modal())


func test_the_arrow_of_the_app_bar_closes_it_too() -> void:
	var page := _open(RaidReportPage.new(ThreatSamples.raid_report(false)))
	press(page.back_button)
	assert_eq(_closed, [null])


func test_a_wave_lost_tells_the_level_the_kernel_drops_to_in_red() -> void:
	var page := _open(VolcanoReportPage.new(ThreatSamples.volcano_report(false)))
	assert_eq(page.title(), "Vague sur le Noyau (tour 12)")
	assert_not_null(find_text("Le Noyau retombe au niveau 2", page))
	assert_not_null(find_text("Rempart de magma : %s" % RampartTexts.magma(3), page))
	assert_not_null(find_text("DÉFAITE", page))
	assert_eq(_kinds(page), [&"FightResultBanner", &"ThreatInfoCard", &"MonsterPreview",
		&"FightKillCount", &"FightTurnList", &""] as Array[StringName])
	assert_no_raw_keys(page)


func test_a_wave_won_tells_the_kernel_holds_and_counts_the_garrison() -> void:
	var page := _open(VolcanoReportPage.new(ThreatSamples.volcano_report(true)))
	assert_not_null(find_text("Le Noyau tient au niveau 3", page))
	assert_not_null(find_text("VICTOIRE", page))
	assert_not_null(find_text("Vos unités", page))


func test_a_kernel_of_level_zero_has_no_rampart_line() -> void:
	var report := ThreatSamples.volcano_report(false)
	report.kernel_level = 0
	var card := find_type("ThreatInfoCard", _open(VolcanoReportPage.new(report)))[0] as ThreatInfoCard
	assert_false(card.subtitle_label.visible)


func test_the_pages_follow_the_language() -> void:
	var raid := _open(RaidReportPage.new(ThreatSamples.raid_report(true, 1)))
	use_language("en")
	assert_eq(raid.title(), text(&"raidTitle", {"turn": 12}))
	assert_not_null(find_text(text(&"commonBackToBase"), raid))
	assert_not_null(find_text(text(&"fightVictory"), raid))
	assert_no_raw_keys(raid)
	var volcano := _open(VolcanoReportPage.new(ThreatSamples.volcano_report(false)))
	use_language("es")
	assert_eq(volcano.title(), text(&"volcanoWaveTitle", {"turn": 12}))
	assert_no_raw_keys(volcano)
