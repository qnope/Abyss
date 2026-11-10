extends TestCase
## How a node of the research reef is drawn, in the order and under the
## names Dart gives. Dart has no test file for tech_node_state.dart.


func test_has_the_values_of_dart_in_its_order() -> void:
	assert_eq(
		DartEnum.names(TechNodeState.Value),
		PackedStringArray(["locked", "accessible", "researched", "discarded"])
	)
