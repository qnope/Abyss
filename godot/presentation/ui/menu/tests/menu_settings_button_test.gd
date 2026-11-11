extends UiTestCase
## test/presentation/screens/menu/main_menu_language_test.dart: the gear.


func test_is_a_touch_sized_gear_that_can_be_pressed() -> void:
	var gear := mount(MenuSettingsButton.new()) as MenuSettingsButton
	var presses := []
	gear.pressed.connect(func() -> void: presses.append(true))
	assert_true(gear.custom_minimum_size.x >= AbyssHudTheme.TOUCH_SIZE)
	var icon := gear.get_child(0) as UiIcon
	assert_eq(icon.icon_path, UiIcon.glyph_path(&"settings"))
	assert_eq(icon.self_modulate, AbyssMenuTheme.CORNER_ICON)
	press(gear)
	assert_eq(presses.size(), 1)


func test_is_named_in_the_language_on() -> void:
	var gear := mount(MenuSettingsButton.new()) as MenuSettingsButton
	assert_eq(gear.tooltip_text, "Paramètres")
	use_language("en")
	assert_eq(gear.tooltip_text, "Settings")
	assert_eq(gear.accessibility_name, "Settings")
