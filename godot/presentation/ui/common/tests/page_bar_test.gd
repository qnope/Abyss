extends UiTestCase
## The app bar of a page: a back arrow, a centred title.

var _backs := 0


func test_shows_a_centred_title_between_the_arrow_and_a_balance() -> void:
	var bar := _bar()
	assert_eq(bar.title(), "Page")
	var title := find_text("Page") as Label
	assert_eq(title.theme_type_variation, &"AppBarTitle")
	assert_eq(title.horizontal_alignment, HORIZONTAL_ALIGNMENT_CENTER)
	bar.set_title("Other")
	assert_eq(bar.title(), "Other")
	var row := title.get_parent()
	var balance := row.get_child(2) as Control
	assert_eq(balance.custom_minimum_size.x, bar.back_button.custom_minimum_size.x)


func test_the_arrow_is_a_touch_sized_cyan_glyph_that_tells_back() -> void:
	var bar := _bar()
	assert_true(bar.back_button.custom_minimum_size.y >= AbyssHudTheme.TOUCH_SIZE)
	var arrow := bar.back_button.get_child(0) as UiIcon
	assert_eq(arrow.icon_path, UiIcon.glyph_path(&"arrow_back"))
	assert_eq(arrow.self_modulate, AbyssColors.BIOLUM_CYAN)
	press(bar.back_button)
	assert_eq(_backs, 1)


func test_names_the_arrow_in_the_language_on() -> void:
	var bar := _bar()
	assert_eq(bar.back_button.tooltip_text, "Fermer")
	use_language("en")
	assert_eq(bar.back_button.tooltip_text, "Close")
	assert_eq(bar.back_button.accessibility_name, "Close")


func _bar() -> PageBar:
	var bar := mount(PageBar.new("Page")) as PageBar
	bar.back_pressed.connect(func() -> void: _backs += 1)
	return bar
