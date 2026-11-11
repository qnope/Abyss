extends UiTestCase
## The small marks: the status pill and the count badge.

const TEAL := AbyssColors.BIOLUM_TEAL


func test_a_pill_says_its_text_in_its_colour_on_a_faint_tint() -> void:
	var pill := mount(StatusPill.new("VICTOIRE", TEAL)) as StatusPill
	assert_eq(pill.label.text, "VICTOIRE")
	assert_eq(pill.label.theme_type_variation, &"PillLabel")
	assert_eq(pill.label.get_theme_color(&"font_color"), TEAL)
	var box := pill.get_theme_stylebox(&"panel") as StyleBoxFlat
	assert_eq(box.bg_color, Color(TEAL, 0.16))
	assert_eq(box.corner_radius_top_left, 6)
	assert_eq(box.content_margin_left, 7.0)
	assert_eq(box.content_margin_top, 2.0)
	assert_eq(find_text("VICTOIRE"), pill.label)


func test_a_faded_pill_fades_with_the_item_it_labels() -> void:
	var pill := mount(StatusPill.new("PERDU", AbyssColors.ERROR, true)) as StatusPill
	var faded := Color(AbyssColors.ERROR, 0.5)
	assert_eq(pill.label.get_theme_color(&"font_color"), faded)
	assert_eq((pill.get_theme_stylebox(&"panel") as StyleBoxFlat).bg_color, Color(faded, 0.5 * 0.16))


func test_a_pill_hugs_its_text_and_takes_no_touch() -> void:
	var pill := StatusPill.new("OK", TEAL)
	assert_eq(pill.size_flags_horizontal, Control.SIZE_SHRINK_BEGIN)
	assert_eq(pill.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq(pill.label.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	pill.free()


func test_a_badge_is_a_ring_holding_the_count() -> void:
	var badge := mount(CountBadge.new(12, AbyssColors.BIOLUM_CYAN)) as CountBadge
	assert_eq(badge.label.text, "12")
	assert_eq(badge.label.theme_type_variation, &"BadgeLabel")
	assert_eq(badge.label.get_theme_color(&"font_color"), AbyssColors.BIOLUM_CYAN)
	var ring := badge.get_theme_stylebox(&"panel") as StyleBoxFlat
	assert_false(ring.draw_center)
	assert_eq(ring.border_color, AbyssColors.BIOLUM_CYAN)
	assert_eq(ring.border_width_left, 2)
	assert_eq(ring.corner_radius_top_left, 12)
	assert_eq(badge.custom_minimum_size, Vector2(24.0, 24.0))
	assert_eq(find_text("12"), badge.label)


func test_a_badge_follows_its_count() -> void:
	var badge := mount(CountBadge.new(0, TEAL)) as CountBadge
	assert_eq(badge.label.text, "0")
	badge.set_count(100)
	assert_eq(badge.label.text, "100")
	assert_eq(badge.mouse_filter, Control.MOUSE_FILTER_IGNORE)
