extends TestCase
## test/domain/fight/target_picker_test.dart: who an attacker strikes.


func _alive(key: String, side := CombatSide.Value.MONSTER) -> Combatant:
	return Combatant.new(side, key, 10, 2, 1)


func _dead(key: String, side := CombatSide.Value.MONSTER) -> Combatant:
	var c := _alive(key, side)
	c.apply_damage(999)
	return c


func _guardian() -> Combatant:
	return Combatant.new(CombatSide.Value.PLAYER, "guardian", 25, 2, 6)


func test_pick_random_single_alive_target_is_returned() -> void:
	var only := _alive("a")
	var pool: Array[Combatant] = [only, _dead("b"), _dead("c")]
	assert_eq(TargetPicker.pick_random(pool, DartRandom.new(1)), only)


func test_pick_random_returns_null_when_all_combatants_are_dead() -> void:
	var pool: Array[Combatant] = [_dead("a"), _dead("b")]
	assert_null(TargetPicker.pick_random(pool, DartRandom.new(1)))


func test_pick_random_never_returns_a_dead_combatant_over_100_seeded_rolls() -> void:
	var pool: Array[Combatant] = [_dead("x"), _alive("a"), _dead("y"), _alive("b")]
	var random := DartRandom.new(7)
	for _i: int in 100:
		var picked := TargetPicker.pick_random(pool, random)
		assert_not_null(picked)
		assert_true(picked.is_alive())


func test_pick_random_distribution_is_roughly_uniform_across_alive_combatants() -> void:
	var pool: Array[Combatant] = [_alive("a"), _alive("b"), _alive("c")]
	var random := DartRandom.new(123)
	var counts: Dictionary[String, int] = {"a": 0, "b": 0, "c": 0}
	for _i: int in 1000:
		counts[TargetPicker.pick_random(pool, random).type_key] += 1
	for count: int in counts.values():
		assert_true(count > 200 and count < 500, str(counts))


func test_pick_always_targets_a_standing_guardian_first() -> void:
	var tank := _guardian()
	var player := CombatSide.Value.PLAYER
	var pool: Array[Combatant] = [_alive("harpoonist", player), tank, _alive("scout", player)]
	var random := DartRandom.new(7)
	for _i: int in 20:
		assert_eq(TargetPicker.pick(pool, random), tank)


func test_pick_falls_back_to_any_alive_target_once_guardians_are_down() -> void:
	var tank := _guardian()
	tank.apply_damage(999)
	var other := _alive("harpoonist", CombatSide.Value.PLAYER)
	var pool: Array[Combatant] = [tank, other]
	assert_eq(TargetPicker.pick(pool, DartRandom.new(1)), other)


func test_pick_monsters_do_not_taunt() -> void:
	var pool: Array[Combatant] = [_alive("monsterL1"), _alive("a")]
	var seen: Dictionary[String, bool] = {}
	var random := DartRandom.new(3)
	for _i: int in 30:
		seen[TargetPicker.pick(pool, random).type_key] = true
	assert_has(seen, "monsterL1")
	assert_has(seen, "a")
