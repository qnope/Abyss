extends UiTestCase
## test/presentation/widgets/guide/guide_halo_test.dart: a pulsing cyan glow
## around what the guide asks to touch, and the content left alone when it
## is not.

var _content := Label.new()


func before_each() -> void:
	_content.text = "Caserne"


func after_each() -> void:
	if is_instance_valid(_content) and _content.get_parent() == null:
		_content.free()


func test_inactive_shows_the_content_alone_without_animating() -> void:
	var halo := mount(GuideHalo.new(_content)) as GuideHalo
	assert_eq(find_text("Caserne"), _content)
	assert_true(halo.get_theme_stylebox(&"panel") is StyleBoxEmpty)
	assert_false(halo.is_pulsing())
	assert_false(halo.active)


func test_active_glows_around_the_content_in_cyan() -> void:
	var halo := mount(GuideHalo.new(_content, true)) as GuideHalo
	var box := halo.get_theme_stylebox(&"panel") as StyleBoxFlat
	assert_eq(box.border_color, Color(AbyssColors.BIOLUM_CYAN, 1.0))
	assert_true(box.shadow_size > 0)
	assert_false(box.draw_center, "the content stays crisp")
	assert_eq(find_text("Caserne"), _content)
	assert_eq(_content.get_parent(), halo)


func test_active_pulses_while_in_the_tree() -> void:
	var halo := mount(GuideHalo.new(_content, true)) as GuideHalo
	assert_true(halo.is_pulsing())
	halo._show(0.0)
	assert_eq(halo.pulse, 0.0)
	assert_eq((halo.get_theme_stylebox(&"panel") as StyleBoxFlat).shadow_size, 6)


func test_stops_pulsing_once_inactive() -> void:
	var halo := mount(GuideHalo.new(_content, true)) as GuideHalo
	halo.active = false
	assert_false(halo.is_pulsing())
	assert_true(halo.get_theme_stylebox(&"panel") is StyleBoxEmpty)


func test_glows_still_when_animations_are_reduced() -> void:
	var halo := GuideHalo.new(_content, true)
	halo.reduced_motion = true
	mount(halo)
	assert_false(halo.is_pulsing())
	assert_eq(halo.pulse, 1.0)
	assert_true(halo.get_theme_stylebox(&"panel") is StyleBoxFlat)


func test_starts_pulsing_when_it_enters_the_tree_and_stops_when_it_leaves() -> void:
	var halo := GuideHalo.new(_content, true)
	assert_false(halo.is_pulsing(), "not in the tree yet")
	mount(halo)
	assert_true(halo.is_pulsing())
	host().remove_child(halo)
	assert_false(halo.is_pulsing())
	halo.free()


func test_is_rounded_by_its_radius_or_a_circle_and_drawn_inside_by_its_inset() -> void:
	var halo := mount(GuideHalo.new(_content, true, 20)) as GuideHalo
	halo.inset = 8
	var box := halo.get_theme_stylebox(&"panel") as StyleBoxFlat
	assert_eq(box.corner_radius_top_left, 20)
	assert_eq(box.expand_margin_left, -8.0)
	halo.radius = GuideHalo.CIRCLE
	assert_eq((halo.get_theme_stylebox(&"panel") as StyleBoxFlat).corner_radius_top_left, GuideHalo.CIRCLE)


func test_the_content_does_not_move_when_the_halo_appears() -> void:
	var halo := mount(GuideHalo.new(_content)) as GuideHalo
	var idle := halo.get_theme_stylebox(&"panel").get_minimum_size()
	halo.active = true
	assert_eq(halo.get_theme_stylebox(&"panel").get_minimum_size(), idle)


func test_keeps_the_content_when_it_toggles() -> void:
	var halo := mount(GuideHalo.new(_content)) as GuideHalo
	halo.active = true
	halo.active = false
	assert_eq(_content.get_parent(), halo)
	assert_eq(halo.mouse_filter, Control.MOUSE_FILTER_IGNORE)
