extends TestCase
## test/domain/tech/tech_tree_test.dart: the shape of a research branch.


func test_tech_tree_a_branch_has_five_levels() -> void:
	assert_eq(TechTree.MAX_LEVEL, 5)


func test_tech_tree_only_levels_2_and_4_hold_a_choice() -> void:
	var choices: Array[int] = []
	for level: int in range(0, 7):
		if TechTree.is_choice_level(level):
			choices.append(level)
	assert_eq(choices, [2, 4])


func test_tech_tree_choice_levels_are_indexed_in_order() -> void:
	assert_eq(TechTree.choice_index(2), 0)
	assert_eq(TechTree.choice_index(4), 1)


func test_tech_tree_tiers_reached_count_the_odd_levels_researched() -> void:
	var tiers: Array[int] = []
	for level: int in range(0, 6):
		tiers.append(TechTree.tiers_reached(level))
	assert_eq(tiers, [0, 1, 1, 2, 2, 3])


## Not in the Dart file: `isEven` and `~/` below zero, where GDScript's `%`
## and `/` could part from Dart's.
func test_no_level_below_one_holds_a_choice() -> void:
	for level: int in [-4, -3, -2, -1, 0]:
		assert_false(TechTree.is_choice_level(level), str(level))
	assert_eq(TechTree.choice_index(1), -1)
	assert_eq(TechTree.choice_index(-3), -2)
	assert_eq(TechTree.tiers_reached(-2), 0)
	assert_eq(TechTree.tiers_reached(-4), -1)
