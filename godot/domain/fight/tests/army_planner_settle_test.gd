extends TestCase
## test/domain/fight/army_planner_settle_test.dart: `wins` rehearses only
## until its verdict is settled, and always agrees with `win_rate`.

const HARPOONIST := UnitType.Value.HARPOONIST

var _planner := ArmyPlanner.new()
## Never wins, yet strong enough to be rehearsed.
var _doomed: Dictionary[UnitType.Value, int] = {HARPOONIST: 5}
var _crushing: Dictionary[UnitType.Value, int] = {HARPOONIST: 10}


## An enemy that counts its rehearsals: it is asked for once per fight.
class Counted:
	var calls := 0
	var _enemy: Callable

	func _init(enemy_: Callable) -> void:
		_enemy = enemy_

	func enemy() -> Array[Combatant]:
		calls += 1
		return _enemy.call()


static func _wave() -> Array[Combatant]:
	return CombatantBuilder.monster_combatants_from(MonsterLair.new(MonsterDifficulty.Value.EASY, 10))


## Rehearsals `planner` plays to judge `army` against `_wave`.
func _rehearsals_of(
	planner: ArmyPlanner, army: Dictionary[UnitType.Value, int], win_rate := false
) -> int:
	var counted := Counted.new(_wave)
	if win_rate:
		planner.win_rate(army, counted.enemy)
	else:
		planner.wins(army, counted.enemy)
	return counted.calls


func test_the_armies_used_below_are_rehearsed_in_full_by_win_rate() -> void:
	assert_eq(_planner.win_rate(_doomed, _wave), 0.0)
	assert_eq(_planner.win_rate(_crushing, _wave), 1.0)
	assert_eq(_rehearsals_of(_planner, _doomed, true), 8)
	assert_eq(_rehearsals_of(_planner, _crushing, true), 8)


func test_wins_stops_once_two_losses_out_of_8_settle_a_no_at_85_percent() -> void:
	assert_false(_planner.wins(_doomed, _wave))
	assert_eq(_rehearsals_of(_planner, _doomed), 2)


func test_wins_stops_once_seven_wins_out_of_8_settle_a_yes_at_85_percent() -> void:
	assert_true(_planner.wins(_crushing, _wave))
	assert_eq(_rehearsals_of(_planner, _crushing), 7)


func test_the_thresholds_follow_rehearsals_and_confidence() -> void:
	var lenient := ArmyPlanner.new(10, 0.7)
	assert_eq(_rehearsals_of(lenient, _doomed), 4)
	assert_eq(_rehearsals_of(lenient, _crushing), 7)
	var strict := ArmyPlanner.new(20, 0.95)
	assert_eq(_rehearsals_of(strict, _doomed), 2)
	assert_eq(_rehearsals_of(strict, _crushing), 19)


func test_wins_always_agrees_with_win_rate_against_confidence() -> void:
	var planners: Array[ArmyPlanner] = [
		ArmyPlanner.new(), ArmyPlanner.new(10, 0.7), ArmyPlanner.new(20, 0.95),
		ArmyPlanner.new(5, 1), ArmyPlanner.new(6, 0.5), ArmyPlanner.new(3, 0.1),
		ArmyPlanner.new(4, 0), ArmyPlanner.new(4, 1.5),
	]
	var enemies: Array[Callable] = [
		_wave, GuardianFactory.for_faille, GuardianFactory.for_volcanic_kernel,
	]
	var armies: Array[Dictionary] = []
	for k: int in 13:
		armies.append(_army({HARPOONIST: k}))
	for k: int in range(0, 61, 15):
		armies.append(_army({HARPOONIST: k, UnitType.Value.ABYSS_ADMIRAL: 1}))
	for p: ArmyPlanner in planners:
		for enemy: Callable in enemies:
			for army: Dictionary[UnitType.Value, int] in armies:
				for admiral: bool in [false, true]:
					assert_eq(
						p.wins(army, enemy, null, Callable(), admiral),
						p.win_rate(army, enemy, null, Callable(), admiral) >= p.confidence,
						"%d@%s %s %s" % [p.rehearsals, p.confidence, army, admiral]
					)


func _army(counts: Dictionary[UnitType.Value, int]) -> Dictionary[UnitType.Value, int]:
	return counts
