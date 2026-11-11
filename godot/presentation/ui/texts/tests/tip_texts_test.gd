extends TextsTestCase
## test/presentation/extensions/tip_texts_test.dart, tip_post_texts_test.dart
## and tip_archive_texts_test.dart: the cards of the tips.

const Id := TipId.Value


func _lines(id: Id, locale := "fr") -> PackedStringArray:
	TranslationServer.set_locale(locale)
	return TipTexts.lines(id)


func _title(id: Id, locale := "fr") -> String:
	TranslationServer.set_locale(locale)
	return TipTexts.title(id)


func test_the_sections_of_the_guide_are_named() -> void:
	var names: Array[String] = []
	for category: TipCategory.Value in TipCategory.Value.values():
		names.append(TipTexts.category_label(category))
	assert_eq(names, ["Base", "Menaces", "Carte", "Événements", "Archives"] as Array[String])
	TranslationServer.set_locale("en")
	assert_eq(TipTexts.category_label(TipCategory.Value.THREATS), "Threats")
	TranslationServer.set_locale("es")
	assert_eq(TipTexts.category_label(TipCategory.Value.EVENTS), "Eventos")


func test_every_tip_has_a_title_and_two_or_three_short_lines() -> void:
	for locale: String in LANGUAGES:
		for id: Id in Id.values():
			var reason := "%s %s" % [locale, id]
			assert_ne(_title(id, locale), "", reason)
			var lines := _lines(id, locale)
			assert_true(lines.size() >= 2 and lines.size() <= 3, reason)
			for line in lines:
				assert_true(line.length() <= 120, line)


func test_the_posts_and_archives_have_three_lines() -> void:
	for id: Id in [Id.ADMIRAL, Id.POST_DEFENCE, Id.KERNEL_GARRISON, Id.POST_LOST, Id.ABYSS_LISTENS,
			Id.RIVAL_COLONIES, Id.ANCIENTS, Id.FORGE_TOWERS, Id.AWAKENING]:
		assert_eq(_lines(id).size(), 3, str(id))


func test_it_names_the_buildings_as_the_base_shows_them() -> void:
	for locale: String in LANGUAGES:
		TranslationServer.set_locale(locale)
		assert_true(" ".join(TipTexts.lines(Id.RAID_ANNOUNCED)).contains(
			BuildingTexts.display_name(BuildingType.Value.CORAL_CITADEL)), locale)
		assert_true(" ".join(TipTexts.lines(Id.DESCENT)).contains(
			BuildingTexts.display_name(BuildingType.Value.DESCENT_MODULE)), locale)


func test_each_event_tip_is_titled_after_its_event() -> void:
	for locale: String in LANGUAGES:
		TranslationServer.set_locale(locale)
		assert_eq(TipTexts.title(Id.PREDATORS), RandomEventTexts.label(RandomEventType.Value.PREDATORS))
		assert_eq(TipTexts.title(Id.WARM_CURRENT), RandomEventTexts.label(RandomEventType.Value.WARM_CURRENT))


func test_it_fills_in_the_rules_of_the_game() -> void:
	assert_eq(_lines(Id.NOISE_GAUGE)[1], "Quand la jauge atteint 40, les monstres l'entendent : un raid est annoncé.")
	assert_eq(_lines(Id.EVENTS, "en")[0], "Every %d to %d turns, an event shakes the abyss." % [
		EventRules.MIN_GAP, EventRules.MAX_GAP])
	assert_eq(_lines(Id.LAST_CHANCE)[0], "Ta base a perdu 2 raids d'affilée.")
	assert_eq(_lines(Id.WRECK, "es")[2], "Registrarlo hace ruido (+%d): elige tu momento." % EventRules.WRECK_NOISE)
	assert_true(_lines(Id.WORKSITES)[0].contains("niveau 5"))
	assert_true(_lines(Id.WORKSITES)[1].contains("niveau 10"))
	assert_true(_lines(Id.KERNEL_GARRISON)[2].contains("Mettre en garnison"))


func test_it_speaks_english_and_spanish() -> void:
	assert_eq(_title(Id.NOISE_GAUGE, "en"), "The noise gauge")
	assert_eq(_lines(Id.RAID_ANNOUNCED, "en")[0], "Your noise drew monsters: they will strike your base in 2 turns.")
	assert_eq(_title(Id.TECH_CHOICE, "es"), "Las elecciones de la investigación")
	assert_eq(_lines(Id.STORM, "es")[0], "La tormenta cierra la exploración durante 2 turnos.")
	assert_eq(_title(Id.ADMIRAL), "L'Amiral")
	assert_eq(_title(Id.POST_LOST, "es"), "Puesto perdido")
