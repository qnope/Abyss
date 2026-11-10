extends TestCase
## test/domain/unit/unit_stats_test.dart: the health, attack and defence of
## each unit.


func _stats(type: UnitType.Value) -> Array[int]:
	var stats := UnitStats.for_type(type)
	return [stats.hp, stats.atk, stats.def]


func test_unit_stats_for_type_scout() -> void:
	assert_eq(_stats(UnitType.Value.SCOUT), [10, 2, 1])


func test_unit_stats_for_type_harpoonist() -> void:
	assert_eq(_stats(UnitType.Value.HARPOONIST), [15, 5, 2])


func test_unit_stats_for_type_guardian() -> void:
	assert_eq(_stats(UnitType.Value.GUARDIAN), [25, 2, 6])


func test_unit_stats_for_type_dome_breaker() -> void:
	assert_eq(_stats(UnitType.Value.DOME_BREAKER), [20, 8, 3])


func test_unit_stats_for_type_abyss_admiral() -> void:
	assert_eq(_stats(UnitType.Value.ABYSS_ADMIRAL), [100, 0, 0])


func test_unit_stats_for_type_saboteur() -> void:
	assert_eq(_stats(UnitType.Value.SABOTEUR), [8, 10, 1])
