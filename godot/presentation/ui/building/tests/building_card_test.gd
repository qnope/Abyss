extends BuildingTestCase
## A building in a list (building_card_test.dart): its name, its level or that
## it is to build, the degraded marker, and the touch.

const Type := BuildingType.Value

var _taps := 0


func after_each() -> void:
	_taps = 0


func _card(type: BuildingType.Value, missing := 0) -> BuildingCard:
	var card := BuildingCard.new(human.buildings[type], missing)
	card.tapped.connect(_tap)
	mount(card)
	return card


func _tap() -> void:
	_taps += 1


func test_a_built_building_wears_its_colour_and_tells_its_level() -> void:
	set_levels({Type.ALGAE_FARM: 3})
	var card := _card(Type.ALGAE_FARM)
	assert_eq(card.name_label.text, "Ferme d'algues")
	assert_eq(card.level_label.text, "Niveau 3")
	assert_eq(card.name_label.get_theme_color(&"font_color"), BuildingColors.of(Type.ALGAE_FARM))
	assert_null(card.degraded)
	assert_no_raw_keys()


func test_the_render_of_a_built_building_with_a_model_is_in_its_card() -> void:
	set_levels({Type.SOLAR_PANEL: 1, Type.BARRACKS: 1})
	var with_model := find_type("Portrait", _card(Type.SOLAR_PANEL))
	assert_not_null((with_model[0] as Portrait).picture_rect)
	var without := find_type("Portrait", _card(Type.BARRACKS))
	assert_null((without[0] as Portrait).picture_rect)


func test_a_building_to_build_is_dimmed_and_says_so() -> void:
	var card := _card(Type.LABORATORY)
	assert_eq(card.level_label.text, "Non construit")
	assert_eq(card.name_label.get_theme_color(&"font_color"), AbyssColors.dimmed(AbyssColors.ON_SURFACE))


func test_a_degraded_building_carries_the_marker() -> void:
	set_levels({Type.BARRACKS: 3})
	var card := _card(Type.BARRACKS, 6)
	assert_not_null(card.degraded)
	assert_not_null(find_text("Dégradé", card))


func test_a_touch_is_told() -> void:
	var card := _card(Type.ALGAE_FARM)
	press(card.tap_button)
	assert_eq(_taps, 1)
	assert_eq(card.tap_button.accessibility_name, "Ferme d'algues")


func test_follows_the_language() -> void:
	set_levels({Type.ALGAE_FARM: 3})
	var card := _card(Type.ALGAE_FARM)
	use_language("en")
	assert_eq(card.level_label.text, "Level 3")
	assert_eq(card.name_label.text, BuildingTexts.display_name(Type.ALGAE_FARM))
