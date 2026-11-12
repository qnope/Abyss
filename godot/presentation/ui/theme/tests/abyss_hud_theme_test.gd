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


func test_a_toggle_on_is_tinted_and_rimmed_not_filled() -> void:
	assert_eq(_theme.get_type_variation_base("HudToggle"), &"Button")
	for state: String in ["pressed", "hover_pressed"]:
		var on := _theme.get_stylebox(state, "HudToggle") as StyleBoxFlat
		assert_eq(on.bg_color, Color(AbyssColors.BIOLUM_CYAN, 0.14), state)
		assert_true(on.bg_color.a < 0.25, "a tint, not a fill")
		assert_eq(on.border_color, AbyssHudTheme.TOGGLE_EDGE, state)
		assert_eq(on.border_width_top, 1, state)
	for state: String in ["normal", "hover", "disabled"]:
		var off := _theme.get_stylebox(state, "HudToggle") as StyleBoxFlat
		assert_false(off.draw_center, state)
		assert_eq(off.border_color, AbyssHudTheme.TOGGLE_IDLE_EDGE, state)
	assert_true(_theme.get_stylebox("focus", "HudToggle") is StyleBoxEmpty)
	assert_eq(_theme.get_color("font_pressed_color", "HudToggle"), AbyssColors.BIOLUM_CYAN)
	assert_eq(_theme.get_color("font_color", "HudToggle"), AbyssColors.ON_SURFACE_DIM)
	assert_eq(_theme.get_font("font", "HudToggle"), AbyssFonts.BOLD)


func test_a_finger_gets_room() -> void:
	assert_true(AbyssHudTheme.TOUCH_SIZE >= 44.0)


func test_the_strips_of_the_game_screen_are_veils_of_the_abyss() -> void:
	var bar := _theme.get_stylebox("panel", "ResourceBarPanel") as StyleBoxFlat
	assert_eq(_theme.get_type_variation_base("ResourceBarPanel"), &"PanelContainer")
	assert_eq(bar.bg_color, Color(AbyssColors.ABYSS_BLACK, 0.9))
	assert_eq(bar.content_margin_left, 8.0)
	assert_eq(bar.content_margin_top, 6.0)
	var row := _theme.get_stylebox("panel", "ActionRowPanel") as StyleBoxFlat
	assert_eq(_theme.get_type_variation_base("ActionRowPanel"), &"PanelContainer")
	assert_eq(row.bg_color, AbyssColors.DEEP_NAVY)
	assert_eq(row.content_margin_left, 12.0)
	assert_eq(row.content_margin_top, 6.0)


func test_the_turn_counter_is_bold_cyan_and_the_amounts_bold() -> void:
	assert_eq(_theme.get_color("font_color", "HudTurn"), AbyssColors.BIOLUM_CYAN)
	assert_eq(_theme.get_font_size("font_size", "HudTurn"), 16)
	assert_eq(_theme.get_font_size("font_size", "ResourceAmount"), 14)
	assert_eq(_theme.get_font("font", "ResourceAmount"), AbyssFonts.BOLD)
	assert_eq(_theme.get_font_size("font_size", "ResourceRate"), 11)
	assert_eq(_theme.get_color("font_color", "ResourceRate"), AbyssColors.ON_SURFACE_DIM)


func test_the_figure_floating_up_is_small_and_bold() -> void:
	assert_eq(_theme.get_font_size("font_size", "DeltaFloat"), 12)
	assert_eq(_theme.get_font("font", "DeltaFloat"), AbyssFonts.BOLD)
