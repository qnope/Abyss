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


func test_builds_the_stocks_of_a_new_player() -> void:
	var stocks := VectorInputs.resources({"coral": 7})
	assert_eq(stocks.keys(), ResourceType.Value.values())
	assert_eq(stocks[ResourceType.Value.CORAL].amount, 7)
	assert_eq(stocks[ALGAE].amount, 0)
	assert_eq(stocks[ResourceType.Value.ENERGY].max_storage, 2000)
	assert_eq(stocks[ResourceType.Value.PEARL].max_storage, 100)
