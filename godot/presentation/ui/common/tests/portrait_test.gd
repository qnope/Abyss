extends UiTestCase
## The picture of a building, a unit or a monster: a tinted panel with the
## render of its model, or the initials of the name when it has none yet.


func test_shows_the_initials_of_the_name_on_a_tinted_panel() -> void:
	var portrait := mount(Portrait.new("Éclaireur", 64.0, AbyssColors.ALGAE_GREEN)) as Portrait
	assert_eq(portrait.initials_label.text, "ÉC")
	assert_eq(portrait.custom_minimum_size, Vector2(64.0, 64.0))
	var box := portrait.get_theme_stylebox(&"panel") as StyleBoxFlat
	assert_eq(box.bg_color, Color(AbyssColors.ALGAE_GREEN, 0.18))
	assert_eq(box.border_color, Color(AbyssColors.ALGAE_GREEN, 0.5))
	assert_eq(box.corner_radius_top_left, 13)
	assert_eq(portrait.initials_label.get_theme_color(&"font_color"), AbyssColors.ALGAE_GREEN)
	assert_eq(portrait.display_name, "Éclaireur")


func test_reads_the_first_letters_of_the_first_two_capitalised_words() -> void:
	assert_eq(Portrait.initials("Quartier Général"), "QG")
	assert_eq(Portrait.initials("Ferme d'algues"), "FE", "an article is skipped")
	assert_eq(Portrait.initials("Tour"), "TO")
	assert_eq(Portrait.initials("Grande Fosse Noire"), "GF")
	assert_eq(Portrait.initials("de la mer"), "DE", "no capital at all: its first letters")
	assert_eq(Portrait.initials(""), "")


func test_sets_the_initials_larger_as_the_portrait_grows() -> void:
	var sizes := {24.0: &"PillLabel", 64.0: &"TitleLarge", 128.0: &"DisplaySmall"}
	for portrait_size: float in sizes:
		var portrait := Portrait.new("Kraken", portrait_size)
		assert_eq(portrait.initials_label.theme_type_variation, sizes[portrait_size])
		portrait.free()


func test_is_cyan_unless_told_and_takes_no_touch() -> void:
	var portrait := Portrait.new("Kraken")
	assert_eq(portrait.custom_minimum_size, Vector2(64.0, 64.0))
	assert_eq(portrait.initials_label.get_theme_color(&"font_color"), AbyssColors.BIOLUM_CYAN)
	assert_eq(portrait.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq(portrait.initials_label.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	portrait.free()



func test_shows_the_render_of_a_model_that_has_one() -> void:
	var portrait := mount(Portrait.new("Quartier Général", 64.0, AbyssColors.ALGAE_GREEN,
		PortraitFiles.building(BuildingType.Value.HEADQUARTERS))) as Portrait
	assert_not_null(portrait.picture_rect)
	assert_eq(portrait.picture_rect.texture, PortraitFiles.texture("headquarters"))
	assert_false(portrait.initials_label.visible)
	assert_eq(portrait.picture_rect.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq(portrait.picture_rect.stretch_mode, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	assert_eq(portrait.picture_rect.texture_filter, CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS)
	var box := portrait.get_theme_stylebox(&"panel") as StyleBoxFlat
	assert_eq(box.bg_color, Color(AbyssColors.ALGAE_GREEN, 0.18), "the tinted panel stays under it")


func test_falls_back_to_the_initials_without_a_render() -> void:
	for picture: String in ["", PortraitFiles.building(BuildingType.Value.BARRACKS), "nothing_at_all"]:
		var portrait := mount(Portrait.new("Ferme d'algues", 64.0, AbyssColors.ALGAE_GREEN, picture)) as Portrait
		assert_null(portrait.picture_rect, picture)
		assert_true(portrait.initials_label.visible, picture)
		assert_eq(portrait.initials_label.text, "FE", picture)
