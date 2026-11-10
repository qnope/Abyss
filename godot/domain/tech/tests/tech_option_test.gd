extends TestCase
## The two options of a choice node, in the order and under the names Dart
## gives them: a branch records an option by its index. Dart has no test
## file for tech_option.dart.


func test_has_the_values_of_dart_in_its_order() -> void:
	assert_eq(DartEnum.names(TechOption.Value), PackedStringArray(["a", "b"]))
	assert_eq(TechOption.Value.values(), [0, 1])
