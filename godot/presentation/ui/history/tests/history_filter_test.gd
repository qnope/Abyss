extends TextsTestCase
## test/presentation/widgets/history/history_filter_test.dart and the filter
## part of history_event_card_test.dart.

const Filter := HistoryFilter.Value


func _entries() -> Array[HistoryEntry]:
	return [
		BuildingEntry.new(1, BuildingType.Value.ALGAE_FARM, 1),
		ResearchEntry.new(1, TechBranch.Value.MILITARY, true),
		RecruitEntry.new(2, UnitType.Value.SCOUT, 3),
		ExploreEntry.new(2, 1, 2),
		CollectEntry.new(3, 4, 5, {}),
		CombatEntry.new(3, true, 6, 7, MonsterLair.new(MonsterDifficulty.Value.EASY, 2),
			HistorySamples.fight(true), {}, {}, {}, {}, {}),
		HistorySamples.turn_end_entry(4),
	]


func _count_of(entries: Array[HistoryEntry], type: GDScript) -> int:
	return entries.filter(func(entry: HistoryEntry) -> bool: return is_instance_of(entry, type)).size()


func test_all_returns_every_entry() -> void:
	assert_eq(HistoryFilter.apply(_entries(), Filter.ALL).size(), 7)


func test_combat_keeps_only_combat_entries() -> void:
	var kept := HistoryFilter.apply(_entries(), Filter.COMBAT)
	assert_eq(kept.size(), 1)
	assert_true(kept[0] is CombatEntry)


func test_building_keeps_only_building_entries() -> void:
	var kept := HistoryFilter.apply(_entries(), Filter.BUILDING)
	assert_eq(kept.size(), 1)
	assert_true(kept[0] is BuildingEntry)


func test_research_keeps_only_research_entries() -> void:
	var kept := HistoryFilter.apply(_entries(), Filter.RESEARCH)
	assert_eq(kept.size(), 1)
	assert_true(kept[0] is ResearchEntry)


func test_other_groups_recruit_explore_collect_and_turn_end() -> void:
	var kept := HistoryFilter.apply(_entries(), Filter.OTHER)
	assert_eq(kept.size(), 4)
	for type: GDScript in [RecruitEntry, ExploreEntry, CollectEntry, TurnEndEntry]:
		assert_eq(_count_of(kept, type), 1)


func test_other_also_keeps_captures_descents_and_reinforcements() -> void:
	var entries: Array[HistoryEntry] = [HistorySamples.capture_entry("faille:0"), DescentEntry.new(1, 2, 3),
		ReinforcementEntry.new(1, 2, 3), HistorySamples.combat_entry(true)]
	assert_eq(HistoryFilter.apply(entries, Filter.OTHER).size(), 3)


func test_combat_keeps_the_raids_the_waves_and_the_assaults() -> void:
	var entries: Array[HistoryEntry] = [HistorySamples.combat_entry(true), HistorySamples.raid_entry(true),
		HistorySamples.volcano_entry(true), HistorySamples.base_assault_entry(true, false),
		BuildingEntry.new(1, BuildingType.Value.BARRACKS, 1)]
	assert_eq(HistoryFilter.apply(entries, Filter.COMBAT).size(), 4)


func test_the_event_filter_keeps_the_events_and_the_predators() -> void:
	var caravan := EventEntry.new(6, RandomEventType.Value.CARAVAN, false, true)
	var raid := HistorySamples.raid_entry(true)
	var predators := HistorySamples.raid_entry(true, true)
	var entries: Array[HistoryEntry] = [caravan, raid, predators]
	assert_eq(HistoryFilter.apply(entries, Filter.EVENT), [caravan, predators] as Array[HistoryEntry])
	assert_true(HistoryFilter.apply(entries, Filter.OTHER).is_empty())
	assert_eq(HistoryFilter.apply(entries, Filter.COMBAT), [raid, predators] as Array[HistoryEntry])


func test_the_order_of_the_entries_is_kept() -> void:
	var entries := _entries()
	var kept := HistoryFilter.apply(entries, Filter.OTHER)
	assert_eq(kept, [entries[2], entries[3], entries[4], entries[6]] as Array[HistoryEntry])


func test_exposes_the_french_labels() -> void:
	assert_eq(HistoryFilter.label(Filter.ALL), "Tous")
	assert_eq(HistoryFilter.label(Filter.COMBAT), "Combats")
	assert_eq(HistoryFilter.label(Filter.BUILDING), "Construction")
	assert_eq(HistoryFilter.label(Filter.RESEARCH), "Recherche")
	assert_eq(HistoryFilter.label(Filter.EVENT), "Événements")
	assert_eq(HistoryFilter.label(Filter.OTHER), "Autres")


func test_words_every_value_in_english_and_spanish() -> void:
	var expected := {"en": ["All", "Combat", "Construction", "Research", "Events", "Other"],
		"es": ["Todos", "Combates", "Construcción", "Investigación", "Eventos", "Otros"]}
	for locale: String in expected:
		TranslationServer.set_locale(locale)
		var labels := []
		for filter: Filter in Filter.values():
			labels.append(HistoryFilter.label(filter))
		assert_eq(labels, expected[locale])
	assert_every_value_translated(Filter, func(filter: int) -> String:
		return TextKeys.of("historyFilter", Filter, filter))
