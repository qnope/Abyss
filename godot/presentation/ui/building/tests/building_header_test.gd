extends BuildingTestCase
## The top of a building's sheet: its picture, its name and its level.

const Type := BuildingType.Value


func _header(type: BuildingType.Value) -> BuildingHeader:
	var header := BuildingHeader.new(human.buildings[type])
	mount(header)
	return header


func test_a_built_building_wears_its_colour() -> void:
	set_levels({Type.SOLAR_PANEL: 2})
	var header := _header(Type.SOLAR_PANEL)
	assert_eq(header.name_label.text, "Panneau solaire")
	assert_eq(header.level_label.text, "Niveau 2")
	assert_eq(header.name_label.get_theme_color(&"font_color"), BuildingColors.of(Type.SOLAR_PANEL))
	assert_eq(header.portrait.display_name, "Panneau solaire")


func test_a_building_to_build_says_so() -> void:
	var header := _header(Type.LABORATORY)
	assert_eq(header.level_label.text, "Non construit")
	assert_no_raw_keys()


func test_a_built_building_with_a_model_shows_its_render() -> void:
	set_levels({Type.HEADQUARTERS: 1})
	assert_not_null(_header(Type.HEADQUARTERS).portrait.picture_rect)


func test_a_building_without_a_model_or_not_built_keeps_its_initials() -> void:
	set_levels({Type.ALGAE_FARM: 1})
	assert_null(_header(Type.ALGAE_FARM).portrait.picture_rect)
	assert_null(_header(Type.HEADQUARTERS).portrait.picture_rect, "to build: no picture")
