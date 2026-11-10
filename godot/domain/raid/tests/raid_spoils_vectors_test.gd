extends VectorTestCase
## reference/vectors/raids.json, loot and pillage: what a raid brings back
## or carries away, as RaidSpoils answers in Dart.

var _vectors := VectorFile.new("raids")


func test_loot() -> void:
	var cases := _vectors.cases("loot")
	assert_eq(cases.size(), 27)
	for case: Dictionary in cases:
		var difficulty := (
			VectorInputs.value(MonsterDifficulty.Value, case["difficulty"]) as MonsterDifficulty.Value
		)
		var seed_: int = case["seed"]
		var percent: int = case["percent"]
		var loot := RaidSpoils.loot(difficulty, DartRandom.new(seed_), percent)
		assert_same(VectorInputs.named(ResourceType.Value, loot), case["out"], str(case))
		var production: Dictionary[ResourceType.Value, int] = VectorInputs.amounts(
			ResourceType.Value, case["production"]
		)
		var capped := RaidSpoils.cap_to_production(loot, production)
		assert_same(VectorInputs.named(ResourceType.Value, capped), case["capped"], str(case))


func test_pillage() -> void:
	var cases := _vectors.cases("pillage")
	assert_eq(cases.size(), 12)
	for case: Dictionary in cases:
		var stocks := VectorInputs.resources(case["stocks"])
		var rate: float = case["rate"]
		var taken := RaidSpoils.pillage(stocks, rate)
		var left := {}
		for type: ResourceType.Value in stocks:
			left[type] = stocks[type].amount
		var out := {
			"taken": VectorInputs.named(ResourceType.Value, taken),
			"left": VectorInputs.named(ResourceType.Value, left),
		}
		assert_same(out, case["out"], str(case))
