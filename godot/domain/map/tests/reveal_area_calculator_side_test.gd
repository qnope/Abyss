extends TestCase
## test/domain/map/reveal_area_calculator_side_test.dart: the side of the
## square an exploration reveals, by explorer research.

const A := TechOption.Value.A
const B := TechOption.Value.B


func test_locked_explorer_branch_reveals_a_3x3_square() -> void:
	assert_eq(TechHelpers.effects_of([]).reveal_side(), 3)


func test_each_tier_levels_1_3_5_widens_the_side_by_2() -> void:
	assert_eq(_side(0), 3)
	assert_eq(_side(1), 5)
	assert_eq(_side(2, [B]), 5)
	assert_eq(_side(3, [B]), 7)
	assert_eq(_side(5, [B, A]), 9)


func test_sonar_profond_level_2_option_a_adds_2_more() -> void:
	assert_eq(_side(2, [A]), 7)
	assert_eq(_side(5, [A, A]), 11)


func test_an_old_save_without_choices_defaults_to_sonar() -> void:
	assert_eq(_side(2), 7)


func _side(level: int, options: Array[TechOption.Value] = []) -> int:
	var explorer := TechHelpers.researched_branch(TechBranch.Value.EXPLORER, level, options)
	return TechHelpers.effects_of([explorer]).reveal_side()
