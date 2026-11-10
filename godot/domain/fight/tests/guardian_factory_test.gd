extends TestCase
## test/domain/fight/guardian_factory_test.dart: the guardians of the posts
## and of the volcanic kernel.

const MONSTER := CombatSide.Value.MONSTER


func _stats_of(c: Combatant) -> Array:
	return [c.type_key, c.max_hp, c.atk, c.def, c.side, c.is_boss]


func _bosses(side: Array[Combatant]) -> Array[Combatant]:
	return side.filter(func(c: Combatant) -> bool: return c.is_boss)


func _minions(side: Array[Combatant]) -> Array[Combatant]:
	return side.filter(func(c: Combatant) -> bool: return not c.is_boss)


func test_for_faille_returns_6_combatants_1_boss_and_5_escorts() -> void:
	assert_eq(GuardianFactory.for_faille().size(), 6)


func test_for_faille_first_combatant_is_the_boss() -> void:
	var boss := GuardianFactory.for_faille()[0]
	assert_eq(_stats_of(boss), ["leviathan", 100, 15, 10, MONSTER, true])


func test_for_faille_escorts_are_not_bosses() -> void:
	var escorts := GuardianFactory.for_faille().slice(1)
	assert_eq(escorts.size(), 5)
	for e: Combatant in escorts:
		assert_eq(_stats_of(e), ["sentinelle", 30, 8, 4, MONSTER, false])


func test_for_cheminee_returns_9_combatants_1_boss_and_8_escorts() -> void:
	assert_eq(GuardianFactory.for_cheminee().size(), 9)


func test_for_cheminee_first_combatant_is_the_boss() -> void:
	var boss := GuardianFactory.for_cheminee()[0]
	assert_eq(_stats_of(boss), ["titanVolcanique", 200, 25, 15, MONSTER, true])


func test_for_cheminee_escorts_are_not_bosses() -> void:
	var escorts := GuardianFactory.for_cheminee().slice(1)
	assert_eq(escorts.size(), 8)
	for e: Combatant in escorts:
		assert_eq(_stats_of(e), ["golemMagma", 50, 12, 7, MONSTER, false])


func test_for_volcanic_kernel_returns_31_combatants_with_exactly_1_boss() -> void:
	var combatants := GuardianFactory.for_volcanic_kernel()
	assert_eq(combatants.size(), 31)
	assert_eq(_bosses(combatants).size(), 1)


func test_for_volcanic_kernel_boss_has_correct_stats() -> void:
	var boss := _bosses(GuardianFactory.for_volcanic_kernel())[0]
	assert_eq(_stats_of(boss), ["seigneurNoyau", 1050, 35, 20, MONSTER, true])


func test_for_volcanic_kernel_all_minions_have_correct_stats() -> void:
	var minions := _minions(GuardianFactory.for_volcanic_kernel())
	assert_eq(minions.size(), 30)
	for m: Combatant in minions:
		assert_eq(_stats_of(m), ["sentinelleNoyau", 80, 18, 10, MONSTER, false])


func test_for_volcanic_kernel_boss_stats_are_strictly_greater_than_titan_volcanique() -> void:
	var boss := _bosses(GuardianFactory.for_volcanic_kernel())[0]
	assert_true(boss.max_hp > 200 and boss.atk > 25 and boss.def > 15)


func test_for_volcanic_kernel_minion_stats_are_strictly_greater_than_golem_de_magma() -> void:
	var minion := _minions(GuardianFactory.for_volcanic_kernel())[0]
	assert_true(minion.max_hp > 50 and minion.atk > 12 and minion.def > 7)


func test_for_type_dispatches_faille() -> void:
	var combatants := GuardianFactory.for_type(TransitionBaseType.Value.FAILLE)
	assert_eq(combatants.size(), 6)
	assert_eq(combatants[0].type_key, "leviathan")


func test_for_type_dispatches_cheminee() -> void:
	var combatants := GuardianFactory.for_type(TransitionBaseType.Value.CHEMINEE)
	assert_eq(combatants.size(), 9)
	assert_eq(combatants[0].type_key, "titanVolcanique")


## Not in the Dart file: each call gives fresh guardians.
func test_gives_fresh_guardians_at_each_call() -> void:
	assert_false(is_same(GuardianFactory.for_faille()[1], GuardianFactory.for_faille()[1]))
	var side := GuardianFactory.for_faille()
	assert_false(is_same(side[1], side[2]))
