extends TestCase
## test/domain/action/attack_held_kernel/attack_held_kernel_cooldown_test.dart:
## the rest an attacker gives the kernel of a player between two sieges.

const HORDE := KernelWar.HORDE


## A war at turn 40 where `by`, armed, last besieged the owner's kernel
## `ago` turns before (never when null).
func _war(by: Callable, ago: Variant = null, human_holds := false) -> KernelWar:
	var war := KernelWar.new(3, 7, human_holds)
	war.game.turn = 40
	var attacker: Player = by.call(war)
	war.put(attacker, KernelGarrison.VOLCANO_LEVEL, HORDE)
	if ago != null:
		var turns_ago: int = ago
		attacker.raid_state.kernel_attack_turns[war.owner().id] = 40 - turns_ago
	return war


func _refusal(war: KernelWar, attacker: Player) -> Variant:
	return war.strike(HORDE).validate(war.game, attacker).reason


func _attacker(w: KernelWar) -> Player:
	return w.attacker()


func _human(w: KernelWar) -> Player:
	return w.human()


func test_a_faction_waits_the_cooldown_before_besieging_the_human_again() -> void:
	var soon := _war(_attacker, 3, true)
	var late := _war(_attacker, 4, true)
	assert_eq(_refusal(soon, soon.attacker()), ActionFailure.Value.ATTACK_TOO_SOON)
	assert_null(_refusal(late, late.attacker()))


func test_a_faction_waits_the_cooldown_before_besieging_a_faction_again() -> void:
	var soon := _war(_attacker, 2)
	var late := _war(_attacker, 4)
	assert_eq(_refusal(soon, soon.attacker()), ActionFailure.Value.ATTACK_TOO_SOON)
	assert_null(_refusal(late, late.attacker()))


func test_the_human_waits_the_cooldown_before_besieging_a_faction_again() -> void:
	var soon := _war(_human, 3)
	var late := _war(_human, 4)
	assert_eq(_refusal(soon, soon.human()), ActionFailure.Value.ATTACK_TOO_SOON)
	assert_null(_refusal(late, late.human()))


func test_a_hot_kernel_is_besieged_with_no_grace() -> void:
	var war := KernelWar.new(7, 7, true)
	war.game.turn = 40
	war.arm()
	assert_null(_refusal(war, war.attacker()))


func test_a_siege_starts_the_cooldown_whatever_its_outcome() -> void:
	var won := _war(_attacker, null, true)
	var lost := _war(_attacker, null, true)
	lost.garrison(KernelWar.FORTRESS)
	ActionExecutor.new().execute(won.strike(HORDE), won.game, won.attacker())
	ActionExecutor.new().execute(lost.strike(HORDE), lost.game, lost.attacker())
	assert_eq(won.kernel_of(won.human()), 2)
	assert_eq(lost.kernel_of(lost.human()), 3)
	assert_eq(won.attacker().raid_state.kernel_attack_turns, {won.human().id: 40})
	assert_eq(lost.attacker().raid_state.kernel_attack_turns, {lost.human().id: 40})
	assert_null(lost.human().raid_state.kernel_siege_lost_turn)


func test_another_attacker_may_besiege_the_very_next_turn() -> void:
	var war := _war(_attacker, null, true)
	ActionExecutor.new().execute(war.strike(HORDE), war.game, war.attacker())
	var other: Player = war.game.players[war.game.factions()[1].id()]
	war.put(other, KernelGarrison.VOLCANO_LEVEL, HORDE)
	war.game.turn = 41
	assert_eq(_refusal(war, war.attacker()), ActionFailure.Value.ATTACK_TOO_SOON)
	assert_null(_refusal(war, other))


func test_the_post_cooldown_leaves_the_kernel_alone() -> void:
	var war := _war(_attacker)
	war.attacker().raid_state.post_attack_turns[war.owner().id] = 40
	assert_null(_refusal(war, war.attacker()))
