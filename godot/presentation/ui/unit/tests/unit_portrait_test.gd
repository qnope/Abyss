extends UiTestCase
## test/presentation/widgets/unit/unit_icon_test.dart: the picture of a unit,
## in colour or in grey.

const Type := UnitType.Value


func test_is_the_portrait_of_the_unit_in_its_colour() -> void:
	var portrait := mount(UnitPortrait.of(Type.GUARDIAN, 64.0)) as Portrait
	assert_eq(portrait.display_name, "Gardien")
	assert_eq(portrait.initials_label.get_theme_color(&"font_color"), UnitColors.of(Type.GUARDIAN))
	assert_eq(portrait.custom_minimum_size, Vector2(64.0, 64.0))
	assert_eq(portrait.modulate.a, 1.0)
	assert_not_null(portrait.picture_rect)
	assert_null(portrait.picture_rect.material, "in its colours")


func test_each_unit_has_a_colour_of_its_own() -> void:
	var seen: Array[Color] = []
	for type: UnitType.Value in Type.values():
		var portrait := UnitPortrait.of(type)
		var tint := portrait.initials_label.get_theme_color(&"font_color")
		portrait.free()
		assert_false(seen.has(tint), str(type))
		seen.append(tint)


func test_is_grey_while_locked() -> void:
	var portrait := UnitPortrait.of(Type.GUARDIAN, 64.0, true)
	assert_eq(portrait.initials_label.get_theme_color(&"font_color"), AbyssColors.DISABLED)
	assert_not_null(portrait.picture_rect, "its render, never the initials")
	assert_eq((portrait.picture_rect.material as ShaderMaterial).shader, Greyscale.SHADER)
	portrait.free()


func test_is_faded_too_in_a_list_of_unavailable_units() -> void:
	var portrait := UnitPortrait.of(Type.GUARDIAN, 40.0, true, true)
	assert_almost_eq(portrait.modulate.a, AbyssColors.UNAVAILABLE_OPACITY, 1e-5)
	portrait.free()
