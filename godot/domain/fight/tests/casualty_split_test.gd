extends TestCase
## test/domain/fight/casualty_split_test.dart: the fallen of a fight, split
## into the wounded and the dead.


func _c(key: String) -> Combatant:
	return Combatant.new(CombatSide.Value.PLAYER, key, 10, 1, 1)


func test_casualty_split_constructor_stores_both_lists() -> void:
	var wounded: Array[Combatant] = [_c("a"), _c("b")]
	var dead: Array[Combatant] = [_c("c")]
	var split := CasualtySplit.new(wounded, dead)
	assert_true(is_same(split.wounded, wounded))
	assert_true(is_same(split.dead, dead))
	assert_eq(split.wounded.size(), 2)
	assert_eq(split.dead.size(), 1)
