extends TestCase
## test/domain/building/building_test.dart: a building and its level.

const HQ := BuildingType.Value.HEADQUARTERS


func test_building_creates_with_required_type() -> void:
	var b := Building.new(HQ)
	assert_eq(b.type, HQ)


func test_building_default_level_is_0() -> void:
	var b := Building.new(HQ)
	assert_eq(b.level, 0)


func test_building_level_is_mutable() -> void:
	var b := Building.new(HQ)
	b.level = 3
	assert_eq(b.level, 3)


func test_building_accepts_custom_level() -> void:
	var b := Building.new(HQ, 5)
	assert_eq(b.level, 5)


## Not in the Dart file: `buildings[type]?.level ?? 0`.
func test_reads_the_level_of_a_building_in_a_map_0_when_it_is_missing() -> void:
	var buildings := DomainSamples.buildings({HQ: 4})
	assert_eq(Building.level_in(buildings, HQ), 4)
	assert_eq(Building.level_in(buildings, BuildingType.Value.BARRACKS), 0)
	assert_eq(Building.level_in({}, HQ), 0)
