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


func test_the_render_of_a_building_is_in_its_card_in_grey_until_it_is_built() -> void:
	set_levels({Type.SOLAR_PANEL: 1})
	var built := find_type("Portrait", _card(Type.SOLAR_PANEL))[0] as Portrait
	assert_not_null(built.picture_rect)
	assert_null(built.picture_rect.material, "in its colours")
	var to_build := find_type("Portrait", _card(Type.LABORATORY))[0] as Portrait
	assert_not_null(to_build.picture_rect, "never the initials")
	assert_eq((to_build.picture_rect.material as ShaderMaterial).shader, Greyscale.SHADER)


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


func test_a_level_that_rises_pops_the_picture() -> void:
	set_levels({Type.ALGAE_FARM: 3})
	var card := _card(Type.ALGAE_FARM)
	assert_false(card.pop.is_rising(), "nothing moves when first shown")
	assert_eq(card.pop.glow_color, AbyssColors.BIOLUM_CYAN)
	human.buildings[Type.ALGAE_FARM].level = 4
	card.refresh()
	assert_true(card.pop.is_rising())
	assert_eq(card.level_label.text, "Niveau 4")
