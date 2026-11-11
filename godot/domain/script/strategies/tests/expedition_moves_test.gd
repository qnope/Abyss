extends TestCase
## Not in the Dart files: the fighters of a level, whether they are ready for
## the guardians of a post or the kernel or a given enemy, the boosts of the
## army, and the descents a script refuses itself.

const FAILLE := TransitionBaseType.Value.FAILLE
const ADMIRAL := UnitType.Value.ABYSS_ADMIRAL
const HARPOONIST := UnitType.Value.HARPOONIST


func _station(deep: DeepScouts, level: int, units: Dictionary[UnitType.Value, int]) -> void:
	for type: UnitType.Value in units:
		KernelGarrison.stock_at(deep.faction(), level)[type].count = units[type]


func test_the_fighters_of_a_level_leave_the_scouts_and_the_empty_types_out() -> void:
	var deep := DeepScouts.new()
	_station(deep, 1, {UnitType.Value.SCOUT: 3, HARPOONIST: 4, UnitType.Value.GUARDIAN: 0})
	assert_eq(ExpeditionMoves.fighters_on(deep.turn(), 1), {HARPOONIST: 4} as Dictionary[UnitType.Value, int])


func test_the_guardians_of_a_post_or_of_the_kernel() -> void:
	var kernel: Array[Combatant] = ExpeditionMoves.guardians_of(null).call()
	var faille: Array[Combatant] = ExpeditionMoves.guardians_of(FAILLE).call()
	assert_eq(kernel.size(), GuardianFactory.for_volcanic_kernel().size())
	assert_eq(faille.size(), GuardianFactory.for_type(FAILLE).size())
	assert_eq(faille[0].type_key, GuardianFactory.for_type(FAILLE)[0].type_key)


func test_an_army_is_ready_only_with_an_admiral_against_the_guardians() -> void:
	var deep := DeepScouts.new()
	var planner := ArmyPlanner.new()
	var turn := deep.turn()
	_station(deep, 1, {HARPOONIST: 400})
	assert_false(ExpeditionMoves.ready_for(turn, FAILLE, 1, planner))
	assert_true(ExpeditionMoves.ready_for(turn, FAILLE, 1, planner, {ADMIRAL: 1}))
	_station(deep, 1, {HARPOONIST: 1, ADMIRAL: 1})
	assert_false(ExpeditionMoves.ready_for(turn, null, 1, planner))


func test_against_a_given_enemy_the_admiral_stays_out() -> void:
	var deep := DeepScouts.new()
	var planner := ArmyPlanner.new()
	var weak := func() -> Array[Combatant]:
		return CombatantBuilder.monster_combatants_from(MonsterLair.new(MonsterDifficulty.Value.EASY, 1))
	_station(deep, 1, {ADMIRAL: 1})
	assert_false(ExpeditionMoves.ready_for(deep.turn(), null, 1, planner, {}, weak), "the admiral alone")
	_station(deep, 1, {HARPOONIST: 50})
	assert_true(ExpeditionMoves.ready_for(deep.turn(), null, 1, planner, {}, weak))


func test_the_army_is_boosted_by_the_research_when_it_attacks_or_guards() -> void:
	var deep := DeepScouts.new()
	var military := deep.faction().tech_branches[TechBranch.Value.MILITARY]
	military.unlocked = true
	military.research_level = 3
	var effects := TechEffects.of(deep.faction())
	assert_eq(ExpeditionMoves.attack_boost(deep.turn()).atk(100), effects.unit_boost(true).atk(100))
	assert_eq(ExpeditionMoves.defence_boost(deep.turn()).def(100), effects.unit_boost(false, true).def(100))


func test_a_descent_needs_a_post_held_and_units_to_send() -> void:
	var deep := DeepScouts.new()
	_station(deep, 1, {HARPOONIST: 5})
	assert_false(ExpeditionMoves.descend(deep.turn(), 1, {HARPOONIST: 2}), "no post")
	deep.hold(FAILLE)
	assert_false(ExpeditionMoves.descend(deep.turn(), 1, {HARPOONIST: 0}))
	assert_true(ExpeditionMoves.descend(deep.turn(), 1, {HARPOONIST: 2, ADMIRAL: 0}))
	assert_eq(KernelGarrison.stock_at(deep.faction(), 2)[HARPOONIST].count, 2)
