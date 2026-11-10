extends TestCase
## test/domain/map/reinforcement_order_test.dart: units on their way to
## another level.

const SCOUT := UnitType.Value.SCOUT
const HARPOONIST := UnitType.Value.HARPOONIST

var _order := ReinforcementOrder.new(1, 2, {SCOUT: 3, HARPOONIST: 2}, 5, GridPosition.new(4, 7))


func test_reinforcement_order_stores_all_fields_correctly() -> void:
	assert_eq(_order.from_level, 1)
	assert_eq(_order.to_level, 2)
	assert_eq(_order.units, {SCOUT: 3, HARPOONIST: 2})
	assert_eq(_order.units.keys(), [SCOUT, HARPOONIST])
	assert_eq(_order.depart_turn, 5)
	assert_true(_order.arrival_point.equals(GridPosition.new(4, 7)))


func test_reinforcement_order_is_ready_to_arrive_returns_false_on_depart_turn() -> void:
	assert_false(_order.is_ready_to_arrive(5))


func test_reinforcement_order_is_ready_to_arrive_returns_true_one_turn_after_depart() -> void:
	assert_true(_order.is_ready_to_arrive(6))


func test_reinforcement_order_is_ready_to_arrive_returns_false_before_depart_turn() -> void:
	assert_false(_order.is_ready_to_arrive(4))
