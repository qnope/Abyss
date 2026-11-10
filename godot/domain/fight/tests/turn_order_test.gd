extends TestCase
## test/domain/fight/turn_order_test.dart: the order the fighters act in
## during one turn.

const PLAYER := CombatSide.Value.PLAYER
const MONSTER := CombatSide.Value.MONSTER


func _alive(key: String, side: CombatSide.Value) -> Combatant:
	return Combatant.new(side, key, 10, 2, 1)


func _dead(key: String, side: CombatSide.Value) -> Combatant:
	var c := _alive(key, side)
	c.apply_damage(999)
	return c


func _side(keys: Array[String], side: CombatSide.Value) -> Array[Combatant]:
	var fighters: Array[Combatant] = []
	for key: String in keys:
		fighters.append(_alive(key, side))
	return fighters


func _keys(order: Array[Combatant]) -> Array:
	return order.map(func(c: Combatant) -> String: return c.type_key)


func test_shuffle_contains_every_alive_combatant_from_both_sides_exactly_once() -> void:
	var players := _side(["p1", "p2"], PLAYER)
	var monsters := _side(["m1", "m2"], MONSTER)

	var order := TurnOrder.shuffle(players, monsters, DartRandom.new(1))

	assert_eq(order.size(), 4)
	for c: Combatant in players + monsters:
		assert_eq(order.count(c), 1)


func test_shuffle_excludes_dead_combatants_from_both_sides() -> void:
	var p1 := _alive("p1", PLAYER)
	var p_dead := _dead("pDead", PLAYER)
	var m1 := _alive("m1", MONSTER)
	var m_dead := _dead("mDead", MONSTER)
	var players: Array[Combatant] = [p1, p_dead]
	var monsters: Array[Combatant] = [m1, m_dead]

	var order := TurnOrder.shuffle(players, monsters, DartRandom.new(2))

	assert_eq(order.size(), 2)
	assert_has(order, p1)
	assert_has(order, m1)
	assert_false(order.has(p_dead))
	assert_false(order.has(m_dead))


func test_shuffle_orders_differ_between_random_42_and_random_43() -> void:
	assert_ne(_keys_for(42, ["p1", "p2", "p3"], ["m1", "m2", "m3"]),
		_keys_for(43, ["p1", "p2", "p3"], ["m1", "m2", "m3"]))


func test_shuffle_ordering_is_deterministic_given_a_seeded_random() -> void:
	assert_eq(_keys_for(99, ["p1", "p2"], ["m1", "m2"]), _keys_for(99, ["p1", "p2"], ["m1", "m2"]))


func test_shuffle_matches_the_reference_alive_players_then_alive_monsters_shuffled() -> void:
	var players: Array[Combatant] = [
		_alive("p1", PLAYER), _dead("pDead", PLAYER), _alive("p2", PLAYER), _alive("p3", PLAYER),
	]
	var monsters: Array[Combatant] = [
		_dead("mDead", MONSTER), _alive("m1", MONSTER), _alive("m2", MONSTER),
	]
	for seed_: int in 25:
		var reference: Array[Combatant] = []
		for c: Combatant in players + monsters:
			if c.is_alive():
				reference.append(c)
		DartRandom.shuffle(reference, DartRandom.new(seed_))

		assert_eq(TurnOrder.shuffle(players, monsters, DartRandom.new(seed_)), reference,
			"seed %d" % seed_)


## Not in the Dart file: the order Dart draws for Random(42), listed by a
## Dart script.
func test_draws_the_order_of_dart() -> void:
	var dart_order := ["m2", "p3", "m3", "p1", "m1", "p2"]
	assert_eq(_keys_for(42, ["p1", "p2", "p3"], ["m1", "m2", "m3"]), dart_order)


func _keys_for(seed_: int, player_keys: Array[String], monster_keys: Array[String]) -> Array:
	var order := TurnOrder.shuffle(
		_side(player_keys, PLAYER), _side(monster_keys, MONSTER), DartRandom.new(seed_)
	)
	return _keys(order)
