extends TextsTestCase
## test/presentation/extensions/history_entry_category_extensions_test.dart.

const Category := HistoryEntryCategory.Value


func test_maps_every_category_to_its_french_label() -> void:
	var expected: Dictionary[HistoryEntryCategory.Value, String] = {
		Category.COMBAT: "Combat", Category.BUILDING: "Construction", Category.RESEARCH: "Recherche",
		Category.RECRUIT: "Recrutement", Category.EXPLORE: "Exploration", Category.COLLECT: "Collecte",
		Category.TURN_END: "Fin de tour", Category.CAPTURE: "Capture", Category.DESCENT: "Descente",
		Category.REINFORCEMENT: "Renfort", Category.EVENT: "Événement",
	}
	for category: Category in expected:
		assert_eq(HistoryCategoryTexts.label(category), expected[category])


func test_translates_the_labels() -> void:
	TranslationServer.set_locale("en")
	assert_eq(HistoryCategoryTexts.label(Category.TURN_END), "End of turn")
	TranslationServer.set_locale("es")
	assert_eq(HistoryCategoryTexts.label(Category.RESEARCH), "Investigación")


func test_every_category_has_a_distinct_label_in_every_language() -> void:
	assert_every_value_translated(Category, func(category: int) -> String:
		return TextKeys.of("historyCategory", Category, category))
	var labels := {}
	for category: Category in Category.values():
		labels[HistoryCategoryTexts.label(category)] = true
	assert_eq(labels.size(), Category.size())


func test_every_category_has_a_distinct_glyph_that_exists() -> void:
	var icons := {}
	for category: Category in Category.values():
		var icon := HistoryCategoryTexts.icon(category)
		icons[icon] = true
		assert_true(ResourceLoader.exists(UiIcon.glyph_path(icon)), str(icon))
	assert_eq(icons.size(), Category.size())
	assert_eq(HistoryCategoryTexts.icon(Category.BUILDING), &"build")
	assert_eq(HistoryCategoryTexts.icon(Category.ASSAULT), &"sports_kabaddi")
