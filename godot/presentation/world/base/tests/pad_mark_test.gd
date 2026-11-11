extends TestCase
## The signs and the level that float over the pads.

const Kind := PadMark.Kind

var _node: Node3D


func after_each() -> void:
	if _node != null:
		_node.free()


func test_every_sign_has_a_glyph_a_colour_and_faces_the_camera() -> void:
	var tints: Dictionary[Color, bool] = {}
	for kind: PadMark.Kind in Kind.values():
		var mark := PadMark.new(kind)
		assert_not_null(mark.texture, str(kind))
		assert_eq(mark.billboard, BaseMaterial3D.BILLBOARD_ENABLED)
		assert_true(mark.no_depth_test)
		assert_eq(mark.modulate, PadMark.tint_of(kind))
		assert_almost_eq(mark.texture.get_width() * mark.pixel_size, PadMark.WIDTH, 0.01)
		tints[mark.modulate] = true
		mark.free()
	assert_eq(tints.size(), 4, "four colours")


func test_each_sign_has_its_own_glyph() -> void:
	var paths: Dictionary[String, bool] = {}
	for kind: PadMark.Kind in Kind.values():
		paths[PadMark.ICONS[kind]] = true
		assert_true(ResourceLoader.exists(PadMark.ICONS[kind]), str(kind))
	assert_eq(paths.size(), 4)


func test_the_level_is_a_white_number_with_an_outline() -> void:
	var label := PadLevelLabel.new(7)
	_node = label
	assert_eq(label.text, "7")
	assert_eq(label.modulate, WorldPalette.LEVEL)
	assert_eq(label.outline_modulate, WorldPalette.LEVEL_OUTLINE)
	assert_eq(label.billboard, BaseMaterial3D.BILLBOARD_ENABLED)
	assert_true(label.no_depth_test)
	assert_true(label.render_priority > 1, "over the signs")
