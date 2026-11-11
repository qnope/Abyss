extends TestCase
## The thread between two nodes of a branch.


func test_a_lit_link_is_in_the_colour_of_the_branch() -> void:
	var link := TechLink.new(AbyssColors.BIOLUM_PINK, true, 20.0)
	add_cleanup(link.free)
	assert_true(link.lit)
	assert_eq(link.color, Color(AbyssColors.BIOLUM_PINK, TechLink.LIT_ALPHA))
	assert_eq(link.custom_minimum_size, Vector2(TechLink.WIDTH, 20.0))
	var box := link.get_theme_stylebox(&"panel") as StyleBoxFlat
	assert_eq(box.bg_color, link.color)


func test_an_unlit_link_is_dim() -> void:
	var link := TechLink.new(AbyssColors.BIOLUM_PINK, false)
	add_cleanup(link.free)
	assert_false(link.lit)
	assert_eq(link.color, AbyssColors.DISABLED)
	assert_eq(link.mouse_filter, Control.MOUSE_FILTER_IGNORE)
