extends VectorTestCase
## reference/vectors/fight_engine.json: whole fights, turn by turn, as the
## Dart engine plays them: every die of the turn order, the targets and the
## crits, every blow and the hit points of every fighter at the end.

var _vectors := VectorFile.new("fight_engine")


func test_resolve() -> void:
	var cases := _vectors.cases("resolve")
	assert_eq(cases.size(), 72, "24 fights, 3 seeds")
	for case: Dictionary in cases:
		var seed_: int = case["seed"]
		var out := _fought(case, FightEngine.new(DartRandom.new(seed_)))
		assert_same(out, case["out"], "%s, seed %d" % [case["fight"], seed_])


func test_crit_chance() -> void:
	var cases := _vectors.cases("critChance")
	assert_eq(cases.size(), 9)
	for case: Dictionary in cases:
		var seed_: int = case["seed"]
		var chance: float = case["critChance"]
		var out := _fought(case, FightEngine.new(DartRandom.new(seed_), chance))
		assert_same(out, case["out"], "%s, crits %s" % [case["fight"], chance])


func test_two_fights() -> void:
	var cases := _vectors.cases("twoFights")
	assert_eq(cases.size(), 6)
	for case: Dictionary in cases:
		var seed_: int = case["seed"]
		var random := DartRandom.new(seed_)
		var out := [_fought(case, FightEngine.new(random)), _fought(case, FightEngine.new(random))]
		assert_same(out, case["out"], "%s, seed %d" % [case["fight"], seed_])


## The fight of the case resolved by `engine`, written as a case writes its
## result. The engine is built as the case's Dart call builds it: with the
## default crit chance unless the case gives one.
func _fought(case: Dictionary, engine: FightEngine) -> Dictionary:
	var players := FightInputs.runs(case["players"])
	var monsters := FightInputs.runs(case["monsters"])
	var result := engine.resolve(players, monsters)
	var turns := []
	for t: FightTurnSummary in result.turn_summaries:
		turns.append([
			t.attacks_played, t.crit_count, t.damage_dealt_by_player, t.damage_dealt_by_monster,
			t.player_alive_at_end, t.monster_alive_at_end, t.player_hp_at_end, t.monster_hp_at_end,
		])
	return {
		"winner": DartEnum.name_of(CombatSide.Value, result.winner),
		"turnCount": result.turn_count,
		"initialMonsterCount": result.initial_monster_count,
		"finalMonsterCount": result.final_monster_count,
		"playerHp": _hp(result.final_player_combatants),
		"monsterHp": _hp(monsters),
		"turns": turns,
	}


func _hp(side: Array[Combatant]) -> Array:
	return side.map(func(c: Combatant) -> int: return c.current_hp)
