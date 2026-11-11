extends UiTestCase
## test/presentation/widgets/menu/menu_button_test.dart.

var _presses := 0


func test_calls_back_when_pressed() -> void:
	var entry := _entry("JOUER")
	press(entry)
	press("JOUER")
	assert_eq(_presses, 2)


func test_shows_its_subtitle_under_the_label() -> void:
	var entry := _entry("JOUER", MenuEntry.Look.PRIMARY, "Alice")
	assert_eq(texts(entry), PackedStringArray(["JOUER", "Alice"]))
	assert_eq(entry.subtitle_label.get_index(), entry.label.get_parent().get_index() + 1)
	assert_eq(entry.custom_minimum_size.y, MenuEntry.TWO_LINES_HEIGHT)
	assert_true(entry.custom_minimum_size.y > AbyssMenuTheme.BUTTON_MIN_HEIGHT)


func test_a_button_without_subtitle_stays_low_and_shows_one_line() -> void:
	var entry := _entry("JOUER")
	assert_eq(entry.custom_minimum_size.y, AbyssMenuTheme.BUTTON_MIN_HEIGHT)
	assert_false(entry.subtitle_label.visible)
	assert_eq(texts(entry), PackedStringArray(["JOUER"]))


func test_a_primary_button_glows_and_an_outlined_one_is_rimmed() -> void:
	var primary := _entry("A")
	assert_eq(primary.theme_type_variation, &"MenuPrimaryButton")
	assert_eq(primary.label.theme_type_variation, &"MenuPrimaryLabel")
	assert_eq(primary.subtitle_label.theme_type_variation, &"MenuPrimarySubtitle")
	var outlined := _entry("B", MenuEntry.Look.OUTLINED)
	assert_eq(outlined.theme_type_variation, &"MenuOutlinedButton")
	assert_eq(outlined.label.theme_type_variation, &"MenuButtonLabel")
	assert_eq(outlined.subtitle_label.theme_type_variation, &"MenuButtonSubtitle")


func test_shows_a_count_badge_only_when_the_count_is_positive() -> void:
	var counted := _entry("A", MenuEntry.Look.OUTLINED, "", 3)
	assert_eq(counted.badge.label.text, "3")
	assert_not_null(find_text("3", counted))
	assert_eq(counted.badge.label.get_theme_color(&"font_color"), AbyssMenuTheme.CYAN)
	var primary := _entry("A", MenuEntry.Look.PRIMARY, "", 2)
	assert_eq(primary.badge.label.get_theme_color(&"font_color"), AbyssMenuTheme.PRIMARY_INK)
	assert_null(_entry("A", MenuEntry.Look.PRIMARY, "", 0).badge)


func test_stretches_to_the_width_it_is_given_and_is_named_for_screen_readers() -> void:
	var entry := _entry("A")
	assert_eq(entry.size_flags_horizontal, Control.SIZE_EXPAND_FILL)
	assert_eq(entry.accessibility_name, "A")
	entry.set_label("B")
	assert_eq(entry.accessibility_name, "B")
	assert_eq(entry.label.text, "B")
	entry.set_subtitle("sub")
	assert_eq(entry.subtitle_label.text, "sub")


func test_the_touch_goes_to_the_button_not_to_its_labels() -> void:
	var entry := _entry("A", MenuEntry.Look.PRIMARY, "b", 1)
	for node in entry.find_children("*", "Control", true, false):
		assert_eq((node as Control).mouse_filter, Control.MOUSE_FILTER_IGNORE)


func _entry(label: String, look := MenuEntry.Look.PRIMARY, subtitle := "", badge := 0) -> MenuEntry:
	var entry := mount(MenuEntry.new(label, look, subtitle, badge)) as MenuEntry
	entry.pressed.connect(func() -> void: _presses += 1)
	return entry
