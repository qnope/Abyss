extends UiTestCase
## A line of a status strip: a small glyph and a short text in one colour.


func test_a_glyph_and_a_text_in_one_colour() -> void:
	var line := mount(StripLine.new(&"hourglass_bottom", AbyssColors.WARNING)) as StripLine
	line.show_text("Tempête : encore 2 tours")
	assert_true(line.visible)
	assert_eq(line.label.text, "Tempête : encore 2 tours")
	assert_eq(line.label.get_theme_color(&"font_color"), AbyssColors.WARNING)
	assert_eq(line.label.theme_type_variation, &"BodySmall")
	assert_eq(line.icon.icon_path, UiIcon.glyph_path(&"hourglass_bottom"))
	assert_eq(line.icon.self_modulate, AbyssColors.WARNING)
	assert_eq(line.icon.custom_minimum_size, Vector2(StripLine.ICON_SIZE, StripLine.ICON_SIZE))


func test_no_text_hides_the_line() -> void:
	var line := mount(StripLine.new(&"auto_awesome", AbyssColors.BIOLUM_CYAN)) as StripLine
	line.show_text("Un événement")
	line.show_text(null)
	assert_false(line.visible)
	line.show_text("Un autre")
	assert_true(line.visible)
	assert_eq(line.label.text, "Un autre")


func test_lets_the_touches_through() -> void:
	var line := mount(StripLine.new(&"auto_awesome", AbyssColors.BIOLUM_CYAN)) as StripLine
	assert_eq(line.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq(line.label.mouse_filter, Control.MOUSE_FILTER_IGNORE)
