extends TestCase
## test/domain/action/held_attack_report/takeover_losses_test.dart: what the
## owner of a post or of a kernel loses when it is taken.


func test_a_post_taken_returns_the_units_its_owner_had_below() -> void:
	var war := PostWar.new(TransitionBaseType.Value.FAILLE)
	war.put(war.owner(), war.below(), {UnitType.Value.SCOUT: 2})
	war.put(war.owner(), 1, {UnitType.Value.GUARDIAN: 4})

	var lost := PostTakeover.apply(war.post, war.attacker(), war.owner())

	assert_eq(lost.units, {UnitType.Value.SCOUT: 2})
	assert_true(lost.passage)


func test_a_post_taken_before_its_passage_was_built_destroys_none() -> void:
	var war := PostWar.new(TransitionBaseType.Value.FAILLE)
	war.owner().buildings[war.passage()].level = 0

	var lost := PostTakeover.apply(war.post, war.attacker(), war.owner())

	assert_false(lost.passage)


func _take(war: KernelWar, after: int) -> Dictionary[UnitType.Value, int]:
	return KernelTakeover.apply(war.game, war.at.x, war.at.y, war.attacker(), war.owner(), after)


func test_a_kernel_taken_returns_its_garrison() -> void:
	var war := KernelWar.new(1)
	war.garrison(KernelWar.SMALL_GARRISON)

	assert_eq(_take(war, 0), KernelWar.SMALL_GARRISON)
	assert_eq(war.holder(), war.attacker().id)


func test_a_kernel_that_only_loses_a_level_keeps_its_garrison() -> void:
	var war := KernelWar.new(3)
	war.garrison(KernelWar.SMALL_GARRISON)

	assert_eq(_take(war, 2), {} as Dictionary[UnitType.Value, int])
	assert_eq(war.kernel_of(war.owner()), 2)
	assert_eq(war.holder(), war.owner().id)


## Not in the Dart file: a kernel taken down to level 1 is still held, with
## its garrison, by its owner.
func test_a_kernel_left_at_level_1_keeps_its_owner_and_garrison() -> void:
	var war := KernelWar.new(2)
	war.garrison(KernelWar.SMALL_GARRISON)

	assert_eq(_take(war, 1), {} as Dictionary[UnitType.Value, int])
	assert_eq(war.kernel_of(war.owner()), 1)
	assert_eq(war.holder(), war.owner().id)
