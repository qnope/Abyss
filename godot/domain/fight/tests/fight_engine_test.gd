extends TestCase
## test/domain/fight/fight_engine_test.dart: a fight resolved turn by turn.

const PLAYER := CombatSide.Value.PLAYER
const MONSTER := CombatSide.Value.MONSTER


func _c(side: CombatSide.Value, key: String, max_hp: int, atk: int, def := 0) -> Combatant:
	return Combatant.new(side, key, max_hp, atk, def)


func _five(side: CombatSide.Value, prefix: String) -> Array[Combatant]:
	var side_: Array[Combatant] = []
	for i: int in range(1, 6):
		side_.append(_c(side, "%s%d" % [prefix, i], 100, 50))
	return side_


func _one(side: CombatSide.Value, key: String, max_hp: int, atk: int, def := 0) -> Array[Combatant]:
	var side_: Array[Combatant] = [_c(side, key, max_hp, atk, def)]
	return side_


func _any_alive(side: Array[Combatant]) -> bool:
	return side.any(func(c: Combatant) -> bool: return c.is_alive())


func test_resolve_victory_strong_players_crush_a_weak_monster() -> void:
	var players := _five(PLAYER, "p")
	var monsters := _one(MONSTER, "m1", 5, 1)

	var result := FightEngine.new(DartRandom.new(1)).resolve(players, monsters)

	assert_eq(result.winner, PLAYER)
	assert_true(result.turn_count >= 1)
	assert_false(_any_alive(monsters))
	assert_true(_any_alive(players))
	assert_eq(result.turn_summaries.size(), result.turn_count)


func test_resolve_defeat_strong_monsters_crush_a_weak_player() -> void:
	var players := _one(PLAYER, "p1", 5, 1)

	var result := FightEngine.new(DartRandom.new(2)).resolve(players, _five(MONSTER, "m"))

	assert_eq(result.winner, MONSTER)
	assert_false(_any_alive(players))


func test_resolve_determinism_same_seed_identical_turn_count_and_summaries() -> void:
	var a := _duel_of_pairs()
	var b := _duel_of_pairs()

	assert_eq(a.turn_count, b.turn_count)
	assert_eq(a.turn_summaries.size(), b.turn_summaries.size())
	for i: int in a.turn_summaries.size():
		assert_eq(_fields(a.turn_summaries[i]), _fields(b.turn_summaries[i]), "turn %d" % i)


func test_resolve_no_infinite_loops_1v1_with_0_atk_on_both_sides_still_terminates() -> void:
	var players := _one(PLAYER, "p1", 3, 0)
	var monsters := _one(MONSTER, "m1", 3, 0)

	var result := FightEngine.new(DartRandom.new(3), 0.0).resolve(players, monsters)

	assert_true(result.turn_count > 0)
	assert_true(not players[0].is_alive() or not monsters[0].is_alive())


func test_resolve_per_turn_summary_1v1_atk_1_with_crit_off_dmg_equals_attacks() -> void:
	var result := FightEngine.new(DartRandom.new(10), 0.0).resolve(
		_one(PLAYER, "p1", 10, 1), _one(MONSTER, "m1", 10, 1)
	)

	for s: FightTurnSummary in result.turn_summaries:
		assert_eq(s.damage_dealt_by_player + s.damage_dealt_by_monster, s.attacks_played * 1)


func test_resolve_initial_snapshot_is_a_clone_mutating_it_does_not_affect_player_side() -> void:
	var players := _one(PLAYER, "p1", 20, 10, 2)

	var result := FightEngine.new(DartRandom.new(4)).resolve(players, _one(MONSTER, "m1", 20, 10, 2))

	var original_live_hp := players[0].current_hp
	result.initial_player_combatants[0].current_hp = 0
	assert_eq(players[0].current_hp, original_live_hp)


## Not in the Dart file: without a die, the engine rolls its own, and its
## crits another of their own, as FightEngine() does in Dart.
func test_resolves_without_a_die_of_its_own() -> void:
	var result := FightEngine.new().resolve(_five(PLAYER, "p"), _one(MONSTER, "m1", 5, 1))
	assert_eq(result.winner, PLAYER)


func _duel_of_pairs() -> FightResult:
	var players: Array[Combatant] = [_c(PLAYER, "p1", 30, 10, 5), _c(PLAYER, "p2", 30, 10, 5)]
	var monsters: Array[Combatant] = [_c(MONSTER, "m1", 30, 8, 3), _c(MONSTER, "m2", 30, 8, 3)]
	return FightEngine.new(DartRandom.new(777)).resolve(players, monsters)


func _fields(s: FightTurnSummary) -> Array[int]:
	return [
		s.turn_number, s.attacks_played, s.crit_count, s.damage_dealt_by_player,
		s.damage_dealt_by_monster, s.player_alive_at_end, s.monster_alive_at_end,
		s.player_hp_at_end, s.monster_hp_at_end,
	]
