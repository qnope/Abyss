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
