extends TextsTestCase
## test/presentation/extensions/objective_extensions_test.dart and
## temporary_objective_kind_extensions_test.dart.

const Chapter := ObjectiveChapter.Value
const Id := ObjectiveId.Value


func _title(id: Id) -> String:
	return ObjectiveTexts.display_title(ObjectiveCatalog.by_id(id))


func test_names_the_six_chapters_in_french() -> void:
	var titles: Array[String] = []
	for chapter: Chapter in Chapter.values():
		titles.append(ChapterTexts.title(chapter))
	assert_eq(titles, ["Installation", "Le récif", "La Faille", "La Cheminée", "Le Noyau", "Le réveil"] as Array[String])


func test_names_the_chapters_in_english_and_spanish() -> void:
	TranslationServer.set_locale("en")
	assert_eq(ChapterTexts.title(Chapter.REEF), "The Reef")
	assert_eq(ChapterTexts.title(Chapter.AWAKENING), "The Awakening")
	TranslationServer.set_locale("es")
	assert_eq(ChapterTexts.title(Chapter.CHIMNEY), "La Chimenea")
	assert_eq(ChapterTexts.title(Chapter.INSTALLATION), "Instalación")


func test_tells_the_lore_of_a_chapter() -> void:
	assert_eq(ChapterTexts.lore(Chapter.REEF), "Le récif a ses propres créatures, et elles écoutent. Tiens ton dôme.")
	assert_eq(ChapterTexts.lore(Chapter.RIFT), "Sous le récif, un Léviathan garde chaque Faille. Qui descend ne remonte pas.")
	for locale: String in ["en", "es"]:
		TranslationServer.set_locale(locale)
		var seen := {}
		for chapter: Chapter in Chapter.values():
			seen[ChapterTexts.lore(chapter)] = true
		assert_eq(seen.size(), Chapter.size(), locale)


func test_numbers_the_chapters_from_one() -> void:
	assert_eq(ChapterTexts.numbered_title(Chapter.INSTALLATION), "1. Installation")
	TranslationServer.set_locale("en")
	assert_eq(ChapterTexts.numbered_title(Chapter.REEF), "2. The Reef")
	TranslationServer.set_locale("es")
	assert_eq(ChapterTexts.numbered_title(Chapter.KERNEL), "5. El Núcleo")


func test_words_every_objective_in_french_in_catalog_order() -> void:
	var titles: Array[String] = []
	for objective in ObjectiveCatalog.all():
		titles.append(ObjectiveTexts.display_title(objective))
	assert_eq(titles.slice(0, 7), [
		"Monte le QG au niveau 1", "Construis la Ferme d'algues",
		"Construis la Mine de corail et l'Extracteur de minerai", "Construis le Panneau solaire",
		"Monte le QG au niveau 2", "Construis la Caserne et recrute 2 Éclaireurs",
		"Explore une case autour de la base"] as Array[String])
	assert_eq(titles.slice(14, 16), ["Construis le Module de Descente", "Descends au niveau 2"] as Array[String])
	assert_eq(titles[24], "Monte le Noyau au niveau 10")


func test_words_them_in_english_and_spanish() -> void:
	TranslationServer.set_locale("en")
	assert_eq(_title(Id.HQ_LEVEL_5), "Raise the HQ to level 5")
	assert_eq(_title(Id.BARRACKS_AND_SCOUTS), "Build the Barracks and recruit 2 Scouts")
	assert_eq(_title(Id.TAKE_KERNEL), "Take the Volcanic Core")
	TranslationServer.set_locale("es")
	assert_eq(_title(Id.DESCEND_LEVEL_3), "Desciende al nivel 3")
	assert_eq(_title(Id.FIRST_RAID), "Repele la primera incursión")


func test_every_title_is_unique_in_each_language() -> void:
	for locale: String in LANGUAGES:
		TranslationServer.set_locale(locale)
		var seen := {}
		for objective in ObjectiveCatalog.all():
			seen[ObjectiveTexts.display_title(objective)] = true
		assert_eq(seen.size(), ObjectiveId.Value.size(), locale)


func test_the_figure_is_the_number_the_goal_names() -> void:
	var raise := ObjectiveCatalog.by_id(Id.HQ_LEVEL_8)
	assert_eq(ObjectiveTexts.figure(raise), 8)
	assert_eq(ObjectiveTexts.figure(ObjectiveCatalog.by_id(Id.DESCEND_LEVEL_3)), 3)
	assert_eq(ObjectiveTexts.figure(ObjectiveCatalog.by_id(Id.BARRACKS_AND_SCOUTS)), 2)
	assert_eq(ObjectiveTexts.figure(ObjectiveCatalog.by_id(Id.FIRST_RAID)), 1)
	assert_eq(ObjectiveTexts.figure(ObjectiveCatalog.by_id(Id.TAKE_LAIR)), 1)


func test_a_temporary_objective_has_a_short_name_and_a_title() -> void:
	var wreck := TemporaryObjective.new(TemporaryObjectiveKind.Value.WRECK, 17)
	var predators := TemporaryObjective.new(TemporaryObjectiveKind.Value.PREDATORS, 12)
	assert_eq(TemporaryObjectiveTexts.short_label(wreck.kind), "Épave")
	assert_eq(TemporaryObjectiveTexts.display_title(wreck), "Fouille l'épave d'ici la fin du tour 17")
	assert_eq(TemporaryObjectiveTexts.display_title(predators), "Repousse le banc de prédateurs")
	TranslationServer.set_locale("en")
	assert_eq(TemporaryObjectiveTexts.display_title(predators), "Repel the predator shoal")
	TranslationServer.set_locale("es")
	assert_eq(TemporaryObjectiveTexts.display_title(predators), "Repele el banco de depredadores")


func test_every_text_is_translated_in_every_language() -> void:
	assert_every_value_translated(Chapter, func(value: int) -> String:
		return TextKeys.of("chapter", Chapter, value, "Lore"))
	assert_every_value_translated(TemporaryObjectiveKind.Value, func(value: int) -> String:
		return TextKeys.of("temporaryObjective", TemporaryObjectiveKind.Value, value, "Short"))
