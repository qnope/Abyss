extends VectorTestCase
## test/domain/raid/coral_citadel_rampart_test.dart, which tests a rule of
## the building module: the rampart the Coral Citadel raises when the base
## is raided. Then the rampart section of buildings.json.


func test_no_rampart_without_a_citadel() -> void:
	assert_null(CoralCitadelRampart.combatant_for(0))


func test_40_pv_and_one_def_point_per_level() -> void:
	var rampart := CoralCitadelRampart.combatant_for(3)
	assert_eq(rampart.max_hp, 120)
	assert_eq(rampart.def, 7)
	assert_eq(rampart.atk, 0)
	assert_eq(rampart.side, CombatSide.Value.PLAYER)


func test_the_rampart_taunts() -> void:
	var rampart := CoralCitadelRampart.combatant_for(1)
	assert_eq(CombatRole.of(rampart), CombatRole.Value.TAUNT)
	assert_eq(rampart.type_key, CoralCitadelRampart.TYPE_KEY)


func test_rampart_vectors() -> void:
	var cases := VectorFile.new("buildings").cases("rampart")
	assert_eq(cases.size(), 12)
	for case: Dictionary in cases:
		var level: int = case["level"]
		var degraded: bool = case["degraded"]
		var rampart := CoralCitadelRampart.combatant_for(level, degraded)
		var out := {
			"combatant": null if rampart == null else VectorInputs.combatant(rampart),
			"def": CoralCitadelRampart.def_for_level(level),
			"hp": CoralCitadelRampart.hp_for_level(level),
		}
		assert_same(out, case["out"], str(case))
