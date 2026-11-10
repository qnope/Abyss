extends TestCase
## Not in the Dart files: the advice against the first raid. The Dart tests
## read it through GuideAdvisor, which waits for `leviathan`
## (guide_advisor_raid_test.dart); here GuideRaid takes the target the
## advisor passes it, the Harpoonists or, once recruited this turn, the end
## of the turn. The values are what a scratch Dart script printed.

const HARPOONIST := UnitType.Value.HARPOONIST


func test_the_advice_names_the_harpoonists_to_have_and_where_to_get_them() -> void:
	var harpoonists := GuideTarget.for_unit(HARPOONIST)
	var end := GuideTarget.for_end_turn()
	var cases: Array = [
		[3, 12, harpoonists, _wave()],
		[0, 12, harpoonists, _wave()],
		[0, 12, end, _wave()],
		[0, 10, end, _wave()],
		[0, 10, harpoonists, _wave()],
		[0, 12, harpoonists, MonsterLair.new(MonsterDifficulty.Value.HARD, 400)],
		[40, 12, harpoonists, _wave()],
	]
	var got: Array[String] = []
	for case: Array in cases:
		var harpoonists_on_base: int = case[0]
		var arrival: int = case[1]
		var target: GuideTarget = case[2]
		var wave: MonsterLair = case[3]
		var game := _raid_game(harpoonists_on_base, arrival, wave)
		got.append(str(GuideRaid.of(game, game.human_player(), target)))
	assert_eq(got, [
		"GuideAdvice(GuideRaidAlert[12, 28, 11, 8, true, false], GuideTarget(army, harpoonist))",
		"GuideAdvice(GuideRaidAlert[12, 28, 11, 11, true, false], GuideTarget(army, harpoonist))",
		"GuideAdvice(GuideRaidAlert[12, 28, 11, 11, false, false], GuideTarget(endTurn, ()))",
		"GuideAdvice(GuideRaidAlert[10, 28, 11, 11, false, true], GuideTarget(endTurn, ()))",
		"GuideAdvice(GuideRaidAlert[10, 28, 11, 11, true, true], GuideTarget(army, harpoonist))",
		"GuideAdvice(GuideRaidAlert[12, 400, -1, 0, false, false], GuideTarget(army, harpoonist))",
		"GuideAdvice(GuideRaidAlert[12, 28, 40, 0, false, false], GuideTarget(endTurn, ()))",
	] as Array[String])


## `_wave` of guide_advisor_raid_test.dart: 22 swarm and 6 armoured.
func _wave() -> MonsterLair:
	return MonsterLair.new(
		MonsterDifficulty.Value.EASY, 22, MonsterFamily.Value.SWARM, MonsterFamily.Value.ARMOURED, 6
	)


## `_raidGame`: turn 10, `wave` announced for the end of `arrival`,
## `harpoonists` on the base.
func _raid_game(harpoonists: int, arrival: int, wave: MonsterLair) -> Game:
	var game := ObjectiveSamples.objective_game()
	game.turn = 10
	game.human_player().raid_state.announce(wave, arrival)
	RaidSamples.set_units(game.human_player(), HARPOONIST, harpoonists)
	return game
