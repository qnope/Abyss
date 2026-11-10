extends VectorTestCase
## reference/vectors/resources.json: the storage of a stock, a credit, the
## energy the buildings burn and what they make, as the Dart rules answer.

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


func test_energy_consumption() -> void:
	var cases := _vectors.cases("energyConsumption")
	assert_eq(cases.size(), 77)
	for case: Dictionary in cases:
		var type := VectorInputs.value(BuildingType.Value, case["type"]) as BuildingType.Value
		var level: int = case["level"]
		assert_same(
			ConsumptionCalculator.building_energy_consumption(type, level), case["out"], str(case)
		)


func test_total_consumption() -> void:
	var cases := _vectors.cases("totalConsumption")
	assert_eq(cases.size(), 28)
	for case: Dictionary in cases:
		var excluded: Dictionary[BuildingType.Value, bool] = VectorInputs.values_set(
			BuildingType.Value, case["excluded"]
		)
		var total := ConsumptionCalculator.total_building_consumption(
			VectorInputs.buildings(case["buildings"]), excluded
		)
		assert_same(total, case["out"], str(case))


## `scaled` is the production under each difficulty, of a human then of a
## faction; Difficulty scales a map in place, so each gets its own.
func test_production() -> void:
	var cases := _vectors.cases("production")
	assert_eq(cases.size(), 14)
	for case: Dictionary in cases:
		assert_same(_production(case), case["out"], str(case))
		var scaled := {}
		for difficulty: Difficulty.Value in Difficulty.Value.values():
			var human := Difficulty.scale_production(difficulty, _made(case))
			var faction := Difficulty.scale_production(difficulty, _made(case), true)
			scaled[DartEnum.name_of(Difficulty.Value, difficulty)] = [
				VectorInputs.named(ResourceType.Value, human),
				VectorInputs.named(ResourceType.Value, faction),
			]
		assert_same(scaled, case["scaled"], str(case))


func _production(case: Dictionary) -> Dictionary:
	return VectorInputs.named(ResourceType.Value, _made(case))


## The production of the buildings of a case, without research when its
## `tech` is null.
func _made(case: Dictionary) -> Dictionary[ResourceType.Value, int]:
	var buildings := VectorInputs.buildings(case["buildings"])
	if case["tech"] == null:
		return ProductionCalculator.from_buildings(buildings)
	return ProductionCalculator.from_buildings(buildings, VectorInputs.tech(case["tech"]))
