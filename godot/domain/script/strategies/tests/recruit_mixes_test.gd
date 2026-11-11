extends TestCase
## Not in the Dart files: the mixes a script recruits, what it can pay, and
## the smallest top-up that beats an enemy.

const HARPOONIST := UnitType.Value.HARPOONIST
const GUARDIAN := UnitType.Value.GUARDIAN
const BARRACKS := BuildingType.Value.BARRACKS
const PAIR: Dictionary[UnitType.Value, int] = {GUARDIAN: 1, HARPOONIST: 2}
const SOLO: Dictionary[UnitType.Value, int] = {HARPOONIST: 1}


func _turn(barracks: int, algae := 100000, coral := 100000) -> ScriptTurn:
	var amounts := ActionSamples.amounts(algae, coral, 100000, 100000, 0)
	var player := ActionSamples.stocked(amounts, {BuildingType.Value.HEADQUARTERS: 10, BARRACKS: barracks})
	for r: ResourceType.Value in amounts:
		player.resources[r].amount = amounts[r]
	return ScriptSamples.turn(ActionSamples.game_of(player))


func _enemy(count: int) -> Callable:
	return func() -> Array[Combatant]:
		return CombatantBuilder.monster_combatants_from(MonsterLair.new(MonsterDifficulty.Value.EASY, count))


func test_a_mix_is_usable_once_unlocked_and_not_yet_recruited() -> void:
	var turn := _turn(1)
	assert_eq(RecruitMoves.usable_mixes(turn, [PAIR, SOLO]), [SOLO] as Array[Dictionary])
	turn.player.recruited_unit_types.append(HARPOONIST)
	assert_true(RecruitMoves.usable_mixes(turn, [PAIR, SOLO]).is_empty())
	assert_eq(RecruitMoves.usable_mixes(_turn(3), [PAIR, SOLO]).size(), 2)


func test_what_a_mix_affords_is_capped_by_the_stocks_the_upkeep_the_barracks_and_the_batch() -> void:
	assert_eq(RecruitMoves.affordable(_turn(3), PAIR), RecruitMoves.MAX_BATCH)
	assert_eq(RecruitMoves.affordable(_turn(1), SOLO), 100, "the barracks at 1")
	assert_eq(RecruitMoves.affordable(_turn(3), PAIR, 0.0), 0)
	var coral := _turn(3, 100000, 300)
	var per_pair := 0
	var costs := UnitCostCalculator.new()
	for t: UnitType.Value in PAIR:
		per_pair += costs.recruitment_cost(t).get(ResourceType.Value.CORAL, 0) * PAIR[t]
	assert_eq(RecruitMoves.affordable(coral, PAIR), DartMath.trunc_div(300, per_pair))
	assert_eq(RecruitMoves.affordable(coral, PAIR, 0.5), DartMath.trunc_div(150, per_pair))
	var hungry := _turn(3, 100)
	var upkeep := 3 + 2 * 2
	var room := RecruitMoves.algae_margin(hungry) + 10
	assert_eq(RecruitMoves.affordable(hungry, PAIR), clampi(DartMath.trunc_div(room, upkeep), 0, 150))
	hungry.player.units_on_level(1)[HARPOONIST].count = 1000
	assert_eq(RecruitMoves.affordable(hungry, PAIR), 0, "a starving base recruits nobody")


func test_a_mix_is_recruited_type_by_type() -> void:
	var turn := _turn(3)
	assert_false(RecruitMoves.recruit_mix(turn, PAIR, 0))
	assert_true(RecruitMoves.recruit_mix(turn, PAIR, 4))
	assert_eq(turn.player.units_on_level(1)[GUARDIAN].count, 4)
	assert_eq(turn.player.units_on_level(1)[HARPOONIST].count, 8)
	assert_false(RecruitMoves.recruit_mix(turn, PAIR, 1), "once a turn")


func test_a_base_strong_enough_recruits_nothing() -> void:
	var turn := _turn(3)
	var done := RecruitMoves.top_up(turn, {HARPOONIST: 200}, _enemy(2), [PAIR], ArmyPlanner.new(), null)
	assert_true(done)
	assert_eq(turn.player.units_on_level(1)[HARPOONIST].count, 0)


func test_the_smallest_winning_top_up_of_the_first_usable_mix_is_recruited() -> void:
	var turn := _turn(3)
	var planner := ArmyPlanner.new()
	var base: Dictionary[UnitType.Value, int] = {HARPOONIST: 1}
	assert_true(RecruitMoves.top_up(turn, base, _enemy(6), [SOLO], planner, null))
	var k := turn.player.units_on_level(1)[HARPOONIST].count
	assert_true(k > 0)
	var fewer: Dictionary[UnitType.Value, int] = {HARPOONIST: k}
	assert_false(planner.wins(fewer, _enemy(6)), "one fewer would lose")
	var more: Dictionary[UnitType.Value, int] = {HARPOONIST: k + 1}
	assert_true(planner.wins(more, _enemy(6)))


func test_when_no_mix_is_enough_the_first_usable_one_takes_the_share() -> void:
	var turn := _turn(1, 100000, 1000)
	var done := RecruitMoves.top_up(turn, {}, _enemy(400), [PAIR, SOLO], ArmyPlanner.new(), null, Callable(), false, 0.5)
	assert_false(done)
	assert_eq(turn.player.units_on_level(1)[HARPOONIST].count, RecruitMoves.affordable(_turn(1, 100000, 1000), SOLO, 0.5))
	var locked := _turn(0)
	assert_false(RecruitMoves.top_up(locked, {}, _enemy(400), [PAIR, SOLO], ArmyPlanner.new(), null))
	assert_eq(RecruitMoves.barracks_level(locked), 0)


func test_a_mix_eating_one_algae_is_capped_by_the_algae_and_none_tries_nothing() -> void:
	var turn := _turn(3)
	turn.player.units_on_level(1)[HARPOONIST].count = 4975
	var scout: Dictionary[UnitType.Value, int] = {UnitType.Value.SCOUT: 1}
	var room := RecruitMoves.algae_margin(turn) + 10000
	assert_true(room > 0 and room < RecruitMoves.MAX_BATCH)
	assert_eq(RecruitMoves.affordable(turn, scout), room)
	var log_: Array[ScriptLogEntry] = []
	assert_false(RecruitMoves.recruit_mix(ScriptSamples.turn(turn.game, null, 1, log_), PAIR, 0))
	assert_true(log_.is_empty())
