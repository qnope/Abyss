extends BuildingTestCase
## What the sheet reads of the game (BuildingView).

const Type := BuildingType.Value


func test_reads_the_building_and_the_stock_of_the_human_player() -> void:
	var view := view_of(Type.HEADQUARTERS)
	assert_eq(view.type, Type.HEADQUARTERS)
	assert_true(view.building == human.buildings[Type.HEADQUARTERS])
	assert_true(view.resources == human.resources)
	assert_true(view.worksite == human.worksite)


func test_tells_whether_the_building_stands() -> void:
	assert_false(view_of(Type.HEADQUARTERS).is_built())
	set_levels({Type.HEADQUARTERS: 1})
	assert_true(view_of(Type.HEADQUARTERS).is_built())


func test_tells_the_level_of_any_building_of_the_base() -> void:
	set_levels({Type.HEADQUARTERS: 4})
	assert_eq(view_of(Type.ALGAE_FARM).level_of(Type.HEADQUARTERS), 4)


func test_is_not_degraded_unless_the_headquarters_is_too_low() -> void:
	set_levels({Type.HEADQUARTERS: 1, Type.BARRACKS: 3})
	assert_eq(view_of(Type.BARRACKS).missing_headquarters, 6)
	assert_null(view_of(Type.HEADQUARTERS).missing_headquarters)


func test_applies_the_discount_of_the_research() -> void:
	var view := view_of(Type.HEADQUARTERS)
	assert_eq(view.calculator.upgrade_cost(Type.HEADQUARTERS, 1),
		BuildingCostCalculator.new().upgrade_cost(Type.HEADQUARTERS, 1))
