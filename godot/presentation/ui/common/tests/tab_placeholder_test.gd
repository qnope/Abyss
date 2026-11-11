extends UiTestCase
## A tab still to come: its icon, its name and "coming soon" in the language
## on (common_widgets_l10n_test.dart: "a tab still to come in English").


func test_shows_the_icon_the_name_and_coming_soon() -> void:
	var tab := mount(TabPlaceholder.new(UiIcon.path_of(&"tech", &"explorer_1"), "Tech")) as TabPlaceholder
	assert_eq(texts(tab), PackedStringArray(["Tech", "Bientôt disponible"]))
	assert_eq(tab.name_label.theme_type_variation, &"HeadlineSmall")
	assert_eq(tab.name_label.get_theme_color(&"font_color"), AbyssColors.ON_SURFACE_DIM)
	assert_eq(tab.soon_label.get_theme_color(&"font_color"), AbyssColors.DISABLED)
	var icon := find_type("TextureRect", tab)[0] as UiIcon
	assert_eq(icon.custom_minimum_size, Vector2(64.0, 64.0))
	assert_eq(icon.self_modulate, Color(AbyssColors.BIOLUM_CYAN, 0.5))
	assert_no_raw_keys()


func test_says_coming_soon_in_the_language_on() -> void:
	var tab := mount(TabPlaceholder.new(UiIcon.glyph_path(&"info"), "Tech")) as TabPlaceholder
	use_language("en")
	assert_eq(tab.soon_label.text, text(&"screenComingSoon"))
	assert_eq(tab.soon_label.text, "Coming soon")
	use_language("es")
	assert_eq(tab.soon_label.text, "Próximamente")
	assert_eq(tab.name_label.text, "Tech", "the tab's name is the caller's")


func test_draws_nothing_of_its_own_and_centres_its_content() -> void:
	var tab := mount(TabPlaceholder.new(UiIcon.glyph_path(&"info"), "Tech")) as TabPlaceholder
	assert_eq(tab.theme_type_variation, &"BarePanel")
	assert_eq((tab.get_child(0) as Control).size_flags_horizontal, Control.SIZE_SHRINK_CENTER)
	assert_eq((tab.get_child(0) as Control).size_flags_vertical, Control.SIZE_SHRINK_CENTER)
