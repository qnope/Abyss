extends TestCase
## Not in the Dart files: lib/domain/action/base_damage.dart, which the
## tests of the attacks on a base read through AttackBaseAction: a base
## left as it stands, a kernel's levels, and the price of a lost base.

const CITADEL := BuildingType.Value.CORAL_CITADEL
const CORAL := ResourceType.Value.CORAL


func _fields(d: BaseDamage) -> Array:
	return [d.rampart_before, d.rampart_after, d.headquarters_before, d.headquarters_after]


func test_none_and_kernel_break_nothing() -> void:
	var target := AssaultSamples.rival_of(AssaultSamples.assault_game())
	AssaultSamples.set_level(target, CITADEL, 3)
	var none := BaseDamage.none(target)
	assert_eq(_fields(none), [3, 3, 5, 5])
	assert_true(none.pillaged.is_empty() and none.loot.is_empty())
	assert_eq(_fields(BaseDamage.kernel(4, 2)), [4, 2, 0, 0])


func test_a_razed_base_loses_two_rampart_levels_and_its_stocks() -> void:
	var game := AssaultSamples.assault_game()
	var attacker := game.human_player()
	var target := AssaultSamples.rival_of(game)
	AssaultSamples.set_level(target, CITADEL, 3)
	target.resources[CORAL].amount = 640
	var coral := attacker.resources[CORAL].amount
	var damage := BaseRaze.apply(attacker, target)
	assert_eq(_fields(damage), [3, 1, 5, 5])
	assert_eq(target.buildings[CITADEL].level, 1)
	assert_eq(damage.pillaged[CORAL], 192)
	assert_eq(target.resources[CORAL].amount, 448)
	assert_eq(attacker.resources[CORAL].amount, coral + damage.loot[CORAL])
	AssaultSamples.set_level(target, CITADEL, 1)
	assert_eq(_fields(BaseRaze.apply(attacker, target)), [1, 0, 5, 5])


func test_without_a_rampart_the_headquarters_fall_by_one() -> void:
	var game := AssaultSamples.assault_game()
	var target := AssaultSamples.rival_of(game)
	assert_eq(_fields(BaseRaze.apply(game.human_player(), target)), [0, 0, 5, 4])
	assert_eq(target.buildings[BuildingType.Value.HEADQUARTERS].level, 4)
