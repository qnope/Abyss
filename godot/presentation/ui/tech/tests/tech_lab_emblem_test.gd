extends UiTestCase
## The laboratory at the head of the tree.


func test_a_built_laboratory_is_teal_with_its_level() -> void:
	var emblem := mount(TechLabEmblem.new(3)) as TechLabEmblem
	assert_true(emblem.built)
	assert_eq(emblem.level_label.text, Texts.t(&"baseLevel", {"level": 3}))
	assert_eq(emblem.level_label.get_theme_color(&"font_color"), AbyssColors.BIOLUM_TEAL)
	assert_eq(emblem.portrait.display_name, "Laboratoire")


func test_a_laboratory_to_build_is_grey() -> void:
	var emblem := mount(TechLabEmblem.new(0)) as TechLabEmblem
	assert_false(emblem.built)
	assert_eq(emblem.level_label.text, "Non construit")
	assert_eq(emblem.level_label.get_theme_color(&"font_color"), AbyssColors.DISABLED)
	assert_not_null(emblem.portrait.picture_rect, "its render, never the initials")
	assert_eq((emblem.portrait.picture_rect.material as ShaderMaterial).shader, Greyscale.SHADER)
