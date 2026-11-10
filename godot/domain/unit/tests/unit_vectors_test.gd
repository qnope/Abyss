extends VectorTestCase
## reference/vectors/units.json: how many units a stock pays for and those
## lost when the algae run short, as the Dart rules answer.

var _vectors := VectorFile.new("units")


func test_max_recruitable() -> void:
	var cases := _vectors.cases("maxRecruitable")
	assert_eq(cases.size(), 144)
	for case: Dictionary in cases:
		var type := VectorInputs.value(UnitType.Value, case["type"]) as UnitType.Value
		var barracks: int = case["barracks"]
		var degraded: bool = case["degraded"]
		var stock: int = case["stock"]
		var resources := VectorInputs.resources(
			{"algae": stock, "coral": stock, "ore": stock, "energy": stock, "pearl": stock}
		)
		var count := UnitCostCalculator.new().max_recruitable_count(
			type, barracks, resources, degraded
		)
		assert_same(count, case["out"], str(case))


func test_hunger_losses() -> void:
	var cases := _vectors.cases("hungerLosses")
	assert_eq(cases.size(), 30)
	for case: Dictionary in cases:
		var units := VectorInputs.units(case["units"])
		var production: int = case["production"]
		assert_same(ConsumptionCalculator.total_unit_consumption(units), case["upkeep"], str(case))
		var losses := UnitLossCalculator.calculate_losses(units, production, 0)
		assert_same(VectorInputs.named(UnitType.Value, losses), case["out"], str(case))


func test_hunger_losses_all_levels() -> void:
	var cases := _vectors.cases("hungerLossesAllLevels")
	assert_eq(cases.size(), 24)
	for case: Dictionary in cases:
		var levels: Dictionary[int, Dictionary] = {
			1: VectorInputs.units(case["first"]), 2: VectorInputs.units(case["second"]),
		}
		var production: int = case["production"]
		var stock: int = case["stock"]
		var preview := UnitLossCalculator.calculate_losses_all_levels(levels, production, stock)
		var losses := UnitLossCalculator.apply_losses_all_levels(levels, production, stock)
		assert_eq(preview, losses, str(case))
		assert_eq(preview.keys(), losses.keys(), str(case))
		var left := []
		for level: int in levels:
			var counts := {}
			var units: Dictionary[UnitType.Value, Unit] = levels[level]
			for type: UnitType.Value in units:
				counts[DartEnum.name_of(UnitType.Value, type)] = units[type].count
			left.append(counts)
		var out := {"left": left, "losses": VectorInputs.named(UnitType.Value, losses)}
		assert_same(out, case["out"], str(case))
