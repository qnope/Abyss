extends UiTestCase
## One resource of the bar: its icon, its amount and its rate per turn
## (resource_bar_item_test.dart).

const Type := ResourceType.Value


func test_shows_the_icon_and_the_amount() -> void:
	var item := _item(Type.ALGAE, 100)
	assert_eq(item.amount_label.text, "100")
	assert_eq((find_type("TextureRect", item)[0] as ResourceIcon).type, Type.ALGAE)
	assert_eq(item.amount_label.base_color, AbyssColors.ALGAE_GREEN)


func test_shows_the_production_under_the_amount() -> void:
	var item := _item(Type.CORAL, 80, 8)
	assert_eq(item.rate_label.text, "+8/t")
	assert_eq(item.rate_label.get_theme_color(&"font_color"), Color(AbyssColors.CORAL_PINK, 0.7))
	assert_false(item.is_short())


func test_shows_the_production_and_the_consumption() -> void:
	var item := _item(Type.ALGAE, 100, 50, 12)
	assert_eq(item.rate_label.text, "+50/-12/t")
	assert_false(item.is_short())


func test_alerts_when_the_consumption_exceeds_the_production() -> void:
	var item := _item(Type.ENERGY, 100, 10, 20)
	assert_eq(item.rate_label.text, "+10/-20/t")
	assert_true(item.is_short())
	assert_eq(item.rate_label.get_theme_color(&"font_color"), AbyssColors.ERROR)


func test_a_consumption_equal_to_the_production_is_not_a_shortage() -> void:
	assert_false(_item(Type.ENERGY, 100, 20, 20).is_short())


func test_a_consumption_with_no_production_is_a_shortage() -> void:
	var item := _item(Type.ENERGY, 100, 0, 4)
	assert_eq(item.rate_label.text, "+0/-4/t")
	assert_true(item.is_short())


func test_hides_the_rate_when_there_is_none_but_keeps_the_height() -> void:
	var item := _item(Type.PEARL, 5)
	assert_eq(item.rate_label.text, "")
	assert_false(item.is_short())
	assert_eq(item.rate_label.custom_minimum_size.y, ResourceBarItem.RATE_HEIGHT)


func test_follows_new_figures_and_pops_the_amount() -> void:
	var item := _item(Type.ALGAE, 100, 10)
	item.show_figures(GameResource.new(Type.ALGAE, 130), 30, 5)
	assert_eq(item.amount_label.text, "130")
	assert_true(item.amount_label.is_flashing())
	assert_eq(item.rate_label.text, "+30/-5/t")
	assert_eq(item.resource.amount, 130)
	assert_eq(item.production, 30)


func test_is_pressed_as_a_button() -> void:
	var item := _item(Type.ENERGY, 60, 6)
	var pressed: Array[ResourceType.Value] = []
	item.pressed.connect(func() -> void: pressed.append(item.resource.type))
	press("60")
	assert_eq(pressed, [Type.ENERGY] as Array[ResourceType.Value])


func _item(type: ResourceType.Value, amount: int, production := 0, consumption := 0) -> ResourceBarItem:
	return mount(ResourceBarItem.new(GameResource.new(type, amount), production, consumption)) as ResourceBarItem
