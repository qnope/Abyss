extends TestCase
## test/domain/objective/guide/guide_advisor_context_test.dart: what the
## guide says around the lesson: a goal met, a worksite or a recruitment
## already used, a scout on its way, a storm, a wreck on the map.

const Id := ObjectiveId.Value
const Building_ := BuildingType.Value
const SCOUT := UnitType.Value.SCOUT


func _advice(game: Game) -> GuideAdvice:
	return GuideSamples.advice_of(game)


func _expect(advice: GuideAdvice, message: GuideMessage, target: GuideTarget) -> void:
	assert_true(advice.message.equals(message), str(advice.message))
	assert_true(advice.target.equals(target), str(advice.target))


func _sink_wreck(game: Game) -> void:
	game.human_player().event_state.wreck_position = GridPosition.new(8, 5)
	game.human_player().event_state.wreck_until_turn = 9


func test_a_goal_met_asks_to_end_the_turn_to_validate_it() -> void:
	var game := GuideSamples.guide_game(Id.HQ_LEVEL_1)
	ObjectiveSamples.set_building(game.human_player(), Building_.HEADQUARTERS, 1)
	_expect(_advice(game), GuideGoalMet.new(), GuideTarget.for_end_turn())


func test_a_taken_worksite_asks_to_end_the_turn() -> void:
	var game := GuideSamples.guide_game(Id.MINES)
	ObjectiveSamples.set_building(game.human_player(), Building_.CORAL_MINE, 1)
	game.human_player().worksite.upgrades = 1
	_expect(_advice(game), GuideWorksiteTaken.new(), GuideTarget.for_end_turn())


func test_scouts_already_recruited_this_turn_ask_to_end_the_turn() -> void:
	var game := GuideSamples.guide_game(Id.BARRACKS_AND_SCOUTS)
	var player := game.human_player()
	ObjectiveSamples.set_building(player, Building_.BARRACKS, 1)
	RaidSamples.set_units(player, SCOUT, 1)
	player.recruited_unit_types.append(SCOUT)
	_expect(_advice(game), GuideAlreadyRecruited.new(), GuideTarget.for_end_turn())


func test_exploring_a_scout_on_its_way_asks_to_end_the_turn() -> void:
	var game := GuideSamples.guide_game(Id.EXPLORE)
	game.human_player().pending_explorations.append(ExplorationOrder.new(GridPosition.new(8, 5)))
	_expect(_advice(game), GuideExploring.new(), GuideTarget.for_end_turn())


func test_exploring_a_storm_makes_the_objective_wait() -> void:
	var game := GuideSamples.guide_game(Id.EXPLORE)
	game.turn = 7
	game.human_player().event_state.activate(RandomEventType.Value.STORM, 8)
	_expect(_advice(game), GuideStorm.new(8), GuideTarget.for_end_turn())


func test_exploring_a_storm_does_not_change_another_objective() -> void:
	var game := GuideSamples.guide_game(Id.SOLAR_PANEL)
	game.turn = 7
	game.human_player().event_state.activate(RandomEventType.Value.STORM, 8)
	assert_true(_advice(game).message.equals(GuideLesson.new(Id.SOLAR_PANEL)))


func test_a_wreck_before_the_barracks_keeps_pointing_at_the_objective() -> void:
	var game := GuideSamples.guide_game(Id.SOLAR_PANEL)
	_sink_wreck(game)
	_expect(_advice(game), GuideWreck.new(9, false), GuideTarget.for_building(Building_.SOLAR_PANEL))


func test_a_wreck_with_the_barracks_but_no_scout_points_at_the_scouts() -> void:
	var game := GuideSamples.guide_game(Id.BARRACKS_AND_SCOUTS)
	ObjectiveSamples.set_building(game.human_player(), Building_.BARRACKS, 1)
	_sink_wreck(game)
	_expect(_advice(game), GuideWreck.new(9, true), GuideTarget.for_unit(SCOUT))


func test_a_wreck_says_nothing_more_once_a_scout_can_reach_it() -> void:
	var game := GuideSamples.guide_game(Id.LABORATORY_AND_RESEARCH)
	ObjectiveSamples.set_building(game.human_player(), Building_.BARRACKS, 1)
	RaidSamples.set_units(game.human_player(), SCOUT, 2)
	_sink_wreck(game)
	assert_false(_advice(game).message is GuideWreck)
