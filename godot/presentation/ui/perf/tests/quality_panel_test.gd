extends TestCase
## The panel comparing the scene's costs: folded at first, its switches and
## render scales tell what the player chose, in the HUD's styles, sized for
## a finger.

var _panel: QualityPanel
var _changes: Array = []


func before_each() -> void:
	_panel = QualityPanel.new()
	_panel.changed.connect(func(setting: StringName, value: Variant) -> void:
		_changes.append([setting, value]))


func after_each() -> void:
	_panel.free()


func test_opens_and_folds_under_its_title() -> void:
	assert_eq(_panel.theme_type_variation, &"HudPanel")
	assert_false(_panel.is_expanded())
	_panel.expand()
	assert_true(_panel.is_expanded())
	_panel.collapse()
	assert_false(_panel.is_expanded())
	var title := _panel.get_child(0).get_child(0) as Button
	assert_eq(title.theme_type_variation, &"TextButton")
	title.pressed.emit()
	assert_true(_panel.is_expanded(), "a tap on its title opens it")
	title.pressed.emit()
	assert_false(_panel.is_expanded())


func test_tells_a_switch_turned() -> void:
	for setting: StringName in [QualityPanel.SHADOWS, QualityPanel.GLOW, QualityPanel.PARTICLES,
			QualityPanel.IDLE_CAP]:
		assert_true(_panel.button(setting).button_pressed, "on at first")
		_panel.button(setting).button_pressed = false
	assert_eq(_changes, [
		[&"shadows", false], [&"glow", false], [&"particles", false], [&"idle_cap", false],
	])


func test_tells_the_render_scale_chosen() -> void:
	assert_true(_panel.button(QualityPanel.SCALE, 1.0).button_pressed)
	_panel.button(QualityPanel.SCALE, 0.5).button_pressed = true
	assert_false(_panel.button(QualityPanel.SCALE, 1.0).button_pressed, "one scale at a time")
	assert_eq(_changes, [[&"scale", 0.5]])


func test_shows_the_starting_state_without_telling_it() -> void:
	_panel.show_value(QualityPanel.SHADOWS, false)
	_panel.show_value(QualityPanel.SCALE, 0.75)
	assert_false(_panel.button(QualityPanel.SHADOWS).button_pressed)
	assert_true(_panel.button(QualityPanel.SCALE, 0.75).button_pressed)
	assert_eq(_changes.size(), 0)


func test_its_buttons_are_light_toggles_sized_for_a_finger() -> void:
	var button := _panel.button(QualityPanel.GLOW)
	assert_eq(button.theme_type_variation, &"HudToggle")
	assert_true(button.custom_minimum_size.y >= AbyssHudTheme.TOUCH_SIZE)
	assert_eq((button.get_parent().get_parent() as Control).theme_type_variation, &"SegmentedTray")
