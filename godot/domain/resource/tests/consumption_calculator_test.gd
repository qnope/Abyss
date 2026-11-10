extends TestCase
## test/domain/resource/consumption_calculator_test.dart, the energy the
## buildings burn; the algae of the units is in
## consumption_calculator_units_test.gd.

const HQ := BuildingType.Value.HEADQUARTERS
const FARM := BuildingType.Value.ALGAE_FARM
const CITADEL := BuildingType.Value.CORAL_CITADEL


func _energy(type: BuildingType.Value, level: int) -> int:
	return ConsumptionCalculator.building_energy_consumption(type, level)


func test_building_energy_consumption_headquarters_level_3_consumes_9_energy() -> void:
	assert_eq(_energy(HQ, 3), 9)


func test_building_energy_consumption_algae_farm_level_5_consumes_10_energy() -> void:
	assert_eq(_energy(FARM, 5), 10)


func test_building_energy_consumption_coral_mine_level_2_consumes_4_energy() -> void:
	assert_eq(_energy(BuildingType.Value.CORAL_MINE, 2), 4)


func test_building_energy_consumption_ore_extractor_level_4_consumes_12_energy() -> void:
	assert_eq(_energy(BuildingType.Value.ORE_EXTRACTOR, 4), 12)


func test_building_energy_consumption_solar_panel_level_5_consumes_5_energy() -> void:
	assert_eq(_energy(BuildingType.Value.SOLAR_PANEL, 5), 5)


func test_building_energy_consumption_laboratory_level_1_consumes_4_energy() -> void:
	assert_eq(_energy(BuildingType.Value.LABORATORY, 1), 4)


func test_building_energy_consumption_barracks_level_3_consumes_9_energy() -> void:
	assert_eq(_energy(BuildingType.Value.BARRACKS, 3), 9)


func test_building_energy_consumption_coral_citadel_level_0_consumes_0_energy() -> void:
	assert_eq(_energy(CITADEL, 0), 0)


func test_building_energy_consumption_coral_citadel_level_1_consumes_1_energy() -> void:
	assert_eq(_energy(CITADEL, 1), 1)


func test_building_energy_consumption_coral_citadel_level_5_consumes_5_energy() -> void:
	assert_eq(_energy(CITADEL, 5), 5)


func test_building_energy_consumption_level_0_returns_0() -> void:
	assert_eq(_energy(HQ, 0), 0)


func test_total_building_consumption_sums_all_active_buildings() -> void:
	var buildings := DomainSamples.buildings({HQ: 2, FARM: 1})
	assert_eq(ConsumptionCalculator.total_building_consumption(buildings), 8)


func test_total_building_consumption_level_0_buildings_are_excluded() -> void:
	var buildings := DomainSamples.buildings({HQ: 0, FARM: 0})
	assert_eq(ConsumptionCalculator.total_building_consumption(buildings), 0)


func test_total_building_consumption_excluded_buildings_are_not_counted() -> void:
	var buildings := DomainSamples.buildings({HQ: 2, FARM: 1})
	assert_eq(ConsumptionCalculator.total_building_consumption(buildings, {FARM: true}), 6)


func test_total_building_consumption_empty_map_returns_0() -> void:
	assert_eq(ConsumptionCalculator.total_building_consumption({}), 0)


func test_total_building_consumption_includes_coral_citadel_contribution() -> void:
	# HQ lvl2=6, algae lvl1=2, coralCitadel lvl3=3 => 11.
	var buildings := DomainSamples.buildings({HQ: 2, FARM: 1, CITADEL: 3})
	assert_eq(ConsumptionCalculator.total_building_consumption(buildings), 11)


## Not in the Dart file: every building has its energy, the kernel none.
func test_every_building_has_its_energy() -> void:
	for type: BuildingType.Value in BuildingType.Value.values():
		var kernel := type == BuildingType.Value.VOLCANIC_KERNEL
		assert_eq(_energy(type, 2) > 0, not kernel, DartEnum.name_of(BuildingType.Value, type))
