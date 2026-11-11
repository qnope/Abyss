extends UiTestCase
## The interface icons: an SVG of assets/icons/ drawn square, crisp through
## its mipmaps, tinted or in its own colours; and the resource icons.


func test_draws_the_svg_as_a_square_texture() -> void:
	var icon := UiIcon.new(UiIcon.path_of(&"tech", &"military_1"), 40.0)
	assert_eq(icon.icon_path, "res://assets/icons/tech/military_1.svg")
	assert_true(icon.texture is Texture2D)
	assert_eq(icon.custom_minimum_size, Vector2(40.0, 40.0))
	assert_eq(icon.expand_mode, TextureRect.EXPAND_IGNORE_SIZE)
	assert_eq(icon.stretch_mode, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	icon.free()


func test_samples_its_mipmaps_to_stay_crisp_at_any_size() -> void:
	var icon := UiIcon.new(UiIcon.path_of(&"events", &"storm"))
	assert_eq(icon.texture_filter, CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS)
	assert_eq(icon.custom_minimum_size, Vector2(24.0, 24.0), "24 points by default")
	icon.free()


func test_takes_no_touch_and_does_not_stretch_in_a_row() -> void:
	var icon := UiIcon.new(UiIcon.path_of(&"guide", &"octopus_archivist"))
	assert_eq(icon.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq(icon.size_flags_horizontal, Control.SIZE_SHRINK_CENTER)
	assert_eq(icon.size_flags_vertical, Control.SIZE_SHRINK_CENTER)
	icon.free()


func test_keeps_its_colours_or_wears_a_tint() -> void:
	var plain := UiIcon.new(UiIcon.path_of(&"factions", &"angler_cult"))
	assert_eq(plain.self_modulate, Color.WHITE)
	var tinted := UiIcon.glyph(&"warning", 18.0, AbyssColors.WARNING)
	assert_eq(tinted.self_modulate, AbyssColors.WARNING)
	assert_eq(tinted.icon_path, "res://assets/icons/ui/warning.svg")
	assert_eq(tinted.custom_minimum_size, Vector2(18.0, 18.0))
	plain.free()
	tinted.free()


func test_a_missing_file_is_an_error_and_a_blank_icon() -> void:
	expect_error("UiIcon: no icon at res://assets/icons/ui/nowhere.svg")
	var icon := UiIcon.new(UiIcon.glyph_path(&"nowhere"))
	assert_null(icon.texture)
	icon.free()


func test_a_resource_icon_is_the_svg_named_as_the_resource() -> void:
	for type: ResourceType.Value in ResourceType.Value.values():
		var icon := ResourceIcon.new(type)
		var expected := "res://assets/icons/resources/%s.svg" % DartEnum.name_of(ResourceType.Value, type)
		assert_eq(icon.icon_path, expected)
		assert_eq(ResourceIcon.path_for(type), expected)
		assert_not_null(icon.texture, expected)
		assert_eq(icon.type, type)
		assert_eq(icon.custom_minimum_size, Vector2(24.0, 24.0))
		icon.free()


func test_a_resource_icon_can_be_any_size() -> void:
	var icon := ResourceIcon.new(ResourceType.Value.CORAL, 48.0)
	assert_eq(icon.custom_minimum_size, Vector2(48.0, 48.0))
	assert_eq(icon.icon_path, "res://assets/icons/resources/coral.svg")
	icon.free()
