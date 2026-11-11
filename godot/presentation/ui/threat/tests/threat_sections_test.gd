extends UiTestCase
## The raid and volcano lines of the end-of-turn summary
## (test/presentation/screens/game/game_screen_turn_flow_volcano_test.dart,
## widgets/volcano/volcano_widgets_test.dart).


func _summary(result: TurnResult) -> TurnSummary:
	return mount(TurnSummary.new(result)) as TurnSummary


func _total(units: Dictionary[UnitType.Value, int]) -> int:
	var total := 0
	for count: int in units.values():
		total += count
	return total


func test_no_section_when_the_turn_met_no_threat() -> void:
	var result := ThreatSamples.result()
	assert_eq(ThreatSections.raid(result), [] as Array[Control])
	assert_eq(ThreatSections.volcano(result), [] as Array[Control])


func test_a_raid_repelled_is_a_green_line_with_a_separator() -> void:
	var section := mount(RaidTurnSection.new(ThreatSamples.result(ThreatSamples.raid_report(true)))) as RaidTurnSection
	assert_true(section.get_child(0) is HSeparator)
	assert_eq(section.fought_line.label.text, "Raid repoussé")
	assert_eq(section.fought_line.label.get_theme_color(&"font_color"), AbyssColors.SUCCESS)
	assert_null(section.announced_line)
	assert_no_raw_keys()


func test_a_raid_lost_is_a_red_line() -> void:
	var section := mount(RaidTurnSection.new(ThreatSamples.result(ThreatSamples.raid_report(false)))) as RaidTurnSection
	assert_eq(section.fought_line.label.text, "La base a été pillée")
	assert_eq(section.fought_line.label.get_theme_color(&"font_color"), AbyssColors.ERROR)


func test_a_raid_announced_tells_the_wave_and_the_turn_it_hits() -> void:
	var section := mount(RaidTurnSection.new(ThreatSamples.result(null, ThreatSamples.wave()))) as RaidTurnSection
	assert_null(section.fought_line)
	assert_eq(section.announced_line.label.text, "Un raid approche : %s, fin du tour 14" % MonsterLairTexts.wave_label(ThreatSamples.wave()))
	assert_eq(section.announced_line.label.get_theme_color(&"font_color"), AbyssColors.WARNING)


func test_a_raid_announced_with_no_turn_says_turn_zero() -> void:
	var result := ThreatSamples.result(null, ThreatSamples.wave())
	result.announced_raid_turn = null
	var section := mount(RaidTurnSection.new(result)) as RaidTurnSection
	assert_true(section.announced_line.label.text.ends_with("fin du tour 0"))


func test_a_wave_repelled_counts_the_wounded_and_the_dead() -> void:
	var report := ThreatSamples.volcano_report(true)
	var result := ThreatSamples.result(null, null, report)
	var section := mount(VolcanoTurnSection.new(result)) as VolcanoTurnSection
	var wounded := _total(report.wounded)
	var dead := _total(report.dead)
	assert_eq(section.fought_line.label.text, "Volcan : vague repoussée, %s, %s" % [
		text(&"volcanoWounded", {"count": wounded}), text(&"volcanoDead", {"count": dead})])
	assert_eq(section.fought_line.label.get_theme_color(&"font_color"), AbyssColors.SUCCESS)
	assert_no_raw_keys()


func test_a_wave_lost_tells_the_level_the_kernel_falls_to() -> void:
	var result := ThreatSamples.result(null, null, ThreatSamples.volcano_report(false))
	var section := mount(VolcanoTurnSection.new(result)) as VolcanoTurnSection
	assert_eq(section.fought_line.label.text, "Volcan : le Noyau retombe au niveau 2")
	assert_eq(section.fought_line.label.get_theme_color(&"font_color"), AbyssColors.ERROR)


func test_a_wave_announced_says_the_kraken_rises() -> void:
	var wave := VolcanoWaveFactory.from_kernel_level(1)
	var section := mount(VolcanoTurnSection.new(ThreatSamples.result(null, null, null, wave))) as VolcanoTurnSection
	assert_null(section.fought_line)
	assert_eq(section.announced_line.label.text, "Le Kraken remonte : %s au prochain tour" % MonsterLairTexts.wave_label(wave))


func test_the_summary_lists_the_raid_then_the_wave_and_no_longer_says_nothing_changed() -> void:
	var result := ThreatSamples.result(ThreatSamples.raid_report(false), null, null, VolcanoWaveFactory.from_kernel_level(1))
	var summary := _summary(result)
	var lines := texts(summary)
	assert_false(summary.empty_label.visible)
	var raid_at := lines.find("La base a été pillée")
	assert_true(raid_at >= 0)
	assert_true(raid_at < lines.find("Le Kraken remonte : %s au prochain tour" % MonsterLairTexts.wave_label(result.announced_wave)))


func test_the_lines_follow_the_language() -> void:
	var section := mount(RaidTurnSection.new(ThreatSamples.result(ThreatSamples.raid_report(true), ThreatSamples.wave()))) as RaidTurnSection
	use_language("en")
	assert_eq(section.fought_line.label.text, text(&"historyRaidRepelled"))
	assert_eq(section.announced_line.label.text, text(&"raidAnnounced", {"wave": MonsterLairTexts.wave_label(ThreatSamples.wave()), "turn": 14}))
