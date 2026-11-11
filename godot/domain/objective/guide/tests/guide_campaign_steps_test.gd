extends TestCase
## test/domain/objective/guide/guide_campaign_steps_test.dart: the steps of
## the campaign past the assaults: the passages, the descents, the
## headquarters and the kernel.

const Id := ObjectiveId.Value
const Building_ := BuildingType.Value


static func _hq() -> GuideTarget:
	return GuideTarget.for_building(Building_.HEADQUARTERS)


func _expect(game: Game, expected: GuideAdvice) -> void:
	var advice := GuideSamples.advice_of(game)
	assert_true(advice != null and advice.equals(expected), str(advice))


func test_the_reef_and_the_awakening_stay_silent() -> void:
	assert_null(GuideSamples.advice_of(GuideSamples.campaign_game(Id.TAKE_LAIR)))
	assert_null(GuideSamples.advice_of(GuideSamples.campaign_game(Id.KERNEL_LEVEL_5)))


func test_a_met_objective_asks_to_end_the_turn() -> void:
	var game := GuideSamples.campaign_game(Id.HQ_LEVEL_8)
	ObjectiveSamples.set_building(game.human_player(), Building_.HEADQUARTERS, 8)
	_expect(game, GuideAdvice.new(GuideGoalMet.new(), GuideTarget.for_end_turn()))


func test_a_passage_building_first_asks_for_the_headquarters_it_needs() -> void:
	_expect(GuideSamples.campaign_game(Id.DESCENT_MODULE),
		GuideAdvice.new(GuidePassageNeedsHq.new(Building_.DESCENT_MODULE, 5), _hq()))
	_expect(GuideSamples.campaign_game(Id.PRESSURE_CAPSULE),
		GuideAdvice.new(GuidePassageNeedsHq.new(Building_.PRESSURE_CAPSULE, 8), _hq()))


func test_a_passage_building_then_points_at_its_card() -> void:
	var game := GuideSamples.campaign_game(Id.DESCENT_MODULE)
	ObjectiveSamples.set_building(game.human_player(), Building_.HEADQUARTERS, 5)
	_expect(game, GuideAdvice.new(
		GuideLesson.new(Id.DESCENT_MODULE), GuideTarget.for_building(Building_.DESCENT_MODULE)))


func test_a_passage_building_unless_the_worksite_is_taken() -> void:
	var game := GuideSamples.campaign_game(Id.PRESSURE_CAPSULE)
	ObjectiveSamples.set_building(game.human_player(), Building_.HEADQUARTERS, 8)
	game.human_player().worksite.upgrades = WorksiteRules.build_sites(8)
	_expect(game, GuideAdvice.new(GuideWorksiteTaken.new(), GuideTarget.for_end_turn()))


func test_a_descent_points_at_the_faille_for_level_2() -> void:
	var game := GuideSamples.campaign_game(Id.DESCEND_LEVEL_2)
	ObjectiveSamples.set_building(game.human_player(), Building_.DESCENT_MODULE, 1)
	GuideSamples.place_post(game, 1, 7, 5, TransitionBaseType.Value.FAILLE, true)
	_expect(game, GuideAdvice.new(
		GuideLesson.new(Id.DESCEND_LEVEL_2), GuideTarget.for_cell(1, GridPosition.new(7, 5))))


func test_a_descent_points_at_the_cheminee_for_level_3() -> void:
	var game := GuideSamples.campaign_game(Id.DESCEND_LEVEL_3)
	GuideSamples.place_post(game, 2, 3, 3, TransitionBaseType.Value.CHEMINEE, true)
	var target := GuideSamples.advice_of(game).target
	assert_true(target.equals(GuideTarget.for_cell(2, GridPosition.new(3, 3))), str(target))


func test_a_descent_points_at_the_map_without_a_post_held() -> void:
	var target := GuideSamples.advice_of(GuideSamples.campaign_game(Id.DESCEND_LEVEL_2)).target
	assert_true(target.equals(GuideTarget.for_map()), str(target))


func test_the_headquarters_and_the_kernel_teach_their_lesson() -> void:
	for id: Id in [Id.HQ_LEVEL_8, Id.HQ_LEVEL_10]:
		_expect(GuideSamples.campaign_game(id), GuideAdvice.new(GuideLesson.new(id), _hq()))
	_expect(GuideSamples.campaign_game(Id.KERNEL_LEVEL_1), GuideAdvice.new(
		GuideLesson.new(Id.KERNEL_LEVEL_1), GuideTarget.for_building(Building_.VOLCANIC_KERNEL)))
