extends TestCase
## test/domain/objective/temporary/temporary_objective_test.dart: an
## objective an event sets for a while, compared by value.

const WRECK := TemporaryObjectiveKind.Value.WRECK
const PREDATORS := TemporaryObjectiveKind.Value.PREDATORS


func test_temporary_objective_equal_when_its_kind_and_last_turn_are() -> void:
	assert_true(_wreck().equals(_wreck()))
	assert_eq(_wreck().hash_code(), _wreck().hash_code())


func test_temporary_objective_different_as_soon_as_one_of_them_differs() -> void:
	assert_false(_wreck().equals(_wreck(18)))
	assert_false(_wreck().equals(TemporaryObjective.new(PREDATORS, 17)))
	assert_false(_wreck().equals("wreck"))


func test_temporary_objective_reads_as_its_kind_and_last_turn() -> void:
	assert_eq(str(_wreck()), "TemporaryObjective(wreck, 17)")


## Not in the Dart file: the kinds and the outcomes under their Dart names,
## in the Dart order, and an end done only when reached in time.
func test_the_kinds_and_the_outcomes_have_the_dart_names_and_order() -> void:
	assert_eq(DartEnum.names(TemporaryObjectiveKind.Value), PackedStringArray(["wreck", "predators"]))
	var outcomes := TemporaryObjectiveOutcome.Value
	assert_eq(DartEnum.names(outcomes), PackedStringArray(["done", "expired", "failed"]))
	assert_true(TemporaryObjectiveEnd.new(_wreck(), outcomes.DONE).is_done())
	assert_false(TemporaryObjectiveEnd.new(_wreck(), outcomes.EXPIRED).is_done())
	assert_false(TemporaryObjectiveEnd.new(_wreck(), outcomes.FAILED).is_done())


func _wreck(last_turn := 17) -> TemporaryObjective:
	return TemporaryObjective.new(WRECK, last_turn)
