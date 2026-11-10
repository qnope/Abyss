extends TestCase
## test/domain/volcano/kraken_rules_test.dart: the krakens that rise against
## the kernel, and the magma rampart that answers them.


func _unit() -> Combatant:
	return Combatant.new(CombatSide.Value.PLAYER, "harpoonist", 10, 3, 1)


func _kraken() -> Combatant:
	return CombatantBuilder.monster_combatants_from(VolcanoWaveFactory.from_kernel_level(1))[0]


func test_krakens_fight_as_bosses() -> void:
	assert_true(_kraken().is_boss)
	assert_true(MonsterFamily.is_boss(MonsterFamily.Value.KRAKEN))


func test_etreinte_a_kraken_hit_strikes_a_second_defender() -> void:
	var target := _unit()
	var other := _unit()
	var second := MonsterRules.second_target(_kraken(), target, [target, other], DartRandom.new(1))
	assert_true(second == other)


func test_no_second_strike_when_the_target_stands_alone() -> void:
	var target := _unit()
	assert_null(MonsterRules.embrace_target(_kraken(), target, [target], DartRandom.new(1)))


func test_the_kraken_never_shows_up_in_lairs_or_base_raids() -> void:
	for level: int in [1, 2, 3]:
		assert_false(MonsterFamily.available_at(level).has(MonsterFamily.Value.KRAKEN))


func test_the_magma_rampart_grows_with_the_kernel() -> void:
	assert_null(MagmaRampart.combatant_for(0))
	var low := MagmaRampart.combatant_for(1)
	var high := MagmaRampart.combatant_for(9)
	assert_true(high.max_hp > low.max_hp)
	assert_true(high.atk > low.atk)
