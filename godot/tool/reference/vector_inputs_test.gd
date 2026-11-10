extends TestCase
## What a vector case writes, read as the objects the rules take, and back.

const ALGAE := ResourceType.Value.ALGAE
const ORE := ResourceType.Value.ORE


func test_reads_a_named_value() -> void:
	assert_eq(VectorInputs.value(ResourceType.Value, "ore"), ORE)
	expect_error('VectorInputs: no "gold" among')
	assert_eq(VectorInputs.value(ResourceType.Value, "gold"), -1)


func test_reads_named_amounts_as_a_typed_map_in_the_order_of_the_enum() -> void:
	var amounts: Dictionary[ResourceType.Value, int] = VectorInputs.amounts(
		ResourceType.Value, {"ore": 3, "algae": 1}
	)
	assert_eq(amounts, {ALGAE: 1, ORE: 3})
	assert_eq(amounts.keys(), [ALGAE, ORE])


func test_writes_a_map_and_a_list_by_dart_names() -> void:
	assert_eq(VectorInputs.named(ResourceType.Value, {ORE: 3, ALGAE: 1}), {"ore": 3, "algae": 1})
	assert_eq(VectorInputs.names(ResourceType.Value, [ORE, ALGAE]), ["ore", "algae"])
	assert_eq(VectorInputs.name_or_null(ResourceType.Value, ORE), "ore")
	assert_null(VectorInputs.name_or_null(ResourceType.Value, null))


func test_builds_the_stocks_of_a_new_player() -> void:
	var stocks := VectorInputs.resources({"coral": 7})
	assert_eq(stocks.keys(), ResourceType.Value.values())
	assert_eq(stocks[ResourceType.Value.CORAL].amount, 7)
	assert_eq(stocks[ALGAE].amount, 0)
	assert_eq(stocks[ResourceType.Value.ENERGY].max_storage, 2000)
	assert_eq(stocks[ResourceType.Value.PEARL].max_storage, 100)


func test_builds_the_buildings_and_the_units_of_a_player() -> void:
	var built := VectorInputs.buildings({"laboratory": 3})
	assert_eq(built.keys(), BuildingType.Value.values())
	assert_eq(built[BuildingType.Value.LABORATORY].level, 3)
	assert_eq(built[BuildingType.Value.HEADQUARTERS].level, 0)
	var army := VectorInputs.units({"guardian": 4})
	assert_eq(army.keys(), UnitType.Value.values())
	assert_eq(army[UnitType.Value.GUARDIAN].count, 4)
	assert_eq(army[UnitType.Value.SCOUT].count, 0)


func test_reads_a_list_of_names_as_a_set() -> void:
	var excluded: Dictionary[BuildingType.Value, bool] = VectorInputs.values_set(
		BuildingType.Value, ["laboratory", "barracks"]
	)
	assert_eq(excluded, {BuildingType.Value.LABORATORY: true, BuildingType.Value.BARRACKS: true})
	assert_eq(VectorInputs.values_set(BuildingType.Value, null), {})
