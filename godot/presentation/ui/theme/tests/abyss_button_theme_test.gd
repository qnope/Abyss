extends TestCase
## The buttons of abyss_button_theme.dart: the filled one as the plain
## Button, the outlined, text and over-map ones as its variations, each
## with Material 3's hover (8 %) and press (10 %) overlays of its ink.

const CYAN := AbyssColors.BIOLUM_CYAN
const BLACK := AbyssColors.ABYSS_BLACK

var _theme: Theme


func before_each() -> void:
	_theme = Theme.new()
	AbyssButtonTheme.apply(_theme)


func test_a_plain_button_is_filled_with_cyan() -> void:
	var normal := _box("normal", "Button")
	assert_eq(normal.bg_color, CYAN)
	assert_eq(normal.corner_radius_top_left, 12)
	assert_eq(normal.content_margin_left, 24.0)
	assert_eq(normal.content_margin_top, 14.0)
	assert_eq(normal.shadow_size, 0)
	assert_eq(_box("hover", "Button").bg_color, CYAN.blend(Color(BLACK, 0.08)))
	assert_eq(_box("pressed", "Button").bg_color, CYAN.blend(Color(BLACK, 0.1)))
	assert_eq(_box("disabled", "Button").bg_color, AbyssColors.DISABLED)
	_check_ink("Button", BLACK, AbyssColors.ON_SURFACE_DIM)


func test_a_filled_button_rises_on_hover_and_press() -> void:
	assert_eq(_box("hover", "Button").shadow_size, 2)
	assert_eq(_box("pressed", "Button").shadow_size, 6)
	assert_eq(_box("pressed", "Button").shadow_color, Color(CYAN, 0.4 * 0.25))
	assert_eq(_box("disabled", "Button").shadow_size, 0)


func test_writes_its_label_in_label_large() -> void:
	var font := _theme.get_font("font", "Button") as FontVariation
	assert_eq(font.base_font, AbyssFonts.SEMI_BOLD)
	assert_eq(font.spacing_glyph, 1)
	assert_eq(_theme.get_font_size("font_size", "Button"), 14)


func test_shows_its_focus_as_an_overlay() -> void:
	var focus := _box("focus", "Button")
	assert_eq(focus.bg_color, Color(BLACK, 0.1))
	assert_eq(focus.corner_radius_bottom_right, 12)


func test_an_outlined_button_is_rimmed_with_cyan() -> void:
	assert_eq(_theme.get_type_variation_base("OutlinedButton"), &"Button")
	var normal := _box("normal", "OutlinedButton")
	assert_false(normal.draw_center)
	assert_eq(normal.border_color, CYAN)
	assert_eq(normal.border_width_top, 2)
	assert_eq(normal.corner_radius_top_left, 12)
	assert_eq(normal.content_margin_left, 24.0)
	_assert_near(_box("hover", "OutlinedButton").bg_color, Color(CYAN, 0.08))
	_assert_near(_box("pressed", "OutlinedButton").bg_color, Color(CYAN, 0.1))
	assert_eq(_box("pressed", "OutlinedButton").border_color, CYAN)
	assert_eq(_box("disabled", "OutlinedButton").border_color, CYAN)
	_check_ink("OutlinedButton", CYAN, Color(AbyssColors.ON_SURFACE, 0.38))


func test_a_text_button_is_teal_ink_alone() -> void:
	assert_eq(_theme.get_type_variation_base("TextButton"), &"Button")
	var normal := _box("normal", "TextButton")
	assert_false(normal.draw_center)
	assert_eq(normal.border_width_top, 0)
	assert_eq(normal.corner_radius_top_left, 8)
	assert_eq(normal.content_margin_left, 16.0)
	assert_eq(normal.content_margin_top, 8.0)
	_assert_near(_box("hover", "TextButton").bg_color, Color(AbyssColors.BIOLUM_TEAL, 0.08))
	_check_ink("TextButton", AbyssColors.BIOLUM_TEAL, Color(AbyssColors.ON_SURFACE, 0.38))


func test_a_button_over_the_map_lies_on_deep_water() -> void:
	assert_eq(_theme.get_type_variation_base("OverMapButton"), &"Button")
	var normal := _box("normal", "OverMapButton")
	var water := Color(AbyssColors.DEEP_NAVY, 0.85)
	assert_eq(normal.bg_color, water)
	assert_eq(normal.border_color, CYAN)
	assert_eq(normal.content_margin_left, 18.0)
	assert_eq(normal.content_margin_top, 10.0)
	assert_eq(_box("hover", "OverMapButton").bg_color, water.blend(Color(CYAN, 0.08)))
	_check_ink("OverMapButton", CYAN, Color(AbyssColors.ON_SURFACE, 0.38))


func _box(state: StringName, type: StringName) -> StyleBoxFlat:
	return _theme.get_stylebox(state, type) as StyleBoxFlat


## An overlay on nothing is the overlay, but for float rounding.
func _assert_near(actual: Color, expected: Color) -> void:
	assert_true(actual.is_equal_approx(expected), "expected %s, got %s" % [expected, actual])


func _check_ink(type: StringName, ink: Color, disabled: Color) -> void:
	for state: String in ["font", "font_hover", "font_pressed", "font_hover_pressed", "font_focus"]:
		assert_eq(_theme.get_color(state + "_color", type), ink, "%s %s" % [type, state])
	assert_eq(_theme.get_color("icon_normal_color", type), ink, type)
	assert_eq(_theme.get_color("font_disabled_color", type), disabled, type)
	assert_eq(_theme.get_color("icon_disabled_color", type), disabled, type)
