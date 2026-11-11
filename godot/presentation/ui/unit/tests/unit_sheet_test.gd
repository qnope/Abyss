extends UnitTestCase
## What the sheet of a unit shows (test/presentation/widgets/unit/
## unit_detail_sheet_test.dart).


func _guardian() -> UnitSheet:
	human.buildings[Barracks].level = 0
	return open_sheet(Type.GUARDIAN)


func test_a_locked_unit_shows_its_name_and_the_barracks_level_it_waits_for() -> void:
	var sheet := _guardian()
	assert_not_null(find_text("Gardien", sheet))
	assert_not_null(find_text("Caserne niveau 3 requise pour débloquer", sheet))
	assert_no_raw_keys()


func test_a_locked_unit_shows_no_stats_and_no_recruiting() -> void:
	var sheet := _guardian()
	assert_null(find_text("PV: 25", sheet))
	assert_null(slider_in(sheet))
	assert_null(find_text("Recruter", sheet))


func test_a_locked_unit_has_its_picture_in_grey() -> void:
	var sheet := _guardian()
	var portrait := portrait_in(sheet)
	assert_eq(portrait.initials_label.get_theme_color(&"font_color"), AbyssColors.DISABLED)


func test_an_unlocked_unit_shows_its_name_role_and_what_it_does() -> void:
	var sheet := open_sheet(Type.HARPOONIST, 5)
	assert_not_null(find_text("Harponneur", sheet))
	assert_not_null(find_text(UnitTexts.role(Type.HARPOONIST), sheet))
	assert_not_null(find_text(UnitTexts.role_effect(Type.HARPOONIST), sheet))
	assert_eq(find_text("Harponneur", sheet).get_theme_color(&"font_color"), UnitColors.of(Type.HARPOONIST))


func test_an_unlocked_unit_shows_its_stats() -> void:
	var sheet := open_sheet(Type.SCOUT, 5)
	for stat: String in ["PV: 10", "ATK: 2", "DEF: 1"]:
		assert_not_null(find_text(stat, sheet), stat)


func test_an_unlocked_unit_shows_how_many_serve() -> void:
	var sheet := open_sheet(Type.SCOUT, 5)
	assert_not_null(find_text("En service : 5", sheet))
	assert_not_null(find_text("Recruter", sheet))
	assert_not_null(slider_in(sheet))


func test_its_picture_is_in_colour() -> void:
	var sheet := open_sheet(Type.SCOUT, 5)
	var portrait := portrait_in(sheet)
	assert_eq(portrait.initials_label.get_theme_color(&"font_color"), UnitColors.of(Type.SCOUT))


func test_says_that_the_type_was_already_recruited() -> void:
	human.recruited_unit_types.append(Type.SCOUT)
	var sheet := open_sheet(Type.SCOUT, 5)
	assert_not_null(find_text("Recrutement déjà effectué ce tour", sheet))


func test_the_sheet_reads_the_game_when_it_is_built_again() -> void:
	var sheet := open_sheet(Type.SCOUT, 5)
	human.buildings[Barracks].level = 0
	sheet.refresh()
	assert_not_null(find_text("Caserne niveau 1 requise pour débloquer", sheet))
	assert_null(find_text("PV: 10", sheet))


func test_follows_the_language_without_a_rebuild() -> void:
	var sheet := open_sheet(Type.SCOUT, 5)
	use_language("en")
	assert_not_null(find_text("In service: 5", sheet))
	assert_not_null(find_text("Recruit", sheet))
	assert_not_null(find_text("Scout", sheet))
	assert_no_raw_keys()
	use_language("es")
	assert_no_raw_keys()
	assert_not_null(find_text("Explorador", sheet))
