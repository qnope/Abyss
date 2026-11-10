extends VectorTestCase
## reference/vectors/raids.json, defenceStrength and upgradeNoise: the
## strength of a base and the noise of an upgrade, as the Dart rules answer.

var _vectors := VectorFile.new("raids")


func test_defence_strength() -> void:
	var cases := _vectors.cases("defenceStrength")
	assert_eq(cases.size(), 6)
	for case: Dictionary in cases:
		var per_level: Dictionary[int, Dictionary] = {1: VectorInputs.units(case["units"])}
		var player := Player.new("defender", "defender", 0, 0, null, null, null, per_level)
		assert_same(DefenceStrength.of(player), case["out"], str(case))


func test_upgrade_noise() -> void:
	var cases := _vectors.cases("upgradeNoise")
	assert_eq(cases.size(), 6)
	for case: Dictionary in cases:
		var type := VectorInputs.value(BuildingType.Value, case["type"]) as BuildingType.Value
		var level: int = case["level"]
		assert_same(NoiseRules.for_upgrade(type, level), case["out"], str(case))
