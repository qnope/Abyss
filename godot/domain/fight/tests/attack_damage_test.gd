extends TestCase
## test/domain/fight/attack_damage_test.dart: the damage of one attack
## between two combatants, roles included.


func _player(key: String, atk := 8) -> Combatant:
	return Combatant.new(CombatSide.Value.PLAYER, key, 20, atk, 0)


func _monster(def := 10, is_boss := false) -> Combatant:
	return Combatant.new(CombatSide.Value.MONSTER, "m", 100, 1, def, null, is_boss)


func test_compute_plain_unit_is_reduced_by_the_target_def() -> void:
	assert_eq(AttackDamage.compute(_player("harpoonist"), _monster()), 4)


func test_compute_dome_breaker_deals_double_damage_to_bosses_only() -> void:
	var breaker := _player("domeBreaker")
	assert_eq(AttackDamage.compute(breaker, _monster()), 4)
	assert_eq(AttackDamage.compute(breaker, _monster(10, true)), 8)


func test_compute_saboteur_ignores_the_target_def() -> void:
	assert_eq(AttackDamage.compute(_player("saboteur", 10), _monster(20)), 10)


func test_compute_crit_triples_the_role_adjusted_damage() -> void:
	assert_eq(AttackDamage.compute(_player("domeBreaker"), _monster(10, true), true), 24)


## Not in the Dart file: the multiplier of a boss breaker on a boss.
func test_holds_the_boss_multiplier() -> void:
	assert_eq(AttackDamage.BOSS_MULTIPLIER, 2)
