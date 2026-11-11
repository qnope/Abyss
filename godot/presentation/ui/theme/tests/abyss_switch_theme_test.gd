extends TestCase
## The switch of abyss_input_theme.dart, drawn as the CheckButton's icons:
## a rimmed track with a thumb that grows and goes right when on.

const CYAN := AbyssColors.BIOLUM_CYAN

var _theme: Theme


func before_each() -> void:
	_theme = Theme.new()
	AbyssSwitchTheme.apply(_theme)


func test_a_switch_is_a_check_button_that_draws_nothing_else() -> void:
	assert_eq(_theme.get_type_variation_base("Switch"), &"CheckButton")
	for state: String in ["normal", "pressed", "hover", "hover_pressed", "disabled", "focus"]:
		assert_true(_theme.get_stylebox(state, "Switch") is StyleBoxEmpty, state)


func test_its_four_icons_are_the_material_switch_size() -> void:
	for icon: String in ["checked", "unchecked", "checked_disabled", "unchecked_disabled"]:
		var texture := _theme.get_icon(icon, "Switch")
		assert_eq(texture.get_size(), Vector2(52, 32), icon)


func test_off_is_a_dim_thumb_on_the_left_of_a_dim_track() -> void:
	var image := _theme.get_icon("unchecked", "Switch").get_image()
	assert_eq(image.get_pixel(16, 16), AbyssColors.ON_SURFACE_DIM, "the thumb")
	assert_eq(image.get_pixel(40, 16), AbyssColors.SURFACE_DIM, "the track")
	assert_eq(image.get_pixel(26, 1), AbyssColors.TRENCH, "the track's outline")
	assert_eq(image.get_pixel(0, 0).a, 0.0, "outside the track")


func test_on_is_a_cyan_thumb_on_the_right_of_a_tinted_track() -> void:
	var image := _theme.get_icon("checked", "Switch").get_image()
	assert_eq(image.get_pixel(36, 16), CYAN, "the thumb")
	var track := image.get_pixel(12, 16)
	assert_eq(Color(track, 1.0), CYAN, "the track is cyan")
	assert_almost_eq(track.a, 0.3, 0.01, "at 30 %")
	assert_eq(image.get_pixel(26, 1), CYAN, "the track's outline")


func test_a_disabled_switch_fades() -> void:
	var on := _theme.get_icon("checked", "Switch").get_image().get_pixel(36, 16)
	var off := _theme.get_icon("checked_disabled", "Switch").get_image().get_pixel(36, 16)
	assert_almost_eq(off.a, on.a * AbyssSwitchTheme.DISABLED_OPACITY, 0.01)
	assert_eq(off.r, on.r)


func test_the_thumb_is_larger_on() -> void:
	assert_eq(AbyssSwitchTheme.THUMB_OFF, 16)
	assert_eq(AbyssSwitchTheme.THUMB_ON, 24)
