extends TestCase
## test/domain/objective/guide/guide_advisor_raid_test.dart: the first raid
## announced on its objective, the harpoonists the guide asks for.

const HARPOONIST := UnitType.Value.HARPOONIST


static func _wave() -> MonsterLair:
	return MonsterLair.new(
		MonsterDifficulty.Value.EASY, 22, MonsterFamily.Value.SWARM, MonsterFamily.Value.ARMOURED, 6
	)


## On the first raid objective at turn 10, the wave announced for the end of
## turn `arrival`, with `harpoonists` on the base.
static func _raid_game(harpoonists := 0, arrival := 12) -> Game:
	var game := GuideSamples.guide_game(ObjectiveId.Value.FIRST_RAID)
	game.turn = 10
	game.human_player().raid_state.announce(_wave(), arrival)
	RaidSamples.set_units(game.human_player(), HARPOONIST, harpoonists)
	return game


static func _needed(game: Game) -> int:
	return RaidDefenceAdvisor.harpoonists_for(game.human_player(), _wave())


func _expect(game: Game, message: GuideMessage, target: GuideTarget) -> void:
	var advice := GuideSamples.advice_of(game)
	assert_true(advice.message.equals(message), str(advice.message))
	assert_true(advice.target.equals(target), str(advice.target))


func test_names_the_harpoonists_to_have_against_the_first_raid() -> void:
	var game := _raid_game(3)
	var needed := _needed(game)
	_expect(game, GuideRaidAlert.new(12, 28, needed, needed - 3, true), GuideTarget.for_unit(HARPOONIST))


func test_a_base_strong_enough_waits_for_the_raid() -> void:
	var game := _raid_game()
	RaidSamples.set_units(game.human_player(), HARPOONIST, _needed(game))
	_expect(game, GuideRaidAlert.new(12, 28, _needed(game)), GuideTarget.for_end_turn())


func test_harpoonists_already_recruited_this_turn_the_rest_next_turn() -> void:
	var game := _raid_game()
	game.human_player().recruited_unit_types.append(HARPOONIST)
	_expect(game, GuideRaidAlert.new(12, 28, _needed(game), _needed(game)), GuideTarget.for_end_turn())


func test_harpoonists_already_recruited_on_the_last_turn_hold_on() -> void:
	var game := _raid_game(0, 10)
	game.human_player().recruited_unit_types.append(HARPOONIST)
	_expect(
		game, GuideRaidAlert.new(10, 28, _needed(game), _needed(game), false, true), GuideTarget.for_end_turn()
	)


func test_a_wave_out_of_reach_asks_for_as_many_harpoonists_as_possible() -> void:
	var game := GuideSamples.guide_game(ObjectiveId.Value.FIRST_RAID)
	game.turn = 10
	game.human_player().raid_state.announce(MonsterLair.new(MonsterDifficulty.Value.HARD, 400), 12)
	_expect(game, GuideRaidAlert.new(12, 400), GuideTarget.for_unit(HARPOONIST))
