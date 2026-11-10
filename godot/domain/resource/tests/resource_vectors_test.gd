extends VectorTestCase
## reference/vectors/resources.json: what a player holds, the storage of a
## stock and a credit, as the Dart rules answer.

var _vectors := VectorFile.new("resources")


func test_storage() -> void:
	var cases := _vectors.cases("storage")
	assert_eq(cases.size(), 25)
	for case: Dictionary in cases:
		var type := VectorInputs.value(ResourceType.Value, case["type"]) as ResourceType.Value
		var stock := GameResource.new(type, 0)
		if case["asked"] != null:
			var asked: int = case["asked"]
			stock = GameResource.new(type, 0, asked)
		assert_same(stock.max_storage, case["out"], str(case))


func test_credit() -> void:
	var cases := _vectors.cases("credit")
	assert_eq(cases.size(), 6)
	for case: Dictionary in cases:
		var resources := VectorInputs.resources(case["stocks"])
		var amounts: Dictionary[ResourceType.Value, int] = {}
		var pairs: Array = case["amounts"]
		for pair: Array in pairs:
			amounts[VectorInputs.value(ResourceType.Value, pair[0]) as ResourceType.Value] = pair[1]
		var added := ResourceCredit.add(resources, amounts)
		var left := {}
		for type: ResourceType.Value in resources:
			left[type] = resources[type].amount
		var out := {
			"added": VectorInputs.named(ResourceType.Value, added),
			"stocks": VectorInputs.named(ResourceType.Value, left),
		}
		assert_same(out, case["out"], str(case))
