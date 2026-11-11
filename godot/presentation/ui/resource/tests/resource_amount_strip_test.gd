extends UiTestCase
## The line of resource amounts of a save card.


func test_shows_an_icon_and_an_amount_per_resource_in_order() -> void:
	var strip := mount(ResourceAmountStrip.new({
		ResourceType.Value.ALGAE: 412,
		ResourceType.Value.CORAL: 298,
		ResourceType.Value.PEARL: 9,
	})) as ResourceAmountStrip
	assert_eq(texts(strip), PackedStringArray(["412", "298", "9"]))
	var icons := find_type("TextureRect", strip)
	assert_eq(icons.size(), 3)
	assert_eq((icons[0] as ResourceIcon).type, ResourceType.Value.ALGAE)
	assert_eq((icons[2] as ResourceIcon).type, ResourceType.Value.PEARL)


func test_sizes_its_icons_and_dims_nothing_but_wraps() -> void:
	var strip := mount(ResourceAmountStrip.new({ResourceType.Value.ORE: 1}, 20.0)) as ResourceAmountStrip
	assert_eq((find_type("TextureRect", strip)[0] as Control).custom_minimum_size, Vector2(20.0, 20.0))
	assert_eq(strip.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq(strip.get_theme_constant(&"h_separation"), ResourceAmountStrip.SPACING)
	var amount := find_text("1", strip)
	assert_eq(amount.get_theme_color(&"font_color"), AbyssColors.ON_SURFACE)
