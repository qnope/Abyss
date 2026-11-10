extends TestCase
## test/domain/raid/raid_defence_advisor_test.dart: the harpoonists a base
## needs against an announced wave.

const HARPOONIST := UnitType.Value.HARPOONIST

## A first raid of Normal where the Nuée dominates.
var _wave := MonsterLair.new(
	MonsterDifficulty.Value.EASY, 22, MonsterFamily.Value.SWARM, MonsterFamily.Value.ARMOURED, 6
)


func _needed(units: Dictionary[UnitType.Value, int] = {}, citadel := 0) -> int:
	return RaidDefenceAdvisor.harpoonists_for(RaidSamples.raid_player(units, citadel), _wave)


func _wave_side() -> Array[Combatant]:
	return CombatantBuilder.monster_combatants_from(_wave)


func test_the_advised_harpoonists_win_at_least_95_percent_of_the_rehearsals() -> void:
	var needed := _needed()
	var planner := RaidDefenceAdvisor.planner()

	assert_eq(planner.rehearsals, 20)
	assert_eq(planner.confidence, 0.95)
	assert_true(planner.wins({HARPOONIST: needed}, _wave_side))
	assert_false(planner.wins({HARPOONIST: needed - 1}, _wave_side))


func test_counts_the_harpoonists_already_on_the_base() -> void:
	var needed := _needed()

	assert_eq(_needed({HARPOONIST: 3}), needed)
	assert_eq(_needed({HARPOONIST: needed + 4}), needed + 4)


func test_a_bigger_wave_needs_more_harpoonists() -> void:
	var player := RaidSamples.raid_player()
	var needed_against := func(count: int) -> int:
		return RaidDefenceAdvisor.harpoonists_for(
			player, MonsterLair.new(MonsterDifficulty.Value.EASY, count)
		)

	var against_30: int = needed_against.call(30)
	var against_10: int = needed_against.call(10)
	assert_true(against_30 > against_10)


func test_the_citadel_rampart_and_the_other_defenders_lower_the_count() -> void:
	var alone := _needed()

	assert_true(_needed({}, 5) < alone)
	assert_true(_needed({UnitType.Value.GUARDIAN: 6}) < alone)


func test_is_the_same_for_the_same_game_and_leaves_the_player_as_it_is() -> void:
	var player := RaidSamples.raid_player({UnitType.Value.SCOUT: 2})
	var first: int = RaidDefenceAdvisor.harpoonists_for(player, _wave)

	assert_eq(RaidDefenceAdvisor.harpoonists_for(player, _wave), first)
	assert_eq(RaidSamples.units_on_base(player), 2)


func test_follows_the_base_as_it_changes_from_one_call_to_the_next() -> void:
	var player := RaidSamples.raid_player()
	var needed: int = RaidDefenceAdvisor.harpoonists_for(player, _wave)

	player.units_on_level(1)[HARPOONIST].count = needed + 2

	assert_eq(RaidDefenceAdvisor.harpoonists_for(player, _wave), needed + 2)


func test_none_when_no_number_of_harpoonists_is_enough() -> void:
	var horde := MonsterLair.new(MonsterDifficulty.Value.HARD, 400)

	assert_null(RaidDefenceAdvisor.harpoonists_for(RaidSamples.raid_player(), horde))
