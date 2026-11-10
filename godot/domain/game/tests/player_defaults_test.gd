extends TestCase
## Not in the Dart tests, which read PlayerDefaults through a new Player and
## the startingStocks vectors: the order of each map, which is state, and a
## new object at each call.


func test_lists_the_stocks_in_the_order_of_dart() -> void:
	var stocks := PlayerDefaults.resources()
	assert_eq(stocks.keys(), ResourceType.Value.values())
	for type: ResourceType.Value in stocks:
		assert_eq(stocks[type].type, type)


func test_lists_every_building_at_level_0_in_the_order_of_dart() -> void:
	var buildings := PlayerDefaults.buildings()
	assert_eq(buildings.keys(), BuildingType.Value.values())
	for type: BuildingType.Value in buildings:
		assert_eq([buildings[type].type, buildings[type].level], [type, 0])


func test_lists_the_three_branches_locked_in_the_order_of_dart() -> void:
	var branches := PlayerDefaults.tech_branches()
	assert_eq(branches.keys(), TechBranch.Value.values())
	for branch: TechBranch.Value in branches:
		assert_eq(branches[branch].branch, branch)
		assert_false(branches[branch].unlocked)


func test_puts_no_unit_of_any_type_on_level_1() -> void:
	var levels := PlayerDefaults.units_per_level()
	assert_eq(levels.keys(), [1])
	var units: Dictionary[UnitType.Value, Unit] = levels[1]
	assert_eq(units.keys(), UnitType.Value.values())
	for type: UnitType.Value in units:
		assert_eq([units[type].type, units[type].count], [type, 0])


func test_builds_new_objects_at_each_call() -> void:
	PlayerDefaults.resources()[ResourceType.Value.ALGAE].amount = 7
	PlayerDefaults.buildings()[BuildingType.Value.HEADQUARTERS].level = 7
	assert_eq(PlayerDefaults.resources()[ResourceType.Value.ALGAE].amount, 100)
	assert_eq(PlayerDefaults.buildings()[BuildingType.Value.HEADQUARTERS].level, 0)
