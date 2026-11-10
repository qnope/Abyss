extends TestCase
## test/domain/fight/army_planner_test.dart: an army sized by rehearsing its
## fight. ArmyRehearsal has no Dart test of its own: these, the settle tests
## and the vectors of fight_planning.json hold it.

const HARPOONIST := UnitType.Value.HARPOONIST

var _planner := ArmyPlanner.new()


func _wave() -> Array[Combatant]:
	return CombatantBuilder.monster_combatants_from(MonsterLair.new(MonsterDifficulty.Value.EASY, 10))


func _harpoons(k: int) -> Dictionary[UnitType.Value, int]:
	return {HARPOONIST: k}


func _scouts(k: int) -> Dictionary[UnitType.Value, int]:
	return {UnitType.Value.SCOUT: k}


func test_a_crushing_army_always_wins_an_empty_one_never_does() -> void:
	assert_eq(_planner.win_rate({HARPOONIST: 60}, _wave), 1.0)
	assert_eq(_planner.win_rate({}, _wave), 0.0)


func test_a_win_without_a_surviving_admiral_does_not_count_when_one_is_needed() -> void:
	var army: Dictionary[UnitType.Value, int] = {HARPOONIST: 60}
	assert_true(_planner.wins(army, GuardianFactory.for_faille))
	assert_false(_planner.wins(army, GuardianFactory.for_faille, null, Callable(), true))


func test_smallest_winning_finds_the_smallest_army_that_wins() -> void:
	var k: int = _planner.smallest_winning(60, _harpoons, _wave)

	assert_true(_planner.wins(_harpoons(k), _wave))
	assert_false(_planner.wins(_harpoons(k - 1), _wave))


func test_smallest_winning_gives_up_when_even_the_largest_army_loses() -> void:
	assert_null(_planner.smallest_winning(3, _scouts, GuardianFactory.for_volcanic_kernel))


func test_planning_never_touches_the_game_dice_same_answer_every_time() -> void:
	var army: Dictionary[UnitType.Value, int] = {HARPOONIST: 8}
	assert_eq(_planner.win_rate(army, _wave), _planner.win_rate(army, _wave))


## Not in the Dart file: the defaults, the strength read through the
## planner, allies that fight with the army, and a negative cap.
func test_holds_its_defaults_and_counts_allies() -> void:
	assert_eq([_planner.rehearsals, _planner.confidence], [8, 0.85])
	var players := _harpoons(3)
	var foes := _wave()
	var side := CombatantBuilder.player_combatants_from(players)
	assert_eq(ArmyPlanner.strength(side, foes), ArmyRehearsal.strength(side, foes))
	var allies := func() -> Array[Combatant]: return CombatantBuilder.player_combatants_from(
		_harpoons(60)
	)
	assert_eq(_planner.win_rate({}, _wave, null, allies), 1.0)
	assert_eq(_planner.smallest_winning(40, _harpoons, _wave, null, allies), 0)
	assert_null(_planner.smallest_winning(-1, _harpoons, _wave))
