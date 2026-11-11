extends TestCase
## What the player aims at in the tree (tech_target_test.dart).

const Branch := TechBranch.Value


func test_a_target_without_level_is_the_branch() -> void:
	var target := TechTarget.new(Branch.MILITARY)
	assert_true(target.is_branch())
	assert_false(target.is_choice())
	assert_false(TechTarget.new(Branch.MILITARY, 3).is_branch())


func test_the_even_levels_are_choices() -> void:
	var choices: Array[bool] = []
	for level in range(1, 6):
		choices.append(TechTarget.new(Branch.EXPLORER, level).is_choice())
	assert_eq(choices, [false, true, false, true, false] as Array[bool])


func test_two_targets_are_equal_for_the_same_branch_and_level() -> void:
	var target := TechTarget.new(Branch.MILITARY, 2)
	assert_true(target.equals(TechTarget.new(Branch.MILITARY, 2)))
	assert_false(target.equals(TechTarget.new(Branch.MILITARY, 3)))
	assert_false(target.equals(TechTarget.new(Branch.RESOURCES, 2)))
	assert_false(target.equals(TechTarget.new(Branch.MILITARY)))
	assert_false(target.equals(null))
