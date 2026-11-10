extends TestCase
## test/domain/fight/monster_rules_test.dart: the combat rules of the
## monster families.


func _unit(key: String, hp := 20, atk := 5) -> Combatant:
	return Combatant.new(CombatSide.Value.PLAYER, key, hp, atk, 0)


func _monster(key: String, hp := 10, atk := 6) -> Combatant:
	return Combatant.new(CombatSide.Value.MONSTER, key, hp, atk, 0)


func test_traque_a_hunter_goes_for_the_frailest_unit() -> void:
	var frail := _unit("scout", 4)
	var pool: Array[Combatant] = [_unit("harpoonist", 15), frail, _unit("saboteur")]
	assert_eq(TargetPicker.pick(pool, DartRandom.new(1), _monster("hunterL1")), frail)


func test_traque_a_taunting_unit_still_draws_the_hunter() -> void:
	var guardian := _unit("guardian", 25)
	var pool: Array[Combatant] = [_unit("scout", 4), guardian]
	assert_eq(TargetPicker.pick(pool, DartRandom.new(1), _monster("hunterL1")), guardian)


func test_traque_a_hunter_hits_twice_as_hard_except_a_taunting_unit() -> void:
	var hunter := _monster("hunterL1", 10, 6)
	assert_eq(AttackDamage.compute(hunter, _unit("scout")), 12)
	assert_eq(AttackDamage.compute(hunter, _unit("guardian")), 6)
	assert_eq(AttackDamage.compute(_monster("swarmL1", 10, 6), _unit("scout")), 6)


func test_essaim_a_harponneur_s_hit_on_the_swarm_strikes_another_fish() -> void:
	var target := _monster("swarmL1")
	var other := _monster("swarmL1")
	var pool: Array[Combatant] = [target, _monster("hunterL1"), other]
	var swept := MonsterRules.sweep_target(_unit("harpoonist"), target, pool, DartRandom.new(3))
	assert_eq(swept, other)


func test_essaim_only_a_harponneur_sweeps_and_only_the_swarm() -> void:
	var target := _monster("swarmL1")
	var pool: Array[Combatant] = [target, _monster("swarmL1")]
	assert_null(MonsterRules.sweep_target(_unit("saboteur"), target, pool, DartRandom.new(1)))
	var hunter := _monster("hunterL1")
	var hunters: Array[Combatant] = [hunter, _monster("hunterL1")]
	assert_null(
		MonsterRules.sweep_target(_unit("harpoonist"), hunter, hunters, DartRandom.new(1))
	)


func test_essaim_a_lone_fish_leaves_nothing_to_sweep() -> void:
	var target := _monster("swarmL1")
	var fallen := _monster("swarmL1", 0)
	fallen.apply_damage(1)
	var pool: Array[Combatant] = [target, fallen]
	assert_null(MonsterRules.sweep_target(_unit("harpoonist"), target, pool, DartRandom.new(1)))


## Not in the Dart file: the constants of the rules, the key of the unit
## that sweeps being the Dart name of its type.
func test_holds_the_constants_of_the_rules() -> void:
	assert_eq(MonsterRules.HUNT_MULTIPLIER, 2)
	var harpoonist := DartEnum.name_of(UnitType.Value, UnitType.Value.HARPOONIST)
	assert_eq(MonsterRules.HARPOONIST_KEY, harpoonist)
	assert_eq(MonsterRules.family_of(_monster("krakenL2")), MonsterFamily.Value.KRAKEN)
	assert_null(MonsterRules.family_of(_unit("scout")))


## Not in the Dart file (alive_index_reference_test.dart draws them through
## the index): the frailest of none, the first of two as frail, and the
## kraken's second blow, through the lists.
func test_etreinte_a_kraken_strikes_another_defender() -> void:
	var target := _unit("guardian")
	var other := _unit("scout", 4)
	var twin := _unit("scout", 4)
	var pool: Array[Combatant] = [target, other, twin]
	var none: Array[Combatant] = []
	var alone: Array[Combatant] = [target]
	var kraken := _monster("krakenL1")
	assert_null(MonsterRules.frailest(none))
	assert_eq(MonsterRules.frailest(pool), other)
	assert_null(MonsterRules.embrace_target(_monster("hunterL1"), target, pool, DartRandom.new(1)))
	assert_null(MonsterRules.embrace_target(kraken, target, alone, DartRandom.new(1)))
	# Random(1).nextInt(2) is 0 (a Dart script): the first of the two others.
	assert_eq(MonsterRules.embrace_target(kraken, target, pool, DartRandom.new(1)), other)
	assert_eq(MonsterRules.second_target(kraken, target, pool, DartRandom.new(1)), other)
	assert_ne(twin, other)
	assert_null(MonsterRules.second_target(_unit("harpoonist"), target, pool, DartRandom.new(1)))
