extends TestCase
## The resources, in the order and under the names Dart gives them: the
## snapshots and the vectors write both.


func test_has_the_values_of_dart_in_its_order() -> void:
	assert_eq(
		DartEnum.names(ResourceType.Value),
		PackedStringArray(["algae", "coral", "ore", "energy", "pearl"])
	)
	assert_eq(ResourceType.Value.values(), [0, 1, 2, 3, 4])
