extends TestCase
## test/domain/unit/unit_type_test.dart: the units a base recruits.


func test_unit_type_has_6_values() -> void:
	assert_eq(UnitType.Value.size(), 6)


func test_unit_type_all_values_are_distinct() -> void:
	var distinct := {}
	for type: UnitType.Value in UnitType.Value.values():
		distinct[type] = true
	assert_eq(distinct.size(), 6)


## Not in the Dart file: the names and the order the snapshots write.
func test_has_the_values_of_dart_in_its_order() -> void:
	assert_eq(
		DartEnum.names(UnitType.Value),
		PackedStringArray([
			"scout", "harpoonist", "guardian", "domeBreaker", "abyssAdmiral", "saboteur",
		])
	)
