extends TestCase
## test/presentation/extensions/history_entry_extensions_test.dart and
## history_entry_extensions_all_types_test.dart: the colour, the touch and the
## picture of each kind of entry.


func _plain_entries() -> Array[HistoryEntry]:
	return [
		ResearchEntry.new(1, TechBranch.Value.EXPLORER, true),
		RecruitEntry.new(1, UnitType.Value.SCOUT, 2),
		ExploreEntry.new(1, 3, 4),
		CollectEntry.new(1, 3, 4, {}),
		HistorySamples.turn_end_entry(1),
		DescentEntry.new(1, 2, 5),
		ReinforcementEntry.new(1, 2, 5),
		BuildingEntry.new(1, BuildingType.Value.LABORATORY, 2),
		EventEntry.new(1, RandomEventType.Value.CARAVAN, true, false),
	]


func test_a_won_fight_glows_green_and_a_lost_one_red() -> void:
	assert_eq(HistoryEntryDisplay.accent_color(HistorySamples.combat_entry(true)), AbyssColors.SUCCESS)
	assert_eq(HistoryEntryDisplay.accent_color(HistorySamples.combat_entry(false)), AbyssColors.ERROR)
	assert_eq(HistoryEntryDisplay.accent_color(HistorySamples.raid_entry(true)), AbyssColors.SUCCESS)
	assert_eq(HistoryEntryDisplay.accent_color(HistorySamples.raid_entry(false)), AbyssColors.ERROR)
	assert_eq(HistoryEntryDisplay.accent_color(HistorySamples.volcano_entry(true)), AbyssColors.SUCCESS)
	assert_eq(HistoryEntryDisplay.accent_color(HistorySamples.volcano_entry(false)), AbyssColors.ERROR)


func test_an_assault_glows_with_the_side_of_the_player() -> void:
	var attacking_won := HistorySamples.base_assault_entry(true, false)
	var attacking_lost := HistorySamples.base_assault_entry(false, false)
	var defending_won := HistorySamples.base_assault_entry(false, true)
	var defending_lost := HistorySamples.base_assault_entry(true, true)
	assert_eq(HistoryEntryDisplay.accent_color(attacking_won), AbyssColors.SUCCESS)
	assert_eq(HistoryEntryDisplay.accent_color(attacking_lost), AbyssColors.ERROR)
	assert_eq(HistoryEntryDisplay.accent_color(defending_won), AbyssColors.SUCCESS, "the attacker failed")
	assert_eq(HistoryEntryDisplay.accent_color(defending_lost), AbyssColors.ERROR, "the base fell")


func test_a_capture_glows_with_the_energy_yellow() -> void:
	assert_eq(HistoryEntryDisplay.accent_color(HistorySamples.capture_entry("faille:0")), AbyssColors.ENERGY_YELLOW)


func test_every_other_entry_wears_the_colour_of_its_category() -> void:
	for entry in _plain_entries():
		assert_eq(HistoryEntryDisplay.accent_color(entry), HistoryColors.of(entry.category), str(entry.category))
		assert_false(HistoryEntryDisplay.is_tappable(entry), str(entry.category))


func test_the_entries_with_a_stored_fight_are_tappable() -> void:
	var tappable: Array[HistoryEntry] = [HistorySamples.combat_entry(true), HistorySamples.combat_entry(false),
		HistorySamples.raid_entry(true), HistorySamples.raid_entry(false, true), HistorySamples.volcano_entry(true),
		HistorySamples.capture_entry("faille:0"), HistorySamples.base_assault_entry(true, false)]
	for entry in tappable:
		assert_true(HistoryEntryDisplay.is_tappable(entry), str(entry.category))


func test_an_event_and_a_school_of_predators_have_a_picture() -> void:
	var caravan := EventEntry.new(1, RandomEventType.Value.CARAVAN, true, false)
	assert_eq(HistoryEntryDisplay.illustration(caravan), RandomEventTexts.illustration(RandomEventType.Value.CARAVAN))
	assert_eq(HistoryEntryDisplay.illustration(HistorySamples.raid_entry(true, true)),
		RandomEventTexts.illustration(RandomEventType.Value.PREDATORS))


func test_the_others_keep_the_glyph_of_their_category() -> void:
	assert_eq(HistoryEntryDisplay.illustration(HistorySamples.raid_entry(true)), "")
	assert_eq(HistoryEntryDisplay.illustration(HistorySamples.combat_entry(true)), "")
	assert_eq(HistoryEntryDisplay.illustration(BuildingEntry.new(1, BuildingType.Value.BARRACKS, 1)), "")
