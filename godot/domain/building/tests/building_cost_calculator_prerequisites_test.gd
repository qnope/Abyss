extends TestCase
## test/domain/building/building_cost_calculator_prerequisites_test.dart:
## the headquarters each level of a building asks for.

const HQ := BuildingType.Value.HEADQUARTERS
const FARM := BuildingType.Value.ALGAE_FARM
const LABORATORY := BuildingType.Value.LABORATORY
const BARRACKS := BuildingType.Value.BARRACKS
const CITADEL := BuildingType.Value.CORAL_CITADEL


func _prereqs(type: BuildingType.Value, level: int) -> Dictionary[BuildingType.Value, int]:
	return BuildingCostCalculator.new().prerequisites(type, level)


func test_prerequisites_hq_has_no_prerequisites() -> void:
	assert_eq(_prereqs(HQ, 1), {})


func test_prerequisites_algae_farm_level_1_requires_hq_1() -> void:
	assert_eq(_prereqs(FARM, 1)[HQ], 1)


func test_prerequisites_algae_farm_level_3_requires_hq_4() -> void:
	assert_eq(_prereqs(FARM, 3)[HQ], 4)


func test_prerequisites_algae_farm_level_5_requires_hq_10() -> void:
	assert_eq(_prereqs(FARM, 5)[HQ], 10)


func test_prerequisites_coral_mine_level_2_requires_hq_2() -> void:
	assert_eq(_prereqs(BuildingType.Value.CORAL_MINE, 2)[HQ], 2)


func test_prerequisites_solar_panel_level_4_requires_hq_6() -> void:
	assert_eq(_prereqs(BuildingType.Value.SOLAR_PANEL, 4)[HQ], 6)


func test_prerequisites_laboratory_level_1_requires_hq_2() -> void:
	assert_eq(_prereqs(LABORATORY, 1)[HQ], 2)


func test_prerequisites_laboratory_level_5_requires_hq_10() -> void:
	assert_eq(_prereqs(LABORATORY, 5)[HQ], 10)


func test_prerequisites_barracks_level_1_requires_hq_2() -> void:
	assert_eq(_prereqs(BARRACKS, 1)[HQ], 2)


func test_prerequisites_barracks_level_2_still_requires_hq_4() -> void:
	assert_eq(_prereqs(BARRACKS, 2)[HQ], 4)


func test_prerequisites_barracks_level_5_requires_hq_10() -> void:
	assert_eq(_prereqs(BARRACKS, 5)[HQ], 10)


func test_prerequisites_coral_citadel_level_1_requires_hq_3() -> void:
	assert_eq(_prereqs(CITADEL, 1)[HQ], 3)


func test_prerequisites_coral_citadel_level_2_requires_hq_5() -> void:
	assert_eq(_prereqs(CITADEL, 2)[HQ], 5)


func test_prerequisites_coral_citadel_level_3_requires_hq_7() -> void:
	assert_eq(_prereqs(CITADEL, 3)[HQ], 7)


func test_prerequisites_coral_citadel_level_4_requires_hq_9() -> void:
	assert_eq(_prereqs(CITADEL, 4)[HQ], 9)


func test_prerequisites_coral_citadel_level_5_requires_hq_10() -> void:
	assert_eq(_prereqs(CITADEL, 5)[HQ], 10)


func test_prerequisites_coral_citadel_level_6_returns_empty_map() -> void:
	assert_eq(_prereqs(CITADEL, 6), {})
