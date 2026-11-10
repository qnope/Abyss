extends TestCase
## test/domain/unit/unit_test.dart: the units of one type on a level.


func test_unit_default_count_is_0() -> void:
	var unit := Unit.new(UnitType.Value.SCOUT)
	assert_eq(unit.count, 0)


func test_unit_count_is_mutable() -> void:
	var unit := Unit.new(UnitType.Value.SCOUT)
	unit.count = 5
	assert_eq(unit.count, 5)


func test_unit_custom_count_at_construction() -> void:
	var unit := Unit.new(UnitType.Value.GUARDIAN, 10)
	assert_eq(unit.count, 10)
	assert_eq(unit.type, UnitType.Value.GUARDIAN)
