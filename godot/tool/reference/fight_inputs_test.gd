extends TestCase
## FightInputs reads the fighters, the armies and the boosts a fight case
## writes, as tool/vectors/domain/vector_inputs.dart writes them.


func test_reads_a_combatant_as_a_case_writes_it() -> void:
	var c := FightInputs.combatant(["hunterL2", "monster", 16, 10, 2, 7, true])
	assert_eq([c.type_key, c.side, c.max_hp, c.atk, c.def, c.current_hp, c.is_boss],
		["hunterL2", CombatSide.Value.MONSTER, 16, 10, 2, 7, true])
	assert_eq(VectorInputs.combatant(c), ["hunterL2", "monster", 16, 10, 2, 7, true])


func test_reads_runs_of_fresh_combatants_in_order() -> void:
	var side := FightInputs.runs([
		["leviathan", "monster", 100, 15, 10, true, 1],
		["sentinelle", "player", 30, 8, 4, false, 2],
	])
	assert_eq(side.size(), 3)
	assert_eq(VectorInputs.combatant(side[0]), ["leviathan", "monster", 100, 15, 10, 100, true])
	assert_eq(VectorInputs.combatant(side[2]), ["sentinelle", "player", 30, 8, 4, 30, false])
	assert_false(is_same(side[1], side[2]))


func test_writes_a_side_as_runs() -> void:
	var written := [
		["guardian", "player", 25, 2, 6, false, 2],
		["scout", "player", 10, 2, 1, false, 1],
		["guardian", "player", 25, 2, 6, false, 1],
	]
	assert_eq(FightInputs.runs_of(FightInputs.runs(written)), written)
	assert_eq(FightInputs.runs_of([]), [])


func test_reads_an_army_in_the_order_of_its_pairs() -> void:
	var army := FightInputs.army([["harpoonist", 13], ["abyssAdmiral", 1]])
	assert_eq(army.keys(), [UnitType.Value.HARPOONIST, UnitType.Value.ABYSS_ADMIRAL])
	assert_eq(army.values(), [13, 1])
	assert_eq(FightInputs.army([]), {})


func test_reads_a_boost() -> void:
	var boost := FightInputs.boost([130, 60, 35])
	assert_eq([boost.atk_percent, boost.def_percent, boost.hp_percent], [130, 60, 35])
