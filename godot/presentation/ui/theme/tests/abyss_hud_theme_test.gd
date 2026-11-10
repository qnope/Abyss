extends TestCase
## The panels over the 3D world: translucent, rimmed in cyan, with compact
## figures.

var _theme: Theme


func before_each() -> void:
	_theme = Theme.new()
	AbyssHudTheme.apply(_theme)


func test_the_panel_lets_the_world_show_through() -> void:
	assert_eq(_theme.get_type_variation_base("HudPanel"), &"PanelContainer")
	var panel := _theme.get_stylebox("panel", "HudPanel") as StyleBoxFlat
	assert_eq(panel.bg_color, Color(AbyssColors.ABYSS_BLACK, 0.72))
	assert_true(panel.bg_color.a < 1.0)
	assert_eq(panel.border_color, AbyssHudTheme.PANEL_EDGE)
	assert_eq(panel.corner_radius_top_left, 12)
	assert_eq(panel.content_margin_left, 12.0)
	assert_eq(panel.content_margin_top, 8.0)


func test_its_figures_are_compact_and_its_headline_cyan() -> void:
	assert_eq(_theme.get_type_variation_base("HudFigure"), &"Label")
	assert_eq(_theme.get_font_size("font_size", "HudFigure"), 12)
	assert_eq(_theme.get_color("font_color", "HudHeadline"), AbyssColors.BIOLUM_CYAN)
	assert_eq(_theme.get_color("font_color", "HudCaption"), AbyssColors.ON_SURFACE_DIM)


func test_a_finger_gets_room() -> void:
	assert_true(AbyssHudTheme.TOUCH_SIZE >= 44.0)
