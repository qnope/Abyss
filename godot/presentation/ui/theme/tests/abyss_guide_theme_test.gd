extends TestCase
## The guide's halo of guide_halo_painter.dart: a cyan rim and glow that
## pulse together.

const CYAN := AbyssColors.BIOLUM_CYAN


func test_the_rim_is_a_cyan_line_that_brightens_with_the_pulse() -> void:
	var dim := AbyssGuideTheme.halo(0.0, 12)
	var bright := AbyssGuideTheme.halo(1.0, 12)
	assert_eq(dim.border_color, Color(CYAN, 0.55))
	assert_eq(bright.border_color, Color(CYAN, 1.0))
	assert_eq(dim.border_width_left, 2)
	assert_false(dim.draw_center, "the content stays crisp")


func test_the_glow_swells_with_the_pulse() -> void:
	var dim := AbyssGuideTheme.halo(0.0, 12)
	var bright := AbyssGuideTheme.halo(1.0, 12)
	assert_eq(dim.shadow_color, Color(CYAN, 0.35))
	assert_eq(bright.shadow_color, Color(CYAN, 0.8))
	assert_eq(dim.shadow_size, 6)
	assert_eq(bright.shadow_size, 12)


func test_the_halo_is_rounded_and_drawn_inside_by_its_inset() -> void:
	var box := AbyssGuideTheme.halo(0.5, 20, 8)
	assert_eq(box.corner_radius_top_left, 20)
	assert_eq(box.expand_margin_left, -8.0)
	assert_eq(AbyssGuideTheme.halo(0.5, 20).expand_margin_left, 0.0)


func test_the_content_sits_in_from_the_rim_whether_or_not_the_halo_shows() -> void:
	assert_eq(AbyssGuideTheme.halo(0.5, 12).get_minimum_size(), Vector2(4, 4))
	assert_eq(AbyssGuideTheme.idle().get_minimum_size(), Vector2(4, 4))


func test_the_bubble_is_a_panel_variation_rimmed_and_glowing_in_cyan() -> void:
	var theme := AbyssTheme.build()
	assert_eq(theme.get_type_variation_base(AbyssGuideTheme.BUBBLE), &"PanelContainer")
	var box := theme.get_stylebox(&"panel", AbyssGuideTheme.BUBBLE) as StyleBoxFlat
	assert_eq(box.border_color, Color(CYAN, 0.4))
	assert_eq(box.shadow_color, Color(CYAN, 0.15))
	assert_eq(box.corner_radius_top_left, 16)
	assert_eq(box.bg_color, AbyssColors.SURFACE_LIGHT)
