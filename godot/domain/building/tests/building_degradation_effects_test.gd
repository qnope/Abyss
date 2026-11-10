extends TestCase
## test/domain/building/building_degradation_effects_test.dart: what a
## degraded building still does. Only this test stands on what is ported:
## the others read ProductionCalculator and TechEffects (the tech module),
## a Player and TurnProduction (the game and turn modules).


func test_production_buildings_make_half_when_degraded_a_degraded_building_still_burns_its_energy() -> void:
	var b := DomainSamples.base(1, {BuildingType.Value.ORE_EXTRACTOR: 3})
	assert_true(BuildingDegradation.is_degraded(b, BuildingType.Value.ORE_EXTRACTOR))
	assert_eq(ConsumptionCalculator.total_building_consumption(b), 3 * 1 + 3 * 3)
