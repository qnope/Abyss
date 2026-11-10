extends VectorTestCase
## test/domain/building/building_degradation_test.dart: a building works
## badly while the headquarters is below the level it asked for. Then the
## degradation section of buildings.json.

const HQ := BuildingType.Value.HEADQUARTERS
const BARRACKS := BuildingType.Value.BARRACKS
const LABORATORY := BuildingType.Value.LABORATORY
## Each type at a level, with the HQ level it needs.
const CASES: Dictionary[BuildingType.Value, Array] = {
	BuildingType.Value.ALGAE_FARM: [3, 4],
	BuildingType.Value.CORAL_MINE: [2, 2],
	BuildingType.Value.ORE_EXTRACTOR: [5, 10],
	BuildingType.Value.SOLAR_PANEL: [4, 6],
	BuildingType.Value.LABORATORY: [3, 5],
	BuildingType.Value.BARRACKS: [2, 4],
	BuildingType.Value.CORAL_CITADEL: [2, 5],
	BuildingType.Value.DESCENT_MODULE: [1, 5],
	BuildingType.Value.PRESSURE_CAPSULE: [1, 8],
	BuildingType.Value.VOLCANIC_KERNEL: [7, 10],
}


func test_is_degraded_each_type_at_a_level_needs_the_qg_at_its_level() -> void:
	for type: BuildingType.Value in CASES:
		var level: int = CASES[type][0]
		var needs: int = CASES[type][1]
		var name := DartEnum.name_of(BuildingType.Value, type)
		assert_eq(BuildingCostCalculator.new().prerequisites(type, level)[HQ], needs, name)
		var met := DomainSamples.base(needs, {type: level})
		var below := DomainSamples.base(needs - 1, {type: level})
		assert_false(BuildingDegradation.is_degraded(met, type), name)
		assert_true(BuildingDegradation.is_degraded(below, type), name)
		assert_eq(BuildingDegradation.missing_headquarters(below, type), needs, name)
		assert_null(BuildingDegradation.missing_headquarters(met, type), name)


func test_is_degraded_each_type_comes_back_to_normal_once_the_qg_is_raised_again() -> void:
	for type: BuildingType.Value in CASES:
		var level: int = CASES[type][0]
		var needs: int = CASES[type][1]
		var buildings := DomainSamples.base(needs - 1, {type: level})
		assert_true(BuildingDegradation.is_degraded(buildings, type))
		buildings[HQ].level = needs
		assert_false(BuildingDegradation.is_degraded(buildings, type))


func test_is_degraded_the_levels_are_kept_only_the_state_changes() -> void:
	var buildings := DomainSamples.base(1, {LABORATORY: 3})
	assert_true(BuildingDegradation.is_degraded(buildings, LABORATORY))
	assert_eq(buildings[LABORATORY].level, 3)


func test_is_degraded_an_unbuilt_building_or_the_qg_itself_is_never_degraded() -> void:
	var buildings := DomainSamples.base(1, {BARRACKS: 0})
	assert_false(BuildingDegradation.is_degraded(buildings, BARRACKS))
	assert_false(BuildingDegradation.is_degraded(buildings, HQ))
	assert_false(BuildingDegradation.is_degraded(buildings, BuildingType.Value.CORAL_MINE))


func test_is_degraded_a_bare_fixture_without_a_built_qg_is_not_degraded() -> void:
	var buildings := DomainSamples.base(0, {BARRACKS: 2})
	assert_false(BuildingDegradation.is_degraded(buildings, BARRACKS))
	assert_false(BuildingDegradation.is_degraded(DomainSamples.buildings({BARRACKS: 2}), BARRACKS))


## Not in the Dart file, which halves through the production and the
## research: `amount ~/ 2`, towards zero.
func test_half_halves_only_when_degraded() -> void:
	assert_eq(BuildingDegradation.half(7, false), 7)
	assert_eq(BuildingDegradation.half(7, true), 3)
	assert_eq(BuildingDegradation.half(-7, true), -3)


func test_degradation_vectors() -> void:
	var cases := VectorFile.new("buildings").cases("degradation")
	assert_eq(cases.size(), 5)
	for case: Dictionary in cases:
		var levels: Dictionary = case["buildings"]
		var buildings := VectorInputs.buildings(levels)
		var required := {}
		var missing := {}
		for name: String in levels:
			if name != "headquarters":
				var type := VectorInputs.value(BuildingType.Value, name) as BuildingType.Value
				required[name] = BuildingDegradation.required_headquarters(buildings, type)
				missing[name] = BuildingDegradation.missing_headquarters(buildings, type)
		var deactivated := BuildingDeactivator.deactivate(buildings, 10, 5)
		var out := {
			"deactivated": VectorInputs.names(BuildingType.Value, deactivated),
			"missing": missing,
			"required": required,
		}
		assert_same(out, case["out"], str(case))


func test_is_degraded_the_same_rule_on_a_player() -> void:
	var player := Player.new("P", null, 0, 0, null, DomainSamples.base(4, {BARRACKS: 2}))
	assert_false(player.is_degraded(BARRACKS))
	player.lower_headquarters(1)
	assert_true(player.is_degraded(BARRACKS))


func test_player_lower_headquarters_lowers_the_qg_by_the_given_levels() -> void:
	var p := _player(6)
	assert_eq(p.lower_headquarters(2), 4)
	assert_eq(p.buildings[HQ].level, 4)


func test_player_lower_headquarters_never_goes_below_level_1() -> void:
	var p := _player(2)
	assert_eq(p.lower_headquarters(5), 1)
	assert_eq(p.buildings[HQ].level, 1)
	assert_eq(p.lower_headquarters(1), 1)


func _player(hq: int) -> Player:
	return Player.new("P", null, 0, 0, null, DomainSamples.base(hq))
