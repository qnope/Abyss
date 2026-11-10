extends VectorTestCase
## The startingStocks section of resources.json: the stocks of a new
## player, `PlayerDefaults.resources()`, as [amount, maxStorage] by type.


func test_a_new_player_starts_with_the_stocks_of_dart() -> void:
	for case: Dictionary in VectorFile.new("resources").cases("startingStocks"):
		var stocks := {}
		for resource: GameResource in PlayerDefaults.resources().values():
			stocks[DartEnum.name_of(ResourceType.Value, resource.type)] = [
				resource.amount, resource.max_storage,
			]
		assert_same(stocks, case["out"], str(case))
		assert_same(PlayerDefaults.resources().keys(), ResourceType.Value.values())
