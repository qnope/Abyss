extends TestCase
## test/domain/turn/turn_result_test.dart: its group TurnResourceChange, the
## type a TurnEndEntry holds, ported ahead. Its group TurnResult waits for
## the `turn` module (TurnResult holds the reports of the raids, the
## volcano and the factions).


func test_turn_resource_change_consumed_defaults_to_0() -> void:
	var change := TurnResourceChange.new(ResourceType.Value.ALGAE, 50, false, 100, 150)
	assert_eq(change.consumed, 0)


func test_turn_resource_change_consumed_stores_given_value() -> void:
	var change := TurnResourceChange.new(ResourceType.Value.ALGAE, 50, false, 100, 138, 12)
	assert_eq(change.consumed, 12)


## Not in the Dart file: every field as given.
func test_keeps_every_field() -> void:
	var change := TurnResourceChange.new(ResourceType.Value.ENERGY, 5, true, 50, 50, 3)
	assert_eq(change.type, ResourceType.Value.ENERGY)
	assert_eq(change.produced, 5)
	assert_true(change.was_capped)
	assert_eq([change.before_amount, change.after_amount], [50, 50])
