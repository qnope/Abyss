extends TestCase
## test/domain/leviathan/leviathan_force_test.dart: the guardians that come
## back to the human's first Faille.


func test_a_leviathan_and_four_sentinelles_attacking() -> void:
	var force := LeviathanForce.combatants()
	assert_eq(LeviathanForce.SENTINELS, 4)
	assert_eq(force.size(), 1 + LeviathanForce.SENTINELS)
	for c: Combatant in force:
		assert_eq(c.side, CombatSide.Value.PLAYER)
	assert_eq(force[0].type_key, LeviathanForce.LEVIATHAN_KEY)
	assert_true(force[0].is_boss)
	for c: Combatant in force.slice(1):
		assert_eq(c.type_key, LeviathanForce.SENTINEL_KEY)


func test_the_guardians_of_a_faille_at_full_strength_by_default() -> void:
	var faille := GuardianFactory.for_faille()
	var force := LeviathanForce.combatants()
	assert_eq(force[0].max_hp, faille[0].max_hp)
	assert_eq(force[0].atk, faille[0].atk)
	assert_eq(force[-1].max_hp, faille[-1].max_hp)
	assert_eq(force[-1].def, faille[-1].def)


func test_scaled_like_the_other_monsters_of_the_game() -> void:
	var game := GameFactory.new_game("Nemo", 7, Difficulty.Value.HARD, false, 2)
	var percent := Difficulty.monster_percent_for(Difficulty.Value.HARD, false, 2)
	assert_eq(LeviathanForce.percent_of(game), percent)
	var force := LeviathanForce.of(game)
	var faille := GuardianFactory.for_faille()
	assert_eq(force[0].max_hp, DartMath.trunc_div(faille[0].max_hp * percent, 100))
	assert_eq(force[0].atk, DartMath.trunc_div(faille[0].atk * percent, 100))
	assert_eq(force[-1].max_hp, DartMath.trunc_div(faille[-1].max_hp * percent, 100))
	assert_eq(force[-1].def, faille[-1].def)


func test_counts_the_force_by_kind() -> void:
	assert_eq(LeviathanForce.COUNTS, {
		LeviathanForce.LEVIATHAN_KEY: 1,
		LeviathanForce.SENTINEL_KEY: LeviathanForce.SENTINELS,
	})
	assert_eq(LeviathanForce.ATTACKER_NAME, "leviathan")
	assert_eq(LeviathanForce.SENTINEL_KEY, "sentinelle")
