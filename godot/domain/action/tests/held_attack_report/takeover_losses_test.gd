extends TestCase
## test/domain/action/held_attack_report/takeover_losses_test.dart: what the
## owner of a post or of a kernel loses when it is taken. Its last two
## tests (KernelTakeover) wait for the next commit of the lot.


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
