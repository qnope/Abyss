extends BuildingTestCase
## The sheet of a building (building_detail_sheet_test.dart): what it is, what
## it does, and what is special to the headquarters and the citadel.

const Type := BuildingType.Value


func test_names_a_built_building_with_its_level_and_what_it_does() -> void:
	set_levels({Type.HEADQUARTERS: 3, Type.ALGAE_FARM: 2})
	var sheet := open_sheet(Type.ALGAE_FARM)
	assert_not_null(find_text("Ferme d'algues", sheet))
	assert_not_null(find_text("Niveau 2", sheet))
	assert_not_null(find_text(BuildingTexts.description(Type.ALGAE_FARM), sheet))
	assert_eq(sheet.placement, ModalPanel.Placement.BOTTOM)
	assert_no_raw_keys()


func test_a_building_still_to_build_says_so() -> void:
	var sheet := open_sheet(Type.LABORATORY)
	assert_not_null(find_text("Non construit", sheet))
	assert_null(find_text("Niveau 0", sheet))
	assert_not_null(find_text("Construire", sheet))


func test_the_name_wears_the_colour_of_the_building() -> void:
	var sheet := open_sheet(Type.SOLAR_PANEL)
	var header := sheet.column.get_child(0) as BuildingHeader
	assert_eq(header.name_label.get_theme_color(&"font_color"), BuildingColors.of(Type.SOLAR_PANEL))
	assert_eq(header.portrait.display_name, "Panneau solaire")


func test_the_headquarters_tells_the_worksites_and_the_rampart() -> void:
	set_levels({Type.HEADQUARTERS: 2})
	var sheet := open_sheet(Type.HEADQUARTERS)
	assert_not_null(find_text("Chantiers libres ce tour : 1/1 · +1 au QG 5", sheet))
	assert_eq(shown(sheet, ShieldBadge).size(), 0, "no citadel, no rampart")
	set_levels({Type.CORAL_CITADEL: 3})
	sheet.refresh()
	assert_not_null(find_text("Rempart de la base : 120 PV, DEF 7", sheet))


func test_the_other_buildings_do_not_tell_them() -> void:
	set_levels({Type.HEADQUARTERS: 2})
	var sheet := open_sheet(Type.ALGAE_FARM)
	assert_null(find_text("Chantiers libres ce tour : 1/1 · +1 au QG 5", sheet))
	assert_eq(shown(sheet, WorksiteBadge).size(), 0)


func test_the_citadel_tells_the_rampart_it_raises() -> void:
	set_levels({Type.HEADQUARTERS: 5, Type.CORAL_CITADEL: 2})
	var sheet := open_sheet(Type.CORAL_CITADEL)
	assert_not_null(find_text("Rempart actuel : 80 PV, DEF 6", sheet))
	assert_not_null(find_text("Prochain niveau : 120 PV, DEF 7", sheet))
	assert_not_null(find_text(Texts.t(&"baseRampartHint"), sheet))


func test_a_degraded_building_tells_why_and_what_it_suffers() -> void:
	set_levels({Type.HEADQUARTERS: 1, Type.BARRACKS: 3})
	var sheet := open_sheet(Type.BARRACKS)
	assert_not_null(find_text("Dégradé : le QG doit être au niveau 6", sheet))
	assert_not_null(find_text("Les unités coûtent deux fois plus cher", sheet))
	set_levels({Type.HEADQUARTERS: 6})
	sheet.refresh()
	assert_null(find_text("Dégradé : le QG doit être au niveau 6", sheet))


func test_a_building_that_works_has_no_degraded_notice() -> void:
	set_levels({Type.HEADQUARTERS: 6, Type.BARRACKS: 3})
	var sheet := open_sheet(Type.BARRACKS)
	assert_null(find_text("Dégradé", sheet))


func test_follows_the_language() -> void:
	set_levels({Type.HEADQUARTERS: 2, Type.ALGAE_FARM: 2})
	var sheet := open_sheet(Type.ALGAE_FARM)
	use_language("en")
	assert_not_null(find_text("Algae Farm", sheet))
	assert_not_null(find_text("Level 2", sheet))
	assert_not_null(find_text("Upgrade", sheet))
	assert_no_raw_keys()


func test_can_be_dismissed() -> void:
	open_sheet(Type.ALGAE_FARM)
	modals().close_top()
	assert_null(current_modal())
