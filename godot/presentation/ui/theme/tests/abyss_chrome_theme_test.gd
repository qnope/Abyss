extends TestCase
## The snack bar and the navigation bar of abyss_theme.dart.

const CYAN := AbyssColors.BIOLUM_CYAN
const DIM := AbyssColors.ON_SURFACE_DIM

var _theme: Theme


func before_each() -> void:
	_theme = Theme.new()
	AbyssChromeTheme.apply(_theme)


func test_a_snack_bar_floats_on_a_bright_rounded_panel() -> void:
	assert_eq(_theme.get_type_variation_base("SnackBarPanel"), &"PanelContainer")
	var bar := _theme.get_stylebox("panel", "SnackBarPanel") as StyleBoxFlat
	assert_eq(bar.bg_color, AbyssColors.SURFACE_BRIGHT)
	assert_eq(bar.corner_radius_top_left, 12)
	assert_true(bar.shadow_size > 0, "it floats")
	assert_eq(_theme.get_type_variation_base("SnackBarLabel"), &"Label")
	assert_eq(_theme.get_color("font_color", "SnackBarLabel"), AbyssColors.ON_SURFACE)


func test_the_navigation_bar_is_a_dark_veil() -> void:
	assert_eq(_theme.get_type_variation_base("NavigationBarPanel"), &"PanelContainer")
	var bar := _theme.get_stylebox("panel", "NavigationBarPanel") as StyleBoxFlat
	assert_eq(bar.bg_color, Color(AbyssColors.ABYSS_BLACK, 0.95))
	assert_eq(bar.corner_radius_top_left, 0)


func test_the_selected_destination_is_lit_in_cyan_on_a_tint() -> void:
	assert_eq(_theme.get_type_variation_base("NavigationItem"), &"Button")
	for state: String in ["pressed", "hover_pressed"]:
		var on := _theme.get_stylebox(state, "NavigationItem") as StyleBoxFlat
		assert_eq(on.bg_color, Color(CYAN, 0.15), state)
		assert_eq(on.corner_radius_top_left, 16, state)
		assert_eq(_theme.get_color("font_%s_color" % state, "NavigationItem"), CYAN, state)
		assert_eq(_theme.get_color("icon_%s_color" % state, "NavigationItem"), CYAN, state)
	var off := _theme.get_stylebox("normal", "NavigationItem") as StyleBoxFlat
	assert_false(off.draw_center)
	assert_eq(_theme.get_color("font_color", "NavigationItem"), DIM)
	assert_eq(_theme.get_color("icon_normal_color", "NavigationItem"), DIM)
	assert_eq(_theme.get_font_size("font_size", "NavigationItem"), 12)


func test_a_destination_stacks_its_icon_over_its_name() -> void:
	assert_eq(AbyssChromeTheme.BAR_HEIGHT, 80.0)
	assert_eq(_theme.get_constant("icon_max_width", "NavigationItem"), 24)
	assert_eq(_theme.get_constant("h_separation", "NavigationItem"), 4)
