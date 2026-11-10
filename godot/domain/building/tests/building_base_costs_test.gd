extends TestCase
## The first cost of the buildings that grow by 1.6 a level. Dart has no
## test of its own for building_base_costs.dart.

const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE
const ENERGY := ResourceType.Value.ENERGY


func test_lists_the_seven_buildings_that_grow_in_the_order_of_dart() -> void:
	assert_eq(BuildingBaseCosts.BUILDING_BASE_COSTS.keys(), [
		BuildingType.Value.HEADQUARTERS, BuildingType.Value.ALGAE_FARM,
		BuildingType.Value.CORAL_MINE, BuildingType.Value.ORE_EXTRACTOR,
		BuildingType.Value.SOLAR_PANEL, BuildingType.Value.LABORATORY,
		BuildingType.Value.BARRACKS,
	])


func test_gives_the_cost_of_a_building_as_a_typed_map_of_its_own() -> void:
	var cost := BuildingBaseCosts.of(BuildingType.Value.BARRACKS)
	assert_eq(cost, {CORAL: 60, ORE: 75, ENERGY: 30})
	assert_eq(cost.keys(), [CORAL, ORE, ENERGY])
	cost[CORAL] = 0
	assert_eq(BuildingBaseCosts.of(BuildingType.Value.BARRACKS)[CORAL], 60)


func test_a_building_with_a_cost_of_its_own_has_none_here() -> void:
	assert_eq(BuildingBaseCosts.of(BuildingType.Value.CORAL_CITADEL), {})
