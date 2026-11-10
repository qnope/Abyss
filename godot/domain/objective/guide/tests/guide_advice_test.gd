extends TestCase
## test/domain/objective/guide/guide_advice_test.dart: what the guide says
## and what its halo surrounds, compared by value.


func test_guide_advice_equal_when_its_message_and_target_are() -> void:
	assert_true(_advice().equals(_advice()))
	assert_eq(_advice().hash_code(), _advice().hash_code())


func test_guide_advice_different_as_soon_as_the_message_or_the_target_differs() -> void:
	assert_false(_advice().equals(_advice(GuideGoalMet.new())))
	assert_false(_advice().equals(_advice(null, GuideTarget.for_end_turn())))
	assert_false(_advice().equals(_lesson()))


func test_guide_advice_reads_as_its_message_and_target() -> void:
	assert_eq(
		str(_advice()),
		"GuideAdvice(GuideLesson[ObjectiveId.algaeFarm], GuideTarget(base, algaeFarm))",
	)


func test_guide_message_equal_when_of_the_same_kind_with_the_same_figures() -> void:
	assert_true(GuideStorm.new(8).equals(GuideStorm.new(8)))
	assert_eq(GuideStorm.new(8).hash_code(), GuideStorm.new(8).hash_code())
	assert_true(GuideGoalMet.new().equals(GuideGoalMet.new()))
	assert_true(GuideRaidAlert.new(12, 28, 5, 2).equals(GuideRaidAlert.new(12, 28, 5, 2)))


func test_guide_message_different_as_soon_as_the_kind_or_a_figure_differs() -> void:
	assert_false(GuideStorm.new(8).equals(GuideStorm.new(9)))
	assert_false(GuideGoalMet.new().equals(GuideExploring.new()))
	assert_false(GuideWreck.new(9, false).equals(GuideWreck.new(9, true)))
	assert_false(GuideRaidAlert.new(12, 28).equals(GuideRaidAlert.new(12, 28, 5)))
	assert_false(GuideLesson.new(ObjectiveId.Value.MINES).equals(GuideLesson.new(ObjectiveId.Value.EXPLORE)))


func _lesson() -> GuideLesson:
	return GuideLesson.new(ObjectiveId.Value.ALGAE_FARM)


func _advice(message: GuideMessage = null, target: GuideTarget = null) -> GuideAdvice:
	return GuideAdvice.new(
		message if message != null else _lesson(),
		target if target != null else GuideTarget.for_building(BuildingType.Value.ALGAE_FARM),
	)
