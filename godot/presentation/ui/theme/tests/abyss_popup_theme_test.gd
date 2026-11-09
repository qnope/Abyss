extends TestCase
## The popup menu of abyss_card_theme.dart and the tooltip of
## abyss_theme.dart.

const CYAN := AbyssColors.BIOLUM_CYAN

var _theme: Theme


func before_each() -> void:
	_theme = Theme.new()
	AbyssPopupTheme.apply(_theme)


func test_a_popup_menu_floats_on_a_rimmed_deep_navy_panel() -> void:
	var panel := _theme.get_stylebox("panel", "PopupMenu") as StyleBoxFlat
	assert_eq(panel.bg_color, AbyssColors.DEEP_NAVY)
	assert_eq(panel.corner_radius_top_left, 12)
	assert_eq(panel.border_color, Color(CYAN, 0.2))
	assert_eq(panel.border_width_bottom, 1)
	assert_eq(panel.shadow_color, Color(0, 0, 0, 0.25))
	assert_eq(panel.shadow_size, 6)
	assert_eq(panel.content_margin_top, 8.0)


func test_a_menu_item_is_a_touch_high_and_lights_up_under_the_pointer() -> void:
	var hover := _theme.get_stylebox("hover", "PopupMenu") as StyleBoxFlat
	assert_eq(hover.bg_color, Color(AbyssColors.ON_SURFACE, 0.08))
	assert_eq(_theme.get_constant("item_start_padding", "PopupMenu"), 12)
	assert_eq(_theme.get_constant("item_end_padding", "PopupMenu"), 12)
	var font := _theme.get_font("font", "PopupMenu")
	var line := ceili(font.get_height(14))
	assert_eq(_theme.get_constant("v_separation", "PopupMenu") + line, 48)


func test_a_menu_item_reads_in_label_large_on_surface() -> void:
	var font := _theme.get_font("font", "PopupMenu") as FontVariation
	assert_eq(font.base_font, AbyssFonts.SEMI_BOLD)
	assert_eq(_theme.get_font_size("font_size", "PopupMenu"), 14)
	assert_eq(_theme.get_color("font_color", "PopupMenu"), AbyssColors.ON_SURFACE)
	assert_eq(_theme.get_color("font_hover_color", "PopupMenu"), AbyssColors.ON_SURFACE)
	assert_eq(
		_theme.get_color("font_disabled_color", "PopupMenu"),
		Color(AbyssColors.ON_SURFACE, 0.38)
	)


func test_a_tooltip_is_a_small_bright_rimmed_panel() -> void:
	var panel := _theme.get_stylebox("panel", "TooltipPanel") as StyleBoxFlat
	assert_eq(panel.bg_color, AbyssColors.SURFACE_BRIGHT)
	assert_eq(panel.corner_radius_top_left, 8)
	assert_eq(panel.border_color, Color(CYAN, 0.3))
	assert_eq(panel.content_margin_left, 16.0)
	assert_eq(panel.content_margin_top, 4.0)
	assert_eq(_theme.get_color("font_color", "TooltipLabel"), AbyssColors.ON_SURFACE)
	assert_eq(_theme.get_font_size("font_size", "TooltipLabel"), 12)
