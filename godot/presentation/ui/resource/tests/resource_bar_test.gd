extends UiTestCase
## The bar of the five resources at the top of the game screen
## (resource_bar_test.dart): the figures of a new game, the figures that
## change, the shortage and the detail a touch opens.

const Type := ResourceType.Value

var _resources: Dictionary[ResourceType.Value, GameResource]


func before_each() -> void:
	_resources = GameFactory.new_single_player("Nemo", 1).human_player().resources


func test_shows_the_amounts_of_a_new_game_in_order() -> void:
	var bar := _bar()
	assert_eq(bar.items.keys(), [Type.ALGAE, Type.CORAL, Type.ORE, Type.ENERGY, Type.PEARL])
	for type: ResourceType.Value in _resources:
		assert_eq(bar.items[type].amount_label.text, str(_resources[type].amount), str(type))
	assert_eq(find_type("TextureRect", bar).size(), 5)


func test_the_pearls_stand_apart_after_a_divider() -> void:
	var bar := _bar()
	var dividers := find_type("VSeparator", bar)
	assert_eq(dividers.size(), 1)
	var row := dividers[0].get_parent()
	assert_eq(dividers[0].get_index(), row.get_child_count() - 3)
	assert_eq(row.get_child(dividers[0].get_index() + 1), bar.items[Type.PEARL])


func test_shows_the_production_and_the_consumption_per_turn() -> void:
	var bar := _bar({Type.ALGAE: 30, Type.PEARL: 2}, {Type.ALGAE: 10})
	assert_eq(bar.items[Type.ALGAE].rate_label.text, "+30/-10/t")
	assert_eq(bar.items[Type.PEARL].rate_label.text, "+2/t")
	assert_eq(bar.items[Type.CORAL].rate_label.text, "")
	assert_false(bar.is_short(Type.ALGAE))


func test_flags_the_energy_that_runs_short() -> void:
	var bar := _bar({Type.ENERGY: 4}, {Type.ENERGY: 9})
	assert_true(bar.is_short(Type.ENERGY))
	assert_false(bar.is_short(Type.ALGAE))
	assert_eq(bar.items[Type.ENERGY].rate_label.get_theme_color(&"font_color"), AbyssColors.ERROR)


func test_follows_the_figures_of_the_next_turn() -> void:
	var bar := _bar()
	var spent := _resources.duplicate()
	spent[Type.CORAL] = GameResource.new(Type.CORAL, _resources[Type.CORAL].amount - 40)
	bar.show_figures(spent, {Type.CORAL: 8} as Dictionary[ResourceType.Value, int],
		{} as Dictionary[ResourceType.Value, int])
	assert_eq(bar.items[Type.CORAL].amount_label.text, str(spent[Type.CORAL].amount))
	assert_true(bar.items[Type.CORAL].amount_label.is_flashing())
	assert_false(bar.items[Type.ALGAE].amount_label.is_flashing())
	assert_eq(bar.items[Type.CORAL].rate_label.text, "+8/t")


func test_a_touch_opens_the_detail_of_the_resource_with_its_production() -> void:
	_bar({Type.ALGAE: 30})
	press(find_type("Button", host())[0] as Button)
	var sheet := current_modal() as ResourceDetailSheet
	assert_not_null(sheet)
	assert_eq(sheet.resource.type, Type.ALGAE)
	assert_eq(sheet.production, 30)


func test_the_detail_shows_the_figures_the_bar_shows_now() -> void:
	var bar := _bar({Type.PEARL: 2})
	bar.show_figures(_resources, {Type.PEARL: 5} as Dictionary[ResourceType.Value, int],
		{} as Dictionary[ResourceType.Value, int])
	press(bar.items[Type.PEARL])
	assert_eq((current_modal() as ResourceDetailSheet).production, 5)


func _bar(production := {}, consumption := {}) -> ResourceBar:
	var made: Dictionary[ResourceType.Value, int] = {}
	made.assign(production)
	var spent: Dictionary[ResourceType.Value, int] = {}
	spent.assign(consumption)
	return mount(ResourceBar.new(_resources, made, spent, modals())) as ResourceBar
