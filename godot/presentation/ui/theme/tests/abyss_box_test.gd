extends TestCase
## The style boxes of the theme: a rounded fill, its border, its shadow.


func test_fills_a_rounded_box_with_its_padding() -> void:
	var box := AbyssBox.flat(Color.RED, 12, Vector2i(24, 14))
	assert_eq(box.bg_color, Color.RED)
	assert_true(box.draw_center)
	for corner in 4:
		assert_eq(box.get_corner_radius(corner as Corner), 12)
	assert_eq(box.content_margin_left, 24.0)
	assert_eq(box.content_margin_right, 24.0)
	assert_eq(box.content_margin_top, 14.0)
	assert_eq(box.content_margin_bottom, 14.0)
	assert_eq(box.get_border_width_min(), 0)
	assert_eq(box.shadow_size, 0)


func test_a_transparent_box_draws_no_fill() -> void:
	assert_false(AbyssBox.flat(Color.TRANSPARENT, 8).draw_center)


func test_rims_a_box() -> void:
	var box := AbyssBox.rimmed(AbyssBox.flat(Color.RED, 12), Color.BLUE, 1.5)
	assert_eq(box.border_color, Color.BLUE)
	for side in 4:
		assert_eq(box.get_border_width(side as Side), 2)


func test_rounds_only_the_top_of_a_sheet() -> void:
	var box := AbyssBox.top_rounded(AbyssBox.flat(Color.RED, 0), 24)
	assert_eq(box.corner_radius_top_left, 24)
	assert_eq(box.corner_radius_top_right, 24)
	assert_eq(box.corner_radius_bottom_left, 0)
	assert_eq(box.corner_radius_bottom_right, 0)


func test_glows_as_a_blurred_box_shadow() -> void:
	var box := AbyssBox.glowing(AbyssBox.flat(Color.RED, 12), Color(0, 1, 1, 0.5), 24)
	assert_eq(box.shadow_color, Color(0, 1, 1, 0.5))
	assert_eq(box.shadow_size, 24)
	assert_eq(box.shadow_offset, Vector2.ZERO)


func test_lifts_as_a_material_elevation() -> void:
	var box := AbyssBox.lifted(AbyssBox.flat(Color.RED, 12), Color(0, 0, 0, 1), 6)
	assert_eq(box.shadow_color, Color(0, 0, 0, 0.25))
	assert_eq(box.shadow_size, 6)


func test_tints_a_copy_with_an_overlay() -> void:
	var box := AbyssBox.flat(Color.WHITE, 12)
	var tinted := AbyssBox.tinted(box, Color(0, 0, 0, 0.5))
	assert_eq(tinted.bg_color, Color(0.5, 0.5, 0.5, 1))
	assert_eq(box.bg_color, Color.WHITE)
	assert_true(tinted.draw_center)


func test_draws_a_disc() -> void:
	var disc := AbyssBox.disc(Color.CYAN, 20)
	assert_eq(disc.get_width(), 20)
	assert_eq(disc.get_height(), 20)
	var image := disc.get_image()
	assert_eq(image.get_pixel(10, 10), Color.CYAN)
	assert_eq(image.get_pixel(0, 0).a, 0.0)
