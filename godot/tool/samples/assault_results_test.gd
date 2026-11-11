extends TestCase
## The assaults the UI tests read their reports from really end the way their
## names say.


func test_a_strong_army_takes_a_faille_and_a_weak_one_dies() -> void:
	var won := AssaultResults.transition(AssaultResults.STRONG)
	assert_true(won.is_success)
	assert_true(won.victory)
	assert_true(won.captured)
	var lost := AssaultResults.transition(AssaultResults.WEAK)
	assert_true(lost.is_success)
	assert_false(lost.victory)
	assert_false(lost.captured)
	assert_eq(lost.dead.get(UnitType.Value.ABYSS_ADMIRAL, 0) + lost.wounded.get(UnitType.Value.ABYSS_ADMIRAL, 0), 1)


func test_a_cheminee_is_assaulted_the_same_way() -> void:
	assert_true(AssaultResults.transition(AssaultResults.STRONG, TransitionBaseType.Value.CHEMINEE).is_success)


func test_a_strong_army_takes_the_kernel_and_a_weak_one_dies() -> void:
	var won := AssaultResults.kernel(AssaultResults.STRONG)
	assert_true(won.victory)
	assert_true(won.captured)
	var lost := AssaultResults.kernel(AssaultResults.WEAK)
	assert_false(lost.victory)
	assert_false(lost.captured)
