extends TestCase
## test/domain/event/random_event_choice_test.dart: the events that wait
## for a choice of the player.

const Type := RandomEventType.Value


func test_every_event_asks_for_a_choice_but_the_storm_and_the_wreck() -> void:
	var without_choice: Array[Type] = [Type.STORM, Type.WRECK]
	for type: Type in Type.values():
		assert_eq(
			RandomEventChoice.has_choice(type),
			not without_choice.has(type),
			DartEnum.name_of(Type, type),
		)


## Not in the Dart file: the names the snapshots and the journals write.
func test_has_the_values_of_dart_in_its_order() -> void:
	assert_eq(
		DartEnum.names(Type),
		PackedStringArray([
			"warmCurrent", "wreck", "predators", "storm", "survivors", "caravan", "coldCurrent",
		]),
	)
