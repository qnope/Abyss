extends ObjectiveCase
## test/presentation/widgets/objective/objectives_sheet_test.dart,
## objectives_sheet_lore_test.dart, objective_section_header_test.dart and the
## row of objective_row.dart.

const Status := ObjectiveStatus.Value


func _sheet(game: Game) -> ObjectivesSheet:
	var sheet := ObjectivesSheet.new(game)
	modals().open(sheet)
	return sheet


func _rows(sheet: ObjectivesSheet) -> Array[ObjectiveRow]:
	var found: Array[ObjectiveRow] = []
	for part in sheet.sections.get_children():
		if part is ObjectiveRow:
			found.append(part as ObjectiveRow)
	return found


func _row(sheet: ObjectivesSheet, id: ObjectiveId.Value) -> ObjectiveRow:
	var title := ObjectiveTexts.display_title(ObjectiveCatalog.by_id(id))
	for row in _rows(sheet):
		if row.title_label.text == title:
			return row
	return null


func test_lists_the_six_chapters_in_order() -> void:
	var sheet := _sheet(game_with_completed(0))
	var titles: Array[String] = []
	for part in sheet.sections.get_children():
		if part is ObjectiveSectionHeader:
			titles.append((part as ObjectiveSectionHeader).title_label.text)
	assert_eq(titles.size(), 6)
	assert_eq(titles[0], "1. Installation")
	assert_eq(titles[5], "6. Le réveil")


func test_lists_every_objective_of_the_catalog() -> void:
	assert_eq(_rows(_sheet(game_with_completed(0))).size(), ObjectiveId.Value.size())


func test_marks_objectives_done_current_and_to_do() -> void:
	var sheet := _sheet(game_with_completed(2))
	assert_eq(_row(sheet, ObjectiveId.Value.HQ_LEVEL_1).status, Status.DONE)
	assert_eq(_row(sheet, ObjectiveId.Value.ALGAE_FARM).status, Status.DONE)
	assert_eq(_row(sheet, ObjectiveId.Value.MINES).status, Status.CURRENT)
	assert_eq(_row(sheet, ObjectiveId.Value.SOLAR_PANEL).status, Status.TO_DO)
	assert_eq(_row(sheet, ObjectiveId.Value.KERNEL_LEVEL_10).status, Status.TO_DO)


func test_shows_the_progress_of_the_current_objective_only() -> void:
	var sheet := _sheet(game_with_completed(2))
	assert_eq(_row(sheet, ObjectiveId.Value.MINES).progress_label.text, "0/2")
	assert_null(_row(sheet, ObjectiveId.Value.SOLAR_PANEL).progress_label)
	assert_eq(texts(sheet).count("0/2"), 1)


func test_shows_the_reward_of_each_objective_with_its_icons() -> void:
	var sheet := _sheet(game_with_completed(0))
	var rewarded := 0
	for objective in ObjectiveCatalog.all():
		rewarded += objective.reward.size()
	assert_eq(find_type("ResourceIcon", sheet).size(), rewarded)


func test_lists_the_active_temporary_objectives_first() -> void:
	var game := game_with_completed(0)
	game.turn = 12
	lay_wreck(game)
	var sheet := _sheet(game)
	var first := sheet.sections.get_child(0) as ObjectiveSectionHeader
	assert_eq(first.title_label.text, "Objectifs d'événement")
	var row := sheet.sections.get_child(1) as ObjectiveRow
	assert_eq(row.status, Status.TEMPORARY)
	assert_eq(row.title_label.text, "Fouille l'épave d'ici la fin du tour 17")


func test_has_no_event_section_without_temporary_objectives() -> void:
	assert_null(find_text("Objectifs d'événement", _sheet(game_with_completed(0))))


func test_titles_the_sheet() -> void:
	var sheet := _sheet(game_with_completed(0))
	assert_eq(sheet.title_label.text, "Objectifs")
	assert_not_null(find_text("2. Le récif", sheet))
	assert_not_null(find_text("Construis la Citadelle corallienne", sheet))


func test_tells_the_lore_under_each_chapter_header() -> void:
	var sheet := _sheet(game_with_completed(0))
	for locale: String in ["fr", "en", "es"]:
		use_language(locale)
		for part in sheet.sections.get_children():
			if part is ObjectiveSectionHeader:
				var header := part as ObjectiveSectionHeader
				assert_not_null(header.lore_label, header.title_label.text)
				assert_ne(header.lore_label.text, "")


func test_speaks_english_and_spanish() -> void:
	var game := game_with_completed(0)
	game.turn = 12
	lay_wreck(game)
	var sheet := _sheet(game)
	use_language("en")
	for words: String in ["Objectives", "Event objectives", "1. Settling In", "6. The Awakening",
			"Raise the HQ to level 10", "Build the Barracks and recruit 2 Scouts"]:
		assert_not_null(find_text(words, sheet), words)
	use_language("es")
	for words: String in ["Objetivos", "Objetivos de evento", "1. Instalación", "Sube el Cuartel General al nivel 10"]:
		assert_not_null(find_text(words, sheet), words)
	assert_no_raw_keys(sheet)


func test_a_header_without_lore_is_its_title_alone() -> void:
	var header := mount(ObjectiveSectionHeader.new("Événements")) as ObjectiveSectionHeader
	assert_null(header.lore_label)
	assert_not_null(find_text("Événements"))
	var with_lore := mount(ObjectiveSectionHeader.new("2. Le récif", "Le récif écoute.")) as ObjectiveSectionHeader
	assert_true(with_lore.lore_label is LoreText)


func test_a_row_pays_its_reward_and_shows_its_progress() -> void:
	var reward: Dictionary[ResourceType.Value, int] = {ResourceType.Value.CORAL: 30}
	var row := mount(ObjectiveRow.new("Monte le QG", Status.CURRENT, ObjectiveProgress.new(1, 3), reward)) as ObjectiveRow
	assert_eq(row.progress_label.text, "1/3")
	assert_not_null(row.rewards)
	var bare := mount(ObjectiveRow.new("Fini", Status.DONE)) as ObjectiveRow
	assert_null(bare.rewards)
	assert_null(bare.progress_label)
