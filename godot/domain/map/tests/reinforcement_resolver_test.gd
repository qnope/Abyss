extends TestCase
## Not in the Dart tests, which read ReinforcementResolver through the end
## of turn (the turn module): the units sent arrive once their turn has
## passed, as lib/domain/map/reinforcement_resolver.dart answers.

const SCOUT := UnitType.Value.SCOUT
const GUARDIAN := UnitType.Value.GUARDIAN


func test_units_arrive_the_turn_after_they_left_on_their_level() -> void:
	var game := GameSamples.game([GameSamples.player("h"), GameSamples.player("f")])
	game.turn = 5
	var human := game.human_player()
	var waiting := _order(5, {GUARDIAN: 2})
	var ready := _order(4, {GUARDIAN: 3, SCOUT: 1})
	human.pending_reinforcements.append_array([waiting, ready])
	var pending := human.pending_reinforcements
	var arrived := ReinforcementResolver.resolve(game)
	assert_eq(arrived, [ready] as Array[ReinforcementOrder])
	assert_eq(human.pending_reinforcements, [waiting] as Array[ReinforcementOrder])
	assert_true(human.pending_reinforcements == pending)
	var units := human.units_on_level(2)
	assert_eq(units.keys(), [GUARDIAN, SCOUT])
	assert_eq([units[GUARDIAN].count, units[SCOUT].count], [3, 1])


func test_units_join_those_already_on_the_level() -> void:
	var game := GameSamples.game([GameSamples.player("h")])
	game.turn = 3
	var human := game.human_player()
	human.units_on_level(1)[SCOUT].count = 4
	human.pending_reinforcements.append(_order(2, {SCOUT: 2, GUARDIAN: 1}, 1))
	assert_eq(ReinforcementResolver.resolve(game).size(), 1)
	assert_eq(human.unit_counts_on_level(1), {SCOUT: 6, GUARDIAN: 1} as Dictionary[UnitType.Value, int])
	assert_eq(human.units_on_level(1).keys(), UnitType.Value.values())


func _order(depart: int, units: Dictionary[UnitType.Value, int], to_level := 2) -> ReinforcementOrder:
	return ReinforcementOrder.new(1, to_level, units, depart, GridPosition.new(0, 0))
