extends TestCase
## The branches of the research, in the order and under the names Dart
## gives them: the snapshots and the vectors write both. Dart has no test
## file for tech_branch.dart.


func test_has_the_values_of_dart_in_its_order() -> void:
	assert_eq(
		DartEnum.names(TechBranch.Value), PackedStringArray(["military", "resources", "explorer"])
	)
	assert_eq(TechBranch.Value.values(), [0, 1, 2])
