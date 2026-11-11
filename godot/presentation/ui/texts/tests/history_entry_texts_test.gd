extends TextsTestCase
## test/presentation/extensions/history_entry_texts_test.dart,
## history_entry_fight_texts_test.dart and the post and kernel assault tests
## of widgets/history/.

const Type := RandomEventType.Value


func _title(entry: HistoryEntry, locale := "fr") -> String:
	TranslationServer.set_locale(locale)
	return HistoryEntryTexts.title(entry)


func _subtitle(entry: HistoryEntry, locale := "fr") -> Variant:
	TranslationServer.set_locale(locale)
	return HistoryEntryTexts.subtitle(entry)


func _recruit(type: UnitType.Value, quantity: int) -> RecruitEntry:
	return RecruitEntry.new(1, type, quantity)


func test_titles_a_recruitment_with_the_plural_of_its_units() -> void:
	assert_eq(_title(_recruit(UnitType.Value.SCOUT, 1)), "1 éclaireur recruté")
	assert_eq(_title(_recruit(UnitType.Value.SCOUT, 3)), "3 éclaireurs recrutés")
	assert_eq(_title(_recruit(UnitType.Value.SCOUT, 1), "en"), "1 scout recruited")
	assert_eq(_title(_recruit(UnitType.Value.SCOUT, 3), "en"), "3 scouts recruited")
	assert_eq(_title(_recruit(UnitType.Value.SCOUT, 1), "es"), "1 explorador reclutado")
	assert_eq(_title(_recruit(UnitType.Value.SCOUT, 3), "es"), "3 exploradores reclutados")
	assert_eq(_title(_recruit(UnitType.Value.ABYSS_ADMIRAL, 2)), "2 amiraux des abysses recrutés")


func test_titles_buildings_research_and_coordinates_in_each_language() -> void:
	var building := BuildingEntry.new(1, BuildingType.Value.BARRACKS, 2)
	assert_eq(_title(building), "Caserne niv. 2")
	assert_eq(_title(building, "en"), "Barracks lv. 2")
	var unlock := ResearchEntry.new(1, TechBranch.Value.MILITARY, true)
	assert_eq(_title(unlock), "Militaire débloquée")
	assert_eq(_title(unlock, "es"), "Militar desbloqueada")
	assert_eq(_title(ResearchEntry.new(1, TechBranch.Value.RESOURCES, false, 3), "en"), "Resources lv. 3")
	assert_eq(_title(ExploreEntry.new(1, 5, 7)), "Exploration (5, 7)")
	assert_eq(_title(ExploreEntry.new(1, 5, 7), "es"), "Exploración (5, 7)")
	var collect := CollectEntry.new(1, 2, 4, {})
	assert_eq(_title(collect), "Trésor collecté (2, 4)")
	assert_eq(_title(collect, "en"), "Treasure collected (2, 4)")
	assert_eq(_title(HistorySamples.turn_end_entry(12)), "Tour 12 terminé")
	assert_eq(_title(HistorySamples.turn_end_entry(12), "en"), "Turn 12 ended")


func test_a_research_saved_without_its_level_says_the_branch_improved() -> void:
	assert_eq(_title(ResearchEntry.new(1, TechBranch.Value.EXPLORER, false), "en"), "Explorer improved")


func test_entries_without_details_have_no_subtitle() -> void:
	assert_null(_subtitle(HistorySamples.combat_entry(true)))
	assert_null(_subtitle(_recruit(UnitType.Value.GUARDIAN, 2)))


func test_titles_fights_after_their_outcome() -> void:
	assert_eq(_title(HistorySamples.combat_entry(true)), "Victoire vs Repaire niv. 2")
	assert_eq(_title(HistorySamples.combat_entry(false), "en"), "Defeat vs Lair lv. 2")
	assert_eq(_title(HistorySamples.raid_entry(true)), "Raid repoussé")
	assert_eq(_title(HistorySamples.raid_entry(false), "es"), "Base saqueada por una incursión")
	assert_eq(_title(HistorySamples.raid_entry(true, true)), "Banc de prédateurs repoussé")
	assert_eq(_title(HistorySamples.raid_entry(false, true), "en"), "Base looted by a predator shoal")
	assert_eq(_title(HistorySamples.volcano_entry(true)), "Vague repoussée sur le Noyau")
	assert_eq(_title(HistorySamples.volcano_entry(false), "en"), "The Core lost a level")


func test_titles_captures_after_the_base_or_the_volcanic_core() -> void:
	var base := HistorySamples.capture_entry("Faille Alpha")
	assert_eq(_title(base), "Capture : Faille Alpha")
	assert_eq(_title(base, "en"), "Capture: Alpha Rift")
	assert_eq(_title(HistorySamples.capture_entry("cheminee:1"), "es"), "Captura: Chimenea Secundaria")
	assert_eq(_title(HistorySamples.capture_entry("Faille Noire"), "en"), "Capture: Faille Noire")
	var kernel := HistorySamples.capture_entry(CaptureEntry.VOLCANIC_KERNEL)
	assert_eq(_title(kernel), "Capture : Noyau Volcanique")
	assert_eq(_title(kernel, "es"), "Captura: Núcleo Volcánico")
	assert_eq(_subtitle(base), "Victoire en 2 tours")
	assert_eq(_subtitle(base, "en"), "Victory in 2 turns")


func test_titles_a_victory_where_the_admiral_fell() -> void:
	var fell := CaptureEntry.new(6, "faille:0", HistorySamples.fight(true), false)
	assert_eq(_title(fell), "Pas de prise : Faille Alpha")
	assert_eq(_title(fell, "en"), "Not captured: Alpha Rift")
	assert_eq(_title(fell, "es"), "Sin captura: Falla Alfa")
	assert_eq(_subtitle(fell), "Victoire, mais l'Amiral est tombé")
	assert_eq(_subtitle(fell, "en"), "Victory, but the Admiral fell")


func test_counts_the_units_of_a_descent_and_of_reinforcements() -> void:
	var descent := DescentEntry.new(1, 2, 1)
	assert_eq(_title(descent), "Descente au Niveau 2")
	assert_eq(_subtitle(descent), "1 unité envoyée")
	assert_eq(_title(descent, "en"), "Descent to Level 2")
	var sent := ReinforcementEntry.new(1, 3, 3)
	assert_eq(_title(sent), "Renforts vers Niveau 3")
	assert_eq(_subtitle(sent), "3 unités en transit")
	assert_eq(_subtitle(sent, "es"), "3 unidades en tránsito")


func test_says_which_choice_an_event_got_when_it_had_one() -> void:
	var accepted := EventEntry.new(1, Type.CARAVAN, true, false)
	var refused := EventEntry.new(1, Type.CARAVAN, false, false)
	assert_eq(_title(refused, "en"), "Turtle Caravan")
	assert_eq(_subtitle(accepted), "Accepté")
	assert_eq(_subtitle(refused), "Refusé")
	assert_eq(_subtitle(EventEntry.new(1, Type.CARAVAN, false, true)), "Option prudente, sans choix")
	assert_eq(_subtitle(refused, "es"), "Rechazado")
	assert_null(_subtitle(EventEntry.new(1, Type.STORM, true, false)))


func test_each_side_reads_the_fate_of_the_post_in_its_own_words() -> void:
	var won := HistorySamples.base_assault_entry(true, false, "faille:1")
	assert_eq(_title(won), "Faille Bêta prise à Nacre")
	assert_eq(_title(HistorySamples.base_assault_entry(false, false, "faille:1")), "Assaut sur Faille Bêta repoussé par Nacre")
	assert_eq(_title(HistorySamples.base_assault_entry(true, true, "faille:1")), "Faille Bêta prise par Nacre")
	assert_eq(_title(HistorySamples.base_assault_entry(false, true, "faille:1")), "Assaut de Nacre sur Faille Bêta repoussé")
	assert_eq(_title(won, "en"), "Beta Rift taken from Nacre")
	assert_false(_title(won, "es").is_empty())


func test_an_assault_on_a_base_or_on_the_kernel_names_the_attacker() -> void:
	assert_eq(_title(HistorySamples.base_assault_entry(true, false)), "Assaut réussi contre Nacre")
	assert_eq(_title(HistorySamples.base_assault_entry(true, false), "en"), "Assault on Nacre succeeded")
	assert_eq(_title(HistorySamples.base_assault_entry(false, false, CaptureEntry.VOLCANIC_KERNEL)), "Assaut repoussé par Nacre")
	assert_eq(_title(HistorySamples.base_assault_entry(true, true)), "Base attaquée par Nacre")
	assert_eq(_title(HistorySamples.base_assault_entry(false, true)), "Assaut de Nacre repoussé")


func test_the_guardians_attack_under_their_own_name() -> void:
	var entry := BaseAssaultEntry.new(14, true, true, LeviathanForce.ATTACKER_NAME, HistorySamples.fight(true),
		{}, {}, {}, {}, 2, 0, 5, 5, {}, {})
	assert_eq(_title(entry, "en"), "Base attacked by The Leviathan")


func test_every_title_is_a_translated_text() -> void:
	for entry: HistoryEntry in [HistorySamples.combat_entry(true), HistorySamples.raid_entry(true, true),
			HistorySamples.volcano_entry(false), HistorySamples.capture_entry("faille:2"),
			HistorySamples.base_assault_entry(true, true, "cheminee:0")]:
		for locale in LANGUAGES:
			assert_false(_title(entry, locale).is_empty())
