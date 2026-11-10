extends TestCase
## The kinds of posts between two levels, under the names Dart gives them.
## Dart has no test of its own for this enum.


func test_has_the_values_of_dart_in_its_order() -> void:
	assert_eq(DartEnum.names(TransitionBaseType.Value), PackedStringArray(["faille", "cheminee"]))
