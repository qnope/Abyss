extends TestCase
## The segmented bar of abyss_segmented_theme.dart: a tray (a
## PanelContainer variation) of toggle buttons (the Segment variation),
## the pressed one lit in cyan.

var _theme: Theme


func before_each() -> void:
	_theme = Theme.new()
	AbyssSegmentedTheme.apply(_theme)


func test_the_tray_is_a_dark_rimmed_panel_inset_by_four() -> void:
	assert_eq(_theme.get_type_variation_base("SegmentedTray"), &"PanelContainer")
	var tray := _box("panel", "SegmentedTray")
	assert_eq(tray.bg_color, AbyssSegmentedTheme.TRAY)
	assert_eq(tray.border_color, AbyssSegmentedTheme.TRAY_EDGE)
	assert_eq(tray.border_width_top, 1)
	assert_eq(tray.corner_radius_top_left, 12)
	assert_eq(tray.content_margin_left, AbyssSegmentedTheme.INSET)


func test_the_selected_segment_is_lit_in_cyan() -> void:
	assert_eq(_theme.get_type_variation_base("Segment"), &"Button")
	for state: String in ["pressed", "hover_pressed"]:
		var lit := _box(state, "Segment")
		assert_eq(lit.bg_color, AbyssColors.BIOLUM_CYAN, state)
		assert_eq(lit.corner_radius_top_left, 9, state)
		assert_eq(lit.content_margin_left, 4.0, state)
	for state: String in ["normal", "hover", "disabled"]:
		assert_false(_box(state, "Segment").draw_center, state)
	assert_true(_theme.get_stylebox("focus", "Segment") is StyleBoxEmpty)


func test_writes_the_segment_name_in_rajdhani_bold() -> void:
	assert_eq(_theme.get_font("font", "Segment"), AbyssFonts.BOLD)
	assert_eq(_theme.get_font_size("font_size", "Segment"), 13)
	assert_eq(_theme.get_color("font_color", "Segment"), Color("9fb8d6"))
	assert_eq(_theme.get_color("font_hover_color", "Segment"), Color("9fb8d6"))
	for state: String in ["font_pressed_color", "font_hover_pressed_color"]:
		assert_eq(_theme.get_color(state, "Segment"), AbyssSegmentedTheme.ON_SELECTED)


func test_writes_the_segment_detail_in_small_semi_bold() -> void:
	assert_eq(_theme.get_type_variation_base("SegmentDetail"), &"Label")
	assert_eq(_theme.get_font("font", "SegmentDetail"), AbyssFonts.SEMI_BOLD)
	assert_eq(_theme.get_font_size("font_size", "SegmentDetail"), 11)
	assert_eq(_theme.get_color("font_color", "SegmentDetail"), Color("5e7da3"))


func test_writes_the_segment_name_in_bold() -> void:
	assert_eq(_theme.get_type_variation_base("SegmentName"), &"Label")
	assert_eq(_theme.get_font("font", "SegmentName"), AbyssFonts.BOLD)
	assert_eq(_theme.get_font_size("font_size", "SegmentName"), 13)
	assert_eq(_theme.get_color("font_color", "SegmentName"), AbyssSegmentedTheme.LABEL_COLOR)


func _box(state: StringName, type: StringName) -> StyleBoxFlat:
	return _theme.get_stylebox(state, type) as StyleBoxFlat
