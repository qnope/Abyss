extends TestCase
## Not in the Dart files: lib/domain/action/post_assault_settlement.dart and
## kernel_assault_settlement.dart, which the tests of attack_post/ and
## attack_held_kernel/ read through the actions: the takeover on a win,
## the cooldown whatever the outcome, the owner's report.

const SCOUT := UnitType.Value.SCOUT


## A success always holds its damage, as in Dart.
func _result(victory: bool, damage: BaseDamage) -> AttackBaseResult:
	var defence := DefenceOutcome.new({SCOUT: 1}, {}, {}, {SCOUT: 1}, [])
	return AttackBaseResult.success(victory, null, {SCOUT: 2}, {}, {}, {}, defence, damage)


func test_a_post_won_is_taken_with_what_stood_below_and_reported() -> void:
	var war := PostWar.new(TransitionBaseType.Value.FAILLE)
	war.put(war.owner(), war.below(), {SCOUT: 2})
	var damage := BaseDamage.none(war.owner())

	var entry := PostAssaultSettlement.settle(12, war.post, war.attacker(), "Raider", war.owner(), _result(true, damage))

	assert_eq(war.post.captured_by, war.attacker().id)
	assert_eq(war.attacker().raid_state.post_attack_turns[war.owner().id], 12)
	assert_true(is_same(war.owner().history_entries[-1], entry))
	assert_eq([entry.opponent_name, entry.post_name, entry.defending], ["Raider", war.post.name, true])
	assert_eq([entry.lost_with_post, entry.passage_destroyed, entry.units], [{SCOUT: 2}, true, {SCOUT: 1}])


func test_a_post_held_loses_nothing_and_the_guardians_start_no_cooldown() -> void:
	var war := PostWar.new(TransitionBaseType.Value.CHEMINEE)
	var owner_id := war.owner().id
	var none := BaseDamage.none(war.owner())
	var held := PostAssaultSettlement.settle(12, war.post, war.attacker(), "Raider", war.owner(), _result(false, none))
	assert_eq(war.post.captured_by, owner_id)
	assert_eq([held.victory, held.lost_with_post, held.passage_destroyed], [false, {}, false])

	var guardians := PostAssaultSettlement.settle(13, war.post, null, "Gardiens", war.owner(), _result(false, none))
	assert_eq(guardians.turn, 13)
	assert_eq(war.post.captured_by, owner_id)
	assert_eq(war.attacker().raid_state.post_attack_turns[owner_id], 12)


func test_a_kernel_won_falls_to_the_attacker_with_its_garrison() -> void:
	var war := KernelWar.new(1)
	war.garrison(KernelWar.SMALL_GARRISON)

	KernelAssaultSettlement.settle(war.game, war.at.x, war.at.y, war.attacker(), war.owner(), _result(true, BaseDamage.kernel(1, 0)), "Noyau")

	assert_eq(war.holder(), war.attacker().id)
	assert_eq(war.owner().raid_state.kernel_siege_lost_turn, 12)
	assert_eq(war.attacker().raid_state.kernel_attack_turns[war.owner().id], 12)
	var entry: BaseAssaultEntry = war.owner().history_entries[-1]
	assert_eq([entry.post_name, entry.opponent_name, entry.lost_with_post], ["Noyau", war.attacker().name, KernelWar.SMALL_GARRISON])
	assert_eq([entry.rampart_before, entry.rampart_after, entry.passage_destroyed], [1, 0, true])


func test_a_kernel_held_keeps_its_level_and_garrison_but_starts_the_cooldown() -> void:
	var war := KernelWar.new(3)
	war.garrison(KernelWar.SMALL_GARRISON)

	KernelAssaultSettlement.settle(war.game, war.at.x, war.at.y, war.attacker(), war.owner(), _result(false, BaseDamage.kernel(3, 3)), "Noyau")

	assert_eq([war.kernel_of(war.owner()), war.holder()], [3, war.owner().id])
	assert_null(war.owner().raid_state.kernel_siege_lost_turn)
	assert_eq(war.attacker().raid_state.kernel_attack_turns[war.owner().id], 12)
	var entry: BaseAssaultEntry = war.owner().history_entries[-1]
	assert_eq([entry.victory, entry.lost_with_post], [false, {}])
