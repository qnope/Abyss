extends UiTestCase
## The costs of a research (tech_cost_row.dart).

const Type := ResourceType.Value


func _stock(amounts: Dictionary[ResourceType.Value, int]) -> Dictionary[ResourceType.Value, GameResource]:
	var stock: Dictionary[ResourceType.Value, GameResource] = {}
	for type: ResourceType.Value in amounts:
		stock[type] = GameResource.new(type, amounts[type], 1000)
	return stock


func test_lists_each_cost_with_its_icon() -> void:
	var row := mount(TechCostRow.new({Type.ORE: 30, Type.ENERGY: 20}, _stock({Type.ORE: 100, Type.ENERGY: 100}))) as TechCostRow
	assert_eq(row.amounts.keys(), [Type.ORE, Type.ENERGY] as Array)
	assert_eq(row.amounts[Type.ORE].text, "30")
	assert_eq(row.amounts[Type.ENERGY].text, "20")
	assert_eq(row.find_children("*", "ResourceIcon", true, false).size(), 2)


func test_a_cost_the_stock_cannot_pay_is_red() -> void:
	var row := mount(TechCostRow.new({Type.ORE: 30, Type.ENERGY: 20}, _stock({Type.ORE: 29, Type.ENERGY: 20}))) as TechCostRow
	assert_eq(row.amounts[Type.ORE].get_theme_color(&"font_color"), AbyssColors.ERROR)
	assert_eq(row.amounts[Type.ENERGY].get_theme_color(&"font_color"), AbyssColors.ON_SURFACE)


func test_a_resource_the_player_lacks_counts_as_none() -> void:
	var row := mount(TechCostRow.new({Type.PEARL: 5}, _stock({}))) as TechCostRow
	assert_eq(row.amounts[Type.PEARL].get_theme_color(&"font_color"), AbyssColors.ERROR)
