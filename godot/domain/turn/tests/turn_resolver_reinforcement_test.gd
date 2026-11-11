extends TestCase
## test/domain/turn/turn_resolver_reinforcement_test.dart: the
## reinforcements that arrive at the end of a turn.

const SCOUT := UnitType.Value.SCOUT


static func _player(
	pending_reinforcements: Array[ReinforcementOrder], units_per_level: Variant = null
) -> Player:
	return Player.new(
		"human", "human", 5, 5, null, null, null, units_per_level, [], [], {}, [], pending_reinforcements
	)


static func _game(p: Player, turn := 1) -> Game:
	var game := Game.single_player(p)
	game.turn = turn
	return game


static func _order(
	to_level: int, units: Dictionary[UnitType.Value, int], depart_turn: int, at: int
) -> ReinforcementOrder:
	return ReinforcementOrder.new(1, to_level, units, depart_turn, GridPosition.new(at, at))


func test_reinforcements_sent_on_turn_n_arrive_after_end_turn_n_plus_1() -> void:
	var p := _player([_order(2, {SCOUT: 5}, 1, 3)])
	var game := _game(p, 1)

	# On turn 1, departTurn=1 => isReadyToArrive(1) = false
	var result1 := TurnResolver.new().resolve(game)
	assert_true(result1.arrived_reinforcements.is_empty())
	assert_eq(p.pending_reinforcements.size(), 1)

	# On turn 2, departTurn=1 => isReadyToArrive(2) = true
	var result2 := TurnResolver.new().resolve(game)
	assert_eq(result2.arrived_reinforcements.size(), 1)
	assert_true(p.pending_reinforcements.is_empty())


func test_arrived_units_are_added_to_target_level() -> void:
	var p := _player([_order(2, {SCOUT: 5, UnitType.Value.HARPOONIST: 3}, 1, 3)])
	var game := _game(p, 2)

	TurnResolver.new().resolve(game)

	var level2_units := p.units_on_level(2)
	assert_eq(level2_units[SCOUT].count, 5)
	assert_eq(level2_units[UnitType.Value.HARPOONIST].count, 3)


func test_arrived_units_merge_with_existing_units_on_target() -> void:
	var on_2: Dictionary[UnitType.Value, Unit] = {SCOUT: Unit.new(SCOUT, 10)}
	var units: Dictionary[int, Dictionary] = {2: on_2}
	var p := _player([_order(2, {SCOUT: 5}, 1, 3)], units)
	var game := _game(p, 2)

	TurnResolver.new().resolve(game)

	assert_eq(p.units_on_level(2)[SCOUT].count, 15)


func test_pending_list_cleared_after_arrival() -> void:
	var p := _player([
		_order(2, {SCOUT: 3}, 1, 3),
		_order(3, {UnitType.Value.GUARDIAN: 2}, 1, 4),
	])
	var game := _game(p, 2)

	var result := TurnResolver.new().resolve(game)

	assert_eq(result.arrived_reinforcements.size(), 2)
	assert_true(p.pending_reinforcements.is_empty())


func test_only_ready_orders_arrive_others_remain_pending() -> void:
	var p := _player([
		_order(2, {SCOUT: 3}, 1, 3),
		_order(3, {UnitType.Value.GUARDIAN: 2}, 5, 4),
	])
	var game := _game(p, 3)

	var result := TurnResolver.new().resolve(game)

	assert_eq(result.arrived_reinforcements.size(), 1)
	assert_eq(p.pending_reinforcements.size(), 1)
	assert_eq(p.pending_reinforcements[0].to_level, 3)
