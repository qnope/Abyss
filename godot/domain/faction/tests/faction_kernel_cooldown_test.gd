extends TestCase
## test/domain/faction/faction_kernel_cooldown_test.dart: a faction spares a
## kernel it besieged a few turns before.


## Counts the kernels the faction weighs before it besieges one.
class Counting:
	extends ArmyPlanner

	var weighed := 0

	func wins(
		army: Dictionary[UnitType.Value, int],
		enemy: Callable,
		boost: UnitBoost = null,
		allies := Callable(),
		needs_admiral := false,
	) -> bool:
		weighed += 1
		return super(army, enemy, boost, allies, needs_admiral)


## The owner (the human with `human_holds`) holds the kernel at `level`; the
## attacker, ready, last besieged it `ago` turns before (never when null).
static func _scene(level: int, human_holds := true, ago: Variant = null) -> KernelWar:
	var war := KernelWar.new(level, 7, human_holds)
	war.game.turn = 40
	war.arm()
	war.garrison(KernelWar.SMALL_GARRISON)
	if ago != null:
		var turns_ago: int = ago
		war.attacker().raid_state.kernel_attack_turns[war.owner().id] = 40 - turns_ago
	return war


static func _turn(war: KernelWar) -> FactionTurn:
	return FactionTurn.new(war.game, war.attacker(), ActionExecutor.new(), DartRandom.new(2, false))


func test_a_kernel_on_cooldown_is_not_even_weighed() -> void:
	for hot: bool in [true, false]:
		var war := _scene(7 if hot else 3, true, 3)
		var planner := Counting.new()
		var turn := _turn(war)

		var besieged := (
			FactionKernelWar.besiege_hot(turn, planner) if hot
			else FactionKernelWar.besiege_cold(turn, planner)
		)
		assert_false(besieged)
		assert_false(FactionKernelWar.play(turn, planner))
		assert_eq(planner.weighed, 0)
		assert_eq(war.kernel_of(war.human()), 7 if hot else 3)


func test_a_freshly_hot_kernel_is_besieged_at_once() -> void:
	var war := _scene(7)

	assert_true(FactionKernelWar.besiege_hot(_turn(war), Counting.new()))
	assert_eq(war.kernel_of(war.human()), 6)


func test_it_is_besieged_again_once_the_cooldown_is_over() -> void:
	var war := _scene(3)

	assert_true(FactionKernelWar.besiege_cold(_turn(war), Counting.new()))
	assert_eq(war.attacker().raid_state.kernel_attack_turns, {war.human().id: 40})
	assert_eq(war.human().raid_state.kernel_siege_lost_turn, 40)
	war.game.turn = 43
	var held := Counting.new()
	assert_false(FactionKernelWar.besiege_cold(_turn(war), held))
	assert_eq(held.weighed, 0)
	war.game.turn = 44
	assert_true(FactionKernelWar.besiege_cold(_turn(war), Counting.new()))


func test_factions_between_them_keep_the_same_cooldown() -> void:
	var soon := _scene(7, false, 3)
	var late := _scene(7, false, 4)

	assert_false(FactionKernelWar.besiege_hot(_turn(soon), Counting.new()))
	assert_true(FactionKernelWar.besiege_hot(_turn(late), Counting.new()))
	assert_eq(late.kernel_of(late.owner()), 6)
