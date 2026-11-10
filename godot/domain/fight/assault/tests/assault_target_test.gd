extends TestCase
## test/domain/fight/assault/assault_target_test.dart: what an assault led by
## an Abyss Admiral can capture. Its second test (the passage, from
## PostTakeover) waits for the action module; the last three (AssaultTarget
## .at, on a Game) wait for the game module. assault_next_step.dart has no
## Dart test: the plan's tests hold it, and wait for the game; the last test
## here holds it in the meantime.


func test_each_target_fights_its_own_guardians() -> void:
	assert_eq(AssaultTarget.guardians(AssaultTarget.Value.FAILLE).size(),
		GuardianFactory.for_faille().size())
	assert_eq(AssaultTarget.guardians(AssaultTarget.Value.CHEMINEE)[0].type_key,
		GuardianFactory.for_cheminee()[0].type_key)
	assert_eq(AssaultTarget.guardians(AssaultTarget.Value.KERNEL).size(),
		GuardianFactory.for_volcanic_kernel().size())


## Not in the Dart file: the targets in the Dart order, and their guardians
## as the Callable a planner asks for fresh ones.
func test_names_the_targets_and_gives_their_guardians_fresh() -> void:
	assert_eq(DartEnum.names(AssaultTarget.Value),
		PackedStringArray(["faille", "cheminee", "kernel"]))
	var enemy := AssaultTarget.guardians_of(AssaultTarget.Value.FAILLE)
	var first: Array[Combatant] = enemy.call()
	var second: Array[Combatant] = enemy.call()
	assert_eq(first.size(), 6)
	assert_false(is_same(first[0], second[0]))


## Not in the Dart tests: the next step after a capture, ready once the
## headquarters reach the level required.
func test_the_next_step_is_ready_once_the_headquarters_are_high_enough() -> void:
	var module := BuildingType.Value.DESCENT_MODULE
	var step := AssaultNextStep.new(module, 5, 4)
	assert_eq([step.building, step.required_hq, step.current_hq], [module, 5, 4])
	assert_false(step.is_ready())
	assert_true(AssaultNextStep.new(module, 5, 5).is_ready())
